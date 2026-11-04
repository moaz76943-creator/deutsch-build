#!/usr/bin/env python3
"""Fail-closed, machine-readable DEUTSCH claim ledger core.

This module is deliberately transport-agnostic. The durable ledger lives in GitHub;
callers MUST use GitHub's current file/blob SHA as the compare-and-swap precondition
when writing the returned JSON. A successful local transition is not write authority.

The core never steals expired claims: expiration becomes RECONCILIATION_REQUIRED.
It also refuses stale main/branch observations, conflicting task/branch writers, and
future-dated heartbeats. Fencing epochs increase monotonically across all claims.
"""
from __future__ import annotations

from datetime import datetime, timedelta, timezone
from pathlib import PurePosixPath
import argparse
import hashlib
import json
import re
import sys
from typing import Any, Callable

REPO = "sali97m-cpu/deutsch-bilarabi"
SCHEMA_VERSION = 1
SHA = re.compile(r"[0-9a-f]{40}\Z")
ID = re.compile(r"[A-Za-z0-9][A-Za-z0-9._:/-]{0,127}\Z")
ALLOWED_STATES = {"ACTIVE", "RELEASED", "RECONCILIATION_REQUIRED"}
BLOCKED_DISPATCH = {
    "BLOCKED_ACTIVE_CLAIM",
    "UNKNOWN_CLAIM_COVERAGE",
    "STALE_GIT_SNAPSHOT",
    "RECONCILIATION_REQUIRED",
    "CONFLICTING_LEDGER",
}
MAX_FUTURE_SKEW = timedelta(seconds=30)


class LedgerError(ValueError):
    """Invalid or unsafe ledger transition."""


class ClaimConflict(LedgerError):
    """A live claim conflicts with the proposed writer."""


def _instant(value: Any, label: str) -> datetime:
    if not isinstance(value, str):
        raise LedgerError(f"invalid {label}")
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError as exc:
        raise LedgerError(f"invalid {label}") from exc
    if parsed.tzinfo is None:
        raise LedgerError(f"timezone required for {label}")
    return parsed.astimezone(timezone.utc)


def _stamp(value: datetime) -> str:
    if not isinstance(value, datetime) or value.tzinfo is None:
        raise LedgerError("timestamp must be timezone-aware")
    return value.astimezone(timezone.utc).isoformat().replace("+00:00", "Z")


def _id(value: Any, label: str) -> str:
    if not isinstance(value, str) or not ID.fullmatch(value):
        raise LedgerError(f"invalid {label}")
    return value


def _sha(value: Any, label: str) -> str:
    if not isinstance(value, str) or not SHA.fullmatch(value):
        raise LedgerError(f"invalid {label}")
    return value


def require_blob_cas_match(*, expected_blob_sha: str, observed_blob_sha: str) -> str:
    """Fail closed when a durable-ledger CAS snapshot is stale.

    This is a transport-boundary preflight. The authoritative GitHub Contents
    API write must still include the previously-read blob SHA; an API conflict
    (for example HTTP 409) is a failed CAS and must never be retried as success.
    """
    expected = _sha(expected_blob_sha, "expected_blob_sha")
    observed = _sha(observed_blob_sha, "observed_blob_sha")
    if expected != observed:
        raise ClaimConflict("stale ledger blob SHA; concurrent writer won CAS")
    return observed


def _paths(value: Any) -> list[str]:
    if not isinstance(value, list) or not value:
        raise LedgerError("paths must be a non-empty list")
    out: list[str] = []
    for path in value:
        if not isinstance(path, str) or not path or len(path) > 250:
            raise LedgerError("invalid path")
        bits = path.split("/")
        if (path.startswith("/") or "\\" in path or any(b in ("", ".", "..") for b in bits)
                or any(ch in path for ch in "*?[") or str(PurePosixPath(path)) != path):
            raise LedgerError("path must be canonical and exact")
        if path in out:
            raise LedgerError("duplicate path")
        out.append(path)
    return out


