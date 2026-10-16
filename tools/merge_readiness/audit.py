#!/usr/bin/env python3
"""Read-only, bounded GitHub PR merge-readiness inventory using authenticated gh CLI.

Never updates GitHub or claims that a clean filename matrix proves merge safety.
Run via: python3 -m tools.merge_readiness.audit --output merge_audit.json
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable

PUBLIC_REPO = "moaz76943-creator/-offline-packs-store"
PRIVATE_REPO = "moaz76943-creator/deutsch-build"
REPO_PATTERN = re.compile(r"^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$")
MAX_PAGES = 6
MAX_FILES_PAGES = 3
PAGE_SIZE = 100
MAX_PRS = 500


class AuditError(RuntimeError):
    """Read-only collection failed; do not issue a partial success claim."""


def gh_get(path: str, *, timeout: int = 25) -> Any:
    """Read only from api.github.com through gh authentication, without a shell."""
    if not path.startswith("repos/") or any(ch in path for ch in "\n\r\x00"):
        raise AuditError("invalid GitHub API endpoint")
    try:
        completed = subprocess.run(
            ["gh", "api", "--method", "GET", path],
            capture_output=True,
            text=True,
            check=False,
            timeout=timeout,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise AuditError("read-only GitHub request unavailable or timed out") from exc
    if completed.returncode:
        # Do not print arbitrary CLI errors containing credentials or secret values.
        raise AuditError(f"read-only GitHub request failed ({completed.returncode})")
    try:
        return json.loads(completed.stdout)
    except ValueError as exc:
        raise AuditError("GitHub returned invalid JSON") from exc


def validate_repo(name: str) -> str:
    if (not isinstance(name, str) or not REPO_PATTERN.fullmatch(name)
            or any(part in (".", "..") for part in name.split("/"))):
        raise AuditError("invalid repository name")
    return name


def fetch_open_prs(repo: str, fetch: Callable[[str], Any], limit: int) -> list[dict[str, Any]]:
    validate_repo(repo)
    if not (1 <= limit <= MAX_PRS):
        raise AuditError("PR limit must be 1..500")
    found: list[dict[str, Any]] = []
    pages = min(MAX_PAGES, (limit + PAGE_SIZE - 1) // PAGE_SIZE)
    for page in range(1, pages + 1):
        rows = fetch(f"repos/{repo}/pulls?state=open&per_page={PAGE_SIZE}&page={page}")
        if not isinstance(rows, list):
            raise AuditError("invalid pull-request listing")
        for row in rows:
            if not isinstance(row, dict) or type(row.get("number")) is not int:
                raise AuditError("invalid pull-request row")
        found.extend(rows)
        if len(rows) < PAGE_SIZE:
            return found[:limit]
    # Explicitly mark intentional truncation rather than silently claiming completeness.
    if len(found) >= limit:
        return found[:limit]
    raise AuditError("unexpected incomplete PR pagination")


def fetch_files(repo: str, number: int, fetch: Callable[[str], Any], expected: int | None = None) -> list[dict[str, Any]]:
    if type(number) is not int or number < 1:
        raise AuditError("invalid PR number")
    if expected is not None and (type(expected) is not int or expected < 0 or expected > MAX_FILES_PAGES * PAGE_SIZE):
        raise AuditError("unbounded changed-file count")
    result: list[dict[str, Any]] = []
    complete = False
    for page in range(1, MAX_FILES_PAGES + 1):
        data = fetch(f"repos/{repo}/pulls/{number}/files?per_page={PAGE_SIZE}&page={page}")
        if not isinstance(data, list):
            raise AuditError("invalid changed-file listing")
        for row in data:
            if not isinstance(row, dict) or not isinstance(row.get("filename"), str):
                raise AuditError("invalid changed-file record")
        result.extend(data)
        if len(data) < PAGE_SIZE:
            complete = True
            break
    if not complete or (expected is not None and len(result) != expected):
        raise AuditError("incomplete changed-file inventory")
    return result


def risk_flags(files: list[dict[str, Any]]) -> list[str]:
    flags: set[str] = set()
    for file in files:
        path = file["filename"]
        status = file.get("status")
        if status == "removed":
            flags.add("DELETIONS_REQUIRE_REVIEW")
        if path.startswith("assets/content/packs/") and status in {"removed", "modified"}:
            flags.add("PACK_BYTES_AT_RISK")
        if path.startswith(".github/workflows/"):
            flags.add("WORKFLOW_CHANGE_REQUIRES_OWNER")
        if path in {"pubspec.yaml", "pubspec.lock", "lib/main.dart", "android/app/src/main/AndroidManifest.xml"}:
            flags.add("SHARED_ROOT_FILE")
    return sorted(flags)


def make_matrix(prs: list[dict[str, Any]], file_map: dict[int, list[dict[str, Any]]], target: str) -> dict[str, Any]:
    """Pure classifier; overlap is potential ownership collision, not proven Git conflict."""
    by_path: dict[str, set[int]] = defaultdict(set)
    for pr in prs:
        number = pr["number"]
        for file in file_map.get(number, []):
            by_path[file["filename"]].add(number)
            if isinstance(file.get("previous_filename"), str):
                by_path[file["previous_filename"]].add(number)
    items = []
    for pr in prs:
        number = pr["number"]
        files = file_map.get(number)
        base = (pr.get("base") or {}).get("ref")
        flags = [] if files is None else risk_flags(files)
        if files is None:
            flags.append("FILES_UNVERIFIED")
        if base != target:
            flags.append("WRONG_BASE_OR_STACKED_PR")
        if pr.get("draft") is True:
            flags.append("DRAFT_REQUIRES_OWNER")
        overlap: dict[str, list[int]] = {}
        for file in files or []:
            others = by_path[file["filename"]] - {number}
            if others:
                overlap[file["filename"]] = sorted(others)
        if overlap:
            flags.append("POTENTIAL_FILE_OVERLAP")
        flags = sorted(set(flags))
        if "PACK_BYTES_AT_RISK" in flags or "FILES_UNVERIFIED" in flags:
            suggested = "HOLD_FOR_SAFETY"
        elif "DRAFT_REQUIRES_OWNER" in flags or "WRONG_BASE_OR_STACKED_PR" in flags:
            suggested = "OWNER_RECONCILIATION"
        elif "POTENTIAL_FILE_OVERLAP" in flags:
            suggested = "ORDER_OR_COMBINE_WITH_OWNER"
        else:
            suggested = "READY_FOR_INDEPENDENT_PREFLIGHT_ONLY"
        items.append({
            "pr": number,
            "title": pr.get("title", ""),
            "url": pr.get("html_url", ""),
            "base": base,
            "draft": pr.get("draft"),
            "head_sha": (pr.get("head") or {}).get("sha"),
            "flags": flags,
            "overlapping_paths": overlap,
            "files_checked": len(files) if files is not None else None,
            "suggested_action": suggested,
            "checks_verified": False,
        })
    pairs = sorted({(min(x["pr"], other), max(x["pr"], other))
                    for x in items for others in x["overlapping_paths"].values()
                    for other in others})
    return {"target": target, "prs": items, "overlap_pairs": [list(x) for x in pairs],
            "draft_count": sum(x["draft"] is True for x in items),
            "wrong_base_count": sum(x["base"] != target for x in items),
            "pack_risk_count": sum("PACK_BYTES_AT_RISK" in x["flags"] for x in items),
            "unverified_file_count": sum("FILES_UNVERIFIED" in x["flags"] for x in items)}


def audit_repo(repo: str, target: str, fetch: Callable[[str], Any], limit: int) -> dict[str, Any]:
    repo = validate_repo(repo)
    target_data = fetch(f"repos/{repo}/branches/{target}")
    sha = ((target_data.get("commit") or {}).get("sha")) if isinstance(target_data, dict) else None
    if not isinstance(sha, str) or not re.fullmatch(r"[a-f0-9]{40}", sha):
        raise AuditError("cannot verify target HEAD")
    prs = fetch_open_prs(repo, fetch, limit)
    files: dict[int, list[dict[str, Any]]] = {}
    fetch_errors: dict[int, str] = {}
    for pr in prs:
        number = pr["number"]
        try:
            files[number] = fetch_files(repo, number, fetch, pr.get("changed_files"))
        except AuditError as exc:
            fetch_errors[number] = str(exc)
    matrix = make_matrix(prs, files, target)
    matrix.update({"repository": repo, "target_head": sha, "pr_count_scanned": len(prs),
                   "file_fetch_errors": fetch_errors,
                   "limited_inventory": len(prs) >= limit})
    return matrix


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="optional local JSON report; GitHub is never modified")
    parser.add_argument("--max-prs", type=int, default=250)
    args = parser.parse_args(argv)
    try:
        rows = [
            audit_repo(PUBLIC_REPO, "main", gh_get, args.max_prs),
            audit_repo(PRIVATE_REPO, "staging/v2-full-platform", gh_get, args.max_prs),
        ]
    except AuditError as exc:
        print(f"MERGE_AUDIT_NOT_VERIFIED: {exc}", file=sys.stderr)
        return 2
    report = {
        "schema_version": "1.0.0", "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "evidence_scope": "read-only PR bases and complete changed-file lists; no merge simulation or CI checks",
        "no_merge_performed": True, "repos": rows,
    }
    text = json.dumps(report, ensure_ascii=False, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        temp = args.output.with_suffix(args.output.suffix + ".tmp")
        temp.write_text(text, encoding="utf-8")
        temp.replace(args.output)
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())