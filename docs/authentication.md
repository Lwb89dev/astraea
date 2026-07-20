# Authentication

How Astraea on Linux proves a Nostr identity and how events get signed
afterwards. Implementation: `native/service/src/account/`.

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
| `RemoteSigner` (NIP-46) | ready | none | bunker/Nostr Connect — preferred for continuous use; connects when relay support is wired (no invented protocol; the audited client library will be used) |
| `LocalDelegatedSigner` | ready | one calendar-scoped key in the **Secret Service** | background signing without interaction |

`SetSigner(name)` on `com.lwb89dev.NostrAccount1` switches modes; secret
material never crosses D-Bus.

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
SQLite, config files, `~/.config`, or logs. True delegation without any
local key is the NIP-46 path.

## Shared identity with Echoes and Kairos (future)

`com.lwb89dev.NostrAccount1` is deliberately product-neutral and lives in a
module that imports no calendar code (ADR-004). The extraction path to a
shared `lwb-nostr-account-service` is: move `account/` to its own crate +
bus name, keep the interface as-is, and have each app's service depend on
it. Keyring attributes (`application=astraea`) would widen to the shared
namespace at that point, with a migration that copies (never moves-and-
breaks) existing items.
