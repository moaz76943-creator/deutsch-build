#!/usr/bin/env python3
"""TASK 12 factory freeze and per-pack safe-capacity admission gate."""
from __future__ import annotations

import argparse
from dataclasses import asdict, dataclass
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import sys
from typing import Any, Mapping, Sequence

ROOT = Path(__file__).resolve().parents[1]
CONTRACT_PATH = ROOT / "tool" / "task12_factory_freeze.json"
SHA40 = re.compile(r"^[0-9a-f]{40}$")
PACK_ID = re.compile(r"^[a-z][a-z0-9-]{1,31}$")


class Task12ContractError(ValueError):
    pass


@dataclass(frozen=True)
class CapacityMeasurement:
    pack_id: str
    evidence_revision: str
    freeze_fingerprint: str
    sample_count: int
    failure_count: int
    conflict_count: int
    observed_peak_parallel_mutations: int
    measured_safe_parallel_mutations: int
    status: str

    @classmethod
    def from_mapping(cls, value: Mapping[str, Any]) -> "CapacityMeasurement":
        required = {
            "pack_id",
            "evidence_revision",
            "freeze_fingerprint",
            "sample_count",
            "failure_count",
            "conflict_count",
            "observed_peak_parallel_mutations",
            "measured_safe_parallel_mutations",
            "status",
        }
        if set(value) != required:
            missing = sorted(required - set(value))
            extra = sorted(set(value) - required)
            raise Task12ContractError(
                f"capacity measurement schema mismatch: missing={missing} extra={extra}"
            )
        return cls(
            pack_id=_pack_id(value["pack_id"]),
            evidence_revision=_sha40(value["evidence_revision"], "evidence_revision"),
            freeze_fingerprint=_hex64(
                value["freeze_fingerprint"],
                "freeze_fingerprint",
            ),
            sample_count=_integer(value["sample_count"], "sample_count", minimum=0),
            failure_count=_integer(value["failure_count"], "failure_count", minimum=0),
            conflict_count=_integer(value["conflict_count"], "conflict_count", minimum=0),
            observed_peak_parallel_mutations=_integer(
                value["observed_peak_parallel_mutations"],
                "observed_peak_parallel_mutations",
                minimum=0,
            ),
            measured_safe_parallel_mutations=_integer(
                value["measured_safe_parallel_mutations"],
                "measured_safe_parallel_mutations",
                minimum=0,
            ),
            status=_text(value["status"], "status").upper(),
        )


@dataclass(frozen=True)
class CapacityDecision:
    admitted: bool
    pack_id: str
    requested_parallel_mutations: int
    effective_capacity: int
    reason: str

    def to_mapping(self) -> dict[str, Any]:
        return asdict(self)


