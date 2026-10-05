#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

MODE="${1:-debug}"
PROFILE="${2:-full}"
case "$MODE" in debug|release) ;; *) fatal "Usage: ./scripts/build.sh [debug|release] [full|termux-fast]";; esac
case "$PROFILE" in full|termux-fast) ;; *) fatal "Usage: ./scripts/build.sh [debug|release] [full|termux-fast]";; esac
if [[ "$PROFILE" == "termux-fast" && "$MODE" != "debug" ]]; then
  fatal "termux-fast is allowed only for debug APK builds"
fi

JSON_CONTENT="${DEUTSCH_JSON_CONTENT:-false}"
case "$JSON_CONTENT" in true|false) ;; *) fatal "DEUTSCH_JSON_CONTENT must be true or false";; esac
DART_DEFINE=("--dart-define=DEUTSCH_JSON_CONTENT=$JSON_CONTENT")
cd "$ROOT"
LOG_DIR="${HOME}/.deutsch_bilarabi_logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/build_${MODE}_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

run_blocking_analyzer() {
  local analyzer_output analyzer_status analyzer_errors
  log TEST "Dart analyzer (lib/ blocking errors only)"
  set +e
  analyzer_output="$(dart analyze --no-fatal-warnings lib/ 2>&1)"
  analyzer_status=$?
  set -e
  printf '%s\n' "$analyzer_output"
  analyzer_errors="$(printf '%s\n' "$analyzer_output" | grep "error •" || true)"
  if [[ -n "$analyzer_errors" ]]; then
    fatal "Dart analyzer found blocking errors in lib/"
  fi
  if [[ "$analyzer_status" -ne 0 ]]; then
    fatal "Dart analyzer failed unexpectedly with exit $analyzer_status"
  fi
  log OK "Dart analyzer: 0 blocking errors in lib/; warnings are non-blocking"
}

write_provenance() {
  local apk="$1" mode="$2"
  mkdir -p "$ROOT/build"
  local sha256 size_bytes build_info
  sha256="$(sha256sum "$apk" | awk '{print $1}')"
  size_bytes="$(wc -c < "$apk" | tr -d ' ')"
  build_info="$ROOT/build/build-info-${mode}.txt"
  {
    printf 'App Version: %s\n' "$(app_version)"
    printf 'Build Number: %s\n' "$(app_build_number)"
    printf 'Flutter Version: %s\n' "$FLUTTER_VERSION"
    printf 'Dart Version: %s\n' "$DART_VERSION"
    printf 'Android Target: android-%s / %s\n' "$ANDROID_TARGET_SDK" "$APK_ABI"
    printf 'Build Mode: %s\n' "$mode"
    printf 'Git Commit: %s\n' "$(git_commit)"
    printf 'APK Path: %s\n' "$apk"
    printf 'APK Size Bytes: %s\n' "$size_bytes"
    printf 'SHA256: %s\n' "$sha256"
  } > "$build_info"
  cat "$build_info"
  printf 'APK: %s\nSHA256: %s\n' "$apk" "$sha256"
}

log CHECK "1/10 Environment"
"$ROOT/scripts/build_guard.sh"

log CHECK "2/10 Dependencies"
snapshot_lockfile
flutter pub get --enforce-lockfile
assert_lockfile_unchanged

if [[ "$PROFILE" == "termux-fast" ]]; then
  log CHECK "3/6 Fast blocking-error gate"
  run_blocking_analyzer

  log BUILD "4/6 Android Build (debug/termux-fast)"
  flutter build apk --debug "${DART_DEFINE[@]}" --target-platform android-arm64
  APK="$ROOT/build/app/outputs/flutter-apk/app-debug.apk"

  log CHECK "5/6 APK Verification"
  "$ROOT/scripts/apk_verify.sh" "$APK" debug

  log CHECK "6/6 Build provenance"
  write_provenance "$APK" debug
  assert_lockfile_unchanged
  log OK "TERMUX FAST BUILD SUCCESS"
  exit 0
fi

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
write_provenance "$APK" "$MODE"

assert_lockfile_unchanged
log OK "10/10 BUILD SUCCESS"
