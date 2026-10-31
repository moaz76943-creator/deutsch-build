#!/usr/bin/env python3
"""Atomic quarantine and fault-isolation guard for automation tasks.

The guard is deliberately local-state only: it never mutates Git refs or base
branches. It isolates delinquent task records, releases active claim slots, and
writes an append-only JSON-lines audit trail.
"""

from __future__ import annotations

import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import fcntl
import json
import os
from pathlib import Path
import tempfile
from typing import Any, Iterator, Mapping, MutableMapping, Sequence

HERE = Path(__file__).resolve().parent
DEFAULT_PIPELINE = HERE / "pipeline_state.json"
DEFAULT_CLAIMS = HERE / "claims.json"
DEFAULT_QUARANTINE = HERE / "quarantine.json"
DEFAULT_AUDIT = HERE / "quarantine_audit.log"
DEFAULT_STALE_THRESHOLD = 3
ACTIVE_CLAIM_STATES = frozenset({"ACTIVE", "CLAIMED", "IN_PROGRESS"})


class QuarantineError(ValueError):
    """Raised when quarantine state is malformed or an unsafe action is requested."""


def _timestamp(now: str | datetime | None = None) -> str:
    if now is None:
        return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    if isinstance(now, datetime):
        if now.tzinfo is None or now.utcoffset() is None:
            raise QuarantineError("timestamp must be timezone-aware")
        return now.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")
    if isinstance(now, str) and now.strip():
        return now.strip()
    raise QuarantineError("timestamp must be a non-empty string or timezone-aware datetime")


def _load_json(path: Path, *, missing: Any = None) -> Any:
    if not path.exists():
        return missing
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise QuarantineError(f"cannot read JSON file {path}: {exc}") from exc


def _atomic_write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=f".{path.name}.", suffix=".tmp", dir=path.parent)
    temp_path = Path(temp_name)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            json.dump(value, handle, ensure_ascii=False, indent=2, sort_keys=True)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_path, path)
        try:
            directory_fd = os.open(path.parent, os.O_RDONLY | getattr(os, "O_DIRECTORY", 0))
        except OSError:
            directory_fd = None
        if directory_fd is not None:
            try:
                os.fsync(directory_fd)
            finally:
                os.close(directory_fd)
    except OSError as exc:
        raise QuarantineError(f"cannot atomically write {path}: {exc}") from exc
    finally:
        try:
            temp_path.unlink()
        except FileNotFoundError:
            pass


