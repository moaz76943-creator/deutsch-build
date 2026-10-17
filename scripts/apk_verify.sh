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
<<<<<<< HEAD
[[ -n "$APK" ]] || fatal --code "$ERR_ENV" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || fatal --code "$ERR_ENV" "Build mode must be debug or release"
[[ -z "$SIGNING_MODE" || "$SIGNING_MODE" == "--ephemeral" ]] || fatal --code "$ERR_ENV" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ -f "$APK" ]] || fatal --code "$ERR_VERIFY" "APK does not exist: $APK"
[[ -s "$APK" ]] || fatal --code "$ERR_VERIFY" "APK is empty: $APK"

need() { command -v "$1" >/dev/null 2>&1 || fatal --code "$ERR_ENV" "Required APK verification tool is missing: $1"; }
=======
[[ -n "$APK" ]] || fatal "$ERR_ARTIFACT" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ "$MODE" == "debug" || "$MODE" == "release" ]] || fatal "$ERR_ARTIFACT" "Build mode must be debug or release"
[[ -z "$SIGNING_MODE" || "$SIGNING_MODE" == "--ephemeral" ]] || fatal "$ERR_ARTIFACT" "Usage: ./scripts/apk_verify.sh <apk> <debug|release> [--ephemeral]"
[[ -f "$APK" ]] || fatal "$ERR_ARTIFACT" "APK does not exist: $APK"
[[ -s "$APK" ]] || fatal "$ERR_ARTIFACT" "APK is empty: $APK"

need() { command -v "$1" >/dev/null 2>&1 || fatal "$ERR_ARTIFACT" "Required APK verification tool is missing: $1"; }
>>>>>>> pr-61
need unzip
need sha256sum
need aapt
if [[ "$MODE" == "release" ]]; then need apksigner; fi

APP_VERSION="$(app_version)"
APP_BUILD="$(app_build_number)"
<<<<<<< HEAD
[[ -n "$APP_VERSION" && -n "$APP_BUILD" ]] || fatal --code "$ERR_ENV" "Could not read app version/build number from pubspec.yaml"

BADGING="$(aapt dump badging "$APK")" || fatal --code "$ERR_VERIFY" "aapt could not parse APK manifest/resources"
grep -F "package: name='com.deutschbilarabi.app'" <<<"$BADGING" >/dev/null || fatal --code "$ERR_VERIFY" "Package ID mismatch"
grep -F "versionCode='$APP_BUILD'" <<<"$BADGING" >/dev/null || fatal --code "$ERR_VERIFY" "Version code mismatch: expected $APP_BUILD"
grep -F "versionName='$APP_VERSION'" <<<"$BADGING" >/dev/null || fatal --code "$ERR_VERIFY" "Version name mismatch: expected $APP_VERSION"
APK_ABI="arm64-v8a"
grep -F "native-code: '$APK_ABI'" <<<"$BADGING" >/dev/null || fatal --code "$ERR_VERIFY" "APK does not advertise $APK_ABI native code"

<<<<<<< HEAD
PERMISSIONS="$(aapt dump permissions "$APK")" || fatal --code "$ERR_VERIFY" "aapt could not inspect APK permissions"
grep -F "android.permission.RECORD_AUDIO" <<<"$PERMISSIONS" >/dev/null || fatal --code "$ERR_VERIFY" "Required pronunciation permission is missing from merged APK"
=======
[[ -n "$APP_VERSION" && -n "$APP_BUILD" ]] || fatal "$ERR_ARTIFACT" "Could not read app version/build number from pubspec.yaml"

