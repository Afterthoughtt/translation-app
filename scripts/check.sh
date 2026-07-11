#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

xcodegen generate

./scripts/with-xcode.sh swift test

npm --prefix server run typecheck
npm --prefix server test
npm --prefix server run build

./scripts/with-xcode.sh xcodebuild \
  -project Interpreter.xcodeproj \
  -scheme Interpreter \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath .build/DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build-for-testing
