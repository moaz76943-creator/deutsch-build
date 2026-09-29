import json
import subprocess
import sys

import pytest

from tool.elastic_worker_factory import (
    ArtifactRecord,
    BudgetClass,
    CiFreshness,
    ContractError,
    DirectedPairKey,
    DispatchEnvelope,
    EvidenceStatus,
    FactoryMode,
    IntegrationPressure,
    ManifestCoordinate,
    WorkerClass,
    aggregate_artifact_records,
    assess_admission,
    classify_ci_freshness,
    dispatch_json_schema,
    evidence_fingerprint,
    fingerprint,
    get_worker_profile,
    plan_incremental_ci,
    route_risk,
    scope_fingerprint,
    shard_logical_workers,
)

BASE = "a" * 40
HEAD = "b" * 40


def dispatch(*, worker_class="DETERMINISTIC_READ_ONLY", priority="P2", central_admitted=False):
    mutable = ["tool/owned.py"] if worker_class == "MUTATION" else []
    read_only = [] if mutable else ["content/german/sample.json"]
    value = {
        "program_id": "ELASTIC-WORKER-FACTORY-001",
        "task_id": "EWF-A-TEST-001",
        "worker_id": "logical-001",
        "worker_class": worker_class,
        "owner": "Central",
        "base_sha": BASE,
        "scope_fingerprint": scope_fingerprint(mutable, read_only),
        "dependencies": ["contract@v1"],
        "acceptance": ["emit exact-SHA evidence"],
        "budget_class": "EXISTING_GITHUB_ACTIONS",
        "evidence_target": "artifacts/ewf/test/evidence.json",
        "next_action": "return evidence to Central",
        "priority": priority,
        "central_admitted": central_admitted,
        "dispatch_schema_version": "1.0",
        "worker_profile_version": "1.0",
        "contract_version_or_hash": "contract-v1",
        "toolchain_or_validator_version": "validator-v1",
        "input_revision": "input-v1",
        "output_evidence_revision": "evidence-v1",
    }
    value["mutable_scope" if mutable else "read_only_scope"] = mutable or read_only
    return value


def test_dispatch_validates_and_derives_stable_id():
    first = DispatchEnvelope.from_mapping(dispatch(), expected_base_sha=BASE)
    second = DispatchEnvelope.from_mapping(dispatch(), expected_base_sha=BASE)
    assert first.dispatch_id == second.dispatch_id
    assert first.worker_class is WorkerClass.DETERMINISTIC_READ_ONLY
    assert first.budget_class is BudgetClass.EXISTING_GITHUB_ACTIONS


def test_required_version_and_dependency_fields_fail_closed_when_missing():
    value = dispatch()
    del value["dependencies"]
    with pytest.raises(ContractError, match="dependencies"):
        DispatchEnvelope.from_mapping(value, expected_base_sha=BASE)
    value = dispatch()
    del value["dispatch_schema_version"]
    with pytest.raises(ContractError, match="dispatch_schema_version"):
        DispatchEnvelope.from_mapping(value, expected_base_sha=BASE)


def test_malformed_stale_and_duplicate_dispatches_fail_closed():
    malformed = dispatch()
    malformed["acceptance"] = []
    with pytest.raises(ContractError, match="acceptance"):
        DispatchEnvelope.from_mapping(malformed, expected_base_sha=BASE)
    with pytest.raises(ContractError, match="stale dispatch base"):
        DispatchEnvelope.from_mapping(dispatch(), expected_base_sha=HEAD)
    valid = DispatchEnvelope.from_mapping(dispatch(), expected_base_sha=BASE)
    with pytest.raises(ContractError, match="duplicate/replayed"):
        DispatchEnvelope.from_mapping(
            dispatch(), expected_base_sha=BASE, seen_dispatch_ids={valid.dispatch_id}
        )


def test_both_scope_keys_fail_closed_even_if_one_is_empty():
    value = dispatch()
    value["mutable_scope"] = []
    with pytest.raises(ContractError, match="exactly one scope key"):
        DispatchEnvelope.from_mapping(value, expected_base_sha=BASE)


