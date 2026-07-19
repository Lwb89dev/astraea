# Security policy

Calendar data and Nostr identities are sensitive. Please do not disclose a
suspected vulnerability in a public issue, discussion or pull request.

## Supported versions

| Version | Supported |
| --- | --- |
| Latest release | Yes |
| Older releases | Best effort |
| Unreleased development builds | No guarantee |

## Reporting a vulnerability

Use GitHub's **Report a vulnerability** private security-advisory flow for this
repository. Include:

- affected version and platform;
- a concise impact assessment;
- reproducible steps or a minimal proof of concept;
- whether private keys or decrypted calendar data may be exposed;
- any suggested remediation, if known.

Do not include a real private key, production calendar export or third-party
personal data. Use generated test identities and synthetic events.

You should receive an acknowledgement within seven days. Maintainers will
validate the report, agree on disclosure timing and prepare a fix. Please allow
a reasonable remediation window before publication.

## Security boundaries

Astraea encrypts synced event contents, but Nostr does not hide all metadata.
Relay operators can still observe the user's IP address, public key, relay
choice, event kind, timestamps, frequency and approximate payload sizes. Local
data is protected by the operating-system application sandbox; a rooted or
already-compromised device is outside the threat model.

The latest code-assisted review is available in
[docs/SECURITY_AUDIT.md](docs/SECURITY_AUDIT.md). It is not a substitute for an
independent penetration test or formal cryptographic review.
