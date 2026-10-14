#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

MODE="${1:-debug}"
case "$MODE" in debug|release) ;; *) fatal "$ERR_ENV" "Usage: ./scripts/build.sh [debug|release]";; esac

JSON_CONTENT="${DEUTSCH_JSON_CONTENT:-false}"
case "$JSON_CONTENT" in true|false) ;; *) fatal "$ERR_ENV" "DEUTSCH_JSON_CONTENT must be true or false";; esac
DART_DEFINE=("--dart-define=DEUTSCH_JSON_CONTENT=$JSON_CONTENT")
cd "$ROOT"
LOG_FILE="$(bash "$ROOT/scripts/create_private_build_log.sh" "$MODE")" || fatal "$ERR_ENV" "Cannot create a private build log"
exec > >(tee -a "$LOG_FILE") 2>&1

log CHECK "1/10 Environment"
"$ROOT/scripts/build_guard.sh" || fatal "$ERR_ENV" "Environment guard failed"

log CHECK "2/10 Dependencies"
python3 "$ROOT/scripts/verify_locked_dependencies.py" || fatal "$ERR_DEP" "Dependency lock mismatch; regenerate with pinned SDK"
snapshot_lockfile
run_pub_get_with_retry || fatal "$ERR_DEP" "Locked dependency resolution failed"
assert_lockfile_unchanged

log TEST "3/10 Analyze + tests + project audits"
bash "$ROOT/scripts/check-dart-errors.sh" || fatal "$ERR_COMP" "Blocking Dart errors or analyzer failure"
flutter test || fatal "$ERR_COMP" "Flutter tests failed"
python -m pytest -q tests || fatal "$ERR_COMP" "Python tests failed"

log CHECK "4/10 Content Quality"
python tool/quality_audit.py || fatal "$ERR_COMP" "Content audit failed"

log CHECK "5/10 Security"
python tool/security_audit.py || fatal "$ERR_COMP" "Security audit failed"
python tool/phase17_production_gate.py || fatal "$ERR_COMP" "Production gate failed"

if [[ "$MODE" == "release" ]]; then
  log CHECK "6/10 Release signing"
  "$ROOT/scripts/signing_guard.sh" || fatal "$ERR_SIGN" "Signing check failed"
fi

log BUILD "7/10 Android Build ($MODE)"
if [[ "$MODE" == "release" ]]; then
  flutter build apk --release "${DART_DEFINE[@]}" --obfuscate --split-debug-info=build/symbols --target-platform android-arm64 || fatal "$ERR_COMP" "Release APK build failed"
  APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
else
  flutter build apk --debug "${DART_DEFINE[@]}" --target-platform android-arm64 || fatal "$ERR_COMP" "Debug APK build failed"
  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"
fi

log CHECK "8/10 APK Verification"
"$ROOT/scripts/apk_verify.sh" "$APK" "$MODE" || fatal "$ERR_ARTIFACT" "APK verification failed"

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
