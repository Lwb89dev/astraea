//! Relay transport boundary. The engine talks to this trait; production uses
//! the `nostr-sdk` relay pool (audited pool, reconnection and dedup included),
//! tests use an in-memory fake. Nothing above this layer touches sockets.

use std::time::Duration;

use async_trait::async_trait;
use nostr::{Event, Filter};

/// Relay URL rules from the wire contract: `wss://`, no userinfo, no
/// fragment, at most this many characters.
pub const MAX_RELAY_URL_CHARS: usize = 2048;

pub fn validate_relay_url(url: &str) -> Result<(), String> {
    if url.chars().count() > MAX_RELAY_URL_CHARS {
        return Err("relay URL too long".into());
    }
    let parsed = url::Url::parse(url).map_err(|e| format!("invalid relay URL: {e}"))?;
    if parsed.scheme() != "wss" {
        return Err("relay URLs must use wss://".into());
    }
    if !parsed.username().is_empty() || parsed.password().is_some() {
        return Err("relay URLs must not carry credentials".into());
    }
    if parsed.fragment().is_some() {
        return Err("relay URLs must not carry a fragment".into());
    }
    Ok(())
}

#[derive(Debug, thiserror::Error)]
pub enum TransportError {
    #[error("relay transport: {0}")]
    Failed(String),
}

/// Per-relay publish outcome. The contract counts an event as synced only
/// when every configured relay accepted it.
#[derive(Debug, Default, Clone)]
pub struct PublishOutcome {
    pub accepted: Vec<String>,
    pub rejected: Vec<(String, String)>,
}

#[derive(Debug, Clone)]
pub struct RelayHealth {
    pub url: String,
    pub connected: bool,
}

#[async_trait]
pub trait RelayTransport: Send + Sync {
    /// Reconciles the pool with `urls` (adding/removing/connecting as
    /// needed). Idempotent; called at the start of every sync run.
    async fn configure(&self, urls: &[String]) -> Result<(), TransportError>;

    /// Publishes to every configured relay and reports per-relay outcomes.
    async fn publish(&self, event: Event) -> Result<PublishOutcome, TransportError>;

    /// Fetches events matching `filter` from all relays, deduplicated.
    async fn fetch(&self, filter: Filter, timeout: Duration)
        -> Result<Vec<Event>, TransportError>;

    async fn health(&self) -> Vec<RelayHealth>;
}

/// Production transport over the `nostr-sdk` relay pool.
pub struct NostrSdkTransport {
    client: nostr_sdk::Client,
}

impl NostrSdkTransport {
    pub fn new() -> Self {
        Self { client: nostr_sdk::Client::default() }
    }
}

impl Default for NostrSdkTransport {
    fn default() -> Self {
        Self::new()
    }
}

#[async_trait]
impl RelayTransport for NostrSdkTransport {
    async fn configure(&self, urls: &[String]) -> Result<(), TransportError> {
        let current: Vec<nostr_sdk::RelayUrl> =
            self.client.relays().await.keys().cloned().collect();
        for existing in &current {
            if !urls.iter().any(|u| u.trim_end_matches('/') == existing.as_str().trim_end_matches('/')) {
                let _ = self.client.remove_relay(existing.clone()).await;
            }
        }
        for url in urls {
            self.client
                .add_relay(url.as_str())
                .await
                .map_err(|e| TransportError::Failed(format!("{url}: {e}")))?;
        }
        self.client.connect().await;
        Ok(())
    }

    async fn publish(&self, event: Event) -> Result<PublishOutcome, TransportError> {
        let output = self
            .client
            .send_event(&event)
            .await
            .map_err(|e| TransportError::Failed(e.to_string()))?;
        Ok(PublishOutcome {
            accepted: output.success.iter().map(|u| u.to_string()).collect(),
            rejected: output
                .failed
                .iter()
                .map(|(u, reason)| (u.to_string(), reason.clone()))
                .collect(),
        })
    }

    async fn fetch(
        &self,
        filter: Filter,
        timeout: Duration,
    ) -> Result<Vec<Event>, TransportError> {
        let events = self
            .client
            .fetch_events(filter, timeout)
            .await
            .map_err(|e| TransportError::Failed(e.to_string()))?;
        Ok(events.into_iter().collect())
    }

    async fn health(&self) -> Vec<RelayHealth> {
        let mut out = Vec::new();
        for (url, relay) in self.client.relays().await {
            out.push(RelayHealth {
                url: url.to_string(),
                connected: relay.status() == nostr_sdk::RelayStatus::Connected,
            });
        }
        out
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn relay_url_validation_enforces_the_contract() {
        assert!(validate_relay_url("wss://relay.damus.io").is_ok());
        assert!(validate_relay_url("ws://relay.damus.io").is_err());
        assert!(validate_relay_url("https://relay.damus.io").is_err());
        assert!(validate_relay_url("wss://user:pw@relay.damus.io").is_err());
        assert!(validate_relay_url("wss://relay.damus.io/#frag").is_err());
        let long = format!("wss://x.io/{}", "a".repeat(2100));
        assert!(validate_relay_url(&long).is_err());
    }
}
