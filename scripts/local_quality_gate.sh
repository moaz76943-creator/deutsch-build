#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$ROOT/scripts/common.sh"
load_toolchain
cd "$ROOT"

SKIP_FLUTTER_CHECK="${SKIP_FLUTTER_CHECK:-0}"
RUN_LEGACY_TEXT_REGRESSIONS="${RUN_LEGACY_TEXT_REGRESSIONS:-0}"
ACTIVE_PYTHON_TESTS=("$ROOT/tests/quality_gate")
while IFS= read -r contract; do
  ACTIVE_PYTHON_TESTS+=("$contract")
done < <(
  find "$ROOT/tests" -maxdepth 1 -type f \
    -name 'test_*_adaptive_glass_contract.py' \
    -print | LC_ALL=C sort
)

log CHECK "Canonical self-healing quality gate"
snapshot_lockfile

if [[ "$SKIP_FLUTTER_CHECK" == "1" ]]; then
  log SKIP "Flutter SDK checks disabled by SKIP_FLUTTER_CHECK=1"
else
  log CHECK "Locked Flutter dependencies"
  flutter pub get --enforce-lockfile
  assert_lockfile_unchanged
fi

CANONICAL_SECURITY_GATE="$ROOT/tests/quality_gate/test_current_topology_security_gate.py"

log TEST "Canonical current-topology security gate"
python3 -m pytest -q "$CANONICAL_SECURITY_GATE"

log TEST "Active semantic Python contracts"
python3 -m pytest -q "${ACTIVE_PYTHON_TESTS[@]}" --ignore="$CANONICAL_SECURITY_GATE"

log CHECK "Gradle wrapper integrity"
python3 tool/gradle_wrapper_integrity.py

log CHECK "Content pack and ingestion contracts"
python3 tool/content_pack.py validate
python3 tool/content_ingestion.py validate

log CHECK "Licensed media manifest contract"
python3 tools/agents/asset_pipeline_agent.py \
  --repo-root "$ROOT" \
  --manifest assets/media/assets_manifest.json \
  --verify-only

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

if [[ "$SKIP_FLUTTER_CHECK" == "1" ]]; then
  log SKIP "Dart analyzer and Flutter behavioral tests skipped because Flutter SDK is unavailable"
else
  log TEST "Dart application analyzer (lib/ errors only)"
  bash "$ROOT/scripts/check-dart-errors.sh"

  if is_termux; then
    log SKIP "Flutter behavioral tests skipped on Termux/Android Bionic because Linux flutter_tester is not ABI-compatible"

    PURE_DART_TESTS=()
    while IFS= read -r dart_test; do
      if grep -q "package:test/test.dart" "$dart_test" \
          && ! grep -Eq "package:flutter_test/|package:flutter/|dart:ui" "$dart_test"; then
        PURE_DART_TESTS+=("$dart_test")
      fi
    done < <(
      find "$ROOT/test" -maxdepth 3 -type f -name '*_test.dart' -print | LC_ALL=C sort
    )

    if (( ${#PURE_DART_TESTS[@]} > 0 )); then
      log TEST "Pure Dart behavioral tests (Termux-native Dart VM)"
      dart test "${PURE_DART_TESTS[@]}"
    else
      log SKIP "No pure package:test Dart tests are currently present; Flutter-engine tests remain required on a compatible non-Termux runner"
    fi
  else
    log TEST "Flutter behavioral tests"
    flutter test
  fi
fi

if [[ "$RUN_LEGACY_TEXT_REGRESSIONS" == "1" ]]; then
  log TEST "Historical lexical regression suite (opt-in, non-canonical)"
  python3 -m pytest -q tests --ignore=tests/quality_gate

  log CHECK "Historical source-contract audits (opt-in, non-canonical)"
  python3 tool/v233_build_path_compatibility.py
  python3 tool/security_audit.py
  python3 tool/privacy_audit.py
  python3 tool/quality_audit.py
  python3 tool/accessibility_audit.py
  python3 tool/architecture_audit.py
  python3 tools/zero_drift_check.py --repo-root "$ROOT"
  python3 tool/weakness_gate.py
  python3 tool/phase17_production_gate.py
else
  log SKIP "Historical lexical/source-contract checks are non-blocking; set RUN_LEGACY_TEXT_REGRESSIONS=1 to run them explicitly"
fi

assert_lockfile_unchanged
log OK "LOCAL QUALITY GATE: PASS"
