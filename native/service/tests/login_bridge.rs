//! Integration tests for the browser login bridge: a real TCP listener on
//! 127.0.0.1 and real HTTP requests, with the browser role played by the
//! test (NIP-07 signature produced with the `nostr` crate).

use astraea_service::account::login;
use nostr::{EventBuilder, JsonUtil, Keys, Kind, Tag};

async fn http_request(port: u16, request: &str) -> String {
    use tokio::io::{AsyncReadExt, AsyncWriteExt};
    let mut stream = tokio::net::TcpStream::connect(("127.0.0.1", port))
        .await
        .expect("connect");
    stream.write_all(request.as_bytes()).await.expect("write");
    let mut response = Vec::new();
    stream.read_to_end(&mut response).await.expect("read");
    String::from_utf8_lossy(&response).into_owned()
}

fn extract_query_param(url: &str, name: &str) -> String {
    url.split('?')
        .nth(1)
        .and_then(|query| {
            query
                .split('&')
                .find_map(|pair| pair.strip_prefix(&format!("{name}=")))
        })
        .expect("param present")
        .to_owned()
}

fn port_of(url: &str) -> u16 {
    url.strip_prefix("http://127.0.0.1:")
        .and_then(|rest| rest.split('/').next())
        .and_then(|p| p.parse().ok())
        .expect("port in url")
}

#[tokio::test]
async fn full_login_round_trip_succeeds() {
    let (session, done) = login::begin(false).await.expect("begin");
    let port = port_of(&session.url);
    let state = extract_query_param(&session.url, "state");
    let challenge = extract_query_param(&session.url, "challenge");

    // The login page is served only with the right state.
    let page = http_request(
        port,
        &format!("GET /login?state={state}&challenge={challenge} HTTP/1.1\r\nHost: x\r\n\r\n"),
    )
    .await;
    assert!(page.starts_with("HTTP/1.1 200"), "page: {}", &page[..40.min(page.len())]);
    assert!(page.contains("window.nostr"));

    let wrong = http_request(port, "GET /login?state=wrong HTTP/1.1\r\nHost: x\r\n\r\n").await;
    assert!(wrong.starts_with("HTTP/1.1 403"));

    // Sign the challenge like a NIP-07 extension would.
    let keys = Keys::generate();
    let event = EventBuilder::new(Kind::from(22242u16), "Astraea Linux desktop login")
        .tags([
            Tag::parse(["challenge", challenge.as_str()]).expect("tag"),
            Tag::parse(["client", "astraea"]).expect("tag"),
        ])
        .sign_with_keys(&keys)
        .expect("sign");
    let body = format!(r#"{{"state":"{state}","event":{}}}"#, event.as_json());
    let request = format!(
        "POST /callback HTTP/1.1\r\nHost: x\r\nContent-Type: application/json\r\nContent-Length: {}\r\n\r\n{body}",
        body.len(),
    );
    let response = http_request(port, &request).await;
    assert!(response.starts_with("HTTP/1.1 200"), "callback: {response}");

    let outcome = done.await.expect("channel").expect("verified");
    assert_eq!(outcome.pubkey, keys.public_key().to_hex());
}

#[tokio::test]
async fn callback_with_bad_signature_is_rejected_and_session_stays_open() {
    let (session, mut done) = login::begin(false).await.expect("begin");
    let port = port_of(&session.url);
    let state = extract_query_param(&session.url, "state");
    let challenge = extract_query_param(&session.url, "challenge");

    // Signature over a DIFFERENT challenge (replay from another session).
    let keys = Keys::generate();
    let event = EventBuilder::new(Kind::from(22242u16), "login")
        .tags([Tag::parse(["challenge", "aaaa"]).expect("tag")])
        .sign_with_keys(&keys)
        .expect("sign");
    let body = format!(r#"{{"state":"{state}","event":{}}}"#, event.as_json());
    let request = format!(
        "POST /callback HTTP/1.1\r\nHost: x\r\nContent-Length: {}\r\n\r\n{body}",
        body.len(),
    );
    let response = http_request(port, &request).await;
    assert!(response.starts_with("HTTP/1.1 400"), "got: {response}");

    // The rejected attempt must not complete the session…
    assert!(done.try_recv().is_err());

    // …and a valid attempt afterwards still works.
    let event = EventBuilder::new(Kind::from(22242u16), "login")
        .tags([Tag::parse(["challenge", challenge.as_str()]).expect("tag")])
        .sign_with_keys(&keys)
        .expect("sign");
    let body = format!(r#"{{"state":"{state}","event":{}}}"#, event.as_json());
    let request = format!(
        "POST /callback HTTP/1.1\r\nHost: x\r\nContent-Length: {}\r\n\r\n{body}",
        body.len(),
    );
    let response = http_request(port, &request).await;
    assert!(response.starts_with("HTTP/1.1 200"), "got: {response}");
    let outcome = done.await.expect("channel").expect("verified");
    assert_eq!(outcome.pubkey, keys.public_key().to_hex());
}

#[tokio::test]
async fn cancelled_session_reports_cancellation() {
    let (mut session, done) = login::begin(false).await.expect("begin");
    session.cancel();
    let result = done.await.expect("channel");
    assert!(result.is_err());
}