def _scope_overlaps(left: list[str], right: list[str]) -> bool:
    """Component-aware exact and ancestor/descendant mutable-path collisions."""
    return any(a == b or a.startswith(b + "/") or b.startswith(a + "/")
               for a in left for b in right)


def empty_ledger(main_sha: str) -> dict[str, Any]:
    return {
        "schema_version": SCHEMA_VERSION,
        "repo": REPO,
        "generation": 0,
        "last_epoch": 0,
        "main_sha": _sha(main_sha, "main_sha"),
        "claims_complete": True,
        "claims": [],
    }


def _normalize_claim(raw: Any, now: datetime) -> dict[str, Any]:
    if not isinstance(raw, dict):
        raise LedgerError("invalid claim")
    claim_id = _id(raw.get("claim_id"), "claim_id")
    task_id = _id(raw.get("task_id"), "task_id")
    owner_role = _id(raw.get("owner_role"), "owner_role")
    branch = _id(raw.get("branch"), "branch")
    head_sha = _sha(raw.get("head_sha"), "head_sha")
    paths = _paths(raw.get("paths"))
    epoch = raw.get("epoch")
    if type(epoch) is not int or epoch < 1:
        raise LedgerError("epoch must be a positive integer")
    state = raw.get("state")
    if state not in ALLOWED_STATES:
        raise LedgerError("unknown claim state")
    issued = _instant(raw.get("issued_at"), "issued_at")
    heartbeat = _instant(raw.get("heartbeat_at"), "heartbeat_at")
    expires = _instant(raw.get("expires_at"), "expires_at")
    if heartbeat > now + MAX_FUTURE_SKEW:
        raise LedgerError("future heartbeat exceeds server-observation skew")
    if not issued <= heartbeat <= expires:
        raise LedgerError("inconsistent claim timestamps")
    if expires - heartbeat > timedelta(minutes=180):
        raise LedgerError("persisted claim TTL exceeds 180 minutes")
    effective = state
    if state == "ACTIVE" and expires <= now:
        effective = "RECONCILIATION_REQUIRED"
    result = dict(raw)
    result.update({
        "claim_id": claim_id,
        "task_id": task_id,
        "owner_role": owner_role,
        "branch": branch,
        "head_sha": head_sha,
        "paths": paths,
        "epoch": epoch,
        "effective_state": effective,
    })
    return result


def validate_ledger(ledger: Any, *, now: datetime) -> dict[str, Any]:
    if not isinstance(now, datetime) or now.tzinfo is None:
        raise LedgerError("trusted now must be timezone-aware")
    now = now.astimezone(timezone.utc)
    if not isinstance(ledger, dict):
        raise LedgerError("ledger must be an object")
    if (type(ledger.get("schema_version")) is not int
            or ledger.get("schema_version") != SCHEMA_VERSION
            or ledger.get("repo") != REPO):
        raise LedgerError("wrong ledger schema/repository")
    generation = ledger.get("generation")
    if type(generation) is not int or generation < 0:
        raise LedgerError("generation must be a non-negative integer")
    main_sha = _sha(ledger.get("main_sha"), "main_sha")
    if ledger.get("claims_complete") is not True:
        raise LedgerError("claim inventory is incomplete")
    raw = ledger.get("claims")
    if not isinstance(raw, list):
        raise LedgerError("claims must be a list")
    claims = [_normalize_claim(item, now) for item in raw]
    ids = [c["claim_id"] for c in claims]
    if len(ids) != len(set(ids)):
        raise LedgerError("duplicate claim_id")
    active_epochs = [c["epoch"] for c in claims]
    if len(active_epochs) != len(set(active_epochs)):
        raise LedgerError("fencing epochs must be globally unique")
    # Append-only epoch history detects corrupt remote snapshots with truncated
    # claims; independently authenticated Git ancestry remains a transport gate.
    highwater = ledger.get("last_epoch")
    if highwater is None and generation == 0 and not claims:
        highwater = 0  # pristine legacy bootstrap manifest only
    if type(highwater) is not int or not 0 <= highwater <= generation:
        raise LedgerError("invalid or missing fencing epoch high-water")
    # Length first avoids allocating attacker-sized ranges for a corrupt JSON
    # high-water mark while preserving append-only consecutive epoch checks.
    if len(active_epochs) != highwater or sorted(active_epochs) != list(range(1, highwater + 1)):
        raise LedgerError("truncated claim history or fencing epoch gap")
    # This also validates persisted remote JSON; only checking at acquire time
    # would let a faulty transport/import bypass the exclusivity invariant.
    unresolved = [c for c in claims if c["effective_state"] != "RELEASED"]
    for i, first in enumerate(unresolved):
        for second in unresolved[i + 1:]:
            if (first["task_id"] == second["task_id"]
                    or first["branch"] == second["branch"]
                    or _scope_overlaps(first["paths"], second["paths"])):
                raise LedgerError("conflicting unresolved claims in persisted ledger")
    # Released NEW epochs also fence OLD writes. In a corrupted/imported ledger,
    # reviving an older claim after a newer overlapping epoch has finished must
    # NEVER regain write authorization merely because pairwise ACTIVE checks pass.
    for old_claim in unresolved:
        for later_claim in claims:
            if later_claim["epoch"] <= old_claim["epoch"]:
                continue
            if (old_claim["task_id"] == later_claim["task_id"]
                    or old_claim["branch"] == later_claim["branch"]
                    or _scope_overlaps(old_claim["paths"], later_claim["paths"])):
                raise LedgerError("unresolved claim superseded by later fencing epoch")
    normalized = dict(ledger)
    normalized.update({"generation": generation, "last_epoch": highwater,
                       "main_sha": main_sha, "claims": claims})
    return normalized


