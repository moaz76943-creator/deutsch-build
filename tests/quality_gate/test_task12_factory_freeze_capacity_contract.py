from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tool" / "task12_factory_freeze.py"
CONTRACT = ROOT / "tool" / "task12_factory_freeze.json"


def _load_module():
    spec = importlib.util.spec_from_file_location("task12_factory_freeze", TOOL)
    assert spec is not None and spec.loader is not None
    module = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = module
    spec.loader.exec_module(module)
    return module


def test_task12_freeze_contract_verifies_current_interfaces():
    result = subprocess.run(
        [sys.executable, str(TOOL), "check"],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
        timeout=30,
    )
    assert result.returncode == 0, result.stderr or result.stdout
    assert "TASK 12 FACTORY FREEZE: PASS" in result.stdout
    assert "CORE_TOUCH_ZERO: PASS" in result.stdout
    assert "INTERFACE_FREEZE: PASS" in result.stdout
    assert "SAFE_CAPACITY_POLICY: PASS" in result.stdout


def test_serial_pack_mutation_is_allowed_without_parallel_capacity_claim():
    module = _load_module()
    contract = module.load_contract()
    decision = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=1,
        active_mutations=0,
        mutable_scope=(
            "lib/language/german/german_language_pack.dart",
            "content/german/",
        ),
        measurement=None,
    )
    assert decision.admitted is True
    assert decision.effective_capacity == 1


def test_parallel_increase_requires_verified_pack_measurement():
    module = _load_module()
    contract = module.load_contract()
    decision = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=2,
        active_mutations=0,
        mutable_scope=("content/german/",),
        measurement=None,
    )
    assert decision.admitted is False
    assert "verified pack capacity measurement" in decision.reason


def test_measured_capacity_allows_only_the_proven_parallel_ceiling():
    module = _load_module()
    contract = module.load_contract()
    measurement = module.CapacityMeasurement(
        pack_id="de",
        evidence_revision="6d908b989b01b1eee4adb74fd4b00dcc4f84291f",
        freeze_fingerprint=module.freeze_fingerprint(contract),
        sample_count=6,
        failure_count=0,
        conflict_count=0,
        observed_peak_parallel_mutations=2,
        measured_safe_parallel_mutations=2,
        status="VERIFIED",
    )
    admitted = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=2,
        active_mutations=1,
        mutable_scope=("content/german/",),
        measurement=measurement,
    )
    denied = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=3,
        active_mutations=1,
        mutable_scope=("content/german/",),
        measurement=measurement,
    )
    assert admitted.admitted is True
    assert admitted.effective_capacity == 2
    assert denied.admitted is False
    assert "measured safe capacity" in denied.reason


def test_core_touch_zero_rejects_shared_core_mutation():
    module = _load_module()
    contract = module.load_contract()
    decision = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=1,
        active_mutations=0,
        mutable_scope=("lib/core/srs/srs_engine.dart",),
        measurement=None,
    )
    assert decision.admitted is False
    assert "CORE_TOUCH_ZERO" in decision.reason


def test_unknown_pack_and_cross_pack_scope_fail_closed():
    module = _load_module()
    contract = module.load_contract()
    unknown = module.assess_language_mutation(
        contract=contract,
        pack_id="fr",
        requested_parallel_mutations=1,
        active_mutations=0,
        mutable_scope=("content/french/",),
        measurement=None,
    )
    cross_pack = module.assess_language_mutation(
        contract=contract,
        pack_id="de",
        requested_parallel_mutations=1,
        active_mutations=0,
        mutable_scope=("content/french/",),
        measurement=None,
    )
    assert unknown.admitted is False
    assert "unknown language pack" in unknown.reason
    assert cross_pack.admitted is False
    assert "outside pack-owned namespace" in cross_pack.reason


def test_task12_surfaces_are_bounded():
    contract = json.loads(CONTRACT.read_text(encoding="utf-8"))
    for relative_path in contract["task12_surfaces"]:
        path = ROOT / relative_path
        assert len(path.read_text(encoding="utf-8").splitlines()) <= 1000, path
