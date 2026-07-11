.PHONY: bootstrap project swift-test server-check xcode-build check

bootstrap:
	./scripts/bootstrap.sh

project:
	xcodegen generate

swift-test:
	./scripts/with-xcode.sh swift test

server-check:
	cd server && npm run typecheck && npm test && npm run build

xcode-build: project
	./scripts/with-xcode.sh xcodebuild \
		-project Interpreter.xcodeproj \
		-scheme Interpreter \
		-sdk iphonesimulator \
		-destination 'generic/platform=iOS Simulator' \
		-derivedDataPath .build/DerivedData \
		CODE_SIGNING_ALLOWED=NO \
		build

check:
	./scripts/check.sh

