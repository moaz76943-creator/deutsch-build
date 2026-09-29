import json

import pytest

from tool.failure_control import classify
from tool.project_record_event import validate_task_transition


TASK_ID = "issue-12-mission-canary-001"


def write_events(path, *events):
    path.write_text(
        "".join(json.dumps(event) + "\n" for event in events),
        encoding="utf-8",
    )


def task_event(event_type):
    status = {
        "task_started": "started",
        "task_completed": "completed",
        "task_failed": "failed",
    }[event_type]
    return {
        "type": event_type,
        "status": status,
        "task_id": TASK_ID,
        "evidence": "issue-12-preflight",
    }


def test_interrupted_session_resumes_same_task_instead_of_duplicate_start(tmp_path):
    path = tmp_path / "events.ndjson"
    write_events(path, task_event("task_started"))

    with pytest.raises(ValueError, match="resume from durable evidence/checkpoint"):
        validate_task_transition(
            "task_started",
            "started",
            TASK_ID,
            "new-session",
            path=path,
        )

    failure = classify("OpenCode session crashed and session lost")
    assert failure["class"] == "SESSION_CONTEXT"
    assert failure["path"] == "RESUME_FROM_VERIFIED_CHECKPOINT"


def test_unknown_critical_state_stops_before_mutation():
    failure = classify("unfamiliar critical condition during mission resume")
    assert failure["class"] == "UNKNOWN"
    assert failure["path"] == "STOP_AND_RECONCILE"


def test_verified_completion_allows_terminal_event_then_blocks_reexecution(tmp_path):
    path = tmp_path / "events.ndjson"
    write_events(path, task_event("task_started"))

    validate_task_transition(
        "task_completed",
        "completed",
        TASK_ID,
        "commit-plus-ci-plus-checkpoint",
        path=path,
    )

    write_events(path, task_event("task_started"), task_event("task_completed"))

    with pytest.raises(ValueError, match="already has terminal event"):
        validate_task_transition(
            "task_started",
            "started",
            TASK_ID,
            "another-session",
            path=path,
        )
