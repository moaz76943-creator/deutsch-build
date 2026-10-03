#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

failures=0
row() { printf '%-16s %s\n' "$1" "$2"; }
required_cmd() { command -v "$1" >/dev/null 2>&1; }

printf 'Deutsch بالعربي — Environment Doctor\n\n'

if required_cmd flutter; then
  actual="$(flutter --version | head -1)"
  if [[ "$actual" == *"$FLUTTER_VERSION"* ]]; then row Flutter "✓ $FLUTTER_VERSION"; else row Flutter "✗ Expected $FLUTTER_VERSION / Found $actual"; failures=1; fi
else row Flutter "✗ command not found"; failures=1; fi

if required_cmd dart; then
  actual="$(dart --version 2>&1 | head -1)"
  if [[ "$actual" == *"$DART_VERSION"* ]]; then row Dart "✓ $DART_VERSION"; else row Dart "✗ Expected $DART_VERSION / Found $actual"; failures=1; fi
else row Dart "✗ command not found"; failures=1; fi

ARCH="$(uname -m)"
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then row Architecture "✓ $ARCH"; else row Architecture "✓ $ARCH (non-Termux host)"; fi

if required_cmd java; then
  java_major="$(java -version 2>&1 | awk -F'[\".]' '/version/ {print $2; exit}')"
  if [[ "$java_major" == "$JAVA_MAJOR" ]]; then row Java "✓ $java_major"; else row Java "✗ Expected $JAVA_MAJOR / Found $java_major"; failures=1; fi
else row Java "✗ command not found"; failures=1; fi

SDK="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -n "$SDK" && -d "$SDK" ]]; then row "Android SDK" "✓ $SDK"; else row "Android SDK" "✗ not found"; failures=1; fi
if [[ -n "$SDK" && -d "$SDK/build-tools/$ANDROID_BUILD_TOOLS_VERSION" ]]; then row "Build Tools" "✓ $ANDROID_BUILD_TOOLS_VERSION"; else row "Build Tools" "✗ $ANDROID_BUILD_TOOLS_VERSION missing"; failures=1; fi
if [[ -n "$SDK" && -d "$SDK/ndk/$ANDROID_NDK_VERSION" ]]; then row NDK "✓ $ANDROID_NDK_VERSION"; elif grep -q 'ndkVersion' android/app/build.gradle; then row NDK "✗ $ANDROID_NDK_VERSION missing"; failures=1; else row NDK "✓ not required by current app"; fi

if [[ -x android/gradlew ]]; then
  wrapper="$(sed -nE 's/^distributionUrl=.*gradle-([0-9.]+)-all\.zip$/\1/p' android/gradle/wrapper/gradle-wrapper.properties)"
  [[ "$wrapper" == "$GRADLE_VERSION" ]] && row Gradle "✓ $GRADLE_VERSION" || { row Gradle "✗ Expected $GRADLE_VERSION / Found $wrapper"; failures=1; }
else row Gradle "✗ wrapper missing"; failures=1; fi

if grep -F "version \"$AGP_VERSION\"" android/settings.gradle >/dev/null; then row AGP "✓ $AGP_VERSION"; else row AGP "✗ Expected $AGP_VERSION"; failures=1; fi
if grep -F "version \"$KOTLIN_VERSION\"" android/settings.gradle >/dev/null; then row Kotlin "✓ $KOTLIN_VERSION"; else row Kotlin "✗ Expected $KOTLIN_VERSION"; failures=1; fi

if [[ -f pubspec.yaml && -f pubspec.lock ]]; then row Dependencies "✓ pubspec.yaml + lockfile"; else row Dependencies "✗ pubspec.lock missing"; failures=1; fi

if required_cmd aapt2 || [[ "$ARCH" != "aarch64" && "$ARCH" != "arm64" ]]; then row AAPT2 "✓"; else row AAPT2 "✗ native ARM64 aapt2 missing"; failures=1; fi

printf '\n'
if [[ "$failures" -ne 0 ]]; then
  row Analyzer "- not run until environment is fixed"
  row Tests "- not run until environment is fixed"
  exit 1
fi

snapshot_lockfile
if flutter analyze >/dev/null; then row Analyzer "✓ 0 errors"; else row Analyzer "✗ failed"; failures=1; fi
if flutter test >/dev/null; then row Tests "✓ Flutter tests"; else row Tests "✗ failed"; failures=1; fi
assert_lockfile_unchanged

if [[ "$failures" -eq 0 ]]; then
  printf '\nDOCTOR PASS\n'
else
  printf '\nDOCTOR FAIL\n'
fi
exit "$failures"
