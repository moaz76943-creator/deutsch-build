import importlib.util
import json
import threading
from pathlib import Path

import pytest

MODULE_PATH = Path(__file__).parents[1] / "tools" / "automation" / "autonomous_daemon.py"
spec = importlib.util.spec_from_file_location("autonomous_daemon", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

AutonomousDispatcher = module.AutonomousDispatcher
DispatcherError = module.DispatcherError


def _write_fixture(tmp_path: Path, *, dependency_status="PENDING"):
    automation = tmp_path / "tools" / "automation"
    automation.mkdir(parents=True)
    backlog = {
        "schema_version": 1,
        "tasks": [
            {
                "task_id": "FOUNDATION",
                "status": "IN_PROGRESS",
                "branch": "feature/foundation",
                "prerequisites": [],
                "allowed_paths": ["lib/foundation/**"],
            },
            {
                "task_id": "READY_TASK",
                "status": "PENDING",
                "branch": "feature/ready",
                "prerequisites": ["FOUNDATION"],
                "allowed_paths": ["lib/ready/**", "test/ready/**"],
            },
        ],
    }
    pipeline = {
        "schema_version": 1,
        "tasks": [
            {
                "task_id": "FOUNDATION",
                "status": dependency_status,
                "branch": "feature/foundation",
                "commit_sha": "a" * 40 if dependency_status == "COMPLETED" else "",
                "test_count": 3,
                "dependent_tasks": [],
            },
            {
                "task_id": "READY_TASK",
                "status": "PENDING",
                "branch": "feature/ready",
                "commit_sha": "",
                "test_count": 0,
                "dependent_tasks": ["FOUNDATION"],
            },
        ],
    }
    (automation / "backlog.json").write_text(json.dumps(backlog), encoding="utf-8")
    (automation / "pipeline_state.json").write_text(json.dumps(pipeline), encoding="utf-8")
    return automation


def _dispatcher(automation: Path):
    return AutonomousDispatcher(
        backlog_path=automation / "backlog.json",
        state_path=automation / "pipeline_state.json",
        claims_path=automation / "claims.json",
        dispatch_dir=automation / "dispatches",
    )


def test_unresolved_dependency_stays_pending(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="IN_PROGRESS")
    result = _dispatcher(automation).poll_once()

    assert result["state"] == "NO_CANDIDATE"
    state = json.loads((automation / "pipeline_state.json").read_text())
    ready = next(t for t in state["tasks"] if t["task_id"] == "READY_TASK")
    assert ready["status"] == "PENDING"
    assert not (automation / "claims.json").exists()


def test_resolved_dependency_claims_and_dispatches(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="COMPLETED")
    result = _dispatcher(automation).poll_once()

    assert result == {"state": "DISPATCHED", "task_id": "READY_TASK"}
    state = json.loads((automation / "pipeline_state.json").read_text())
    ready = next(t for t in state["tasks"] if t["task_id"] == "READY_TASK")
    assert ready["status"] == "IN_PROGRESS"

    claims = json.loads((automation / "claims.json").read_text())
    assert claims["schema_version"] == 1
    assert len(claims["claims"]) == 1
    assert claims["claims"][0]["task_id"] == "READY_TASK"
    assert claims["claims"][0]["status"] == "ACTIVE"

    dispatch_path = automation / "dispatches" / "READY_TASK.dispatch.json"
    payload = json.loads(dispatch_path.read_text())
    assert payload == {
        "schema_version": 1,
        "task_id": "READY_TASK",
        "target_branch": "feature/ready",
        "authorized_scope": ["lib/ready/**", "test/ready/**"],
        "prerequisite_shas": {"FOUNDATION": "a" * 40},
    }


def test_double_claim_race_allows_only_one_dispatch(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="COMPLETED")
    barrier = threading.Barrier(2)
    results = []

    def run():
        dispatcher = _dispatcher(automation)
        barrier.wait()
        results.append(dispatcher.poll_once())

    threads = [threading.Thread(target=run), threading.Thread(target=run)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join()

    assert sorted(r["state"] for r in results) == ["DISPATCHED", "NO_CANDIDATE"]
    claims = json.loads((automation / "claims.json").read_text())
    assert [claim["task_id"] for claim in claims["claims"]] == ["READY_TASK"]


def test_dry_run_does_not_mutate_files(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="COMPLETED")
    before = (automation / "pipeline_state.json").read_text()
    result = _dispatcher(automation).poll_once(dry_run=True)

    assert result["state"] == "DRY_RUN"
    assert result["dispatch"]["task_id"] == "READY_TASK"
    assert (automation / "pipeline_state.json").read_text() == before
    assert not (automation / "claims.json").exists()
    assert not (automation / "dispatches").exists()
    assert not (automation / "pipeline_state.json.dispatch.lock").exists()


def test_status_reports_ready_and_blocked_counts(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="COMPLETED")
    status = _dispatcher(automation).status()
    assert status["ready"] == ["READY_TASK"]
    assert status["in_progress"] == []
    assert status["blocked"] == []


def test_completed_dependency_without_sha_fails_closed(tmp_path):
    automation = _write_fixture(tmp_path, dependency_status="COMPLETED")
    state_path = automation / "pipeline_state.json"
    state = json.loads(state_path.read_text())
    state["tasks"][0]["commit_sha"] = ""
    state_path.write_text(json.dumps(state), encoding="utf-8")

    with pytest.raises(DispatcherError, match="commit_sha"):
        _dispatcher(automation).poll_once()
