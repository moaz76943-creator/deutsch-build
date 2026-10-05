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

log CHECK "Canonical local quality gate"
snapshot_lockfile

if [[ "$SKIP_FLUTTER_CHECK" == "1" ]]; then
  log SKIP "Flutter SDK checks disabled by SKIP_FLUTTER_CHECK=1"
else
  log CHECK "Locked Flutter dependencies"
  flutter pub get --enforce-lockfile
  assert_lockfile_unchanged
fi

log CHECK "Offline-first Android permission boundary"
MANIFEST="$ROOT/android/app/src/main/AndroidManifest.xml"
if grep -Fq "android.permission.INTERNET" "$MANIFEST"; then
  fatal "Offline-first release must not request android.permission.INTERNET"
fi
log OK "Android INTERNET permission is absent"

ADAPTIVE_GLASS_CONTRACTS=(
  tests/test_grammar_adaptive_glass_contract.py
  tests/test_settings_profile_adaptive_glass_contract.py
  tests/test_srs_review_hub_adaptive_glass_contract.py
  tests/test_stories_dialogue_adaptive_glass_contract.py
  tests/test_vocabulary_adaptive_glass_contract.py
)

log TEST "Active Adaptive Glass contracts"
python3 -m pytest -q "${ADAPTIVE_GLASS_CONTRACTS[@]}"

if [[ "$RUN_LEGACY_TEXT_REGRESSIONS" == "1" ]]; then
  log TEST "Historical lexical regression suite (opt-in)"
  python3 -m pytest -q tests
else
  log SKIP "Historical lexical regression suite isolated from the canonical gate; set RUN_LEGACY_TEXT_REGRESSIONS=1 to run it explicitly"
fi

log CHECK "Build-path and Gradle integrity"
python3 tool/v233_build_path_compatibility.py
python3 tool/gradle_wrapper_integrity.py

log CHECK "Security, privacy, quality and architecture audits"
python3 tool/security_audit.py
python3 tool/privacy_audit.py
python3 tool/quality_audit.py
python3 tool/accessibility_audit.py
python3 tool/architecture_audit.py
python3 tools/zero_drift_check.py --repo-root "$ROOT"
python3 tool/weakness_gate.py
python3 tool/phase17_production_gate.py

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
  log SKIP "Dart analyzer and Flutter tests skipped because Flutter SDK is unavailable"
else
  log TEST "Dart application analyzer (lib/ errors only)"
  command -v dart >/dev/null 2>&1 || fatal "Dart executable is unavailable"
  set +e
  ANALYZER_OUTPUT="$(dart analyze lib/ 2>&1)"
  ANALYZER_STATUS=$?
  ANALYZER_ERRORS="$(printf '%s\n' "$ANALYZER_OUTPUT" | grep "error •")"
  set -e
  printf '%s\n' "$ANALYZER_OUTPUT"
  if [[ -n "$ANALYZER_ERRORS" ]]; then
    fatal "Dart analyzer found blocking errors in lib/"
  fi
  if [[ "$ANALYZER_STATUS" == "127" ]]; then
    fatal "Dart analyzer could not be executed"
  fi
  log OK "Dart analyzer: 0 blocking errors in lib/"

  log TEST "Flutter tests"
  flutter test
fi

assert_lockfile_unchanged
log OK "LOCAL QUALITY GATE: PASS"
