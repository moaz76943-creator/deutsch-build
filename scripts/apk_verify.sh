#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

APK="${1:-}"
MODE="${2:-release}"
SIGNING_MODE="${3:-}"
[[ -n "$APK" ]] || fatal --code "$ERR_ENV" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || fatal --code "$ERR_ENV" "Build mode must be debug or release"
[[ -z "$SIGNING_MODE" || "$SIGNING_MODE" == "--ephemeral" ]] || fatal --code "$ERR_ENV" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ -f "$APK" ]] || fatal --code "$ERR_VERIFY" "APK does not exist: $APK"
[[ -s "$APK" ]] || fatal --code "$ERR_VERIFY" "APK is empty: $APK"

need() { command -v "$1" >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Required APK verification tool is missing: $1"; }
need unzip
need sha256sum
need aapt
if [[ "$MODE" == "release" ]]; then need apksigner; fi

APP_VERSION="$(app_version)"
APP_BUILD="$(app_build_number)"
[[ -n "$APP_VERSION" && -n "$APP_BUILD" ]] || fatal --code "$ERR_ENV" "Could not read app version/build number from pubspec.yaml"

BADGING="$(aapt dump badging "$APK")" || fatal "aapt could not parse APK manifest/resources"
grep -F "package: name='com.deutschbilarabi.app'" <<<"$BADGING" >/dev/null || fatal "Package ID mismatch"
grep -F "versionCode='$APP_BUILD'" <<<"$BADGING" >/dev/null || fatal "Version code mismatch: expected $APP_BUILD"
grep -F "versionName='$APP_VERSION'" <<<"$BADGING" >/dev/null || fatal "Version name mismatch: expected $APP_VERSION"
APK_ABI="arm64-v8a"
grep -F "native-code: '$APK_ABI'" <<<"$BADGING" >/dev/null || fatal "APK does not advertise $APK_ABI native code"

PERMISSIONS="$(aapt dump permissions "$APK")" || fatal --code "$ERR_VERIFY" "aapt could not inspect APK permissions"
grep -F "android.permission.RECORD_AUDIO" <<<"$PERMISSIONS" >/dev/null || fatal --code "$ERR_VERIFY" "Required pronunciation permission is missing from merged APK"
for forbidden_permission in \
  android.permission.INTERNET \
  android.permission.ACCESS_NETWORK_STATE \
  android.permission.CHANGE_NETWORK_STATE \
  android.permission.ACCESS_WIFI_STATE \
  android.permission.CHANGE_WIFI_STATE \
  android.permission.POST_NOTIFICATIONS; do
  if [[ "$MODE" == release ]] && grep -F "$forbidden_permission" <<<"$PERMISSIONS" >/dev/null; then
    fatal --code "$ERR_VERIFY" "Unexpected release permission in merged APK: $forbidden_permission"
  fi
done

ZIP_LIST="$(unzip -Z1 "$APK")" || fatal --code "$ERR_VERIFY" "APK is not a readable ZIP archive"
grep -Fx 'AndroidManifest.xml' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "AndroidManifest.xml missing"
grep -Fx 'resources.arsc' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "resources.arsc missing"
grep -F 'lib/arm64-v8a/' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "arm64-v8a native library directory missing"
python3 - "$APK" "$MODE" <<'PY'
import struct
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as apk:
    native = [name for name in apk.namelist() if name.startswith('lib/') and name.endswith('.so')]
    if not native or any(name.split('/')[1] != 'arm64-v8a' for name in native):
        raise SystemExit('APK must contain only ARM64 native libraries')
    library = 'libapp.so' if sys.argv[2] == 'release' else 'libflutter.so'
    data = apk.read('lib/arm64-v8a/' + library)
    if data[:6] != b'\x7fELF\x02\x01' or struct.unpack_from('<H', data, 18)[0] != 183:
        raise SystemExit('Dart AOT library is not a little-endian ARM64 ELF')
    if sys.argv[2] == 'release':
        offset = struct.unpack_from('<Q', data, 40)[0]
        size, count, names_index = struct.unpack_from('<HHH', data, 58)
        if size < 64 or names_index >= count or offset + size * count > len(data):
            raise SystemExit('Dart AOT ELF section table is malformed')
        start, length = struct.unpack_from('<QQ', data, offset + size * names_index + 24)
        names = data[start:start+length]
        for index in range(count):
            name_offset = struct.unpack_from('<I', data, offset + index * size)[0]
            name = names[name_offset:].split(b'\0', 1)[0]
            if name.startswith((b'.debug_', b'.zdebug_')):
                raise SystemExit('Release Dart AOT contains unstripped DWARF; use the release entrypoint')
PY

if [[ "$MODE" == "release" ]]; then
  CERT_INFO="$(apksigner verify --verbose --print-certs "$APK")" || fatal --code "$ERR_VERIFY" "Release APK signature verification failed"
  signing_args=(--fingerprint)
  if [[ "$SIGNING_MODE" == "--ephemeral" ]]; then
    signing_args+=(--ephemeral)
  fi
  EXPECTED_CERT="$(python3 "$ROOT/tool/release_signing.py" "${signing_args[@]}")" || fatal --code "$ERR_SIGN" "Could not verify expected production signing certificate"
  grep -Fi "certificate SHA-256 digest: $EXPECTED_CERT" <<<"$CERT_INFO" >/dev/null || fatal --code "$ERR_VERIFY" "APK certificate differs from the configured release identity"
fi

SIZE_BYTES="$(wc -c < "$APK" | tr -d ' ')"
[[ "$SIZE_BYTES" =~ ^[0-9]+$ && "$SIZE_BYTES" -gt 100000 ]] || fatal --code "$ERR_VERIFY" "APK size is implausibly small: ${SIZE_BYTES} bytes"
SHA256="$(sha256sum "$APK" | awk '{print $1}')"

printf 'APK Verification: PASS\n'
printf 'Package ID: com.deutschbilarabi.app\n'
printf 'Version: %s+%s\n' "$APP_VERSION" "$APP_BUILD"
printf 'ABI: %s\n' "$APK_ABI"
printf 'Manifest: PASS\nResources: PASS\n'
printf 'Signing: %s\n' "$([ "$MODE" = release ] && printf PASS || printf DEBUG-APK)"
printf 'Size: %s bytes\n' "$SIZE_BYTES"
printf 'SHA256: %s\n' "$SHA256"