def _append_audit(path: Path, record: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = json.dumps(dict(record), ensure_ascii=False, sort_keys=True) + "\n"
    try:
        fd = os.open(path, os.O_CREAT | os.O_WRONLY | os.O_APPEND, 0o644)
        try:
            os.write(fd, payload.encode("utf-8"))
            os.fsync(fd)
        finally:
            os.close(fd)
    except OSError as exc:
        raise QuarantineError(f"cannot append audit log {path}: {exc}") from exc


@contextmanager
def _guard_lock(quarantine_path: Path) -> Iterator[None]:
    lock_path = quarantine_path.with_name(quarantine_path.name + ".lock")
    lock_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        with lock_path.open("a+", encoding="utf-8") as lock_file:
            fcntl.flock(lock_file.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(lock_file.fileno(), fcntl.LOCK_UN)
    except OSError as exc:
        raise QuarantineError(f"cannot lock quarantine state: {exc}") from exc


def _pipeline_tasks(value: Any) -> list[MutableMapping[str, Any]]:
    if not isinstance(value, Mapping):
        raise QuarantineError("pipeline state root must be an object")
    tasks = value.get("tasks")
    if not isinstance(tasks, list):
        raise QuarantineError("pipeline state must contain a tasks array")
    out: list[MutableMapping[str, Any]] = []
    seen: set[str] = set()
    for index, task in enumerate(tasks):
        if not isinstance(task, MutableMapping):
            raise QuarantineError(f"task[{index}] must be an object")
        task_id = task.get("task_id")
        if not isinstance(task_id, str) or not task_id.strip():
            raise QuarantineError(f"task[{index}] missing task_id")
        if task_id in seen:
            raise QuarantineError(f"duplicate task_id: {task_id}")
        seen.add(task_id)
        out.append(task)
    return out


def _numeric_count(value: Any) -> int:
    if isinstance(value, bool):
        return int(value)
    if isinstance(value, int):
        return max(value, 0)
    if isinstance(value, (list, tuple, set)):
        return len(value)
    return 0


def _stale_count(task: Mapping[str, Any]) -> int:
    candidates = [
        task.get("stale_count"),
        task.get("stale_attempts"),
        task.get("stale_cycles"),
        task.get("stale_scans"),
        task.get("consecutive_stale_count"),
        task.get("repeated_stale_count"),
        task.get("stale_events"),
        task.get("stale_observations"),
    ]
    return max((_numeric_count(value) for value in candidates), default=0)


def _has_boundary_violation(task: Mapping[str, Any]) -> bool:
    for key in (
        "boundary_violation",
        "boundary_violations",
        "boundary_breaches",
        "scope_violations",
        "out_of_scope_files",
        "changed_files_outside_scope",
    ):
        value = task.get(key)
        if isinstance(value, bool) and value:
            return True
        if isinstance(value, int) and not isinstance(value, bool) and value > 0:
            return True
        if isinstance(value, (str, list, tuple, set, dict)) and len(value) > 0:
            return True
    return False


def quarantine_reasons(task: Mapping[str, Any], *, stale_threshold: int = DEFAULT_STALE_THRESHOLD) -> list[str]:
    if isinstance(stale_threshold, bool) or not isinstance(stale_threshold, int) or stale_threshold < 1:
        raise QuarantineError("stale threshold must be an integer >= 1")
    reasons: list[str] = []
    if str(task.get("status", "")).upper() == "FAILED":
        reasons.append("FAILED")
    if _stale_count(task) >= stale_threshold:
        reasons.append("REPEATEDLY_STALE")
    if _has_boundary_violation(task):
        reasons.append("BOUNDARY_VIOLATION")
    return reasons


def _load_quarantine(path: Path) -> dict[str, Any]:
    data = _load_json(path, missing={"schema_version": 1, "entries": []})
    if not isinstance(data, dict):
        raise QuarantineError("quarantine root must be an object")
    if data.get("schema_version", 1) != 1:
        raise QuarantineError("unsupported quarantine schema_version")
    entries = data.get("entries", [])
    if not isinstance(entries, list) or not all(isinstance(item, dict) for item in entries):
        raise QuarantineError("quarantine entries must be an array of objects")
    data.setdefault("schema_version", 1)
    data["entries"] = entries
    return data


def _claims_records(data: Any) -> tuple[list[MutableMapping[str, Any]], str]:
    if isinstance(data, list):
        if not all(isinstance(item, MutableMapping) for item in data):
            raise QuarantineError("claims list must contain objects")
        return data, "list"
    if isinstance(data, MutableMapping):
        claims = data.get("claims")
        if not isinstance(claims, list) or not all(isinstance(item, MutableMapping) for item in claims):
            raise QuarantineError("claims object must contain a claims array")
        return claims, "object"
    raise QuarantineError("claims must be an array or an object with claims")


def _claim_is_active(claim: Mapping[str, Any]) -> bool:
    state = claim.get("status", claim.get("state", ""))
    return str(state).upper() in ACTIVE_CLAIM_STATES


def _release_claims(data: Any, task_ids: set[str], *, at: str) -> list[str]:
    records, _ = _claims_records(data)
    released: list[str] = []
    released_seen: set[str] = set()
    for claim in records:
        task_id = claim.get("task_id")
        if task_id not in task_ids or not _claim_is_active(claim):
            continue
        if "status" in claim:
            claim["status"] = "RELEASED"
        else:
            claim["state"] = "RELEASED"
        claim["released_at"] = at
        claim["release_reason"] = "QUARANTINED"
        if task_id not in released_seen:
            released.append(task_id)
            released_seen.add(task_id)
    return released


def scan_and_quarantine(
    pipeline_path: str | Path = DEFAULT_PIPELINE,
    claims_path: str | Path = DEFAULT_CLAIMS,
    quarantine_path: str | Path = DEFAULT_QUARANTINE,
    audit_path: str | Path = DEFAULT_AUDIT,
    *,
    stale_threshold: int = DEFAULT_STALE_THRESHOLD,
    now: str | datetime | None = None,
) -> dict[str, list[str]]:
    """Isolate delinquent tasks and release their occupied claim slots.

    Quarantine state is persisted before claim release, so a crash can leave a
    claim occupied but cannot lose the isolation decision. A subsequent scan is
    idempotent and releases any such leftover active claim.
    """
    pipeline_path = Path(pipeline_path)
    claims_path = Path(claims_path)
    quarantine_path = Path(quarantine_path)
    audit_path = Path(audit_path)
    at = _timestamp(now)

    pipeline = _load_json(pipeline_path)
    if pipeline is None:
        raise QuarantineError(f"pipeline state file not found: {pipeline_path}")
    tasks = _pipeline_tasks(pipeline)

    candidates: list[tuple[MutableMapping[str, Any], list[str]]] = []
    for task in tasks:
        reasons = quarantine_reasons(task, stale_threshold=stale_threshold)
        if reasons:
            candidates.append((task, reasons))

    with _guard_lock(quarantine_path):
        quarantine = _load_quarantine(quarantine_path)
        active_ids = {
            entry.get("task_id")
            for entry in quarantine["entries"]
            if entry.get("state") == "QUARANTINED"
        }
        newly_quarantined: list[str] = []
        reason_by_task: dict[str, list[str]] = {}
        branch_by_task: dict[str, Any] = {}

        for task, reasons in candidates:
            task_id = task["task_id"]
            reason_by_task[task_id] = reasons
            branch_by_task[task_id] = task.get("branch")
            if task_id in active_ids:
                continue
            entry = {
                "task_id": task_id,
                "branch": task.get("branch"),
                "state": "QUARANTINED",
                "reasons": reasons,
                "isolated_at": at,
            }
            quarantine["entries"].append(entry)
            active_ids.add(task_id)
            newly_quarantined.append(task_id)

        if newly_quarantined:
            _atomic_write_json(quarantine_path, quarantine)

        claims = _load_json(claims_path, missing=None)
        released_claims: list[str] = []
        if claims is not None:
            released_claims = _release_claims(claims, set(active_ids), at=at)
            if released_claims:
                _atomic_write_json(claims_path, claims)

        for task_id in newly_quarantined:
            _append_audit(
                audit_path,
                {
                    "event": "QUARANTINED",
                    "task_id": task_id,
                    "branch": branch_by_task.get(task_id),
                    "reasons": reason_by_task[task_id],
                    "claim_released": task_id in released_claims,
                    "at": at,
                },
            )
        for task_id in released_claims:
            if task_id not in newly_quarantined:
                _append_audit(
                    audit_path,
                    {
                        "event": "CLAIM_RELEASED_FOR_QUARANTINED_TASK",
                        "task_id": task_id,
                        "claim_released": True,
                        "at": at,
                    },
                )

    return {"quarantined": newly_quarantined, "released_claims": released_claims}


def release_task(
    task_id: str,
    quarantine_path: str | Path = DEFAULT_QUARANTINE,
    audit_path: str | Path = DEFAULT_AUDIT,
    *,
    now: str | datetime | None = None,
) -> dict[str, Any]:
    """Release one task from active quarantine while preserving its history."""
    if not isinstance(task_id, str) or not task_id.strip():
        raise QuarantineError("task_id must be non-empty")
    quarantine_path = Path(quarantine_path)
    audit_path = Path(audit_path)
    at = _timestamp(now)

    with _guard_lock(quarantine_path):
        quarantine = _load_quarantine(quarantine_path)
        target = None
        for entry in reversed(quarantine["entries"]):
            if entry.get("task_id") == task_id and entry.get("state") == "QUARANTINED":
                target = entry
                break
        if target is None:
            raise QuarantineError(f"task {task_id!r} is not actively quarantined")
        target["state"] = "RELEASED"
        target["released_at"] = at
        _atomic_write_json(quarantine_path, quarantine)
        _append_audit(audit_path, {"event": "QUARANTINE_RELEASED", "task_id": task_id, "at": at})
        return dict(target)


def report_quarantine(quarantine_path: str | Path = DEFAULT_QUARANTINE) -> dict[str, Any]:
    """Return a deterministic machine-readable quarantine summary."""
    quarantine = _load_quarantine(Path(quarantine_path))
    active = [dict(entry) for entry in quarantine["entries"] if entry.get("state") == "QUARANTINED"]
    released = [dict(entry) for entry in quarantine["entries"] if entry.get("state") == "RELEASED"]
    return {
        "active_count": len(active),
        "released_count": len(released),
        "active": active,
        "released": released,
    }


# Compact aliases for callers that prefer command-shaped APIs.
scan = scan_and_quarantine
release = release_task
report = report_quarantine


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Quarantine broken automation tasks and free claim slots")
    action = parser.add_mutually_exclusive_group(required=True)
    action.add_argument("--scan", action="store_true", help="scan pipeline state and quarantine delinquent tasks")
    action.add_argument("--release", metavar="TASK_ID", help="release a task from quarantine")
    action.add_argument("--report", action="store_true", help="report current quarantine state")
    parser.add_argument("--pipeline", type=Path, default=DEFAULT_PIPELINE)
    parser.add_argument("--claims", type=Path, default=DEFAULT_CLAIMS)
    parser.add_argument("--quarantine", type=Path, default=DEFAULT_QUARANTINE)
    parser.add_argument("--audit", type=Path, default=DEFAULT_AUDIT)
    parser.add_argument("--stale-threshold", type=int, default=DEFAULT_STALE_THRESHOLD)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        if args.scan:
            payload = scan_and_quarantine(
                args.pipeline,
                args.claims,
                args.quarantine,
                args.audit,
                stale_threshold=args.stale_threshold,
            )
        elif args.release is not None:
            payload = release_task(args.release, args.quarantine, args.audit)
        else:
            payload = report_quarantine(args.quarantine)
    except QuarantineError as exc:
        print(json.dumps({"error": str(exc)}, sort_keys=True), file=os.sys.stderr)
        return 2

    print(json.dumps(payload, ensure_ascii=False, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
