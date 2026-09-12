#!/usr/bin/env bash
set -Eeuo pipefail

# Legacy host bootstrap retained for non-Termux CI/local hosts.
# Termux users must use the repository root install_flutter.sh.
if [[ "${PREFIX:-}" == /data/data/*/files/usr ]]; then
  exec "$(cd "$(dirname "$0")/.." && pwd)/install_flutter.sh" "$@"
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/toolchain.lock"
FLUTTER_VERSION="$FLUTTER_VERSION"
ANDROID_API="$ANDROID_COMPILE_SDK"
FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}"

command -v git >/dev/null 2>&1 || { echo "ERROR: git is required" >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "ERROR: curl is required" >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "ERROR: unzip is required" >&2; exit 1; }

mkdir -p "$ANDROID_SDK_ROOT/cmdline-tools"
if [[ ! -x "$FLUTTER_ROOT/bin/flutter" ]]; then
  [[ -e "$FLUTTER_ROOT" ]] && { echo "ERROR: $FLUTTER_ROOT exists but is not a valid Flutter install; refusing to delete it." >&2; exit 1; }
  git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_ROOT"
fi
export PATH="$FLUTTER_ROOT/bin:$FLUTTER_ROOT/bin/cache/dart-sdk/bin:$PATH"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
flutter --version
 dart --version
