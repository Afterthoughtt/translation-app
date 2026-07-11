# Interpreter repository guidance

## Goal

Build a narrow native iPhone app that continuously translates nearby Portuguese speech into English captions and optional translated audio. Preserve quiet speech, keep translated audio private by default, and never ship a permanent OpenAI API key in the app.

## Layout

- `apps/Interpreter/`: SwiftUI application source and Apple-platform integrations.
- `Sources/InterpreterCore/`: platform-neutral state, transcript, and routing logic.
- `Tests/InterpreterCoreTests/`: fast Swift unit tests.
- `server/`: TypeScript service that creates short-lived translation client secrets.
- `docs/`: product requirements, architecture, security decisions, and device-test checklists.
- `project.yml`: source of truth for the generated Xcode project.
- `docs/reference/Codex Implementation Brief.pdf`: historical handoff only; `docs/PRD.md` is authoritative.

## Setup and checks

- Bootstrap: `brew bundle && make bootstrap`
- Swift core: `make swift-test`
- Server install: `cd server && npm ci`
- Server checks: `cd server && npm run typecheck && npm test && npm run build`
- Generate Xcode project: `make project`
- Simulator build: `make xcode-build`
- Full verification: `make check`
- Physical-device work requires a signing team and an iPhone. Do not claim hardware validation from a simulator build.

## Engineering conventions

- Keep OpenAI endpoint paths, event names, and payloads aligned with current official documentation.
- Decode server events by `type`; preserve transcript deltas exactly without inserting spaces.
- Treat explicit UI Pause as a privacy boundary: stop outbound microphone media and mute translated playback.
- Keep media flowing during conversational silence while the app is Listening; do not add local VAD gating.
- Start every new remote translated-audio track muted. Enable it only after route and mode policy are resolved.
- Treat ambiguous Bluetooth outputs as public unless the user has saved a private-route override.
- Keep Apple/WebRTC code behind protocols so core logic remains unit-testable.
- Never log raw audio, full transcripts, API keys, client secrets, or access tokens by default.
- Avoid unrelated refactors and generated-file churn.

## Verification expectations

- Run the narrowest relevant tests after each change.
- After multi-file edits, check imports and references and review `git diff`.
- WebRTC, audio routing, microphone selection, interruptions, and feedback control require the physical-device checklist.
- Mock transport is allowed in unit tests and previews, but completed acceptance requires the real OpenAI translation path.

## Generated and local-only paths

- `.build/`, `DerivedData/`, the generated `Interpreter.xcodeproj/`, `Config/Local.xcconfig`, `node_modules/`, `server/dist/`, `.env`, diagnostics, recordings, and logs are not committed.
- Do not edit generated Xcode user data or package caches.
