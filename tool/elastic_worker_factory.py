#!/usr/bin/env python3
"""Fail-closed primitives for DEUTSCH Issue #80 Elastic Worker Factory.

Non-production by design: no scheduler, paid API, merge authority, production
activation, or Factory #62-#66 implementation is provided here. Worker success
means evidence only; Central owns admission and Executor B owns integration.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
from dataclasses import asdict, dataclass
from enum import Enum
from pathlib import Path, PurePosixPath
from typing import Any, Iterable, Mapping, Sequence

DISPATCH_SCHEMA_VERSION = "1.0"
WORKER_PROFILE_VERSION = "1.0"
SHA40 = re.compile(r"^[0-9a-f]{40}$")
HEX64 = re.compile(r"^[0-9a-f]{64}$")
IDENT = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}$")
PROTECTED_FILES = {
    ".github/workflows/engineering-ci.yml",
    ".github/workflows/quality.yml",
}
PROTECTED_PREFIXES = ("production/", "secrets/", "signing/")

class ContractError(ValueError):
    pass

class WorkerClass(str, Enum):
    DETERMINISTIC_READ_ONLY = "DETERMINISTIC_READ_ONLY"
    AI_READ_ONLY = "AI_READ_ONLY"
    MUTATION = "MUTATION"

class BudgetClass(str, Enum):
    FREE_DETERMINISTIC_LOW = "FREE_DETERMINISTIC_LOW"
    FREE_DETERMINISTIC_STANDARD = "FREE_DETERMINISTIC_STANDARD"
    EXISTING_PLAN_AI_READ_ONLY = "EXISTING_PLAN_AI_READ_ONLY"
    EXISTING_GITHUB_ACTIONS = "EXISTING_GITHUB_ACTIONS"

class FactoryMode(str, Enum):
    NORMAL = "NORMAL"
    THROTTLED = "THROTTLED"
    PAUSED = "PAUSED"
    STOP_THE_LINE = "STOP_THE_LINE"

class IntegrationPressure(str, Enum):
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"

class EvidenceStatus(str, Enum):
    EVIDENCE_PASS = "EVIDENCE_PASS"
    EVIDENCE_FAIL = "EVIDENCE_FAIL"
    REVIEW_NEEDED = "REVIEW_NEEDED"
    QUARANTINED = "QUARANTINED"

class CiFreshness(str, Enum):
    CURRENT = "CURRENT"
    STALE_REPLACEABLE = "STALE_REPLACEABLE"
    STALE_REQUIRES_REVIEW = "STALE_REQUIRES_REVIEW"

@dataclass(frozen=True)
class WorkerProfile:
    name: str
    worker_class: WorkerClass
    deterministic: bool
    read_only: bool
    artifact_first: bool
    evidence_only: bool
    requires_stable_contract: bool = False

WORKER_PROFILES = {
    "deterministic-validator": WorkerProfile("deterministic-validator", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True),
    "standards-precompute": WorkerProfile("standards-precompute", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True),
    "pack-self-test": WorkerProfile("pack-self-test", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True, True),
    "semantic-benchmark": WorkerProfile("semantic-benchmark", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True, True),
    "pair-derivation": WorkerProfile("pair-derivation", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True, True),
    "incremental-ci-selector": WorkerProfile("incremental-ci-selector", WorkerClass.DETERMINISTIC_READ_ONLY, True, True, True, True, True),
    "ai-analysis": WorkerProfile("ai-analysis", WorkerClass.AI_READ_ONLY, False, True, True, True),
}

def canonical_json(value: Any) -> str:
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))

def fingerprint(value: Any) -> str:
    return hashlib.sha256(canonical_json(value).encode()).hexdigest()

def evidence_fingerprint(*, dependencies: Mapping[str, str], inputs: Mapping[str, Any]) -> str:
    deps = {}
    for key, value in dependencies.items():
        deps[_text(key, "dependency name")] = _text(value, "dependency revision")
    return fingerprint({"dependencies": dict(sorted(deps.items())), "inputs": inputs})

def _has(data: Mapping[str, Any], key: str) -> bool:
    return key in data or key.upper() in data

def _get(data: Mapping[str, Any], key: str) -> Any:
    return data[key] if key in data else data.get(key.upper())

def _text(value: Any, name: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ContractError(f"{name} must be a non-empty string")
    return value.strip()

def _ident(value: Any, name: str) -> str:
    value = _text(value, name)
    if not IDENT.fullmatch(value):
        raise ContractError(f"{name} contains unsupported characters or is too long")
    return value

def _items(value: Any, name: str, *, nonempty: bool = False) -> tuple[str, ...]:
    if not isinstance(value, (list, tuple)):
        raise ContractError(f"{name} must be an array of strings")
    result = tuple(_text(item, name) for item in value)
    if nonempty and not result:
        raise ContractError(f"{name} must not be empty")
    if len(result) != len(set(result)):
        raise ContractError(f"{name} must not contain duplicates")
    return result

def _path(value: Any, name: str) -> str:
    value = _text(value, name)
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        raise ContractError(f"{name} must be repository-relative")
    return value

def _norm(path: str) -> str:
    path = path.strip()
    while path.startswith("./"):
        path = path[2:]
    return path

def scope_fingerprint(mutable_scope: Sequence[str], read_only_scope: Sequence[str]) -> str:
    return fingerprint({"mutable_scope": sorted(mutable_scope), "read_only_scope": sorted(read_only_scope)})

def _protected(path: str) -> bool:
    path = _norm(path)
    return path in PROTECTED_FILES or any(path.startswith(prefix) for prefix in PROTECTED_PREFIXES)

REQUIRED = (
    "program_id", "task_id", "worker_id", "worker_class", "owner", "base_sha",
    "scope_fingerprint", "dependencies", "acceptance", "budget_class",
    "evidence_target", "next_action", "priority", "central_admitted",
    "dispatch_schema_version", "worker_profile_version",
    "contract_version_or_hash", "toolchain_or_validator_version",
    "input_revision", "output_evidence_revision",
)

@dataclass(frozen=True)
class DispatchEnvelope:
    program_id: str
    task_id: str
    worker_id: str
    worker_class: WorkerClass
    owner: str
    base_sha: str
    mutable_scope: tuple[str, ...]
    read_only_scope: tuple[str, ...]
    scope_fingerprint: str
    dependencies: tuple[str, ...]
    acceptance: tuple[str, ...]
    budget_class: BudgetClass
    evidence_target: str
    next_action: str
    priority: str
    central_admitted: bool
    dispatch_schema_version: str
    worker_profile_version: str
    contract_version_or_hash: str
    toolchain_or_validator_version: str
    input_revision: str
    output_evidence_revision: str

    @property
    def dispatch_id(self) -> str:
        return "ewf-" + fingerprint(self.to_mapping(False))[:24]

    def to_mapping(self, include_dispatch_id: bool = True) -> dict[str, Any]:
        value = asdict(self)
        value["worker_class"] = self.worker_class.value
        value["budget_class"] = self.budget_class.value
        for key in ("mutable_scope", "read_only_scope", "dependencies", "acceptance"):
            value[key] = list(value[key])
        if include_dispatch_id:
            value["dispatch_id"] = self.dispatch_id
        return value

    @classmethod
    def from_mapping(cls, data: Mapping[str, Any], *, expected_base_sha: str | None = None,
                     seen_dispatch_ids: Iterable[str] = ()) -> "DispatchEnvelope":
        if not isinstance(data, Mapping):
            raise ContractError("dispatch must be an object")
        missing = [key for key in REQUIRED if not _has(data, key)]
        if missing:
            raise ContractError("missing required dispatch fields: " + ", ".join(sorted(missing)))
        has_mut = _has(data, "mutable_scope")
        has_ro = _has(data, "read_only_scope")
        if has_mut == has_ro:
            raise ContractError("dispatch must contain exactly one scope key: mutable_scope or read_only_scope")

        base = _text(_get(data, "base_sha"), "base_sha").lower()
        if not SHA40.fullmatch(base):
            raise ContractError("base_sha must be a lowercase 40-character git SHA")
        if expected_base_sha is not None:
            expected = expected_base_sha.lower()
            if not SHA40.fullmatch(expected):
                raise ContractError("expected base must be a lowercase 40-character git SHA")
            if base != expected:
                raise ContractError(f"stale dispatch base: {base} != expected {expected}")

        try:
            worker_class = WorkerClass(_get(data, "worker_class"))
        except Exception as exc:
            raise ContractError("worker_class is not allowlisted") from exc
        try:
            budget_class = BudgetClass(_get(data, "budget_class"))
        except Exception as exc:
            raise ContractError("budget_class is not zero-additional-billing allowlisted") from exc

        mutable = _items(_get(data, "mutable_scope"), "mutable_scope", nonempty=True) if has_mut else ()
        read_only = _items(_get(data, "read_only_scope"), "read_only_scope", nonempty=True) if has_ro else ()
        for item in (*mutable, *read_only):
            _path(item, "scope path")
        if any(_protected(item) for item in mutable):
            raise ContractError("dispatch attempts mutation of a protected/human-gated scope")

        admitted = _get(data, "central_admitted")
        if not isinstance(admitted, bool):
            raise ContractError("central_admitted must be boolean")
        if worker_class is WorkerClass.MUTATION:
            if not mutable:
                raise ContractError("mutation workers require mutable_scope")
            if not admitted:
                raise ContractError("mutation workers require explicit Central admission")
        elif not read_only:
            raise ContractError("read-only workers require read_only_scope")

        declared_fp = _text(_get(data, "scope_fingerprint"), "scope_fingerprint").lower()
        if not HEX64.fullmatch(declared_fp):
            raise ContractError("scope_fingerprint must be a SHA-256 hex digest")
        if declared_fp != scope_fingerprint(mutable, read_only):
            raise ContractError("scope_fingerprint does not match declared scope")

        priority = _text(_get(data, "priority"), "priority").upper()
        if priority not in {"P0", "P1", "P2", "P3", "P4"}:
            raise ContractError("priority must be P0..P4")
        schema_version = _text(_get(data, "dispatch_schema_version"), "dispatch_schema_version")
        profile_version = _text(_get(data, "worker_profile_version"), "worker_profile_version")
        if schema_version != DISPATCH_SCHEMA_VERSION:
            raise ContractError("unsupported dispatch_schema_version")
        if profile_version != WORKER_PROFILE_VERSION:
            raise ContractError("unsupported worker_profile_version")

        result = cls(
            program_id=_ident(_get(data, "program_id"), "program_id"),
            task_id=_ident(_get(data, "task_id"), "task_id"),
            worker_id=_ident(_get(data, "worker_id"), "worker_id"),
            worker_class=worker_class,
            owner=_text(_get(data, "owner"), "owner"),
            base_sha=base,
            mutable_scope=mutable,
            read_only_scope=read_only,
            scope_fingerprint=declared_fp,
            dependencies=_items(_get(data, "dependencies"), "dependencies"),
            acceptance=_items(_get(data, "acceptance"), "acceptance", nonempty=True),
            budget_class=budget_class,
            evidence_target=_path(_get(data, "evidence_target"), "evidence_target"),
            next_action=_text(_get(data, "next_action"), "next_action"),
            priority=priority,
            central_admitted=admitted,
            dispatch_schema_version=schema_version,
            worker_profile_version=profile_version,
            contract_version_or_hash=_text(_get(data, "contract_version_or_hash"), "contract_version_or_hash"),
            toolchain_or_validator_version=_text(_get(data, "toolchain_or_validator_version"), "toolchain_or_validator_version"),
            input_revision=_text(_get(data, "input_revision"), "input_revision"),
            output_evidence_revision=_text(_get(data, "output_evidence_revision"), "output_evidence_revision"),
        )
        if result.dispatch_id in set(seen_dispatch_ids):
            raise ContractError(f"duplicate/replayed dispatch: {result.dispatch_id}")
        return result

@dataclass(frozen=True)
class ArtifactRecord:
    dispatch_id: str
    task_id: str
    worker_id: str
    base_sha: str
    head_sha: str
    profile: str
    artifact_path: str
    evidence_fingerprint: str
    status: EvidenceStatus
    output_evidence_revision: str
    merge_ready: bool = False

    def __post_init__(self) -> None:
        _ident(self.dispatch_id, "dispatch_id")
        _ident(self.task_id, "task_id")
        _ident(self.worker_id, "worker_id")
        if not SHA40.fullmatch(self.base_sha) or not SHA40.fullmatch(self.head_sha):
            raise ContractError("artifact record SHAs must be lowercase 40-character git SHAs")
        _path(self.artifact_path, "artifact_path")
        if not HEX64.fullmatch(self.evidence_fingerprint):
            raise ContractError("evidence_fingerprint must be SHA-256 hex")
        _text(self.output_evidence_revision, "output_evidence_revision")
        if self.merge_ready:
            raise ContractError("worker evidence cannot claim merge readiness")

    @property
    def record_id(self) -> str:
        return "record-" + fingerprint({
            "dispatch_id": self.dispatch_id, "task_id": self.task_id,
            "worker_id": self.worker_id, "head_sha": self.head_sha,
            "artifact_path": self.artifact_path,
            "evidence_fingerprint": self.evidence_fingerprint,
            "status": self.status.value,
            "output_evidence_revision": self.output_evidence_revision,
        })[:24]

    def to_mapping(self) -> dict[str, Any]:
        value = asdict(self)
        value["status"] = self.status.value
        value["record_id"] = self.record_id
        value["worker_success_semantics"] = "EVIDENCE_ONLY"
        return value

def aggregate_artifact_records(existing: Sequence[ArtifactRecord], incoming: Sequence[ArtifactRecord]) -> tuple[ArtifactRecord, ...]:
    combined = list(existing)
    record_ids = {r.record_id for r in existing}
    dispatch_ids = {r.dispatch_id for r in existing}
    for record in incoming:
        if record.record_id in record_ids or record.dispatch_id in dispatch_ids:
            raise ContractError(f"duplicate/replayed artifact evidence: {record.dispatch_id}")
        record_ids.add(record.record_id)
        dispatch_ids.add(record.dispatch_id)
        combined.append(record)
    return tuple(combined)

def shard_logical_workers(ids: Sequence[str], physical_shards: int) -> tuple[tuple[str, ...], ...]:
    if not 1 <= physical_shards <= 25:
        raise ContractError("physical_shards must be 1..25")
    if not 1 <= len(ids) <= 100:
        raise ContractError("logical worker count must be 1..100")
    normalized = tuple(sorted(_ident(item, "logical worker id") for item in ids))
    if len(normalized) != len(set(normalized)):
        raise ContractError("logical worker IDs must be unique")
    shards = [[] for _ in range(min(physical_shards, len(normalized)))]
    for index, worker_id in enumerate(normalized):
        shards[index % len(shards)].append(worker_id)
    return tuple(tuple(shard) for shard in shards)

@dataclass(frozen=True)
class ManifestCoordinate:
    language_id: str
    content_namespace_id: str
    artifact_version: str
    artifact_digest: str
    def __post_init__(self) -> None:
        _ident(self.language_id, "language_id")
        _ident(self.content_namespace_id, "content_namespace_id")
        _text(self.artifact_version, "artifact_version")
        if not HEX64.fullmatch(self.artifact_digest):
            raise ContractError("artifact_digest must be SHA-256 hex")

@dataclass(frozen=True)
class DirectedPairKey:
    source_language: str
    target_language: str
    def __post_init__(self) -> None:
        _ident(self.source_language, "source_language")
        _ident(self.target_language, "target_language")
        if self.source_language == self.target_language:
            raise ContractError("directed pair endpoints must differ")
    @property
    def key(self) -> str:
        return f"{self.source_language}->{self.target_language}"

@dataclass(frozen=True)
class RiskDecision:
    tier: str
    requires_deep_review: bool
    quarantine: bool

def route_risk(score: int, *, ambiguous: bool = False) -> RiskDecision:
    if not 0 <= score <= 100:
        raise ContractError("risk score must be 0..100")
    if ambiguous: return RiskDecision("HIGH", True, True)
    if score >= 80: return RiskDecision("CRITICAL", True, True)
    if score >= 50: return RiskDecision("HIGH", True, False)
    if score >= 20: return RiskDecision("MEDIUM", True, False)
    return RiskDecision("LOW", False, False)

def get_worker_profile(name: str) -> WorkerProfile:
    try:
        return WORKER_PROFILES[name]
    except KeyError as exc:
        raise ContractError(f"unknown worker profile: {name}") from exc

def classify_ci_freshness(run_head_sha: str, expected_head_sha: str, *, replaceable: bool) -> CiFreshness:
    if not SHA40.fullmatch(run_head_sha) or not SHA40.fullmatch(expected_head_sha):
        raise ContractError("CI SHAs must be lowercase 40-character git SHAs")
    if run_head_sha == expected_head_sha:
        return CiFreshness.CURRENT
    return CiFreshness.STALE_REPLACEABLE if replaceable else CiFreshness.STALE_REQUIRES_REVIEW

@dataclass(frozen=True)
class IncrementalCiPlan:
    mode: str
    affected_languages: tuple[str, ...]
    affected_pairs: tuple[str, ...]
    reason: str

def plan_incremental_ci(changed_paths: Sequence[str], *, language_boundaries: Mapping[str, Sequence[str]],
                        pair_dependencies: Mapping[str, Sequence[str]], shared_prefixes: Sequence[str],
                        boundaries_verified: bool) -> IncrementalCiPlan:
    if not changed_paths:
        raise ContractError("changed_paths must not be empty")
    if not boundaries_verified:
        return IncrementalCiPlan("FULL", (), (), "machine-readable dependency boundaries are not verified")
    paths = [_norm(p) for p in changed_paths]
    shared = tuple(_norm(p) for p in shared_prefixes)
    if any(any(path.startswith(prefix) for prefix in shared) for path in paths):
        return IncrementalCiPlan("FULL", (), (), "shared-contract path changed")
    affected = set()
    for path in paths:
        owners = {lang for lang, prefixes in language_boundaries.items()
                  if any(path.startswith(_norm(prefix)) for prefix in prefixes)}
        if len(owners) != 1:
            return IncrementalCiPlan("FULL", (), (), f"unknown or ambiguous path impact: {path}")
        affected.update(owners)
    pairs = set()
    for lang in affected:
        pairs.update(pair_dependencies.get(lang, ()))
    return IncrementalCiPlan("INCREMENTAL", tuple(sorted(affected)), tuple(sorted(pairs)),
                             "verified language-owned boundaries only")

@dataclass(frozen=True)
class AdmissionDecision:
    admitted: bool
    reason: str

def assess_admission(dispatch: DispatchEnvelope, *, mode: FactoryMode,
                     integration_pressure: IntegrationPressure,
                     active_mutation_count: int = 0, max_mutations: int = 1) -> AdmissionDecision:
    if active_mutation_count < 0 or max_mutations < 0:
        raise ContractError("mutation counts must be non-negative")
    if mode in {FactoryMode.PAUSED, FactoryMode.STOP_THE_LINE}:
        return AdmissionDecision(False, f"worker factory mode is {mode.value}")
    if dispatch.worker_class is not WorkerClass.MUTATION:
        if mode is FactoryMode.THROTTLED and dispatch.worker_class is WorkerClass.AI_READ_ONLY:
            return AdmissionDecision(False, "THROTTLED permits deterministic read-only dispatch only")
        return AdmissionDecision(True, "read-only evidence work admitted")
    if active_mutation_count >= max_mutations:
        return AdmissionDecision(False, "mutation concurrency budget exhausted")
    if integration_pressure is IntegrationPressure.HIGH and dispatch.priority not in {"P0", "P1"}:
        return AdmissionDecision(False, "HIGH integration pressure blocks new low-priority mutation")
    if mode is FactoryMode.THROTTLED and dispatch.priority != "P0":
        return AdmissionDecision(False, "THROTTLED mutation requires P0 Central admission")
    return AdmissionDecision(True, "Central-admitted bounded mutation")

def dispatch_json_schema() -> dict[str, Any]:
    arr = {"type": "array", "minItems": 1, "items": {"type": "string", "minLength": 1}, "uniqueItems": True}
    return {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "title": "DEUTSCH Elastic Worker Dispatch",
        "type": "object",
        "additionalProperties": False,
        "required": list(REQUIRED),
        "properties": {
            "program_id": {"type": "string", "minLength": 1},
            "task_id": {"type": "string", "minLength": 1},
            "worker_id": {"type": "string", "minLength": 1},
            "worker_class": {"enum": [x.value for x in WorkerClass]},
            "owner": {"type": "string", "minLength": 1},
            "base_sha": {"type": "string", "pattern": "^[0-9a-f]{40}$"},
            "mutable_scope": arr,
            "read_only_scope": arr,
            "scope_fingerprint": {"type": "string", "pattern": "^[0-9a-f]{64}$"},
            "dependencies": {"type": "array", "items": {"type": "string", "minLength": 1}, "uniqueItems": True},
            "acceptance": arr,
            "budget_class": {"enum": [x.value for x in BudgetClass]},
            "evidence_target": {"type": "string", "minLength": 1},
            "next_action": {"type": "string", "minLength": 1},
            "priority": {"enum": ["P0", "P1", "P2", "P3", "P4"]},
            "central_admitted": {"type": "boolean"},
            "dispatch_schema_version": {"const": DISPATCH_SCHEMA_VERSION},
            "worker_profile_version": {"const": WORKER_PROFILE_VERSION},
            "contract_version_or_hash": {"type": "string", "minLength": 1},
            "toolchain_or_validator_version": {"type": "string", "minLength": 1},
            "input_revision": {"type": "string", "minLength": 1},
            "output_evidence_revision": {"type": "string", "minLength": 1},
        },
        "oneOf": [
            {"required": ["mutable_scope"], "not": {"required": ["read_only_scope"]}},
            {"required": ["read_only_scope"], "not": {"required": ["mutable_scope"]}},
        ],
    }

def _load(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))

def _seen(path: Path | None) -> set[str]:
    if path is None or not path.exists():
        return set()
    value = _load(path)
    if not isinstance(value, list) or not all(isinstance(x, str) for x in value):
        raise ContractError("seen-dispatch file must contain a JSON array of strings")
    if len(value) != len(set(value)):
        raise ContractError("seen-dispatch file itself contains duplicates")
    return set(value)

def _validate(args: argparse.Namespace) -> int:
    seen_path = Path(args.seen_dispatches) if args.seen_dispatches else None
    seen = _seen(seen_path)
    dispatch = DispatchEnvelope.from_mapping(_load(Path(args.input)),
                                             expected_base_sha=args.expected_base,
                                             seen_dispatch_ids=seen)
    if args.mark_seen:
        if seen_path is None:
            raise ContractError("--mark-seen requires --seen-dispatches")
        seen.add(dispatch.dispatch_id)
        seen_path.write_text(json.dumps(sorted(seen), indent=2) + "\n", encoding="utf-8")
    print(canonical_json({"ok": True, "dispatch": dispatch.to_mapping()}))
    return 0

def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    validate = sub.add_parser("validate-dispatch")
    validate.add_argument("--input", required=True)
    validate.add_argument("--expected-base", required=True)
    validate.add_argument("--seen-dispatches")
    validate.add_argument("--mark-seen", action="store_true")
    validate.set_defaults(func=_validate)
    schema = sub.add_parser("schema")
    schema.set_defaults(func=lambda _: (print(json.dumps(dispatch_json_schema(), indent=2, sort_keys=True)), 0)[1])
    args = parser.parse_args()
    try:
        return args.func(args)
    except (ContractError, json.JSONDecodeError, OSError) as exc:
        print(canonical_json({"ok": False, "error": exc.__class__.__name__, "message": str(exc)}), file=sys.stderr)
        return 2

if __name__ == "__main__":
    raise SystemExit(main())
