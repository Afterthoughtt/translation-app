# Product Requirements Document

Status: Initial implementation baseline  
Last reviewed: 2026-07-10  
Authoritative over: `docs/reference/Codex Implementation Brief.pdf`

## 1. Product outcome

Enable an English-speaking listener to understand a nearby Portuguese-speaking family member during an existing in-person conversation, with almost no interaction after initial setup.

Primary source speaker characteristics:

- European Portuguese from Casegas, Portugal.
- Older regional vocabulary and pronunciation.
- Sometimes quiet, unclear, breathy, fragmented, or incomplete.
- May mix Portuguese and English.

Success means the listener can open the app and receive useful English captions quickly without turning the conversation into a chat-with-an-assistant interaction.

## 2. MVP boundaries

The MVP is one-way Portuguese speech to English captions and translated English audio. It is not a general assistant and does not implement two-way translation, speaker identity, background listening, recording, cloud history, user accounts, or dialect fine-tuning.

Use OpenAI's dedicated `gpt-realtime-translate` model and translation session lifecycle. Do not call `response.create`.

## 3. User experience

### First launch

1. Explain that microphone audio is sent to OpenAI for live translation.
2. Explain captions and the three output modes.
3. Request microphone permission.
4. Default to Automatic mode.
5. Start after permission is granted.

### Later launches

When the app becomes active, begin configuring and connecting without a Start button unless permission is unavailable, auto-start is disabled, or configuration is invalid.

### Main screen

Show only connection status, a non-color-only listening indicator, large English captions, recent caption history, output mode, Pause/Resume, Stop, and Settings.

Use Dynamic Type, VoiceOver labels, and standard minimum tap targets. Keep the screen awake only while Listening.

## 4. Output modes and privacy invariants

### Automatic

- Always show captions.
- Start translated audio muted.
- Play only after a route is resolved as private.
- Wired headphones and hearing aids are private by default.
- Bluetooth and other ambiguous routes are public until the user saves a private override for that stable route identifier.
- Mute immediately before processing a route-disconnection change.

### Listen

- Show captions and play translated audio through the resolved output.
- Warn once when output is public.
- Verify on-device that acoustic echo cancellation prevents feedback or repeated translation.

### Read

- Show captions and never play translated audio.
- Keep receiving the remote audio track in a muted state so mode changes stay local.

### Pause and Stop

Pause is an explicit privacy boundary. It stops outbound microphone media and mutes translated playback. Conversational silence while Listening does not stop media and must not be treated as Pause.

Stop disconnects, clears all in-memory transcript data, restores the idle timer, and disables automatic foreground resume until the next explicit app launch or user action defined by the final UI.

## 5. Translation session

Use:

- Model: `gpt-realtime-translate`
- Target output language: `en`
- Optional source transcript: `gpt-realtime-whisper`
- WebRTC calls endpoint: `/v1/realtime/translations/calls`
- Data channel: `oai-events`
- Client-secret endpoint: `/v1/realtime/translations/client_secrets`

Use `far_field` noise reduction for the built-in phone microphone and unknown room microphones. Use `near_field` for a verified headset microphone. Change this through `session.update` when the effective input changes.

Decode at least `session.created`, `session.updated`, `session.closed`, `session.input_transcript.delta`, `session.output_transcript.delta`, and `error`. Append delta strings exactly as received.

Official references:

- https://developers.openai.com/api/docs/guides/realtime-translation
- https://developers.openai.com/api/reference/resources/realtime/translation-server-events
- https://developers.openai.com/api/reference/resources/realtime/translation-client-events

## 6. Captions

Maintain a live English segment, optional live Portuguese source segment, and in-memory history. Complete a segment on a configurable idle interval, terminal punctuation followed by a shorter idle interval, maximum length, Pause, Stop, or disconnect.

Initial constants:

- General idle interval: 1.2 seconds.
- Terminal-punctuation idle interval: 500 milliseconds.
- Maximum active segment length: 300 characters.

The most recently visible translation must never disappear during a history transition or reconnect. Portuguese source text is hidden by default and labeled as diagnostic rather than ground truth.

## 7. Audio capture and routing

