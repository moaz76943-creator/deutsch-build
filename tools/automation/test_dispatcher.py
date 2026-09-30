import copy
import json
from pathlib import Path

import pytest

from tools.automation.dispatcher import (
    BacklogValidationError,
    allocate_tasks,
    load_backlog,
    resolve_ready_tasks,
    validate_backlog,
)

HERE = Path(__file__).resolve().parent
BACKLOG_PATH = HERE / "backlog.json"


def load_seed():
    return json.loads(BACKLOG_PATH.read_text(encoding="utf-8"))


def test_seed_backlog_contains_six_verified_components_and_pending_integration_chain():
    backlog = load_backlog(BACKLOG_PATH)
    components = [item for item in backlog["items"] if item["kind"] == "component"]
    pending = [item for item in backlog["items"] if item["kind"] == "integration_stage"]

    assert len(components) == 6
    assert all(item["status"] == "verified" for item in components)
    assert [item["stage"] for item in pending] == [
        "ci",
        "merge",
        "post_merge_regression",
        "checkpoint",
    ]
    assert all(item["status"] == "pending" for item in pending)


def test_only_ci_stage_is_initially_ready():
    backlog = load_backlog(BACKLOG_PATH)
    ready = resolve_ready_tasks(backlog)
    assert [item["id"] for item in ready] == ["integration.pr107.ci"]


def test_dependency_completion_unlocks_next_stage():
    backlog = load_seed()
    by_id = {item["id"]: item for item in backlog["items"]}
    by_id["integration.pr107.ci"]["status"] = "verified"
    ready = resolve_ready_tasks(backlog)
    assert [item["id"] for item in ready] == ["integration.pr107.merge"]


def test_unknown_dependency_is_rejected():
    backlog = load_seed()
    backlog["items"][-1]["dependencies"] = ["missing.task"]
    with pytest.raises(BacklogValidationError, match="unknown dependency"):
        validate_backlog(backlog)


def test_duplicate_item_ids_are_rejected():
    backlog = load_seed()
    backlog["items"].append(copy.deepcopy(backlog["items"][0]))
    with pytest.raises(BacklogValidationError, match="duplicate item id"):
        validate_backlog(backlog)


def test_dependency_cycle_is_rejected():
    backlog = load_seed()
    by_id = {item["id"]: item for item in backlog["items"]}
    by_id["integration.pr107.ci"]["dependencies"] = ["integration.pr107.checkpoint"]
    with pytest.raises(BacklogValidationError, match="dependency cycle"):
        validate_backlog(backlog)


def test_allocation_requires_worker_capabilities():
    backlog = load_backlog(BACKLOG_PATH)
    workers = [
        {"id": "docs-only", "capabilities": ["docs"], "capacity": 1},
        {"id": "python-ci", "capabilities": ["python", "ci"], "capacity": 1},
    ]
    result = allocate_tasks(backlog, workers)
    assert result["assignments"] == [
        {"task_id": "integration.pr107.ci", "worker_id": "python-ci"}
    ]
    assert result["unassigned"] == []


def test_allocation_never_assigns_two_ready_tasks_with_same_mutable_scope():
    backlog = load_seed()
    backlog["items"].extend(
        [
            {
                "id": "integration.extra.a",
                "kind": "integration_stage",
                "stage": "ci",
                "status": "pending",
                "priority": 50,
                "dependencies": [],
                "required_capabilities": ["python"],
                "mutable_scope": "shared/scope",
                "evidence": [],
            },
            {
                "id": "integration.extra.b",
                "kind": "integration_stage",
                "stage": "ci",
                "status": "pending",
                "priority": 40,
                "dependencies": [],
                "required_capabilities": ["python"],
                "mutable_scope": "shared/scope",
                "evidence": [],
            },
        ]
    )
    workers = [
        {"id": "w1", "capabilities": ["python", "ci"], "capacity": 2},
        {"id": "w2", "capabilities": ["python", "ci"], "capacity": 2},
    ]
    result = allocate_tasks(backlog, workers)
    assigned_ids = {item["task_id"] for item in result["assignments"]}
    assert "integration.extra.a" in assigned_ids
    assert "integration.extra.b" not in assigned_ids
    assert any(
        item["task_id"] == "integration.extra.b" and item["reason"] == "mutable_scope_claimed"
        for item in result["unassigned"]
    )


def test_worker_capacity_is_respected_deterministically():
    backlog = load_seed()
    backlog["items"].append(
        {
            "id": "integration.independent",
            "kind": "integration_stage",
            "stage": "ci",
            "status": "pending",
            "priority": 200,
            "dependencies": [],
            "required_capabilities": ["python"],
            "mutable_scope": "independent/scope",
            "evidence": [],
        }
    )
    workers = [{"id": "w1", "capabilities": ["python", "ci"], "capacity": 1}]
    result = allocate_tasks(backlog, workers)
    assert result["assignments"] == [
        {"task_id": "integration.independent", "worker_id": "w1"}
    ]
    assert any(
        item["task_id"] == "integration.pr107.ci" and item["reason"] == "no_eligible_worker_capacity"
        for item in result["unassigned"]
    )