def _next_epoch(ledger: dict[str, Any]) -> int:
    return ledger["last_epoch"] + 1


def _claim_id(task_id: str, owner_role: str, epoch: int, head_sha: str) -> str:
    # Fixed-length identity: valid maximum-length task IDs must not make the
    # generated claim_id violate this module's own 128-character ID contract.
    digest = hashlib.sha256(f"{task_id}\0{owner_role}\0{epoch}\0{head_sha}".encode()).hexdigest()[:24]
    suffix = f"/{epoch}/{digest}"
    limit = 128 - len("claim/") - len(suffix)
    return f"claim/{task_id[:limit]}{suffix}"


def acquire(
    ledger: Any,
    request: Any,
    *,
    now: datetime,
    observed_main_sha: str,
    observed_branch_head: str,
    expected_generation: int,
    ttl_minutes: int = 90,
) -> dict[str, Any]:
    """Return the next ledger state or fail closed.

    The caller MUST persist the returned state with GitHub Contents API using the
    previously-read ledger blob SHA. If that CAS fails, this transition is void.
    """
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    current_main = _sha(observed_main_sha, "observed_main_sha")
    current_head = _sha(observed_branch_head, "observed_branch_head")
    if normalized["main_sha"] != current_main:
        raise LedgerError("stale main snapshot")
    if not isinstance(request, dict):
        raise LedgerError("request must be an object")
    task_id = _id(request.get("task_id"), "task_id")
    owner_role = _id(request.get("owner_role"), "owner_role")
    branch = _id(request.get("branch"), "branch")
    expected_head = _sha(request.get("expected_head_sha"), "expected_head_sha")
    paths = _paths(request.get("paths"))
    if expected_head != current_head:
        raise LedgerError("stale branch head")
    if type(ttl_minutes) is not int or ttl_minutes < 5 or ttl_minutes > 180:
        raise LedgerError("ttl_minutes must be between 5 and 180")

    unresolved = [c for c in normalized["claims"] if c["effective_state"] != "RELEASED"]
    for claim in unresolved:
        if claim["effective_state"] == "RECONCILIATION_REQUIRED":
            if (claim["task_id"] == task_id or claim["branch"] == branch
                    or _scope_overlaps(claim["paths"], paths)):
                raise ClaimConflict("expired claim requires reconciliation; automatic theft forbidden")
        if claim["effective_state"] == "ACTIVE":
            if claim["task_id"] == task_id:
                raise ClaimConflict("same task already has an active claim")
            if claim["branch"] == branch:
                raise ClaimConflict("same branch already has an active writer")
            if _scope_overlaps(claim["paths"], paths):
                raise ClaimConflict("requested files overlap an active claim")

    epoch = _next_epoch(normalized)
    expires = now.astimezone(timezone.utc) + timedelta(minutes=ttl_minutes)
    claim = {
        "claim_id": _claim_id(task_id, owner_role, epoch, current_head),
        "task_id": task_id,
        "owner_role": owner_role,
        "branch": branch,
        "head_sha": current_head,
        "paths": paths,
        "epoch": epoch,
        "state": "ACTIVE",
        "issued_at": _stamp(now),
        "heartbeat_at": _stamp(now),
        "expires_at": _stamp(expires),
    }
    result = {k: v for k, v in normalized.items() if k != "claims"}
    result["generation"] = normalized["generation"] + 1
    result["last_epoch"] = epoch
    result["claims"] = [{k: v for k, v in c.items() if k != "effective_state"}
                        for c in normalized["claims"]] + [claim]
    return result


