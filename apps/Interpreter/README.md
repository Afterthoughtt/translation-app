# Interpreter iOS app

This folder contains the SwiftUI application source. The repository intentionally does not commit a hand-authored `.xcodeproj`; run `make project` from the repository root to generate it from `project.yml`.

The generated project contains the iOS 17 application, the `InterpreterCore` framework, and its unit-test target. Local signing values belong in ignored `Config/Local.xcconfig`.

Do not select or pin a native WebRTC dependency until the Phase 1 package qualification checklist in `docs/PHYSICAL_DEVICE_CHECKLIST.md` is run against the installed Xcode version.
