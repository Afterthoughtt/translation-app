#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen is required. Install it with: brew bundle" >&2
  exit 1
fi

if [ ! -f Config/Local.xcconfig ]; then
  cp Config/Local.xcconfig.example Config/Local.xcconfig
fi

npm --prefix server ci
xcodegen generate

echo "Bootstrap complete. Open Interpreter.xcodeproj in Xcode."

