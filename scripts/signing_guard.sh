#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain

[[ -n "${ORG_GRADLE_PROJECT_releaseStoreFile:-}" ]] || fatal "Release signing is not configured: ORG_GRADLE_PROJECT_releaseStoreFile is missing"
[[ -n "${ORG_GRADLE_PROJECT_releaseStorePassword:-}" ]] || fatal "Release signing is not configured: store password is missing"
[[ -n "${ORG_GRADLE_PROJECT_releaseKeyAlias:-}" ]] || fatal "Release signing is not configured: key alias is missing"
[[ -n "${ORG_GRADLE_PROJECT_releaseKeyPassword:-}" ]] || fatal "Release signing is not configured: key password is missing"
[[ -f "$ROOT/${ORG_GRADLE_PROJECT_releaseStoreFile}" || -f "${ORG_GRADLE_PROJECT_releaseStoreFile}" ]] || fatal "Release keystore file was not found"
grep -F 'secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "secureRelease signing config is missing"
grep -F 'signingConfig signingConfigs.secureRelease' "$ROOT/android/app/build.gradle" >/dev/null || fatal "Release build is not bound to secureRelease signing"
log OK "Release signing contract verified"