def test_paid_or_unadmitted_mutation_is_rejected():
    paid = dispatch()
    paid["budget_class"] = "PAID_API"
    with pytest.raises(ContractError, match="zero-additional-billing"):
        DispatchEnvelope.from_mapping(paid, expected_base_sha=BASE)
    mutation = dispatch(worker_class="MUTATION", central_admitted=False)
    with pytest.raises(ContractError, match="Central admission"):
        DispatchEnvelope.from_mapping(mutation, expected_base_sha=BASE)


def test_protected_workflow_and_production_scope_cannot_be_mutated():
    for path in (
        ".github/workflows/engineering-ci.yml",
        ".github/workflows/quality.yml",
        "production/deploy.sh",
    ):
        value = dispatch(worker_class="MUTATION", central_admitted=True)
        value["mutable_scope"] = [path]
        value["scope_fingerprint"] = scope_fingerprint([path], [])
        with pytest.raises(ContractError, match="protected"):
            DispatchEnvelope.from_mapping(value, expected_base_sha=BASE)


def test_artifact_first_record_never_claims_merge_readiness_and_dedupes():
    fp = evidence_fingerprint(dependencies={"schema": "v1"}, inputs={"count": 3})
    record = ArtifactRecord(
        dispatch_id="ewf-abc",
        task_id="task-1",
        worker_id="worker-1",
        base_sha=BASE,
        head_sha=HEAD,
        profile="pack-self-test",
        artifact_path="artifacts/ewf/task-1/evidence.json",
        evidence_fingerprint=fp,
        status=EvidenceStatus.EVIDENCE_PASS,
        output_evidence_revision="r1",
    )
    assert record.merge_ready is False
    assert record.to_mapping()["worker_success_semantics"] == "EVIDENCE_ONLY"
    with pytest.raises(ContractError, match="duplicate/replayed"):
        aggregate_artifact_records([record], [record])
    with pytest.raises(ContractError, match="merge readiness"):
        ArtifactRecord(**{**record.__dict__, "merge_ready": True})


def test_evidence_fingerprint_is_order_stable_and_dependency_sensitive():
    a = evidence_fingerprint(dependencies={"b": "2", "a": "1"}, inputs={"x": [1, 2]})
    b = evidence_fingerprint(dependencies={"a": "1", "b": "2"}, inputs={"x": [1, 2]})
    c = evidence_fingerprint(dependencies={"a": "1", "b": "3"}, inputs={"x": [1, 2]})
    assert a == b
    assert a != c


def test_logical_worker_sharding_is_bounded_deterministic_and_unique():
    workers = [f"worker-{i:03d}" for i in range(20)]
    assert shard_logical_workers(workers, 4) == shard_logical_workers(list(reversed(workers)), 4)
    flattened = [item for shard in shard_logical_workers(workers, 4) for item in shard]
    assert sorted(flattened) == workers
    with pytest.raises(ContractError, match="unique"):
        shard_logical_workers(["worker-1", "worker-1"], 2)


def test_manifest_namespace_and_artifact_revision_are_separate_coordinates():
    one = ManifestCoordinate("de", "legacy-de", "1", "1" * 64)
    two = ManifestCoordinate("de", "legacy-de", "2", "2" * 64)
    assert one.content_namespace_id == two.content_namespace_id
    assert one.artifact_digest != two.artifact_digest


def test_directed_pairs_are_not_implicitly_reversible():
    ab = DirectedPairKey("ar", "de")
    ba = DirectedPairKey("de", "ar")
    assert ab.key == "ar->de"
    assert ba.key == "de->ar"
    assert ab != ba


def test_risk_routing_quarantines_ambiguity_and_highest_risk():
    assert route_risk(5).requires_deep_review is False
    assert route_risk(55).requires_deep_review is True
    assert route_risk(81).quarantine is True
    ambiguous = route_risk(10, ambiguous=True)
    assert ambiguous.quarantine is True
    assert ambiguous.tier == "HIGH"