BADGING="$(aapt dump badging "$APK")" || fatal "$ERR_ARTIFACT" "aapt could not parse APK manifest/resources"
grep -F "package: name='com.deutschbilarabi.app'" <<<"$BADGING" >/dev/null || fatal "$ERR_ARTIFACT" "Package ID mismatch"
grep -F "versionCode='$APP_BUILD'" <<<"$BADGING" >/dev/null || fatal "$ERR_ARTIFACT" "Version code mismatch: expected $APP_BUILD"
grep -F "versionName='$APP_VERSION'" <<<"$BADGING" >/dev/null || fatal "$ERR_ARTIFACT" "Version name mismatch: expected $APP_VERSION"
APK_ABI="arm64-v8a"
grep -F "native-code: '$APK_ABI'" <<<"$BADGING" >/dev/null || fatal "$ERR_ARTIFACT" "APK does not advertise $APK_ABI native code"

<<<<<<< HEAD
PERMISSIONS="$(aapt dump permissions "$APK")" || fatal "$ERR_ARTIFACT" "aapt could not inspect APK permissions"
grep -F "android.permission.RECORD_AUDIO" <<<"$PERMISSIONS" >/dev/null || fatal "$ERR_ARTIFACT" "Required pronunciation permission is missing from merged APK"
>>>>>>> pr-61
=======
PERMISSIONS="$(aapt dump permissions "$APK")" || fatal "aapt could not inspect APK permissions"
grep -F "android.permission.RECORD_AUDIO" <<<"$PERMISSIONS" >/dev/null || fatal "Required pronunciation permission is missing from merged APK"
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
for forbidden_permission in \
  android.permission.INTERNET \
  android.permission.ACCESS_NETWORK_STATE \
  android.permission.CHANGE_NETWORK_STATE \
  android.permission.ACCESS_WIFI_STATE \
  android.permission.CHANGE_WIFI_STATE \
  android.permission.POST_NOTIFICATIONS; do
  if [[ "$MODE" == release ]] && grep -F "$forbidden_permission" <<<"$PERMISSIONS" >/dev/null; then
<<<<<<< HEAD
<<<<<<< HEAD
    fatal --code "$ERR_VERIFY" "Unexpected release permission in merged APK: $forbidden_permission"
  fi
done
=======
PERMISSIONS="$(aapt dump permissions "$APK")" || fatal "$ERR_ARTIFACT" "aapt could not inspect APK permissions"
printf '%s\n' "$PERMISSIONS" | bash "$ROOT/scripts/check_apk_permissions.sh" "$MODE" || fatal "$ERR_ARTIFACT" "Release APK permission policy failed"
>>>>>>> pr-179
=======
    fatal "Unexpected release permission in merged APK: $forbidden_permission"
  fi
done
>>>>>>> origin/staging/v2-full-platform-1792367411258400957

ZIP_LIST="$(unzip -Z1 "$APK")" || fatal --code "$ERR_VERIFY" "APK is not a readable ZIP archive"
grep -Fx 'AndroidManifest.xml' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "AndroidManifest.xml missing"
grep -Fx 'resources.arsc' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "resources.arsc missing"
grep -F 'lib/arm64-v8a/' <<<"$ZIP_LIST" >/dev/null || fatal --code "$ERR_VERIFY" "arm64-v8a native library directory missing"
=======
    fatal "$ERR_ARTIFACT" "Unexpected release permission in merged APK: $forbidden_permission"
  fi
done

ZIP_LIST="$(unzip -Z1 "$APK")" || fatal "$ERR_ARTIFACT" "APK is not a readable ZIP archive"
grep -Fx 'AndroidManifest.xml' <<<"$ZIP_LIST" >/dev/null || fatal "$ERR_ARTIFACT" "AndroidManifest.xml missing"
grep -Fx 'resources.arsc' <<<"$ZIP_LIST" >/dev/null || fatal "$ERR_ARTIFACT" "resources.arsc missing"
grep -F 'lib/arm64-v8a/' <<<"$ZIP_LIST" >/dev/null || fatal "$ERR_ARTIFACT" "arm64-v8a native library directory missing"
>>>>>>> pr-61
python3 - "$APK" "$MODE" <<'PY'
import struct
import sys
import zipfile

