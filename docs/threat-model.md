# Threat model — Astraea on Linux

Scope: the Linux desktop stack (astraea-service, Flutter app, GNOME
extension, COSMIC applet, packaging). The mobile app has its own
considerations; the wire format they share is analyzed here once.

Assets, in order of value:

1. **Signing keys** (delegated calendar key in the Secret Service; the main
   nsec never exists on this machine by design).
2. **Calendar plaintext** (local SQLite + decrypted payloads in memory).
3. **Account pubkey and login session integrity** (who you are).
4. **Availability** (the calendar keeps working offline and under attack).

## Threats and mitigations

### Authentication bridge (docs/authentication.md)

| Threat | Mitigation |
| --- | --- |
| Callback hijacking (another local process answers first) | Listener binds `127.0.0.1:0` (kernel port), single session, single successful callback; the 32-byte `state` gates both serving the form and accepting the callback and never leaves the login URL + page. |
| Replay of a captured callback | Signed 32-byte `challenge` is per-session; `created_at` freshness window (±10 min); session TTL 5 min; the listener closes after one success. |
| Reused challenge signature from another session | The challenge tag must equal this session's challenge exactly (`tests/login_bridge.rs`). |
| Custom URI (`astraea://auth/callback`) hijacking by another app claiming the scheme | The URI scheme is a **fallback**, never the primary path; the localhost callback with state is primary. Documented in authentication.md. |
| Malicious login page look-alike | The page is served by the service itself from loopback with the state in the URL; it pins a strict CSP, names the requesting app, and never asks for the nsec. A fake page cannot produce a valid callback without the state and a fresh signed challenge. |
| Token theft | There are no bearer tokens: login stores only the pubkey; signing capability is separate (Secret Service item or NIP-46). |
| Oversized/slow-loris requests on the bridge | 16 KiB header / 64 KiB body limits, 10 s socket timeouts, `Cache-Control: no-store`. |

### Keys and signing

| Threat | Mitigation |
| --- | --- |
| Key exfiltration from disk | Keys exist only as Secret Service items (GNOME Keyring/KWallet, encrypted at rest, session-unlocked). Never in SQLite, JSON, SharedPreferences, `~/.config`, logs or argv (`auth provision-key` reads stdin). |
| Main-nsec compromise | The documented rule and CLI validation push users to a calendar-scoped identity; NIP-46 remote signing is the no-local-key path. Revocation = `auth logout` or deleting the keyring item. |
| Secrets in logs | Logging policy: outcomes only; no signatures, tokens, challenges, ciphertexts or event contents. `RUST_LOG` raising verbosity does not add secret fields because they are never passed to tracing. |
| Memory disclosure (swap/core) | systemd unit sets `MemoryDenyWriteExecute`, `NoNewPrivileges`, `PrivateTmp`; keys are held transiently per operation. Residual risk accepted (no mlock) and recorded here. |

### D-Bus surface

The session bus is **not** treated as a sufficient security boundary: any
process in the session can call the API. Consequences, by design:

- The API never exposes key material or decrypted secrets — worst case a
  local malicious process can read calendar data and trigger a sync, which
  equals what any same-user process can already read from the DB file.
  Same-user isolation is out of scope (that is the OS user boundary).
- Sensitive operations (provisioning keys) do NOT cross the bus at all —
  `SetSigner` only flips a mode; provisioning talks to the Secret Service
  directly from the CLI in the user's own session.
- Spoofing the well-known name: D-Bus activation ties
  `com.lwb89dev.Astraea.Service` to the packaged binary path; a rogue
  claimant would have to win the name first, which dbus-daemon prevents
  while the activation file exists.
- All inputs are size-limited (1 MiB) and schema-validated; errors are
  typed, never panics (`unwrap_used` is a lint error in production code).

### Nostr / network