def _text(value: Any, field: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise Task12ContractError(f"{field} must be a non-empty string")
    return value.strip()


def _integer(value: Any, field: str, *, minimum: int) -> int:
    if isinstance(value, bool) or not isinstance(value, int) or value < minimum:
        raise Task12ContractError(f"{field} must be an integer >= {minimum}")
    return value


def _sha40(value: Any, field: str) -> str:
    normalized = _text(value, field).lower()
    if not SHA40.fullmatch(normalized):
        raise Task12ContractError(f"{field} must be a lowercase git SHA")
    return normalized


def _hex64(value: Any, field: str) -> str:
    normalized = _text(value, field).lower()
    if len(normalized) != 64 or re.search(r"[^0-9a-f]", normalized):
        raise Task12ContractError(f"{field} must be a SHA-256 hex digest")
    return normalized


def _pack_id(value: Any) -> str:
    normalized = _text(value, "pack_id").lower()
    if not PACK_ID.fullmatch(normalized):
        raise Task12ContractError("pack_id is invalid")
    return normalized


def _repo_path(value: Any, field: str) -> str:
    normalized = _text(value, field).replace("\\", "/")
    path = PurePosixPath(normalized)
    if path.is_absolute() or ".." in path.parts:
        raise Task12ContractError(f"{field} must be repository-relative")
    return normalized


def load_contract(path: Path = CONTRACT_PATH) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise Task12ContractError("TASK 12 contract root must be an object")
    if data.get("schema_version") != 1:
        raise Task12ContractError("unsupported TASK 12 contract schema")
    if data.get("freeze_state") != "FROZEN":
        raise Task12ContractError("factory interfaces must remain FROZEN")
    if data.get("core_touch_zero") is not True:
        raise Task12ContractError("CORE_TOUCH_ZERO must be true")
    return data


def git_blob_sha(path: Path) -> str:
    payload = path.read_bytes()
    header = f"blob {len(payload)}\0".encode("ascii")
    return hashlib.sha1(header + payload).hexdigest()


def freeze_fingerprint(contract: Mapping[str, Any]) -> str:
    payload = {
        "freeze_version": contract["freeze_version"],
        "frozen_interfaces": contract["frozen_interfaces"],
        "core_touch_zero_prefixes": contract["core_touch_zero_prefixes"],
        "pack_owned_prefixes": contract["pack_owned_prefixes"],
    }
    canonical = json.dumps(
        payload,
        ensure_ascii=False,
        sort_keys=True,
        separators=(",", ":"),
    )
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def verify_contract(contract: Mapping[str, Any]) -> None:
    _sha40(contract["baseline_main"], "baseline_main")
    _text(contract["freeze_version"], "freeze_version")
    serial = _integer(
        contract["serial_mutation_baseline"],
        "serial_mutation_baseline",
        minimum=1,
    )
    if serial != 1:
        raise Task12ContractError("serial mutation baseline must remain 1")
    minimum_samples = _integer(
        contract["minimum_capacity_samples"],
        "minimum_capacity_samples",
        minimum=1,
    )
    maximum = _integer(
        contract["maximum_parallel_mutations"],
        "maximum_parallel_mutations",
        minimum=1,
    )
    if maximum > 25:
        raise Task12ContractError("parallel mutation ceiling must not exceed 25")

    frozen = contract["frozen_interfaces"]
    if not isinstance(frozen, dict) or not frozen:
        raise Task12ContractError("frozen_interfaces must be a non-empty object")
    for raw_path, expected_sha in frozen.items():
        relative = _repo_path(raw_path, "frozen interface path")
        expected = _sha40(expected_sha, f"frozen interface SHA for {relative}")
        path = ROOT / relative
        if not path.is_file():
            raise Task12ContractError(f"frozen interface missing: {relative}")
        actual = git_blob_sha(path)
        if actual != expected:
            raise Task12ContractError(
                f"frozen interface drift: {relative}:{actual}!={expected}"
            )

    protected = contract["core_touch_zero_prefixes"]
    if not isinstance(protected, list) or not protected:
        raise Task12ContractError("core_touch_zero_prefixes must be non-empty")
    normalized_protected = tuple(
        _repo_path(value, "core touch zero prefix") for value in protected
    )

    pack_prefixes = contract["pack_owned_prefixes"]
    if not isinstance(pack_prefixes, dict) or not pack_prefixes:
        raise Task12ContractError("pack_owned_prefixes must be non-empty")
    for raw_pack, raw_prefixes in pack_prefixes.items():
        pack = _pack_id(raw_pack)
        if pack != raw_pack:
            raise Task12ContractError("pack IDs must already be normalized")
        if not isinstance(raw_prefixes, list) or not raw_prefixes:
            raise Task12ContractError(f"pack {pack} must own at least one prefix")
        prefixes = tuple(
            _repo_path(value, f"pack {pack} prefix") for value in raw_prefixes
        )
        for prefix in prefixes:
            if any(
                prefix.startswith(core_prefix)
                or core_prefix.startswith(prefix)
                for core_prefix in normalized_protected
            ):
                raise Task12ContractError(
                    f"pack namespace overlaps CORE_TOUCH_ZERO boundary: {pack}:{prefix}"
                )

    measurements = contract.get("capacity_measurements", {})
    if not isinstance(measurements, dict):
        raise Task12ContractError("capacity_measurements must be an object")
    for pack, raw in measurements.items():
        measurement = CapacityMeasurement.from_mapping(raw)
        if measurement.pack_id != pack:
            raise Task12ContractError("capacity measurement key/pack mismatch")
        _verify_measurement(
            contract,
            measurement,
            minimum_samples=minimum_samples,
            maximum_parallel_mutations=maximum,
        )


def _verify_measurement(
    contract: Mapping[str, Any],
    measurement: CapacityMeasurement,
    *,
    minimum_samples: int | None = None,
    maximum_parallel_mutations: int | None = None,
) -> None:
    minimum = (
        minimum_samples
        if minimum_samples is not None
        else _integer(
            contract["minimum_capacity_samples"],
            "minimum_capacity_samples",
            minimum=1,
        )
    )
    maximum = (
        maximum_parallel_mutations
        if maximum_parallel_mutations is not None
        else _integer(
            contract["maximum_parallel_mutations"],
            "maximum_parallel_mutations",
            minimum=1,
        )
    )
    if measurement.status != "VERIFIED":
        raise Task12ContractError("capacity measurement must be VERIFIED")
    if measurement.freeze_fingerprint != freeze_fingerprint(contract):
        raise Task12ContractError("capacity measurement targets a stale interface freeze")
    if measurement.sample_count < minimum:
        raise Task12ContractError(
            f"capacity measurement needs at least {minimum} samples"
        )
    if measurement.failure_count != 0 or measurement.conflict_count != 0:
        raise Task12ContractError(
            "capacity measurement contains failures or ownership conflicts"
        )
    if measurement.measured_safe_parallel_mutations < 2:
        raise Task12ContractError(
            "parallel capacity evidence must prove an increase above serial baseline"
        )
    if (
        measurement.measured_safe_parallel_mutations
        > measurement.observed_peak_parallel_mutations
    ):
        raise Task12ContractError(
            "safe capacity cannot exceed observed parallel mutation peak"
        )
    if measurement.measured_safe_parallel_mutations > maximum:
        raise Task12ContractError("measured capacity exceeds factory hard ceiling")


def _scope_is_protected(contract: Mapping[str, Any], path: str) -> bool:
    normalized = _repo_path(path, "mutable scope")
    if normalized in contract["frozen_interfaces"]:
        return True
    return any(
        normalized.startswith(prefix)
        for prefix in contract["core_touch_zero_prefixes"]
    )


def _scope_owned_by_pack(
    contract: Mapping[str, Any],
    *,
    pack_id: str,
    path: str,
) -> bool:
    prefixes = contract["pack_owned_prefixes"].get(pack_id)
    if not isinstance(prefixes, list):
        return False
    normalized = _repo_path(path, "mutable scope")
    return any(normalized.startswith(prefix) for prefix in prefixes)


def assess_language_mutation(
    *,
    contract: Mapping[str, Any],
    pack_id: str,
    requested_parallel_mutations: int,
    active_mutations: int,
    mutable_scope: Sequence[str],
    measurement: CapacityMeasurement | None,
) -> CapacityDecision:
    verify_contract(contract)
    pack = _pack_id(pack_id)
    requested = _integer(
        requested_parallel_mutations,
        "requested_parallel_mutations",
        minimum=1,
    )
    active = _integer(active_mutations, "active_mutations", minimum=0)
    maximum = _integer(
        contract["maximum_parallel_mutations"],
        "maximum_parallel_mutations",
        minimum=1,
    )
    if requested > maximum:
        return CapacityDecision(
            False,
            pack,
            requested,
            maximum,
            "requested parallelism exceeds the factory hard ceiling",
        )

    if pack not in contract["pack_owned_prefixes"]:
        return CapacityDecision(
            False,
            pack,
            requested,
            0,
            "unknown language pack; fail-closed admission",
        )
    if not mutable_scope:
        return CapacityDecision(
            False,
            pack,
            requested,
            0,
            "language mutation requires non-empty mutable scope",
        )
    for raw_path in mutable_scope:
        path = _repo_path(raw_path, "mutable scope")
        if _scope_is_protected(contract, path):
            return CapacityDecision(
                False,
                pack,
                requested,
                0,
                f"CORE_TOUCH_ZERO violation: {path}",
            )
        if not _scope_owned_by_pack(contract, pack_id=pack, path=path):
            return CapacityDecision(
                False,
                pack,
                requested,
                0,
                f"mutable scope is outside pack-owned namespace: {path}",
            )

    serial = _integer(
        contract["serial_mutation_baseline"],
        "serial_mutation_baseline",
        minimum=1,
    )
    effective = serial
    if requested > serial:
        if measurement is None:
            return CapacityDecision(
                False,
                pack,
                requested,
                serial,
                "parallel increase requires a verified pack capacity measurement",
            )
        if measurement.pack_id != pack:
            return CapacityDecision(
                False,
                pack,
                requested,
                serial,
                "capacity measurement belongs to another language pack",
            )
        try:
            _verify_measurement(contract, measurement)
        except Task12ContractError as exc:
            return CapacityDecision(False, pack, requested, serial, str(exc))
        effective = measurement.measured_safe_parallel_mutations
        if requested > effective:
            return CapacityDecision(
                False,
                pack,
                requested,
                effective,
                "requested parallelism exceeds measured safe capacity",
            )

    if active >= effective:
        return CapacityDecision(
            False,
            pack,
            requested,
            effective,
            "pack mutation capacity exhausted",
        )
    if active + 1 > requested:
        return CapacityDecision(
            False,
            pack,
            requested,
            effective,
            "requested concurrency is already saturated",
        )
    return CapacityDecision(
        True,
        pack,
        requested,
        effective,
        "CORE_TOUCH_ZERO and frozen-interface capacity policy satisfied",
    )


def _measurement_from_file(path: Path | None) -> CapacityMeasurement | None:
    if path is None:
        return None
    raw = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(raw, dict):
        raise Task12ContractError("measurement file root must be an object")
    return CapacityMeasurement.from_mapping(raw)


def _command_check(_: argparse.Namespace) -> int:
    contract = load_contract()
    verify_contract(contract)
    print("TASK 12 FACTORY FREEZE: PASS")
    print("CORE_TOUCH_ZERO: PASS")
    print("INTERFACE_FREEZE: PASS")
    print("SAFE_CAPACITY_POLICY: PASS")
    print(f"FREEZE_FINGERPRINT: {freeze_fingerprint(contract)}")
    print(
        "VERIFIED_CAPACITY_RECORDS: "
        f"{len(contract.get('capacity_measurements', {}))}"
    )
    return 0


def _command_admit(args: argparse.Namespace) -> int:
    contract = load_contract()
    decision = assess_language_mutation(
        contract=contract,
        pack_id=args.pack_id,
        requested_parallel_mutations=args.requested,
        active_mutations=args.active,
        mutable_scope=tuple(args.scope),
        measurement=_measurement_from_file(
            Path(args.measurement) if args.measurement else None
        ),
    )
    print(json.dumps(decision.to_mapping(), sort_keys=True))
    return 0 if decision.admitted else 3


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    check = sub.add_parser("check")
    check.set_defaults(func=_command_check)
    admit = sub.add_parser("admit")
    admit.add_argument("--pack-id", required=True)
    admit.add_argument("--requested", type=int, required=True)
    admit.add_argument("--active", type=int, required=True)
    admit.add_argument("--scope", action="append", required=True)
    admit.add_argument("--measurement")
    admit.set_defaults(func=_command_admit)
    args = parser.parse_args()
    try:
        return args.func(args)
    except (
        OSError,
        KeyError,
        TypeError,
        ValueError,
        json.JSONDecodeError,
        Task12ContractError,
    ) as exc:
        print(f"TASK 12 FACTORY FREEZE: FAIL — {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
