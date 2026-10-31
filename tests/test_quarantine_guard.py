from __future__ import annotations

import json
from pathlib import Path

from tools.automation.quarantine_guard import (
    DEFAULT_STALE_THRESHOLD,
    QuarantineError,
    main,
    release_task,
    report_quarantine,
    scan_and_quarantine,
)


def _write(path: Path, value) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def _read(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def _task(task_id: str, *, status: str = "IN_PROGRESS", stale_count: int = 0, violations=None):
    return {
        "task_id": task_id,
        "status": status,
        "branch": f"feature/{task_id.lower()}",
        "stale_count": stale_count,
        "boundary_violations": [] if violations is None else violations,
    }


def _paths(tmp_path: Path):
    return (
        tmp_path / "pipeline_state.json",
        tmp_path / "claims.json",
        tmp_path / "quarantine.json",
        tmp_path / "quarantine_audit.log",
    )


def test_scan_isolates_failed_task_releases_claim_and_emits_audit(tmp_path: Path):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(pipeline, {"schema_version": 1, "tasks": [_task("BROKEN", status="FAILED"), _task("OK")]})
    _write(
        claims,
        {
            "schema_version": 1,
            "claims": [
                {"task_id": "BROKEN", "status": "IN_PROGRESS", "slot": 0},
                {"task_id": "OK", "status": "IN_PROGRESS", "slot": 1},
            ],
        },
    )

    result = scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:40:00Z")

    assert result == {"quarantined": ["BROKEN"], "released_claims": ["BROKEN"]}
    stored = _read(quarantine)
    active = [entry for entry in stored["entries"] if entry["state"] == "QUARANTINED"]
    assert active[0]["task_id"] == "BROKEN"
    assert active[0]["reasons"] == ["FAILED"]
    assert active[0]["isolated_at"] == "2026-09-30T13:40:00Z"

    claim_state = _read(claims)
    by_task = {claim["task_id"]: claim for claim in claim_state["claims"]}
    assert by_task["BROKEN"]["status"] == "RELEASED"
    assert by_task["OK"]["status"] == "IN_PROGRESS"

    records = [json.loads(line) for line in audit.read_text(encoding="utf-8").splitlines()]
    assert records[-1]["event"] == "QUARANTINED"
    assert records[-1]["task_id"] == "BROKEN"
    assert records[-1]["claim_released"] is True


def test_scan_quarantines_repeated_stale_and_boundary_violation_signals(tmp_path: Path):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(
        pipeline,
        {
            "tasks": [
                _task("STALE", stale_count=DEFAULT_STALE_THRESHOLD),
                _task("BOUNDARY", violations=["lib/outside.dart"]),
                _task("NOT_YET_STALE", stale_count=DEFAULT_STALE_THRESHOLD - 1),
            ]
        },
    )
    _write(claims, {"claims": [{"task_id": "STALE", "status": "ACTIVE"}, {"task_id": "BOUNDARY", "status": "CLAIMED"}]})

    result = scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:41:00Z")

    assert result["quarantined"] == ["STALE", "BOUNDARY"]
    entries = {entry["task_id"]: entry for entry in _read(quarantine)["entries"]}
    assert entries["STALE"]["reasons"] == ["REPEATEDLY_STALE"]
    assert entries["BOUNDARY"]["reasons"] == ["BOUNDARY_VIOLATION"]
    assert "NOT_YET_STALE" not in entries


def test_scan_is_idempotent_but_releases_a_claim_left_behind_after_prior_isolation(tmp_path: Path):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(pipeline, {"tasks": [_task("BROKEN", status="FAILED")]})
    _write(claims, {"claims": [{"task_id": "BROKEN", "status": "IN_PROGRESS"}]})

    first = scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:42:00Z")
    assert first["quarantined"] == ["BROKEN"]

    # Simulate a crash/race that restored an active claim after quarantine persistence.
    _write(claims, {"claims": [{"task_id": "BROKEN", "status": "ACTIVE"}]})
    second = scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:43:00Z")

    assert second == {"quarantined": [], "released_claims": ["BROKEN"]}
    entries = _read(quarantine)["entries"]
    assert len([entry for entry in entries if entry["state"] == "QUARANTINED"]) == 1


def test_release_marks_quarantine_entry_released_and_report_excludes_it(tmp_path: Path):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(pipeline, {"tasks": [_task("BROKEN", status="FAILED")]})
    _write(claims, {"claims": []})
    scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:44:00Z")

    released = release_task("BROKEN", quarantine, audit, now="2026-09-30T13:45:00Z")
    assert released["task_id"] == "BROKEN"
    assert released["state"] == "RELEASED"
    assert released["released_at"] == "2026-09-30T13:45:00Z"

    report = report_quarantine(quarantine)
    assert report["active_count"] == 0
    assert report["active"] == []
    assert report["released_count"] == 1


def test_cli_scan_report_and_release_emit_json(tmp_path: Path, capsys):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(pipeline, {"tasks": [_task("BROKEN", status="FAILED")]})
    _write(claims, {"claims": [{"task_id": "BROKEN", "status": "IN_PROGRESS"}]})
    common = [
        "--pipeline", str(pipeline), "--claims", str(claims),
        "--quarantine", str(quarantine), "--audit", str(audit),
    ]

    assert main([*common, "--scan"]) == 0
    scan_payload = json.loads(capsys.readouterr().out)
    assert scan_payload["quarantined"] == ["BROKEN"]

    assert main([*common, "--report"]) == 0
    report_payload = json.loads(capsys.readouterr().out)
    assert report_payload["active_count"] == 1

    assert main([*common, "--release", "BROKEN"]) == 0
    release_payload = json.loads(capsys.readouterr().out)
    assert release_payload["state"] == "RELEASED"


def test_missing_claims_file_is_treated_as_zero_occupied_slots(tmp_path: Path):
    pipeline, claims, quarantine, audit = _paths(tmp_path)
    _write(pipeline, {"tasks": [_task("BROKEN", status="FAILED")]})

    result = scan_and_quarantine(pipeline, claims, quarantine, audit, now="2026-09-30T13:46:00Z")

    assert result == {"quarantined": ["BROKEN"], "released_claims": []}
    assert not claims.exists()


def test_release_unknown_task_fails_closed(tmp_path: Path):
    _, _, quarantine, audit = _paths(tmp_path)
    _write(quarantine, {"schema_version": 1, "entries": []})

    try:
        release_task("MISSING", quarantine, audit, now="2026-09-30T13:47:00Z")
    except QuarantineError as exc:
        assert "not actively quarantined" in str(exc)
    else:
        raise AssertionError("release must fail closed for an unknown task")