- Configure `AVAudioSession` before creating the WebRTC audio track.
- Initial category: `playAndRecord`.
- Initial mode: `videoChat`.
- Permit supported Bluetooth HFP input and A2DP output options for the installed SDK.
- Prefer the built-in iPhone microphone, then verify the effective route.
- Do not add local VAD or a volume threshold.
- Do not add arbitrary digital gain in the MVP.
- Do not assume a specific built-in microphone data source or polar pattern.

The Phase 1 spike must prove that a selected, pinned native WebRTC package can exchange SDP with the translation calls endpoint, transmit microphone media, receive remote audio, receive transcript events, and begin with remote playback muted.

## 8. Lifecycle and recovery

Backgrounding stops or suspends translation and mutes playback. Returning to the foreground reconnects unless the user explicitly stopped.

Retry recoverable failures with delays of 0, 1, 2, 4, and 8 seconds. After five failures, enter `waitingForNetworkOrUser`: no more timer retries, one retry on a genuine offline-to-online transition, or an immediate user Retry. Preserve captions during recovery and fetch a new client secret for each new session.

## 9. Token service

Expose `POST /api/translation-token` with a maximum 2 KB JSON body:

```json
{
  "noiseReduction": "far_field",
  "deviceId": "stable-random-installation-id"
}
```

Reject missing, unknown, oversized, or invalid fields. Hard-code the model, source-transcription model, target language, and client-secret TTL server-side. Return only normalized errors to the app.

The initial side-loaded build may use a long random bootstrap bearer token stored in Keychain, but production readiness requires either per-install enrollment and revocation or private-network restriction. Rate-limit by installation and network source, and support an operational duration or spending ceiling.

## 10. Privacy, observability, and cost

Do not persist conversation audio or transcripts by default. Do not log raw audio, full transcripts, OpenAI keys, client secrets, or access tokens. Diagnostic recording requires explicit action, a visible indicator, local-only storage, and deletion controls.

Log redacted event types, state transitions, route types, latency, character counts, reconnection counts, and upstream status classes. Display session duration. Translation is billed by audio duration, so the deployed service must have bounded issuance and usage monitoring.

## 11. Delivery phases

### Phase 0 - Foundation

- Repository, Swift core, token service, documentation, tests, and environment template.
- Full Xcode availability confirmed before generating the app target.

### Phase 1 - Physical-device connectivity spike

- Pin native WebRTC dependency.
- Prove client secret, SDP, microphone upload, remote audio, data channel, captions, and initially muted playback.
- Do not proceed without a physical-iPhone result recorded in the checklist.

### Phase 2 - Product state and captions

- State machine, permissions, automatic launch, captions, history, Pause, Stop, and reconnection.

### Phase 3 - Route-aware output

- Three modes, conservative route privacy, overrides, immediate disconnection mute, and feedback tests.

### Phase 4 - Audio quality and diagnostics

- Preferred input verification, noise-profile updates, interruption recovery, route diagnostics, and target-speaker evaluation.

### Phase 5 - Optional correction

- Only after the live path is acceptable. Correct completed displayed captions without delaying live output or altering translated audio.

## 12. MVP acceptance gates

- Swift core and server checks pass.
- Full Xcode app target builds without committed secrets.
- A physical iPhone reaches Listening through the real translation API.
- Portuguese produces incremental English captions.
- Pause promptly stops outbound audio and mutes playback.
- Automatic mode never emits audio before private-route resolution.
- Ambiguous Bluetooth defaults to muted until overridden.
- Mode changes do not reconnect.
- Network and route changes do not crash or erase captions.
- Backgrounding stops or suspends capture.
- Dynamic Type and VoiceOver checks pass.
- Physical tests cover quiet speech, names, numbers, mixed English, TV noise, route changes, and speaker-output feedback.

## 13. Decisions still required

- Apple bundle identifier and development team.
- Token-service deployment platform and public base URL.
- Bootstrap-token enrollment method for the private installation.
- Exact iPhone, iOS version, and headphone routes used for qualification.
- Native WebRTC package and pinned version, selected during Phase 1 rather than by guesswork.
