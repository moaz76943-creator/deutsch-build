import unittest
import os
import json
import tempfile
import time
from unittest.mock import patch, MagicMock
from pathlib import Path
from guard import TaskLedger, is_safe_path, validate_changes, match_path, check_overlap_paths, acquire_lock, release_lock, recover_lock

class TestAgentGuard(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "task_ledger.json")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_ledger_creation_and_transition(self):
        ledger = TaskLedger(self.ledger_path)
        ledger.add_task("T001", ["docs/**"])

        task = ledger.get_task("T001")
        self.assertIsNotNone(task)
        self.assertEqual(task["state"], "CLAIM")

        ledger.transition_state("T001", "ACTIVE")
        self.assertEqual(ledger.get_task("T001")["state"], "ACTIVE")

        with self.assertRaises(ValueError):
             ledger.transition_state("T001", "CLAIM") # Invalid transition

    def test_path_matching(self):
        self.assertTrue(match_path("docs/project-record/task_ledger.json", "docs/project-record/**"))
        self.assertTrue(match_path("AGENTS.md", "AGENTS.md"))
        self.assertFalse(match_path("lib/main.dart", "docs/**"))
        self.assertFalse(match_path("docs/project-record/task_ledger.json", "docs/project-record/other.json"))

        # Test directory vs subdirectory overlaps
        self.assertTrue(check_overlap_paths(["docs/**"], ["docs/project-record/**"]))
        self.assertTrue(check_overlap_paths(["docs/project-record/**"], ["docs/**"]))
        self.assertTrue(check_overlap_paths(["tools/agent_contract/**"], ["tools/agent_contract/guard.py"]))
        self.assertFalse(check_overlap_paths(["docs/project-record/**"], ["lib/**"]))

    def test_safe_path(self):
        # Create a dummy structure in temp dir
        os.makedirs(os.path.join(self.temp_dir.name, "allowed"))
        os.makedirs(os.path.join(self.temp_dir.name, "forbidden"))

        # Safe
        self.assertTrue(is_safe_path(self.temp_dir.name, "allowed/file.txt"))

        # Traversal (resolves outside)
        self.assertFalse(is_safe_path(self.temp_dir.name, "../outside.txt"))

        # Symlink escape
        target_outside = os.path.join(self.temp_dir.name, "forbidden", "secret.txt")
        open(target_outside, 'w').close()
        symlink_path = os.path.join(self.temp_dir.name, "allowed", "link.txt")
        os.symlink(target_outside, symlink_path)

        # Since is_safe_path resolves relative to base,
        # actually within temp dir is safe, let's create a symlink to outside temp dir
        outside_temp = os.path.join(tempfile.gettempdir(), "some_other_file.txt")
        open(outside_temp, 'w').close()
        symlink_out = os.path.join(self.temp_dir.name, "escape.txt")
        os.symlink(outside_temp, symlink_out)

        self.assertFalse(is_safe_path(self.temp_dir.name, "escape.txt"))

        os.remove(outside_temp)

    def test_parallel_claims_overlap(self):
        ledger = TaskLedger(self.ledger_path)
        ledger.add_task("T1", ["docs/project-record/**"])
        ledger.add_task("T2", ["docs/project-record/task_ledger.json"])

        self.assertTrue(ledger.check_overlap("T2", ["docs/project-record/task_ledger.json"]))

        ledger.add_task("T3", ["lib/**"])
        self.assertFalse(ledger.check_overlap("T3", ["lib/**"]))

    @patch('guard.get_git_diff')
    def test_validate_changes_success(self, mock_diff):
        mock_diff.return_value = ["AGENTS.md", "docs/project-record/task_ledger.json"]

        ledger = TaskLedger(self.ledger_path)
        ledger.add_task("T001", ["AGENTS.md", "docs/project-record/**"])
        ledger.transition_state("T001", "ACTIVE")

        result = validate_changes("T001", "base_sha", "head_sha", base_dir=self.temp_dir.name, ledger_path=self.ledger_path)

        self.assertEqual(result.get("status"), "APPROVED")
        self.assertEqual(len(result["permitted"]), 2)
        self.assertEqual(len(result["denied"]), 0)

    @patch('guard.get_git_diff')
    def test_validate_changes_unauthorized(self, mock_diff):
        mock_diff.return_value = ["AGENTS.md", "lib/main.dart"]

        ledger = TaskLedger(self.ledger_path)
        ledger.add_task("T001", ["AGENTS.md", "docs/project-record/**"])
        ledger.transition_state("T001", "ACTIVE")

        result = validate_changes("T001", "base_sha", "head_sha", base_dir=self.temp_dir.name, ledger_path=self.ledger_path)

        self.assertEqual(result.get("status"), "REJECTED")
        self.assertEqual(len(result["permitted"]), 1)
        self.assertEqual(len(result["denied"]), 1)
        self.assertEqual(result["denied"][0]["path"], "lib/main.dart")

    @patch('guard.get_git_diff')
    def test_validate_changes_stale_base(self, mock_diff):
        mock_diff.side_effect = ValueError("Stale base SHA")

        ledger = TaskLedger(self.ledger_path)
        ledger.add_task("T001", ["AGENTS.md"])
        ledger.transition_state("T001", "ACTIVE")

        result = validate_changes("T001", "base_sha", "head_sha", base_dir=self.temp_dir.name, ledger_path=self.ledger_path)

        self.assertIn("error", result)
        self.assertEqual(result["error"], "Stale base SHA")

    @patch('guard.validate_base_sha')
    def test_acquire_lock(self, mock_validate_sha):
        mock_validate_sha.return_value = True

        # Test basic acquisition
        result = acquire_lock("T1", ["docs/**"], "Agent1", "sha1", ledger_path=self.ledger_path)
        self.assertEqual(result.get("status"), "ACQUIRED")

        # Test overlap rejection
        result2 = acquire_lock("T2", ["docs/project-record/**"], "Agent2", "sha1", ledger_path=self.ledger_path)
        self.assertIn("error", result2)
        self.assertEqual(result2["error"], "Paths overlap with another active claim.")

        # Test dependency admission
        # First add T3 and complete it
        result3 = acquire_lock("T3", ["lib/**"], "Agent3", "sha1", ledger_path=self.ledger_path)
        self.assertEqual(result3.get("status"), "ACQUIRED")
        release_lock("T3", ledger_path=self.ledger_path)

        # Now try to acquire with T3 dependency
        result4 = acquire_lock("T4", ["test/**"], "Agent4", "sha1", dependencies=["T3"], ledger_path=self.ledger_path)
        self.assertEqual(result4.get("status"), "ACQUIRED")

        # Now try with unmet dependency
        result5 = acquire_lock("T5", ["scripts/**"], "Agent5", "sha1", dependencies=["T1"], ledger_path=self.ledger_path)
        self.assertIn("error", result5)
        self.assertEqual(result5["error"], "Dependencies not met.")

    @patch('guard.validate_base_sha')
    def test_stale_lock_recovery(self, mock_validate_sha):
        mock_validate_sha.return_value = True

        result = acquire_lock("T1", ["docs/**"], "Agent1", "sha1", ledger_path=self.ledger_path)
        self.assertEqual(result.get("status"), "ACQUIRED")

        # Fast forward timestamp in ledger
        ledger = TaskLedger(self.ledger_path)
        task = ledger.get_task("T1")
        task["timestamp"] = time.time() - 4000 # More than 1 hour ago
        ledger.save()

        # Recover
        result2 = recover_lock("T1", "Agent_Manager_Evid", ledger_path=self.ledger_path)
        self.assertEqual(result2.get("status"), "RECOVERED")

        # Verify it's now complete and we can claim it
        ledger = TaskLedger(self.ledger_path)
        self.assertEqual(ledger.get_task("T1")["state"], "COMPLETE")

        result3 = acquire_lock("T2", ["docs/**"], "Agent2", "sha1", ledger_path=self.ledger_path)
        self.assertEqual(result3.get("status"), "ACQUIRED")

    def test_concurrent_lock_acquisition(self):
        import concurrent.futures

        def run_acquire(task_id, path):
            return acquire_lock(task_id, [path], "Owner1", "sha", ledger_path=self.ledger_path)

        # Mock validate_base_sha for all threads
        with patch('guard.validate_base_sha', return_value=True):
            with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
                # 5 agents try to claim overlapping paths at the exact same time
                futures = [
                    executor.submit(run_acquire, "T1", "docs/**"),
                    executor.submit(run_acquire, "T2", "docs/**"),
                    executor.submit(run_acquire, "T3", "docs/**"),
                    executor.submit(run_acquire, "T4", "docs/**"),
                    executor.submit(run_acquire, "T5", "docs/**")
                ]

                results = [f.result() for f in futures]

                # Only 1 should succeed, the rest should fail with overlap error
                successes = [r for r in results if r.get("status") == "ACQUIRED"]
                errors = [r for r in results if "error" in r and "overlap" in r["error"]]

                self.assertEqual(len(successes), 1)
                self.assertEqual(len(errors), 4)

    @patch('guard.validate_base_sha')
    def test_delayed_commit_crash_handling(self, mock_validate_sha):
        # Emulate a crash before task completes but lock was acquired
        mock_validate_sha.return_value = True

        result = acquire_lock("T_CRASH", ["scripts/**"], "AgentCrash", "sha_crash", ledger_path=self.ledger_path)
        self.assertEqual(result.get("status"), "ACQUIRED")

        # Test that another agent cannot claim overlapping path during crash delay
        result_blocked = acquire_lock("T_NEW", ["scripts/auto_build.sh"], "AgentNew", "sha_new", ledger_path=self.ledger_path)
        self.assertEqual(result_blocked.get("error"), "Paths overlap with another active claim.")

        # Fast forward time to emulate stale lock for crash
        ledger = TaskLedger(self.ledger_path)
        task = ledger.get_task("T_CRASH")
        task["timestamp"] = time.time() - 4000
        ledger.save()

        # Recover stale lock with owner evidence
        result_recover = recover_lock("T_CRASH", "Crash_Recovery_Evid", ledger_path=self.ledger_path)
        self.assertEqual(result_recover.get("status"), "RECOVERED")

        # Now the new agent can claim it
        result_success = acquire_lock("T_NEW", ["scripts/auto_build.sh"], "AgentNew", "sha_new", ledger_path=self.ledger_path)
        self.assertEqual(result_success.get("status"), "ACQUIRED")