| Threat | Mitigation |
| --- | --- |
| Malicious or compromised relay | Events are NIP-44 self-encrypted (confidentiality) and Schnorr-signed (integrity); pulls verify NIP-01 id + signature + `pubkey == account` before decrypting. A relay can withhold or replay old versions — LWW on `updatedAt` makes replays inert (strictly-newer wins). |
| Manipulated event (bit-flips, forged payloads) | Signature verification rejects; undecryptable/unparseable payloads are skipped, never crash sync (fixture-tested). |
| Relay flooding / oversized events | Pull bounds: content ≤ 90 000 chars, ≤ 5 000 events per REQ; publish requires acceptance by every configured relay before local state flips to synced. |
| Downgrade / stripping TLS | Relay URLs default to `wss://`; `ws://` is accepted (not silently upgraded) only as an explicit, user-initiated choice for personal/self-hosted relays without a certificate — both Dart and Rust warn inline that transport metadata is then observable on the local network. Event content is NIP-44 encrypted either way, so this is a metadata-only, opt-in trade-off, not a downgrade an attacker can trigger (validated at the D-Bus boundary; a relay cannot flip another relay's scheme). |
| Metadata leakage to relays | Relays see: pubkey, event count, timing, sizes. Content, titles and locations are encrypted. Residual metadata risk documented; mitigations (padding, relay selection) are future work. |
| Another app writing self-authored calendar events | Kairos (sibling task manager, docs/nostr-sync.md) legitimately publishes kind-30078 `epochs:` events using the *same* account key to mirror dated tasks — indistinguishable on the wire from an event Astraea itself published, by design (self-encryption requires the same key either way). This is not a new trust boundary: it requires the same key material an Astraea client on the same account already holds, i.e. it is the user's own choice of which apps run under that account, not something a third party can forge. |

### Local storage

| Threat | Mitigation |
| --- | --- |
| Corrupted database | WAL mode, transactions, versioned migrations with automatic pre-migration backup, quarantine of unreadable databases (`db doctor` path), migration tests. |
| Tombstone resurrection | Deletions are double-published (replaceable tombstone + NIP-09 on the concrete id only — never the `a` coordinate, which would delete the tombstone itself). |
| Uninstall data loss | Package uninstall never touches `$XDG_DATA_HOME/astraea`; the tarball uninstaller removes only its recorded manifest. |

### Shell extensions / frontends

| Threat | Mitigation |
| --- | --- |
| Compromised GNOME extension | The extension holds no keys, no relay access, no DB access — its capability is exactly the D-Bus API (see above). Its code ships read-only under `/usr/share` via the package. |
| Shell stability | Every D-Bus call in the extension has a timeout and error path; service absence renders a status line, never an exception in the shell process (GNOME kills misbehaving extensions, not the shell — but we do not rely on that). |

### Supply chain and packaging

| Threat | Mitigation |
| --- | --- |
| Malicious dependency update | `Cargo.lock` and `pubspec.lock` are committed and CI-enforced (`--locked`, `--enforce-lockfile`); dependency count kept deliberately small; SBOM generated in CI for auditability. |
| Unsigned packages / tampered artifacts | Release artifacts ship sha256 checksums; native repos add their own signing when adopted. AUR PKGBUILD pins sha256 on tagged sources. |
| Downgrade attacks | Debian/RPM version ordering prevents silent downgrades through package managers; the database refuses to open schemas newer than the binary (migration guard). |
| Build reproducibility | Single staged tree from one script; release profile pins (`lto`, `strip`) in-tree. Full bit-reproducibility is future work and tracked honestly here. |

## Non-goals

- Defending one process of a user from another process of the same user
  (OS boundary; Flatpak's sandbox narrows it for the GUI only).
- Hiding relay-visible metadata (see above).
- Physical attackers with an unlocked session.

## Review cadence

Revisit this document whenever: a new D-Bus method lands, a signer backend
is added (NIP-46!), packaging gains a channel, or an incident occurs.