def release(
    ledger: Any,
    *,
    claim_id: str,
    owner_role: str,
    epoch: int,
    now: datetime,
    expected_generation: int,
) -> dict[str, Any]:
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    cid = _id(claim_id, "claim_id")
    owner = _id(owner_role, "owner_role")
    if type(epoch) is not int or epoch < 1:
        raise LedgerError("invalid epoch")
    found = None
    claims = []
    for c in normalized["claims"]:
        plain = {k: v for k, v in c.items() if k != "effective_state"}
        if c["claim_id"] == cid:
            found = c
            if c["owner_role"] != owner or c["epoch"] != epoch:
                raise ClaimConflict("fencing token/owner mismatch")
            if c["effective_state"] == "RELEASED":
                raise ClaimConflict("claim is already released")
            if c["effective_state"] == "RECONCILIATION_REQUIRED":
                raise ClaimConflict("expired claim requires explicit reconciliation, not release")
            # Hosts within the allowed observation skew can still disagree on
            # ordering. Never emit an invalid issued/heartbeat chronology.
            if now.astimezone(timezone.utc) < _instant(c["heartbeat_at"], "heartbeat_at"):
                raise LedgerError("regressing release timestamp")
            plain["state"] = "RELEASED"
            plain["heartbeat_at"] = _stamp(now)
        claims.append(plain)
    if found is None:
        raise LedgerError("claim not found")
    result = {k: v for k, v in normalized.items() if k != "claims"}
    result["generation"] += 1
    result["claims"] = claims
    return result


def renew(
    ledger: Any,
    *,
    claim_id: str,
    owner_role: str,
    epoch: int,
    now: datetime,
    observed_main_sha: str,
    observed_branch_head: str,
    expected_generation: int,
    ttl_minutes: int = 90,
) -> dict[str, Any]:
    """Renew a still-active exact fencing token; transport must CAS this state."""
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    if normalized["main_sha"] != _sha(observed_main_sha, "observed_main_sha"):
        raise LedgerError("stale main snapshot")
    head = _sha(observed_branch_head, "observed_branch_head")
    cid, owner = _id(claim_id, "claim_id"), _id(owner_role, "owner_role")
    if type(epoch) is not int or epoch < 1:
        raise LedgerError("invalid epoch")
    if type(ttl_minutes) is not int or not 5 <= ttl_minutes <= 180:
        raise LedgerError("ttl_minutes must be between 5 and 180")
    found = False
    claims = []
    for c in normalized["claims"]:
        plain = {k: v for k, v in c.items() if k != "effective_state"}
        if c["claim_id"] == cid:
            found = True
            if c["owner_role"] != owner or c["epoch"] != epoch:
                raise ClaimConflict("fencing token/owner mismatch")
            if c["effective_state"] != "ACTIVE":
                raise ClaimConflict("cannot renew inactive/expired claim")
            if c["head_sha"] != head:
                raise LedgerError("stale branch head")
            if now.astimezone(timezone.utc) < _instant(c["heartbeat_at"], "heartbeat_at"):
                raise LedgerError("regressing renewal timestamp")
            plain["heartbeat_at"] = _stamp(now)
            plain["expires_at"] = _stamp(max(
                _instant(c["expires_at"], "expires_at"),
                now.astimezone(timezone.utc) + timedelta(minutes=ttl_minutes),
            ))
        claims.append(plain)
    if not found:
        raise LedgerError("claim not found")
    return {**{k: v for k, v in normalized.items() if k != "claims"},
            "generation": normalized["generation"] + 1, "claims": claims}



