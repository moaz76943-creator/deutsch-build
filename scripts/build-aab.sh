#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

log CHECK "Production App Bundle preflight"
"$ROOT/scripts/build_guard.sh"
"$ROOT/scripts/signing_guard.sh"

snapshot_lockfile
flutter pub get --enforce-lockfile
assert_lockfile_unchanged

flutter analyze
flutter test
python3 -m pytest -q tests
python3 tool/security_audit.py
python3 tool/phase17_production_gate.py

SYMBOL_DIR="$ROOT/build/symbols"
flutter build appbundle --release \
  --obfuscate \
  --split-debug-info="$SYMBOL_DIR"

AAB="$ROOT/build/app/outputs/bundle/release/app-release.aab"
[[ -f "$AAB" && -s "$AAB" ]] || fatal "Release AAB was not produced: $AAB"
command -v jarsigner >/dev/null 2>&1 || fatal "jarsigner is required to verify the release AAB signature"
jarsigner -verify -strict "$AAB" >/dev/null

SHA256="$(sha256sum "$AAB" | awk '{print $1}')"
SIZE_BYTES="$(wc -c < "$AAB" | tr -d ' ')"
BUILD_INFO="$ROOT/build/build-info-bundle-release.txt"
{
  printf 'App Version: %s\n' "$(app_version)"
  printf 'Build Number: %s\n' "$(app_build_number)"
  printf 'Build Mode: appbundle-release\n'
  printf 'Git Commit: %s\n' "$(git_commit)"
  printf 'AAB Path: %s\n' "$AAB"
  printf 'AAB Size Bytes: %s\n' "$SIZE_BYTES"
  printf 'SHA256: %s\n' "$SHA256"
  printf 'Dart Obfuscation: enabled\n'
  printf 'Split Debug Info: %s\n' "$SYMBOL_DIR"
} > "$BUILD_INFO"

log OK "Production App Bundle ready"
printf 'AAB: %s\nSHA256: %s\n' "$AAB" "$SHA256"
