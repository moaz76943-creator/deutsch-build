import copy
import json
from pathlib import Path

import pytest

from tools.automation.dispatcher import (
    BacklogValidationError,
    ClaimSnapshot,
    Dispatcher,
    GitBranchSnapshot,
    load_backlog,
)

HERE = Path(__file__).resolve().parent
BACKLOG = HERE / "backlog.json"


def test_backlog_contains_complete_lifecycle_in_required_order():
    backlog = load_backlog(BACKLOG)
    ids = [task["task_id"] for task in backlog["tasks"]]
    assert ids == [
        "PHASE2_WIRING",
        "AUDIO_ENGINE_DOMAIN",
        "MATRIX_A1_CORE",
        "LOCAL_PERSISTENCE_DRIFT",
        "AUDIO_UI_INTEGRATION",
        "SRS_SCHEDULER_WIRING",
        "MULTILINGUAL_PACK_INGESTION",
        "APP_PAYMENTS_BILLING",
    ]
    assert [task["status"] for task in backlog["tasks"][:3]] == ["IN_PROGRESS"] * 3
    assert all(task["status"] == "PENDING" for task in backlog["tasks"][3:])


def test_backlog_tasks_have_isolated_boundaries_and_valid_domains():
    backlog = load_backlog(BACKLOG)
    allowed_domains = {"UI", "Audio", "DataMatrix", "Database", "Payments"}
    for task in backlog["tasks"]:
        assert task["domain"] in allowed_domains
        assert task["allowed_paths"]
        assert all(pattern and not pattern.startswith("/") for pattern in task["allowed_paths"])


def test_dependencies_reference_existing_tasks_and_graph_is_acyclic():
    backlog = load_backlog(BACKLOG)
    Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty()).validate()


def test_in_progress_tasks_are_not_selected_as_new_work():
    backlog = load_backlog(BACKLOG)
    dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
    assert dispatcher.next_executable() is None


def test_next_pending_task_unlocks_only_when_dependencies_are_verified_or_merged():
    backlog = load_backlog(BACKLOG)
    states = {task["task_id"]: task for task in backlog["tasks"]}
    states["PHASE2_WIRING"]["status"] = "VERIFIED"
    states["AUDIO_ENGINE_DOMAIN"]["status"] = "VERIFIED"
    states["MATRIX_A1_CORE"]["status"] = "VERIFIED"

    dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
    selected = dispatcher.next_executable()
    assert selected["task_id"] == "LOCAL_PERSISTENCE_DRIFT"


def test_active_branch_or_claim_blocks_duplicate_dispatch():
    backlog = load_backlog(BACKLOG)
    for task in backlog["tasks"][:3]:
        task["status"] = "VERIFIED"

    branches = GitBranchSnapshot.from_names(["feature/local-persistence-drift"])
    claims = ClaimSnapshot.from_records([
        {
            "claim_id": "OTHER-WORKER",
            "task_id": "LOCAL_PERSISTENCE_DRIFT",
            "status": "ACTIVE",
            "allowed_paths": ["lib/core/persistence/**"],
        }
    ])
    dispatcher = Dispatcher(backlog, branches, claims)
    assert dispatcher.blocked_by_live_work(next(t for t in backlog["tasks"] if t["task_id"] == "LOCAL_PERSISTENCE_DRIFT"))
    assert dispatcher.next_executable()["task_id"] == "AUDIO_UI_INTEGRATION"


def test_parallel_ready_tasks_are_ranked_by_roadmap_order_without_skipping_dependencies():
    backlog = load_backlog(BACKLOG)
    by_id = {task["task_id"]: task for task in backlog["tasks"]}
    for task_id in ["PHASE2_WIRING", "AUDIO_ENGINE_DOMAIN", "MATRIX_A1_CORE", "LOCAL_PERSISTENCE_DRIFT"]:
        by_id[task_id]["status"] = "VERIFIED"
    by_id["AUDIO_UI_INTEGRATION"]["status"] = "PENDING"
    by_id["SRS_SCHEDULER_WIRING"]["status"] = "PENDING"

    dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
    assert dispatcher.next_executable()["task_id"] == "AUDIO_UI_INTEGRATION"


def test_generated_spec_contains_exact_scope_dependencies_and_claim():
    backlog = load_backlog(BACKLOG)
    for task in backlog["tasks"][:3]:
        task["status"] = "VERIFIED"
    dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
    task = dispatcher.next_executable()
    spec = dispatcher.generate_spec(task, claim_id="TOOLING-DISPATCHER-001")

    assert "Task: LOCAL_PERSISTENCE_DRIFT" in spec
    assert "Claim: TOOLING-DISPATCHER-001" in spec
    assert "Allowed paths:" in spec
    for pattern in task["allowed_paths"]:
        assert pattern in spec
    for dependency in task["prerequisites"]:
        assert dependency in spec
    assert "Do not modify files outside these boundaries." in spec


def test_conflicting_claim_scope_is_fail_closed_even_for_different_task():
    backlog = load_backlog(BACKLOG)
    for task in backlog["tasks"][:3]:
        task["status"] = "VERIFIED"
    candidate = next(t for t in backlog["tasks"] if t["task_id"] == "LOCAL_PERSISTENCE_DRIFT")
    claims = ClaimSnapshot.from_records([
        {
            "claim_id": "DB-OTHER",
            "task_id": "UNRELATED_LABEL",
            "status": "ACTIVE",
            "allowed_paths": candidate["allowed_paths"],
        }
    ])
    dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), claims)
    assert dispatcher.blocked_by_live_work(candidate)
    assert dispatcher.next_executable()["task_id"] == "AUDIO_UI_INTEGRATION"


def test_invalid_status_fails_closed():
    backlog = load_backlog(BACKLOG)
    backlog["tasks"][0]["status"] = "DONE"
    with pytest.raises(BacklogValidationError, match="invalid status"):
        Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty()).validate()