def persist_expiry_observation(
    ledger: Any,
    *,
    claim_id: str,
    expected_epoch: int,
    now: datetime,
    expected_generation: int,
) -> dict[str, Any]:
    """Durably fence an observed expiry; caller MUST CAS the returned ledger.

    Expiry derived only from a reader's wall clock is reversible if a later
    reader's clock regresses. Once an authoritative reader observes expiry,
    this transition persists RECONCILIATION_REQUIRED in the ledger itself.
    The transport must write it with the previously-read GitHub blob SHA.
    """
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    cid = _id(claim_id, "claim_id")
    if type(expected_epoch) is not int or expected_epoch < 1:
        raise LedgerError("invalid expected_epoch")

    found = None
    claims = []
    for c in normalized["claims"]:
        plain = {k: v for k, v in c.items() if k != "effective_state"}
        if c["claim_id"] == cid:
            found = c
            if c["epoch"] != expected_epoch:
                raise ClaimConflict("stale fencing epoch")
            if c["state"] == "RELEASED":
                raise ClaimConflict("released claim cannot observe expiry")
            if c["state"] == "RECONCILIATION_REQUIRED":
                raise ClaimConflict("expiry observation already persisted")
            if c["effective_state"] != "RECONCILIATION_REQUIRED":
                raise ClaimConflict("claim has not expired")
            plain["state"] = "RECONCILIATION_REQUIRED"
            plain["expiry_observed_at"] = _stamp(now)
        claims.append(plain)

    if found is None:
        raise LedgerError("claim not found")
    result = {k: v for k, v in normalized.items() if k != "claims"}
    result["generation"] += 1
    result["claims"] = claims
    return result

def reconcile_expired(
    ledger: Any,
    *,
    claim_id: str,
    expected_epoch: int,
    reconciler_role: str,
    now: datetime,
    expected_generation: int,
    evidence: dict[str, Any] | None = None,
    verify_quiescence: Callable[[dict[str, Any], dict[str, Any]], bool] | None = None,
) -> dict[str, Any]:
    """Close expiry only with externally VERIFIED owner-stop/branch evidence.

    The pure core deliberately has NO default verifier. The trusted transport
    must inject an authenticated verifier; caller-supplied booleans or TTL alone
    are NEVER evidence. No automatic reconciliation after a crashed writer.
    """
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    cid = _id(claim_id, "claim_id")
    _id(reconciler_role, "reconciler_role")
    if type(expected_epoch) is not int or expected_epoch < 1:
        raise LedgerError("invalid expected_epoch")
    found = None
    claims = []
    for c in normalized["claims"]:
        plain = {k: v for k, v in c.items() if k != "effective_state"}
        if c["claim_id"] == cid:
            found = c
            if c["epoch"] != expected_epoch:
                raise ClaimConflict("stale fencing epoch")
            if c["effective_state"] != "RECONCILIATION_REQUIRED":
                raise ClaimConflict("only expired reconciliation-required claims may be reconciled")
            if (not isinstance(evidence, dict)
                    or evidence.get("claim_id") != c["claim_id"]
                    or type(evidence.get("epoch")) is not int
                    or evidence.get("epoch") != c["epoch"]
                    or evidence.get("head_sha") != c["head_sha"]
                    or not callable(verify_quiescence)
                    or verify_quiescence(c, evidence) is not True):
                raise ClaimConflict("independently verified quiescence evidence required")
            plain["state"] = "RELEASED"
            # Preserve the last valid heartbeat: an expired claim's reconciliation
            # occurs after expires_at, so writing now into heartbeat_at would make
            # the released ledger invalid on its next read.
            plain["reconciled_by"] = reconciler_role
            plain["reconciled_at"] = _stamp(now)
        claims.append(plain)
    if found is None:
        raise LedgerError("claim not found")
    result = {k: v for k, v in normalized.items() if k != "claims"}
    result["generation"] += 1
    result["claims"] = claims
    return result


