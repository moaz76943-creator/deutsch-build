.PHONY: all analyze test clean deps deps-refresh build-apk build-debug-apk

# The default path validates the source and produces a locally installable
# ARM64 debug APK. It never commits, pushes, or changes Git branches.
all: analyze test build-debug-apk

clean:
	flutter clean

deps:
	flutter pub get --enforce-lockfile

# Intentional dependency refresh; review and commit the resulting pubspec.lock.
deps-refresh:
	flutter pub get

analyze:
	dart analyze lib/

test:
	flutter test --reporter expanded

# Release builds require the separately configured secure signing material.
build-apk:
	flutter build apk --release --split-per-abi

# Safe local/CI build; no release keystore or production credentials required.
build-debug-apk:
	flutter build apk --debug --target-platform android-arm64
