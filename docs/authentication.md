# Authentication

How Astraea on Linux proves a Nostr identity and how events get signed
afterwards. Implementation: `native/service/src/account/`.

Two ways in, in decreasing order of what they leave the service able to do:
a **NIP-46 remote signer** (identity *and* unattended signing, no key on the
machine) and the **browser NIP-07 bridge** (identity only).

## Browser login (NIP-07 bridge)

NIP-07 (`window.nostr`) exists **only inside browsers**; neither a Flutter
app nor a shell extension can call it. Astraea therefore logs in through the
default browser:

```
astraea-service                     browser (NIP-07 extension)
     │  BeginBrowserLogin
     │──────────────┐
     │  bind 127.0.0.1:<random>     ← loopback only, never 0.0.0.0
     │  state, challenge, 5 min TTL   (32 random bytes each, hex)
     │  xdg-open http://127.0.0.1:PORT/login?state=…&challenge=…
     │                                   │
     │                                   │ page checks window.nostr,
     │                                   │ getPublicKey(), signs kind-22242
     │                                   │ challenge event (never the nsec)
     │   POST /callback {state, event}   │
     │◄──────────────────────────────────┘
     │  verify: state ≡, challenge tag ≡, |now−created_at| ≤ 10 min,
     │          NIP-01 id + Schnorr signature
     │  persist account (pubkey only) → AuthenticationChanged signal
```

Security properties (tested in `tests/login_bridge.rs`):

- listener binds `127.0.0.1:0` (kernel-chosen port), single session, single
  successful callback, 5-minute expiry, cancellable;
- `state` gates both serving the form and accepting the callback; the signed
  `challenge` tag prevents replaying a signature from another session, and
  the `created_at` freshness window bounds replay of a captured callback;
- request limits: 16 KiB headers, 64 KiB body, 10 s socket timeouts;
- responses carry `Cache-Control: no-store`; the page pins a strict CSP and
  never asks for, sees, or transmits a private key;
- logs record outcomes only — never signatures, tokens or page content.

`astraea://auth/callback` is registered as a URI scheme for future remote
flows, but the localhost callback is the primary path by design: custom URI
schemes can be claimed by other applications (docs/threat-model.md).

CLI: `astraea-service auth login | status | logout`.

## Signing after login

Login proves ownership; it does not create signing capability. The service
routes every signature through one `SignerBackend`
(`account/signer.rs`):

| Backend | signerState | Keys held | Use |
| --- | --- | --- | --- |
| `ReadOnlySigner` | interactive_only | none | consultation only (default before any signer is configured) |
| `BrowserNip07Signer` | interactive_only | none | per-signature browser round-trip; fallback. Background sync parks events as `pending_signature` until the user approves interactively |
| `Nip46Signer` (NIP-46) | ready | none | bunker/Nostr Connect — **the preferred backend**: signs in the background with no key material on this machine |
| `LocalDelegatedSigner` | ready | one calendar-scoped key in the **Secret Service** | background signing without interaction |

`SetSigner(name)` on `com.lwb89dev.NostrAccount1` switches modes; secret
material never crosses D-Bus.

## Remote signer (NIP-46 / bunker)

```
astraea-service (throwaway client key)      remote signer (holds the account key)
     │  ConnectRemoteSigner("bunker://<signer-pk>?relay=…&secret=…")
     │  kind 24133, p-tagged to the signer, content = NIP-44 v2 under the
     │  conversation key (client_sk, signer_pk):
     │    {"id":"<16 random bytes>","method":"connect","params":[pk, secret]}
     │────────────────── relays from the bunker URI ──────────────────────►
     │    …"method":"get_public_key"                → the account pubkey
     │  persist session in the Secret Service → AuthenticationChanged signal
```

Answering `get_public_key` through the signer *is* proof of ownership, in the
same sense the browser bridge's signed challenge is — so this both logs in and
leaves the service able to sign unattended.

Security properties (`native/service/src/account/nip46.rs`, tests inline):

- every inbound frame must be kind 24133, authored by the configured signer
  pubkey, and pass `Event::verify()` (NIP-01 id **and** Schnorr signature)
  before it is decrypted;
- replies are matched only against request ids this process generated with the
  OS CSPRNG and is still waiting for — a relay cannot answer an unasked
  question, nor replay a reply from another conversation;
- signed events coming back are re-verified against the request: valid id and
  signature, the expected account pubkey, and the expected kind;
- bounds: 90 s per request (60 s for the handshake), 256 KiB per reply, 64
  concurrent requests, 4 relays per connection string, 4096 characters on the
  D-Bus argument;
- the `bunker://` string is read from stdin (never argv), stored only in the
  Secret Service, and never logged or quoted back in an error — it embeds a
  single-use connection secret;
- `auth_url` replies are refused with an actionable message rather than
  hanging: a background daemon cannot show the user a browser page.

The implementation is hand-rolled on top of `nostr::nips::nip44` and the
`nostr-sdk` relay pool rather than pulling in a NIP-46 client crate. All of the
cryptography and all of the transport is therefore audited upstream code; what
is local is JSON envelope handling and request/response matching. The published
client crate would instead add a dependency subtree that compiles NIP-04
(deprecated, unauthenticated AES-CBC) into the daemon as a feature-flag side
effect. The mobile client (`lib/services/nip46_client.dart`) mirrors this file
one-for-one, including the stored-session format.

```bash
astraea-service auth connect-bunker   # paste bunker://… on stdin
astraea-service auth status           # signer: remote_nip46, state: ready
```

### LocalDelegatedSigner and the "never the main nsec" rule

The mobile wire format requires events to be authored by the account pubkey
(docs/nostr-sync.md), so a background signer must hold *that identity's*
key. The rule is therefore: **use a calendar-scoped Nostr identity** —
imported on your phone's Astraea too — rather than your main social
identity. Provisioning:

```bash
astraea-service auth login            # prove the identity via browser first
astraea-service auth provision-key    # paste the key on stdin (never argv)
```

The key is validated (must match the logged-in pubkey), stored only in the
freedesktop Secret Service (GNOME Keyring / KWallet), and revoked by
`auth logout` or by deleting the keyring item. It is never written to
SQLite, config files, `~/.config`, or logs.

Since 0.4.0 this is the fallback, not the recommendation: `auth
connect-bunker` gives the same unattended signing with no local key at all.

## Shared identity with Echoes and Kairos (future)

`com.lwb89dev.NostrAccount1` is deliberately product-neutral and lives in a
module that imports no calendar code (ADR-004). The extraction path to a
shared `lwb-nostr-account-service` is: move `account/` to its own crate +
bus name, keep the interface as-is, and have each app's service depend on
it. Keyring attributes (`application=astraea`) would widen to the shared
namespace at that point, with a migration that copies (never moves-and-
breaks) existing items.
