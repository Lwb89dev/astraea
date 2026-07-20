//! Browser login bridge (docs/authentication.md).
//!
//! Flow: BeginBrowserLogin binds a listener on 127.0.0.1:<random port>,
//! serves a local NIP-07 page, and waits (bounded) for a single valid
//! callback carrying a signed kind-22242 challenge event. Verification:
//! state match, challenge tag match, created_at freshness, NIP-01 id +
//! Schnorr signature. Nothing here is logged beyond outcomes — never the
//! signature, never the page contents, never tokens.

use std::net::SocketAddr;
use std::sync::Arc;
use std::time::Duration;

use nostr::{Event as NostrEvent, JsonUtil};
use rand::Rng as _;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::{oneshot, Mutex};
use tracing::{info, warn};

const LOGIN_PAGE: &str = include_str!("login.html");
const SESSION_TTL: Duration = Duration::from_secs(300);
const MAX_HEADER_BYTES: usize = 16 * 1024;
const MAX_BODY_BYTES: usize = 64 * 1024;
/// Signed challenge must be fresh within this window (clock skew allowance).
const CREATED_AT_SLACK_SECS: i64 = 600;
const CHALLENGE_KIND: u16 = 22242;

#[derive(Debug, Clone)]
pub struct LoginOutcome {
    pub pubkey: String,
}

pub struct LoginSession {
    pub session_id: String,
    pub url: String,
    pub expires_at: chrono::DateTime<chrono::Utc>,
    cancel: Option<oneshot::Sender<()>>,
}

impl LoginSession {
    pub fn cancel(&mut self) {
        if let Some(tx) = self.cancel.take() {
            let _ = tx.send(());
        }
    }
}

