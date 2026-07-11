# ADR 0002: Native WebRTC package

Status: Pending physical-device qualification

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

## Research snapshot

Reviewed 2026-07-10 against Xcode 26.6 and the iOS 26.5 SDK.

OpenAI's Realtime Translation documentation describes browser WebRTC rather than a supported native iOS package. The native dependency therefore needs to expose the equivalent peer-connection, audio-track, SDP, and data-channel primitives without changing the direct iPhone-to-OpenAI architecture.

Leading candidates:

1. [`stasel/WebRTC` 149.0.0](https://github.com/stasel/WebRTC/releases/tag/149.0.0)
   - Standard `WebRTC` module and upstream-style Objective-C API names.
   - Exact-version Swift Package binary with a published checksum.
   - Device and Simulator slices, BSD 3-Clause wrapper license, and a reproducible public build workflow.
   - Preliminary lead because it minimizes adapter-specific naming and is current, but it is a community binary rather than an official Google mobile distribution.
2. [`livekit/webrtc-xcframework` 144.7559.11](https://github.com/livekit/webrtc-xcframework/releases/tag/144.7559.11)
   - Exact-version Swift Package binary maintained by an active WebRTC product team.
   - Device and Simulator slices and MIT wrapper license.
   - Renames the module and Objective-C symbols to `LiveKitWebRTC`/`LKRTC*`, increasing adapter coupling without providing a benefit needed by this app.

## Current outcome

Do not add either package to `project.yml` yet. `stasel/WebRTC` 149.0.0 is the first package to qualify on the physical iPhone, with the LiveKit build retained as the fallback.

The qualification run must record:

- Exact package tag and resolved commit.
- Xcode, iOS, iPhone, and route details.
- Successful offer/answer exchange with `/v1/realtime/translations/calls`.
- Microphone upload during natural silence without local VAD gating.
- `oai-events` lifecycle and transcript events.
- A remote audio track that is disabled before rendering.
- Pause, background, route change, interruption, and acoustic feedback behavior.

Only after those checks pass should the exact package version be pinned in `project.yml` and this ADR changed to Accepted.
