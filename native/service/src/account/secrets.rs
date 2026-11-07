//! Freedesktop Secret Service storage (GNOME Keyring, KWallet ≥ 5.97, …).
//!
//! The ONLY place secret material is ever persisted. Values never touch
//! SQLite, config files or logs. Missing Secret Service is a soft failure:
//! calendar features keep working, signing-related features report
//! unavailable (astraea-service doctor explains how to fix it).

use std::collections::HashMap;

use secret_service::{EncryptionType, SecretService};

const ATTR_APP: (&str, &str) = ("application", "astraea");

#[derive(Clone, Default)]
pub struct SecretStore;

impl SecretStore {
    async fn service(&self) -> Result<SecretService<'static>, secret_service::Error> {
        SecretService::connect(EncryptionType::Dh).await
    }

    fn attributes<'a>(purpose: &'a str, pubkey: &'a str) -> HashMap<&'a str, &'a str> {
        let mut attributes = HashMap::new();
        attributes.insert(ATTR_APP.0, ATTR_APP.1);
        attributes.insert("purpose", purpose);
        attributes.insert("pubkey", pubkey);
        attributes
    }

    /// Stores/replaces the delegated calendar key for an account.
    pub async fn set_delegated_key(&self, pubkey: &str, secret: &str) -> anyhow::Result<()> {
        self.set(
            pubkey,
            "delegated-key",
            &format!(
                "Astraea delegated calendar key ({})",
                &pubkey[..8.min(pubkey.len())]
            ),
            secret,
        )
        .await
    }

    pub async fn get_delegated_key(&self, pubkey: &str) -> anyhow::Result<Option<String>> {
        self.get(pubkey, "delegated-key").await
    }

    /// Stores/replaces the NIP-46 remote-signer session for an account.
    ///
    /// The blob holds the ephemeral client key and the bunker's single-use
    /// secret — both authorize this machine against the user's signer — so it
    /// belongs here with the delegated key, not in SQLite or a config file.
    /// Note what it does *not* hold: the account private key, which never
    /// leaves the remote signer.
    pub async fn set_remote_signer_session(
        &self,
        pubkey: &str,
        session: &str,
    ) -> anyhow::Result<()> {
        self.set(
            pubkey,
            "remote-signer",
            &format!(
                "Astraea remote signer session ({})",
                &pubkey[..8.min(pubkey.len())]
            ),
            session,
        )
        .await
    }

    pub async fn get_remote_signer_session(&self, pubkey: &str) -> anyhow::Result<Option<String>> {
        self.get(pubkey, "remote-signer").await
    }

    async fn set(
        &self,
        pubkey: &str,
        purpose: &str,
        label: &str,
        secret: &str,
    ) -> anyhow::Result<()> {
        let service = self.service().await?;
        let collection = service.get_default_collection().await?;
        collection
            .create_item(
                label,
                Self::attributes(purpose, pubkey),
                secret.as_bytes(),
                true, // replace
                "text/plain",
            )
            .await?;
        Ok(())
    }

    async fn get(&self, pubkey: &str, purpose: &str) -> anyhow::Result<Option<String>> {
        let service = self.service().await?;
        let results = service
            .search_items(Self::attributes(purpose, pubkey))
            .await?;
        let Some(item) = results.unlocked.first() else {
            // Try to unlock locked matches once; if the user dismisses the
            // prompt the secret simply stays unavailable.
            let Some(locked) = results.locked.first() else {
                return Ok(None);
            };
            locked.unlock().await?;
            let secret = locked.get_secret().await?;
            return Ok(Some(String::from_utf8_lossy(&secret).into_owned()));
        };
        let secret = item.get_secret().await?;
        Ok(Some(String::from_utf8_lossy(&secret).into_owned()))
    }

    /// Deletes every Astraea item for this account (logout / revocation).
    pub async fn clear_account(&self, pubkey: &str) -> anyhow::Result<()> {
        let service = self.service().await?;
        let mut attributes = HashMap::new();
        attributes.insert(ATTR_APP.0, ATTR_APP.1);
        attributes.insert("pubkey", pubkey);
        let results = service.search_items(attributes).await?;
        for item in results.unlocked.iter().chain(results.locked.iter()) {
            let _ = item.delete().await;
        }
        Ok(())
    }

    /// True when a Secret Service provider is reachable on the session bus.
    pub async fn available(&self) -> bool {
        self.service().await.is_ok()
    }
}
