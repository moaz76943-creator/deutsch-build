import copy
import json
import unittest
from pathlib import Path

from tools.automation.dispatcher import (
    BacklogValidationError,
    ClaimSnapshot,
    Dispatcher,
    GitBranchSnapshot,
    load_backlog,
)

HERE = Path(__file__).resolve().parent
BACKLOG = HERE / "backlog.json"


class TestDispatcher(unittest.TestCase):
    def test_backlog_contains_complete_lifecycle_in_required_order(self):
        backlog = load_backlog(BACKLOG)
        ids = [task["task_id"] for task in backlog["tasks"]]
        self.assertEqual(ids, [
            "PHASE2_WIRING",
            "AUDIO_ENGINE_DOMAIN",
            "MATRIX_A1_CORE",
            "LOCAL_PERSISTENCE_DRIFT",
            "AUDIO_UI_INTEGRATION",
            "SRS_SCHEDULER_WIRING",
            "MULTILINGUAL_PACK_INGESTION",
            "APP_PAYMENTS_BILLING",
            "TASK-INT-001",
            "TASK-INT-002",
            "TASK-INT-003",
            "TASK-UI-001",
        ])
        self.assertEqual([task["status"] for task in backlog["tasks"][:3]], ["IN_PROGRESS"] * 3)
        self.assertTrue(all(task["status"] == "PENDING" for task in backlog["tasks"][3:]))

    def test_backlog_tasks_have_isolated_boundaries_and_valid_domains(self):
        backlog = load_backlog(BACKLOG)
        allowed_domains = {"UI", "Audio", "DataMatrix", "Database", "Payments"}
        for task in backlog["tasks"]:
            self.assertIn(task["domain"], allowed_domains)
            self.assertTrue(task["allowed_paths"])
            self.assertTrue(all(pattern and not pattern.startswith("/") for pattern in task["allowed_paths"]))

    def test_dependencies_reference_existing_tasks_and_graph_is_acyclic(self):
        backlog = load_backlog(BACKLOG)
        Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty()).validate()

    def test_post_merge_sequence_has_strict_direct_dependencies(self):
        backlog = load_backlog(BACKLOG)
        by_id = {task["task_id"]: task for task in backlog["tasks"]}

        self.assertEqual(by_id["TASK-INT-002"]["prerequisites"], ["TASK-INT-001"])
        self.assertEqual(by_id["TASK-INT-003"]["prerequisites"], ["TASK-INT-002"])
        self.assertEqual(by_id["TASK-UI-001"]["prerequisites"], ["TASK-INT-002", "TASK-INT-003"])

    def test_post_merge_sequence_cycle_is_rejected(self):
        backlog = load_backlog(BACKLOG)
        by_id = {task["task_id"]: task for task in backlog["tasks"]}
        by_id["TASK-INT-001"]["prerequisites"] = ["TASK-UI-001"]

        with self.assertRaisesRegex(BacklogValidationError, "dependency cycle"):
            Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty()).validate()

    def test_post_merge_sequence_resolves_topologically(self):
        backlog = load_backlog(BACKLOG)
        by_id = {task["task_id"]: task for task in backlog["tasks"]}

        for task in backlog["tasks"]:
            if task["task_id"] not in {
                "TASK-INT-001",
                "TASK-INT-002",
                "TASK-INT-003",
                "TASK-UI-001",
            }:
                task["status"] = "VERIFIED"

        dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())

        self.assertEqual(dispatcher.next_executable()["task_id"], "TASK-INT-001")
        by_id["TASK-INT-001"]["status"] = "VERIFIED"
        self.assertEqual(dispatcher.next_executable()["task_id"], "TASK-INT-002")
        by_id["TASK-INT-002"]["status"] = "VERIFIED"
        self.assertEqual(dispatcher.next_executable()["task_id"], "TASK-INT-003")
        by_id["TASK-INT-003"]["status"] = "VERIFIED"
        self.assertEqual(dispatcher.next_executable()["task_id"], "TASK-UI-001")
        by_id["TASK-UI-001"]["status"] = "VERIFIED"
        self.assertIsNone(dispatcher.next_executable())

    def test_in_progress_tasks_are_not_selected_as_new_work(self):
        backlog = load_backlog(BACKLOG)
        dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
        selected = dispatcher.next_executable()
        self.assertEqual(selected["task_id"], "TASK-INT-001")
        self.assertNotIn(selected["task_id"], {
            "PHASE2_WIRING",
            "AUDIO_ENGINE_DOMAIN",
            "MATRIX_A1_CORE",
        })

    def test_next_pending_task_unlocks_only_when_dependencies_are_verified_or_merged(self):
        backlog = load_backlog(BACKLOG)
        states = {task["task_id"]: task for task in backlog["tasks"]}
        states["PHASE2_WIRING"]["status"] = "VERIFIED"
        states["AUDIO_ENGINE_DOMAIN"]["status"] = "VERIFIED"
        states["MATRIX_A1_CORE"]["status"] = "VERIFIED"

        dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
        selected = dispatcher.next_executable()
        self.assertEqual(selected["task_id"], "LOCAL_PERSISTENCE_DRIFT")

    def test_active_branch_or_claim_blocks_duplicate_dispatch(self):
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
        self.assertTrue(dispatcher.blocked_by_live_work(next(t for t in backlog["tasks"] if t["task_id"] == "LOCAL_PERSISTENCE_DRIFT")))
        self.assertEqual(dispatcher.next_executable()["task_id"], "AUDIO_UI_INTEGRATION")

    def test_parallel_ready_tasks_are_ranked_by_roadmap_order_without_skipping_dependencies(self):
        backlog = load_backlog(BACKLOG)
        by_id = {task["task_id"]: task for task in backlog["tasks"]}
        for task_id in ["PHASE2_WIRING", "AUDIO_ENGINE_DOMAIN", "MATRIX_A1_CORE", "LOCAL_PERSISTENCE_DRIFT"]:
            by_id[task_id]["status"] = "VERIFIED"
        by_id["AUDIO_UI_INTEGRATION"]["status"] = "PENDING"
        by_id["SRS_SCHEDULER_WIRING"]["status"] = "PENDING"

        dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
        self.assertEqual(dispatcher.next_executable()["task_id"], "AUDIO_UI_INTEGRATION")

    def test_generated_spec_contains_exact_scope_dependencies_and_claim(self):
        backlog = load_backlog(BACKLOG)
        for task in backlog["tasks"][:3]:
            task["status"] = "VERIFIED"
        dispatcher = Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty())
        task = dispatcher.next_executable()
        spec = dispatcher.generate_spec(task, claim_id="TOOLING-DISPATCHER-001")

        self.assertIn("Task: LOCAL_PERSISTENCE_DRIFT", spec)
        self.assertIn("Claim: TOOLING-DISPATCHER-001", spec)
        self.assertIn("Allowed paths:", spec)
        for pattern in task["allowed_paths"]:
            self.assertIn(pattern, spec)
        for dependency in task["prerequisites"]:
            self.assertIn(dependency, spec)
        self.assertIn("Do not modify files outside these boundaries.", spec)

    def test_conflicting_claim_scope_is_fail_closed_even_for_different_task(self):
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
        self.assertTrue(dispatcher.blocked_by_live_work(candidate))
        self.assertEqual(dispatcher.next_executable()["task_id"], "AUDIO_UI_INTEGRATION")

    def test_invalid_status_fails_closed(self):
        backlog = load_backlog(BACKLOG)
        backlog["tasks"][0]["status"] = "DONE"
        with self.assertRaisesRegex(BacklogValidationError, "invalid status"):
            Dispatcher(backlog, GitBranchSnapshot.empty(), ClaimSnapshot.empty()).validate()

if __name__ == '__main__':
    unittest.main()
