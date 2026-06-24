# Run tests on macOS (placeholder only — CarPlay unavailable on macOS test host)
test:
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all \
	swift test

# Run full test suite including CarPlay tests on iOS Simulator
test-ios:
	xcodebuild test \
		-scheme CxCarPlay \
		-destination 'platform=iOS Simulator,name=iPhone 16'

build:
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=safe.bareRepository GIT_CONFIG_VALUE_0=all \
	swift build

.PHONY: test test-ios build
