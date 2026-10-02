#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

MODE="${1:-debug}"
case "$MODE" in debug|release) ;; *) fatal "Usage: ./scripts/build.sh [debug|release]";; esac

JSON_CONTENT="${DEUTSCH_JSON_CONTENT:-false}"
case "$JSON_CONTENT" in true|false) ;; *) fatal "DEUTSCH_JSON_CONTENT must be true or false";; esac
DART_DEFINE=("--dart-define=DEUTSCH_JSON_CONTENT=$JSON_CONTENT")
cd "$ROOT"
LOG_DIR="${HOME}/.deutsch_bilarabi_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build_${MODE}_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

log CHECK "1/10 Environment"
"$ROOT/scripts/build_guard.sh"

log CHECK "2/10 Dependencies"
snapshot_lockfile
flutter pub get --enforce-lockfile
assert_lockfile_unchanged

log TEST "3/10 Analyze + tests + project audits"
flutter analyze
flutter test
python -m pytest -q tests

log CHECK "4/10 Content Quality"
python tool/quality_audit.py

log CHECK "5/10 Security"
python tool/security_audit.py
python tool/phase17_production_gate.py

if [[ "$MODE" == "release" ]]; then
  log CHECK "6/10 Release signing"
  "$ROOT/scripts/signing_guard.sh"
fi

log BUILD "7/10 Android Build ($MODE)"
if [[ "$MODE" == "release" ]]; then
  flutter build apk --release "${DART_DEFINE[@]}" --obfuscate --split-debug-info=build/symbols --target-platform android-arm64
  APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
else
  flutter build apk --debug "${DART_DEFINE[@]}" --target-platform android-arm64
  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
fi

log CHECK "8/10 APK Verification"
"$ROOT/scripts/apk_verify.sh" "$APK" "$MODE"

log CHECK "9/10 Build provenance"
mkdir -p "$ROOT/build"
SHA256="$(sha256sum "$APK" | awk '{print $1}')"
SIZE_BYTES="$(wc -c < "$APK" | tr -d ' ')"
BUILD_INFO="$ROOT/build/build-info-${MODE}.txt"
{
  printf 'App Version: %s\n' "$(app_version)"
  printf 'Build Number: %s\n' "$(app_build_number)"
  printf 'Flutter Version: %s\n' "$FLUTTER_VERSION"
  printf 'Dart Version: %s\n' "$DART_VERSION"
  printf 'Android Target: android-%s / %s\n' "$ANDROID_TARGET_SDK" "$APK_ABI"
  printf 'Build Mode: %s\n' "$MODE"
  printf 'Git Commit: %s\n' "$(git_commit)"
  printf 'APK Path: %s\n' "$APK"
  printf 'APK Size Bytes: %s\n' "$SIZE_BYTES"
  printf 'SHA256: %s\n' "$SHA256"
} > "$BUILD_INFO"
cat "$BUILD_INFO"

log OK "10/10 BUILD SUCCESS"
printf 'APK: %s\nSHA256: %s\n' "$APK" "$SHA256"
