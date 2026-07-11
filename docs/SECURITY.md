# Security and privacy baseline

## Secrets

- `OPENAI_API_KEY` exists only in the deployed token service.
- Translation client secrets stay in app memory and are never logged or persisted.
- The initial app-access token is stored in Keychain, never source control or `UserDefaults`.
- `.env` files, recordings, transcripts, logs, and diagnostics are ignored.

The bootstrap bearer token in the initial server is suitable only for a bounded private side-loaded pilot. Before broader distribution, replace it with per-install enrollment and revocable credentials or place the service behind a private network boundary.

## Data minimization

- Stream microphone audio only while the app is foregrounded and Listening.
- Pause and Stop are explicit capture boundaries.
- Keep caption history in memory only.
- Require explicit action for copying session text or recording diagnostics.
- Redact upstream error bodies from client responses and routine logs.

## Server controls

- TLS is mandatory in deployment.
- Reject invalid fields rather than silently defaulting them.
- Limit request bodies and apply timeouts.
- Rate-limit token issuance.
- Hard-code model and language configuration.
- Add deployment-level quotas and alerts before unattended use.
- Store only hashes of per-install credentials when enrollment is implemented.

## Threats tracked for the pilot

- Extraction and reuse of a shared bootstrap token.
- Accidental public playback through ambiguous Bluetooth routes.
- Audio continuing after Pause or backgrounding.
- Transcript or secret disclosure through logs.
- Unbounded token issuance or duration-billed sessions.
- Diagnostic recordings remaining on a shared device.