fn random_hex_32() -> String {
    let mut bytes = [0u8; 32];
    rand::rng().fill_bytes(&mut bytes);
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

/// Starts the listener and returns the session descriptor plus a receiver
/// that resolves with the verified pubkey (or an error string).
pub async fn begin(
    open_browser: bool,
) -> anyhow::Result<(
    LoginSession,
    oneshot::Receiver<Result<LoginOutcome, String>>,
)> {
    // Loopback only, kernel-chosen free port. Never 0.0.0.0.
    let listener = TcpListener::bind((std::net::Ipv4Addr::LOCALHOST, 0)).await?;
    let port = listener.local_addr()?.port();

    let session_id = uuid::Uuid::new_v4().to_string();
    let state = random_hex_32();
    let challenge = random_hex_32();
    let expires_at = chrono::Utc::now() + chrono::Duration::from_std(SESSION_TTL)?;

    let url = format!("http://127.0.0.1:{port}/login?state={state}&challenge={challenge}");

    let (cancel_tx, cancel_rx) = oneshot::channel::<()>();
    let (done_tx, done_rx) = oneshot::channel::<Result<LoginOutcome, String>>();

    tokio::spawn(serve(listener, state, challenge, cancel_rx, done_tx));

    if open_browser {
        // Fixed argv, detached; the URL is entirely service-generated.
        let spawned = std::process::Command::new("xdg-open")
            .arg(&url)
            .stdin(std::process::Stdio::null())
            .stdout(std::process::Stdio::null())
            .stderr(std::process::Stdio::null())
            .spawn();
        if let Err(e) = spawned {
            warn!("could not open the browser automatically: {e}");
        }
    }

    info!(port, "browser login session started");
    Ok((
        LoginSession {
            session_id,
            url,
            expires_at,
            cancel: Some(cancel_tx),
        },
        done_rx,
    ))
}

async fn serve(
    listener: TcpListener,
    state: String,
    challenge: String,
    mut cancel: oneshot::Receiver<()>,
    done: oneshot::Sender<Result<LoginOutcome, String>>,
) {
    let outcome: Arc<Mutex<Option<LoginOutcome>>> = Arc::new(Mutex::new(None));
    let deadline = tokio::time::sleep(SESSION_TTL);
    tokio::pin!(deadline);

    loop {
        tokio::select! {
            _ = &mut deadline => {
                let _ = done.send(Err("login session expired".into()));
                info!("browser login session expired");
                return;
            }
            _ = &mut cancel => {
                let _ = done.send(Err("login session cancelled".into()));
                info!("browser login session cancelled");
                return;
            }
            accepted = listener.accept() => {
                let Ok((stream, peer)) = accepted else { continue };
                if !peer.ip().is_loopback() {
                    continue; // Defence in depth; the bind is loopback-only.
                }
                match handle_connection(stream, peer, &state, &challenge, &outcome).await {
                    Ok(Some(success)) => {
                        let _ = done.send(Ok(success));
                        // Give the browser a beat to render the success page.
                        tokio::time::sleep(Duration::from_millis(300)).await;
                        return;
                    }
                    Ok(None) => {}
                    Err(e) => warn!("login connection error: {e}"),
                }
            }
        }
    }
}

/// Serves one connection. Returns Ok(Some(..)) exactly once: on the first
/// valid callback.
async fn handle_connection(
    mut stream: TcpStream,
    _peer: SocketAddr,
    state: &str,
    challenge: &str,
    outcome: &Arc<Mutex<Option<LoginOutcome>>>,
) -> anyhow::Result<Option<LoginOutcome>> {
    let (request_line, body) = read_request(&mut stream).await?;
    let mut parts = request_line.split_whitespace();
    let method = parts.next().unwrap_or("");
    let target = parts.next().unwrap_or("");

    match (method, target.split('?').next().unwrap_or("")) {
        ("GET", "/login") => {
            // The page reads state/challenge from its own query string; the
            // server only has to check the state to avoid serving the form
            // to unrelated local requests.
            if query_param(target, "state").as_deref() == Some(state) {
                write_response(&mut stream, 200, "text/html; charset=utf-8", LOGIN_PAGE).await?;
            } else {
                write_response(&mut stream, 403, "text/plain", "invalid state").await?;
            }
            Ok(None)
        }
        ("POST", "/callback") => {
            let verdict = verify_callback(&body, state, challenge);
            match verdict {
                Ok(success) => {
                    let mut guard = outcome.lock().await;
                    if guard.is_some() {
                        write_response(&mut stream, 409, "text/plain", "already completed").await?;
                        return Ok(None);
                    }
                    *guard = Some(success.clone());
                    write_response(&mut stream, 200, "application/json", "{\"ok\":true}").await?;
                    info!("browser login verified");
                    Ok(Some(success))
                }
                Err(reason) => {
                    // The reason is safe to return to the local page but is
                    // deliberately generic in logs.
                    warn!("browser login callback rejected");
                    write_response(&mut stream, 400, "text/plain", &reason).await?;
                    Ok(None)
                }
            }
        }
        _ => {
            write_response(&mut stream, 404, "text/plain", "not found").await?;
            Ok(None)
        }
    }
}

fn verify_callback(body: &str, state: &str, challenge: &str) -> Result<LoginOutcome, String> {
    let parsed: serde_json::Value =
        serde_json::from_str(body).map_err(|_| "malformed JSON".to_owned())?;
    let sent_state = parsed["state"].as_str().unwrap_or_default();
    if sent_state.as_bytes() != state.as_bytes() {
        return Err("state mismatch".into());
    }
    let event_json =
        serde_json::to_string(&parsed["event"]).map_err(|_| "malformed event".to_owned())?;
    let event = NostrEvent::from_json(&event_json).map_err(|_| "unparseable event".to_owned())?;

    if event.kind.as_u16() != CHALLENGE_KIND {
        return Err("unexpected event kind".into());
    }
    let has_challenge = event.tags.iter().any(|tag| {
        let parts = tag.as_slice();
        parts.len() >= 2 && parts[0] == "challenge" && parts[1] == challenge
    });
    if !has_challenge {
        return Err("challenge mismatch".into());
    }
    let now = chrono::Utc::now().timestamp();
    let created_at = event.created_at.as_secs() as i64;
    if (now - created_at).abs() > CREATED_AT_SLACK_SECS {
        return Err("challenge signature is not fresh".into());
    }
    event
        .verify()
        .map_err(|_| "invalid event id or signature".to_owned())?;

    Ok(LoginOutcome {
        pubkey: event.pubkey.to_hex(),
    })
}

async fn read_request(stream: &mut TcpStream) -> anyhow::Result<(String, String)> {
    let mut buffer = Vec::with_capacity(2048);
    let mut chunk = [0u8; 2048];
    let header_end;
    loop {
        let n = tokio::time::timeout(Duration::from_secs(10), stream.read(&mut chunk)).await??;
        if n == 0 {
            anyhow::bail!("connection closed mid-request");
        }
        buffer.extend_from_slice(&chunk[..n]);
        if let Some(pos) = find_header_end(&buffer) {
            header_end = pos;
            break;
        }
        if buffer.len() > MAX_HEADER_BYTES {
            anyhow::bail!("headers too large");
        }
    }

    let header_text = String::from_utf8_lossy(&buffer[..header_end]).into_owned();
    let request_line = header_text.lines().next().unwrap_or_default().to_owned();
    let content_length = header_text
        .lines()
        .find_map(|line| {
            let (name, value) = line.split_once(':')?;
            name.eq_ignore_ascii_case("content-length")
                .then(|| value.trim().parse::<usize>().ok())?
        })
        .unwrap_or(0);
    if content_length > MAX_BODY_BYTES {
        anyhow::bail!("body too large");
    }

    let mut body_bytes = buffer[header_end + 4..].to_vec();
    while body_bytes.len() < content_length {
        let n = tokio::time::timeout(Duration::from_secs(10), stream.read(&mut chunk)).await??;
        if n == 0 {
            break;
        }
        body_bytes.extend_from_slice(&chunk[..n]);
        if body_bytes.len() > MAX_BODY_BYTES {
            anyhow::bail!("body too large");
        }
    }
    Ok((
        request_line,
        String::from_utf8_lossy(&body_bytes).into_owned(),
    ))
}

fn find_header_end(buffer: &[u8]) -> Option<usize> {
    buffer.windows(4).position(|w| w == b"\r\n\r\n")
}

fn query_param(target: &str, name: &str) -> Option<String> {
    let query = target.split_once('?')?.1;
    for pair in query.split('&') {
        let (key, value) = pair.split_once('=')?;
        if key == name {
            return Some(value.to_owned());
        }
    }
    None
}

async fn write_response(
    stream: &mut TcpStream,
    code: u16,
    content_type: &str,
    body: &str,
) -> anyhow::Result<()> {
    let reason = match code {
        200 => "OK",
        400 => "Bad Request",
        403 => "Forbidden",
        404 => "Not Found",
        409 => "Conflict",
        _ => "Error",
    };
    let response = format!(
        "HTTP/1.1 {code} {reason}\r\nContent-Type: {content_type}\r\n\
         Content-Length: {}\r\nCache-Control: no-store\r\nConnection: close\r\n\
         X-Content-Type-Options: nosniff\r\nReferrer-Policy: no-referrer\r\n\r\n{body}",
        body.len(),
    );
    stream.write_all(response.as_bytes()).await?;
    stream.shutdown().await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use nostr::{EventBuilder, Keys, Tag};

    fn signed_challenge(keys: &Keys, challenge: &str) -> String {
        let event = EventBuilder::new(nostr::Kind::from(CHALLENGE_KIND), "login")
            .tags([
                Tag::parse(["challenge", challenge]).expect("tag"),
                Tag::parse(["client", "astraea"]).expect("tag"),
            ])
            .sign_with_keys(keys)
            .expect("sign");
        event.as_json()
    }

    #[test]
    fn valid_callback_is_accepted() {
        let keys = Keys::generate();
        let challenge = random_hex_32();
        let state = random_hex_32();
        let body = format!(
            r#"{{"state":"{state}","event":{}}}"#,
            signed_challenge(&keys, &challenge)
        );
        let outcome = verify_callback(&body, &state, &challenge).expect("accepted");
        assert_eq!(outcome.pubkey, keys.public_key().to_hex());
    }

    #[test]
    fn wrong_state_challenge_kind_or_signature_are_rejected() {
        let keys = Keys::generate();
        let challenge = random_hex_32();
        let state = random_hex_32();
        let good = signed_challenge(&keys, &challenge);

        // Wrong state.
        let body = format!(r#"{{"state":"nope","event":{good}}}"#);
        assert!(verify_callback(&body, &state, &challenge).is_err());

        // Wrong challenge (replay of a signature for another session).
        let other = signed_challenge(&keys, "deadbeef");
        let body = format!(r#"{{"state":"{state}","event":{other}}}"#);
        assert!(verify_callback(&body, &state, &challenge).is_err());

        // Tampered content invalidates the signature.
        let tampered = good.replace("login", "pwned");
        let body = format!(r#"{{"state":"{state}","event":{tampered}}}"#);
        assert!(verify_callback(&body, &state, &challenge).is_err());
    }

    #[test]
    fn stale_created_at_is_rejected() {
        let keys = Keys::generate();
        let challenge = random_hex_32();
        let state = random_hex_32();
        let event = EventBuilder::new(nostr::Kind::from(CHALLENGE_KIND), "login")
            .tags([Tag::parse(["challenge", challenge.as_str()]).expect("tag")])
            .custom_created_at(nostr::Timestamp::from(1_000_000u64))
            .sign_with_keys(&keys)
            .expect("sign");
        let body = format!(r#"{{"state":"{state}","event":{}}}"#, event.as_json());
        let err = verify_callback(&body, &state, &challenge).unwrap_err();
        assert!(err.contains("fresh"));
    }
}
