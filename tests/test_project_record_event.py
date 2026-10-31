import json

import pytest

from tool.project_record_event import validate_task_transition


def write_events(path, *events):
    path.write_text(
        "".join(json.dumps(event) + "\n" for event in events),
        encoding="utf-8",
    )


def task_event(event_type, task_id="issue-12-mission-canary-001"):
    status = {
        "task_started": "started",
        "task_completed": "completed",
        "task_failed": "failed",
    }[event_type]
    return {
        "type": event_type,
        "status": status,
        "task_id": task_id,
        "evidence": "https://example.invalid/evidence",
    }


def test_generic_event_remains_backward_compatible(tmp_path):
    validate_task_transition(
        "session.idle",
        None,
        None,
        None,
        path=tmp_path / "events.ndjson",
    )


def test_task_started_requires_stable_id_status_and_evidence(tmp_path):
    path = tmp_path / "events.ndjson"

    with pytest.raises(ValueError, match="stable --task-id"):
        validate_task_transition("task_started", "started", None, "issue", path=path)

    with pytest.raises(ValueError, match="requires --status 'started'"):
        validate_task_transition("task_started", "running", "task-1", "issue", path=path)

    with pytest.raises(ValueError, match="requires non-empty --evidence"):
        validate_task_transition("task_started", "started", "task-1", "", path=path)


def test_first_task_started_is_allowed(tmp_path):
    validate_task_transition(
        "task_started",
        "started",
        "task-1",
        "issue-or-branch",
        path=tmp_path / "events.ndjson",
    )


def test_duplicate_start_becomes_resume_candidate_instead_of_new_execution(tmp_path):
    path = tmp_path / "events.ndjson"
    write_events(path, task_event("task_started", "task-1"))

    with pytest.raises(ValueError, match="resume from durable evidence/checkpoint"):
        validate_task_transition(
            "task_started",
            "started",
            "task-1",
            "issue-or-branch",
            path=path,
        )


def test_terminal_event_requires_prior_start(tmp_path):
    path = tmp_path / "events.ndjson"

    with pytest.raises(ValueError, match="requires a prior task_started"):
        validate_task_transition(
            "task_completed",
            "completed",
            "task-1",
            "commit-and-ci",
            path=path,
        )


def test_completion_after_start_is_allowed(tmp_path):
    path = tmp_path / "events.ndjson"
    write_events(path, task_event("task_started", "task-1"))

    validate_task_transition(
        "task_completed",
        "completed",
        "task-1",
        "commit-and-ci",
        path=path,
    )


@pytest.mark.parametrize("terminal_type", ["task_completed", "task_failed"])
def test_terminal_state_blocks_silent_reexecution(tmp_path, terminal_type):
    path = tmp_path / "events.ndjson"
    write_events(
        path,
        task_event("task_started", "task-1"),
        task_event(terminal_type, "task-1"),
    )

    with pytest.raises(ValueError, match="already has terminal event"):
        validate_task_transition(
            "task_started",
            "started",
            "task-1",
            "new-session",
            path=path,
        )


def test_malformed_ledger_line_does_not_break_valid_recovery_check(tmp_path):
    path = tmp_path / "events.ndjson"
    path.write_text(
        "not-json\n" + json.dumps(task_event("task_started", "task-1")) + "\n",
        encoding="utf-8",
    )

    validate_task_transition(
        "task_completed",
        "completed",
        "task-1",
        "commit-and-ci",
        path=path,
    )
