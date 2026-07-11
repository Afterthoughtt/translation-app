# Interpreter

Interpreter is a native iPhone application for one-way, live Portuguese-to-English interpretation. It is designed for an older European Portuguese speaker whose speech may be quiet, regional, fragmented, or mixed with occasional English.

The product remains deliberately narrow: open the app, begin listening automatically, show large English captions, and play translated audio only when the selected mode permits it.

## Repository status

The repository currently provides:

- An authoritative product requirements document.
- Architecture, security, and physical-device validation guidance.
- A tested platform-neutral Swift core for transcript assembly and conservative output routing.
- A reproducibly generated Xcode project for the SwiftUI app and core tests.
- A TypeScript token service with strict input validation, bounded requests, rate limiting, safe upstream error handling, and OpenAI client-secret creation.

Xcode 26.6 is installed. The repository uses XcodeGen so the generated `.xcodeproj` stays local and the human-readable `project.yml` remains the source of truth. Device signing, the native WebRTC dependency, and the physical-device connectivity spike are intentionally not represented as complete.

## Quick start

Install the development tools and generate the project:

```sh
brew bundle
make bootstrap
```

Open `Interpreter.xcodeproj` in Xcode, or run all available checks:

```sh
make check
```

Do not place a real API key in `.env.example` or commit `server/.env`.

## Source of truth

- Product scope and acceptance: [`docs/PRD.md`](docs/PRD.md)
- System boundaries: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- Credentials and privacy: [`docs/SECURITY.md`](docs/SECURITY.md)
- Hardware qualification: [`docs/PHYSICAL_DEVICE_CHECKLIST.md`](docs/PHYSICAL_DEVICE_CHECKLIST.md)

The original PDF is retained under `docs/reference/` as historical context only.
