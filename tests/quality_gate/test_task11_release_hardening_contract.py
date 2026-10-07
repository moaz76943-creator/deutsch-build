from __future__ import annotations

import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
TASK11 = ROOT / "tool" / "task11_release_hardening.py"
CONTRACT = ROOT / "tool" / "task11_release_contract.json"
LOCAL_RELEASE = ROOT / "scripts" / "local-release.sh"
APK_VERIFY = ROOT / "scripts" / "apk_verify.sh"

FORBIDDEN_RELEASE_PERMISSIONS = {
    "android.permission.INTERNET",
    "android.permission.ACCESS_NETWORK_STATE",
    "android.permission.CHANGE_NETWORK_STATE",
    "android.permission.ACCESS_WIFI_STATE",
    "android.permission.CHANGE_WIFI_STATE",
    "android.permission.POST_NOTIFICATIONS",
}


def test_task11_release_integrity_gate_passes():
    result = subprocess.run(
        [sys.executable, str(TASK11), "check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )
    assert result.returncode == 0, result.stderr or result.stdout
    assert "TASK 11 RELEASE HARDENING: PASS" in result.stdout
    assert "OFFLINE_BOUNDARY: PASS" in result.stdout
    assert "SCHEMA_INTEGRITY: PASS" in result.stdout
    assert "RELEASE_GATES: PASS" in result.stdout


def test_task11_contract_pins_schema_versions_and_offline_policy():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    assert contract["schema_version"] == 1
    assert contract["baseline_main"] == "007fbc8e8e06d5c5fdc3af92fbbc806e57997167"
    assert contract["allowed_main_permissions"] == [
        "android.permission.RECORD_AUDIO",
    ]
    assert set(contract["forbidden_release_permissions"]) == (
        FORBIDDEN_RELEASE_PERMISSIONS
    )
    assert contract["database_schemas"] == {
        "lib/core/storage/local_db/learner_state_database.dart": 1,
        "lib/features/gamification/sqlite_gamification_repository.dart": 4,
    }


def test_release_build_cannot_skip_quality_gate():
    text = LOCAL_RELEASE.read_text(encoding="utf-8")
    assert 'if [[ "$MODE" == "release" || "$VERIFY" == true ]]; then' in text
    assert 'bash "$ROOT/scripts/local_quality_gate.sh"' in text


def test_apk_verifier_is_fail_closed_for_network_permissions_and_abi():
    text = APK_VERIFY.read_text(encoding="utf-8")
    for permission in FORBIDDEN_RELEASE_PERMISSIONS:
        assert permission in text
    assert 'APK_ABI="arm64-v8a"' in text
    assert 'printf \'ABI: %s\\n\' "$APK_ABI"' in text


def test_task11_modified_surfaces_stay_bounded():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    for relative_path in contract["bounded_files"]:
        path = ROOT / relative_path
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
