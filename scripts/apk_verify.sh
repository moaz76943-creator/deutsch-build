#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

APK="${1:-}"
MODE="${2:-release}"
[[ -n "$APK" ]] || fatal "Usage: ./scripts/apk_verify.sh <apk> <debug|release>"
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || fatal "Build mode must be debug or release"
[[ -f "$APK" ]] || fatal "APK does not exist: $APK"
[[ -s "$APK" ]] || fatal "APK is empty: $APK"

need() { command -v "$1" >/dev/null 2>&1 || fatal "Required APK verification tool is missing: $1"; }
need unzip
need sha256sum
need aapt
if [[ "$MODE" == "release" ]]; then need apksigner; fi

APP_VERSION="$(app_version)"
APP_BUILD="$(app_build_number)"
[[ -n "$APP_VERSION" && -n "$APP_BUILD" ]] || fatal "Could not read app version/build number from pubspec.yaml"

BADGING="$(aapt dump badging "$APK")" || fatal "aapt could not parse APK manifest/resources"
grep -F "package: name='com.deutschbilarabi.app'" <<<"$BADGING" >/dev/null || fatal "Package ID mismatch"
grep -F "versionCode='$APP_BUILD'" <<<"$BADGING" >/dev/null || fatal "Version code mismatch: expected $APP_BUILD"
grep -F "versionName='$APP_VERSION'" <<<"$BADGING" >/dev/null || fatal "Version name mismatch: expected $APP_VERSION"
grep -F "native-code: 'arm64-v8a'" <<<"$BADGING" >/dev/null || fatal "APK does not advertise arm64-v8a native code"

PERMISSIONS="$(aapt dump permissions "$APK")" || fatal "aapt could not inspect APK permissions"
grep -F "android.permission.RECORD_AUDIO" <<<"$PERMISSIONS" >/dev/null || fatal "Required pronunciation permission is missing from merged APK"
for forbidden_permission in android.permission.INTERNET android.permission.POST_NOTIFICATIONS; do
  if grep -F "$forbidden_permission" <<<"$PERMISSIONS" >/dev/null; then
    fatal "Unexpected release permission in merged APK: $forbidden_permission"
  fi
done

ZIP_LIST="$(unzip -Z1 "$APK")" || fatal "APK is not a readable ZIP archive"
grep -Fx 'AndroidManifest.xml' <<<"$ZIP_LIST" >/dev/null || fatal "AndroidManifest.xml missing"
grep -Fx 'resources.arsc' <<<"$ZIP_LIST" >/dev/null || fatal "resources.arsc missing"
grep -F 'lib/arm64-v8a/' <<<"$ZIP_LIST" >/dev/null || fatal "arm64-v8a native library directory missing"

if [[ "$MODE" == "release" ]]; then
  apksigner verify --verbose "$APK" >/dev/null || fatal "Release APK signature verification failed"
fi

SIZE_BYTES="$(wc -c < "$APK" | tr -d ' ')"
[[ "$SIZE_BYTES" =~ ^[0-9]+$ && "$SIZE_BYTES" -gt 100000 ]] || fatal "APK size is implausibly small: ${SIZE_BYTES} bytes"
SHA256="$(sha256sum "$APK" | awk '{print $1}')"

printf 'APK Verification: PASS\n'
printf 'Package ID: com.deutschbilarabi.app\n'
printf 'Version: %s+%s\n' "$APP_VERSION" "$APP_BUILD"
printf 'ABI: %s\n' "$APK_ABI"
printf 'Manifest: PASS\nResources: PASS\n'
printf 'Signing: %s\n' "$([ "$MODE" = release ] && printf PASS || printf DEBUG-APK)"
printf 'Size: %s bytes\n' "$SIZE_BYTES"
printf 'SHA256: %s\n' "$SHA256"
