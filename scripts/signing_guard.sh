#!/usr/bin/env bash
set +x
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

SIGNING_ARGS=()
case "${1:-}" in
  --ephemeral)
    SIGNING_ARGS=(--ephemeral)
    shift
    ;;
  "")
    ;;
  *)
<<<<<<< HEAD
    fatal --code "$ERR_ENV" "Usage: ./scripts/signing_guard.sh [--ephemeral]"
    ;;
esac
[[ "$#" -eq 0 ]] || fatal --code "$ERR_ENV" "Usage: ./scripts/signing_guard.sh [--ephemeral]"

# shellcheck disable=SC1091
source "$ROOT/scripts/release-signing.sh"
<<<<<<< HEAD
check_release_signing "${SIGNING_ARGS[@]}" || fatal --code "$ERR_SIGN" "Run bash scripts/local-release.sh to prepare local signing."
grep -F 'secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal --code "$ERR_SIGN" "secureRelease signing config is missing"
grep -F 'signingConfig signingConfigs.secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal --code "$ERR_SIGN" "Release build is not bound to secureRelease signing"
! grep -F 'signingConfigs.debug' "$ROOT/android/app/build.gradle" >/dev/null || fatal --code "$ERR_SIGN" "Release signing must never fall back to the debug keystore"
=======
    fatal "$ERR_SIGN" "Usage: ./scripts/signing_guard.sh [--ephemeral]"
    ;;
esac
[[ "$#" -eq 0 ]] || fatal "$ERR_SIGN" "Usage: ./scripts/signing_guard.sh [--ephemeral]"

# shellcheck disable=SC1091
source "$ROOT/scripts/release-signing.sh"
check_release_signing "${SIGNING_ARGS[@]}" || fatal "$ERR_SIGN" "Run bash scripts/local-release.sh to prepare local signing."
grep -F 'secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "$ERR_SIGN" "secureRelease signing config is missing"
grep -F 'signingConfig signingConfigs.secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "$ERR_SIGN" "Release build is not bound to secureRelease signing"
! grep -F 'signingConfigs.debug' "$ROOT/android/app/build.gradle" >/dev/null || fatal "$ERR_SIGN" "Release signing must never fall back to the debug keystore"
>>>>>>> pr-61
=======
check_release_signing "${SIGNING_ARGS[@]}" || fatal "Run bash scripts/local-release.sh to prepare local signing." "$EXIT_SIGN"
grep -F 'secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "secureRelease signing config is missing" "$EXIT_SIGN"
grep -F 'signingConfig signingConfigs.secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "Release build is not bound to secureRelease signing" "$EXIT_SIGN"
! grep -F 'signingConfigs.debug' "$ROOT/android/app/build.gradle" >/dev/null || fatal "Release signing must never fall back to the debug keystore" "$EXIT_SIGN"
>>>>>>> pr-188
log OK "Android release signing contract verified"

if [[ -d "$ROOT/ios" ]]; then
  PBXPROJ="$ROOT/ios/Runner.xcodeproj/project.pbxproj"
<<<<<<< HEAD
<<<<<<< HEAD
  [[ -f "$PBXPROJ" ]] || fatal --code "$ERR_ENV" "iOS platform exists but Runner.xcodeproj/project.pbxproj is missing"
  grep -F 'CODE_SIGN_STYLE' "$PBXPROJ" >/dev/null || fatal --code "$ERR_SIGN" "iOS code-sign style is not configured"
  grep -F 'PRODUCT_BUNDLE_IDENTIFIER' "$PBXPROJ" >/dev/null || fatal --code "$ERR_SIGN" "iOS bundle identifier is not configured"
=======
  [[ -f "$PBXPROJ" ]] || fatal "$ERR_SIGN" "iOS platform exists but Runner.xcodeproj/project.pbxproj is missing"
  grep -F 'CODE_SIGN_STYLE' "$PBXPROJ" >/dev/null || fatal "$ERR_SIGN" "iOS code-sign style is not configured"
  grep -F 'PRODUCT_BUNDLE_IDENTIFIER' "$PBXPROJ" >/dev/null || fatal "$ERR_SIGN" "iOS bundle identifier is not configured"
>>>>>>> pr-61
=======
  [[ -f "$PBXPROJ" ]] || fatal "iOS platform exists but Runner.xcodeproj/project.pbxproj is missing" "$EXIT_SIGN"
  grep -F 'CODE_SIGN_STYLE' "$PBXPROJ" >/dev/null || fatal "iOS code-sign style is not configured" "$EXIT_SIGN"
  grep -F 'PRODUCT_BUNDLE_IDENTIFIER' "$PBXPROJ" >/dev/null || fatal "iOS bundle identifier is not configured" "$EXIT_SIGN"
>>>>>>> pr-188
  log OK "iOS production signing configuration is present"
else
  log OK "iOS signing check: NOT_APPLICABLE (no ios/ platform directory in this Android project)"
fi
