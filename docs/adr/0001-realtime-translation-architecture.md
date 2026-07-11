# ADR 0001: Dedicated Realtime Translation with direct WebRTC

Status: Accepted  
Date: 2026-07-10

## Decision

Use the dedicated OpenAI Realtime Translation API with `gpt-realtime-translate`. The iPhone establishes WebRTC directly with OpenAI using a short-lived client secret issued by a small server. The server does not relay conversation audio.

## Rationale

The dedicated translation session continuously returns translated audio and transcript deltas without the normal assistant response lifecycle. WebRTC handles mobile audio media more directly than a custom raw-PCM WebSocket pipeline.

## Consequences

- A permanent OpenAI key remains server-side.
- Native iOS WebRTC behavior must be proven because official examples use browser WebRTC.
- Audio routing and muting remain local and must fail closed.
- A raw PCM relay remains a later fallback only after controlled comparison.

