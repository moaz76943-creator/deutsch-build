#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 -m pytest -q tests
python3 tool/quality_audit.py
python3 tool/security_audit.py
python3 tool/privacy_audit.py
python3 tool/accessibility_audit.py
python3 tool/architecture_audit.py
python3 tool/weakness_gate.py
python3 tool/content_pack.py validate
python3 tool/content_ingestion.py validate
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
python3 tool/content_compiler.py compile --output-dir "$TMP_DIR/generated"
python3 tool/content_compiler.py parity --output-dir "$TMP_DIR/generated"

# Full Flutter/Android checks are mandatory when the toolchain is available.
if command -v flutter >/dev/null 2>&1; then
  flutter analyze
  flutter test
  flutter build apk --release
else
  echo "BUILD VERIFICATION: Flutter/Android toolchain unavailable in this environment" >&2
  exit 2
fi

python3 tool/verify.py release --report "docs/V374_RELEASE_VERIFICATION.json"