with zipfile.ZipFile(sys.argv[1]) as apk:
    native = [name for name in apk.namelist() if name.startswith('lib/') and name.endswith('.so')]
    if not native or any(name.split('/')[1] != 'arm64-v8a' for name in native):
        sys.exit(16)
    library = 'libapp.so' if sys.argv[2] == 'release' else 'libflutter.so'
    data = apk.read('lib/arm64-v8a/' + library)
    if data[:6] != b'\x7fELF\x02\x01' or struct.unpack_from('<H', data, 18)[0] != 183:
        sys.exit(16)
    if sys.argv[2] == 'release':
        offset = struct.unpack_from('<Q', data, 40)[0]
        size, count, names_index = struct.unpack_from('<HHH', data, 58)
        if size < 64 or names_index >= count or offset + size * count > len(data):
            sys.exit(16)
        start, length = struct.unpack_from('<QQ', data, offset + size * names_index + 24)
        names = data[start:start+length]
        for index in range(count):
            name_offset = struct.unpack_from('<I', data, offset + index * size)[0]
            name = names[name_offset:].split(b'\0', 1)[0]
            if name.startswith((b'.debug_', b'.zdebug_')):
                sys.exit(16)
PY

if [[ "$MODE" == "release" ]]; then
<<<<<<< HEAD
  CERT_INFO="$(apksigner verify --verbose --print-certs "$APK")" || fatal --code "$ERR_VERIFY" "Release APK signature verification failed"
=======
  CERT_INFO="$(apksigner verify --verbose --print-certs "$APK")" || fatal "$ERR_ARTIFACT" "Release APK signature verification failed"
>>>>>>> pr-61
  signing_args=(--fingerprint)
  if [[ "$SIGNING_MODE" == "--ephemeral" ]]; then
    signing_args+=(--ephemeral)
  fi
<<<<<<< HEAD
  EXPECTED_CERT="$(python3 "$ROOT/tool/release_signing.py" "${signing_args[@]}")" || fatal --code "$ERR_SIGN" "Could not verify expected production signing certificate"
  grep -Fi "certificate SHA-256 digest: $EXPECTED_CERT" <<<"$CERT_INFO" >/dev/null || fatal --code "$ERR_VERIFY" "APK certificate differs from the configured release identity"
fi

SIZE_BYTES="$(wc -c < "$APK" | tr -d ' ')"
[[ "$SIZE_BYTES" =~ ^[0-9]+$ && "$SIZE_BYTES" -gt 100000 ]] || fatal --code "$ERR_VERIFY" "APK size is implausibly small: ${SIZE_BYTES} bytes"
=======
  EXPECTED_CERT="$(python3 "$ROOT/tool/release_signing.py" "${signing_args[@]}")" || fatal "$ERR_ARTIFACT" "Could not verify expected production signing certificate"
  grep -Fi "certificate SHA-256 digest: $EXPECTED_CERT" <<<"$CERT_INFO" >/dev/null || fatal "$ERR_ARTIFACT" "APK certificate differs from the configured release identity"
fi

SIZE_BYTES="$(wc -c < "$APK" | tr -d ' ')"
[[ "$SIZE_BYTES" =~ ^[0-9]+$ && "$SIZE_BYTES" -gt 100000 ]] || fatal "$ERR_ARTIFACT" "APK size is implausibly small: ${SIZE_BYTES} bytes"
>>>>>>> pr-61
SHA256="$(sha256sum "$APK" | awk '{print $1}')"

printf 'APK Verification: PASS\n'
printf 'Package ID: com.deutschbilarabi.app\n'
printf 'Version: %s+%s\n' "$APP_VERSION" "$APP_BUILD"
printf 'ABI: %s\n' "$APK_ABI"
printf 'Manifest: PASS\nResources: PASS\n'
printf 'Signing: %s\n' "$([ "$MODE" = release ] && printf PASS || printf DEBUG-APK)"
printf 'Size: %s bytes\n' "$SIZE_BYTES"
printf 'SHA256: %s\n' "$SHA256"