def test_ci_staleness_classifier_never_treats_other_head_as_current():
    assert classify_ci_freshness(BASE, BASE, replaceable=True) is CiFreshness.CURRENT
    assert classify_ci_freshness(BASE, HEAD, replaceable=True) is CiFreshness.STALE_REPLACEABLE
    assert classify_ci_freshness(BASE, HEAD, replaceable=False) is CiFreshness.STALE_REQUIRES_REVIEW


def test_incremental_ci_fails_back_for_unverified_shared_or_unknown_impact():
    kwargs = dict(
        language_boundaries={"de": ["content/de/"], "ar": ["content/ar/"]},
        pair_dependencies={"de": ["de->ar", "ar->de"], "ar": ["de->ar", "ar->de"]},
        shared_prefixes=["lib/core/", "tool/shared/"],
    )
    assert plan_incremental_ci(["content/de/x.json"], boundaries_verified=False, **kwargs).mode == "FULL"
    assert plan_incremental_ci(["lib/core/x.dart"], boundaries_verified=True, **kwargs).mode == "FULL"
    assert plan_incremental_ci(["unknown/x"], boundaries_verified=True, **kwargs).mode == "FULL"
    plan = plan_incremental_ci(["content/de/x.json"], boundaries_verified=True, **kwargs)
    assert plan.mode == "INCREMENTAL"
    assert plan.affected_languages == ("de",)
    assert plan.affected_pairs == ("ar->de", "de->ar")


def test_pack_self_test_and_semantic_benchmark_profiles_are_read_only_evidence_workers():
    for name in ("pack-self-test", "semantic-benchmark", "pair-derivation", "incremental-ci-selector"):
        profile = get_worker_profile(name)
        assert profile.read_only is True
        assert profile.artifact_first is True
        assert profile.evidence_only is True
        assert profile.worker_class is WorkerClass.DETERMINISTIC_READ_ONLY
        assert profile.requires_stable_contract is True


def test_backpressure_denies_low_priority_mutation_but_allows_read_only():
    read_only = DispatchEnvelope.from_mapping(dispatch(), expected_base_sha=BASE)
    assert assess_admission(
        read_only, mode=FactoryMode.NORMAL, integration_pressure=IntegrationPressure.HIGH
    ).admitted
    mutation = DispatchEnvelope.from_mapping(
        dispatch(worker_class="MUTATION", priority="P2", central_admitted=True),
        expected_base_sha=BASE,
    )
    assert not assess_admission(
        mutation, mode=FactoryMode.NORMAL, integration_pressure=IntegrationPressure.HIGH
    ).admitted
    p1 = DispatchEnvelope.from_mapping(
        dispatch(worker_class="MUTATION", priority="P1", central_admitted=True),
        expected_base_sha=BASE,
    )
    assert assess_admission(
        p1, mode=FactoryMode.NORMAL, integration_pressure=IntegrationPressure.HIGH
    ).admitted
    assert not assess_admission(
        read_only, mode=FactoryMode.STOP_THE_LINE, integration_pressure=IntegrationPressure.LOW
    ).admitted


def test_schema_tracks_versioned_fail_closed_contract():
    schema = dispatch_json_schema()
    assert schema["additionalProperties"] is False
    assert "dependencies" in schema["required"]
    assert "dispatch_schema_version" in schema["required"]
    assert schema["properties"]["dispatch_schema_version"]["const"] == "1.0"


def test_cli_persistent_seen_set_rejects_replay(tmp_path):
    payload = tmp_path / "dispatch.json"
    seen = tmp_path / "seen.json"
    payload.write_text(json.dumps(dispatch()), encoding="utf-8")
    seen.write_text("[]\n", encoding="utf-8")
    command = [
        sys.executable,
        "tool/elastic_worker_factory.py",
        "validate-dispatch",
        "--input", str(payload),
        "--expected-base", BASE,
        "--seen-dispatches", str(seen),
        "--mark-seen",
    ]
    first = subprocess.run(command, check=False, text=True, capture_output=True)
    second = subprocess.run(command, check=False, text=True, capture_output=True)
    assert first.returncode == 0, first.stderr
    assert second.returncode == 2
    assert "duplicate/replayed dispatch" in second.stderr
