# Architecture

## System boundary

```text
iPhone microphone
  -> AVAudioSession and native WebRTC local track
  -> OpenAI Realtime Translation session
  -> remote translated-audio track (muted by default)
  -> oai-events transcript and lifecycle events
  -> SwiftUI captions and local output policy

iPhone app
  -> authenticated HTTPS token request
  -> token service
  -> OpenAI translation client-secret endpoint
```

The token service is a credential broker, not an audio relay. The permanent OpenAI API key stays on the server. The phone uses a short-lived client secret to establish WebRTC directly with OpenAI.

## Modules

`InterpreterCore` owns deterministic state, transcript assembly, and output policy. It does not import AVFoundation or WebRTC.

The iOS app will add adapters for:

- Microphone permission and application lifecycle.
- `AVAudioSession` configuration and route monitoring.
- WebRTC peer connection and data channel.
- Token retrieval and Keychain storage.
- Caption timers, haptics, diagnostics, and settings.

The server owns request authentication, validation, rate limits, stable safety-identifier hashing, OpenAI client-secret creation, and normalized errors.

## Critical invariants

1. A remote translated-audio track is muted before it can render.
2. Explicit Pause stops outbound microphone media.
3. Natural silence during Listening continues to send media.
4. Automatic mode fails closed when route privacy is unknown.
5. Transcript deltas are append-only and are not re-spaced.
6. A new Realtime session receives a new client secret.
7. The permanent API key never crosses the token-service boundary.

## WebRTC dependency decision

The native library is intentionally undecided. Browser WebRTC is the documented OpenAI client path, while native iOS requires an equivalent SDP implementation. Select a maintained package only after confirming compatibility with the installed Xcode and physical-device audio behavior. Record the decision in `docs/adr/0002-native-webrtc-package.md`.

