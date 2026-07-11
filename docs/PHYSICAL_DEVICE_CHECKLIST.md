# Physical-device qualification checklist

Record the date, iPhone model, iOS version, Xcode version, WebRTC package and pinned version, input route, output route, and tester for every run.

## Phase 1 connectivity gate

- [ ] Token service returns a short-lived `ek_` client secret over TLS.
- [ ] Native peer connection creates an audio offer.
- [ ] `oai-events` data channel opens.
- [ ] Translation calls endpoint returns an SDP answer.
- [ ] Peer connection and ICE reach connected states.
- [ ] `session.created` arrives.
- [ ] Microphone Portuguese produces `session.output_transcript.delta`.
- [ ] Remote translated audio arrives.
- [ ] Remote audio is inaudible until route and output mode are resolved.
- [ ] Disconnect and reconnect work with a newly issued client secret.

## Privacy and routing

- [ ] Automatic plus built-in speaker remains silent.
- [ ] Automatic plus wired headphones plays translated audio.
- [ ] Unrecognized Bluetooth speaker or vehicle remains silent.
- [ ] A user-marked private Bluetooth route plays translated audio on later use.
- [ ] Headphone removal mutes before audio reaches the replacement route.
- [ ] Pause stops outbound microphone media and translated playback promptly.
- [ ] Backgrounding stops or suspends capture.
- [ ] Stop clears in-memory captions.

## Capture quality

- [ ] Effective microphone route is visible in diagnostics.
- [ ] Built-in microphone is requested and the actual result is recorded.
- [ ] `videoChat` and `voiceChat` profiles are compared with target-like audio.
- [ ] Built-in microphone uses `far_field`; verified headset microphone uses `near_field`.
- [ ] Quiet syllables and phrase beginnings are not clipped.
- [ ] Phone placement at 30-60 cm is evaluated.
- [ ] Television and overlapping voices are evaluated without claims of speaker isolation.

## Translation quality

- [ ] Normal Casegas Portuguese.
- [ ] Quiet and fragmented speech.
- [ ] Family and place names.
- [ ] Numbers, dates, and ages.
- [ ] Religious and older regional vocabulary.
- [ ] Portuguese mixed with English.
- [ ] Long stories and conversational pauses.
- [ ] Meaning, omissions, names, numbers, and latency are scored separately.

## Playback feedback

- [ ] Listen mode through the iPhone speaker does not create sustained feedback.
- [ ] Speaker playback does not produce repeated English captions or retranslation loops.
- [ ] Acknowledged public-output warning is not shown repeatedly.

