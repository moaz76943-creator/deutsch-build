#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash "$ROOT/scripts/local_quality_gate.sh"

"$ROOT/scripts/signing_guard.sh"
flutter build apk --release --obfuscate --split-debug-info=build/symbols
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

python3 tool/verify.py release --report "docs/V374_RELEASE_VERIFICATION.json"