def refresh_main(
    ledger: Any,
    *,
    expected_old_main_sha: str,
    new_main_sha: str,
    now: datetime,
    expected_generation: int,
) -> dict[str, Any]:
    """Advance the ledger's main baseline only while no unresolved claim exists."""
    normalized = validate_ledger(ledger, now=now)
    if type(expected_generation) is not int or expected_generation < 0:
        raise LedgerError("invalid expected_generation")
    if normalized["generation"] != expected_generation:
        raise LedgerError("stale ledger generation")
    old = _sha(expected_old_main_sha, "expected_old_main_sha")
    new = _sha(new_main_sha, "new_main_sha")
    if normalized["main_sha"] != old:
        raise LedgerError("stale main baseline")
    unresolved = [c for c in normalized["claims"] if c["effective_state"] != "RELEASED"]
    if unresolved:
        raise ClaimConflict("cannot advance main while claims are unresolved")
    result = {k: v for k, v in normalized.items() if k != "claims"}
    result["generation"] += 1
    result["main_sha"] = new
    result["claims"] = [{k: v for k, v in c.items() if k != "effective_state"}
                        for c in normalized["claims"]]
    return result


def dispatch_allowed(
    status: str,
    *,
    claim: dict[str, Any] | None,
    branch_head: str,
    now: datetime,
) -> bool:
    """Final dispatch gate: re-evaluate expiry with trusted current time."""
    if status in BLOCKED_DISPATCH or status != "CLAIM_GRANTED":
        return False
    if not isinstance(claim, dict):
        return False
    try:
        current = _normalize_claim(claim, now.astimezone(timezone.utc))
        return (current["effective_state"] == "ACTIVE"
                and current["head_sha"] == _sha(branch_head, "branch head"))
    except (LedgerError, AttributeError):
        return False


def fenced_dispatch_allowed(
    status: str,
    *,
    ledger: Any,
    claim_id: str,
    owner_role: str,
    epoch: int,
    expected_generation: int,
    observed_main_sha: str,
    branch_head: str,
    now: datetime,
) -> bool:
    """Pure fresh-ledger fencing check; caller MUST fetch authoritative state.

    Not a server lock: the authenticated transport must fetch/CAS the actual
    durable ledger and re-check this predicate immediately before every write.
    """
    try:
        if (type(epoch) is not int or epoch < 1
                or type(expected_generation) is not int
                or expected_generation < 0):
            return False
        current = validate_ledger(ledger, now=now)
        if (current["generation"] != expected_generation
                or current["main_sha"] != _sha(observed_main_sha, "observed_main_sha")):
            return False
        for claim in current["claims"]:
            if (claim["claim_id"] == claim_id
                    and claim["owner_role"] == owner_role
                    and claim["epoch"] == epoch):
                return dispatch_allowed(status, claim=claim, branch_head=branch_head, now=now)
    except (LedgerError, AttributeError, TypeError):
        return False
    return False


def _load(path: str) -> Any:
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="DEUTSCH claim-ledger pure transition core")
    p.add_argument("ledger")
    p.add_argument("--validate-at", required=True, help="trusted observation time, ISO-8601")
    args = p.parse_args(argv)
    try:
        value = validate_ledger(_load(args.ledger), now=_instant(args.validate_at, "validate-at"))
        value["claims"] = [{k: v for k, v in c.items() if k != "effective_state"}
                           for c in value["claims"]]
        print(json.dumps(value, ensure_ascii=False, sort_keys=True, indent=2))
        return 0
    except (OSError, json.JSONDecodeError, LedgerError) as exc:
        print(f"claim ledger invalid: {exc}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
