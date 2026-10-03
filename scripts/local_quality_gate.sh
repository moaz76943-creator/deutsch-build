#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

log CHECK "Canonical local quality gate"
snapshot_lockfile

log CHECK "Locked Flutter dependencies"
flutter pub get --enforce-lockfile
assert_lockfile_unchanged

log TEST "Python regression suite"
python3 -m pytest -q tests

log CHECK "Build-path and Gradle integrity"
python3 tool/v233_build_path_compatibility.py
python3 tool/gradle_wrapper_integrity.py

log CHECK "Security, privacy, quality and architecture audits"
python3 tool/security_audit.py
python3 tool/privacy_audit.py
python3 tool/quality_audit.py
python3 tool/accessibility_audit.py
python3 tool/architecture_audit.py
python3 tool/weakness_gate.py
python3 tool/phase17_production_gate.py

log CHECK "Content pack and ingestion contracts"
python3 tool/content_pack.py validate
python3 tool/content_ingestion.py validate

TMP_DIR="$(mktemp -d)"
cleanup_tmp() {
  python3 - "$TMP_DIR" <<'PY'
from pathlib import Path
import shutil
import sys

shutil.rmtree(Path(sys.argv[1]), ignore_errors=True)
PY
}
trap cleanup_tmp EXIT

log CHECK "Canonical content compilation and parity"
python3 tool/content_compiler.py compile --output-dir "$TMP_DIR/generated"
python3 tool/content_compiler.py parity --output-dir "$TMP_DIR/generated"

log CHECK "Materialize Flutter runtime content"
python3 tool/content_compiler.py compile --output-dir lib/data/generated

log TEST "Flutter analyze"
flutter analyze

log TEST "Flutter tests"
flutter test

assert_lockfile_unchanged
log OK "LOCAL QUALITY GATE: PASS"
