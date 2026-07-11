# ADR 0002: Native WebRTC package

Status: Pending Phase 1 qualification

## Decision to make

Select and pin a maintained native iOS WebRTC XCFramework or Swift package compatible with the installed Xcode version.

## Required evidence

- Current maintenance and a reproducible pinned artifact.
- Physical-device microphone capture.
- SDP offer/answer exchange with the translation calls endpoint.
- `oai-events` data channel support.
- Remote audio reception with initially muted playback.
- Compatible `AVAudioSession` ownership and interruption handling.
- Acceptable binary size and license.

Do not accept the package based only on simulator compilation.
