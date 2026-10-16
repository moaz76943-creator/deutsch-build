import unittest
import os
import json
import tempfile
from unittest.mock import patch, MagicMock
from pathlib import Path
from guard import TaskLedger, is_safe_path, validate_changes, match_path

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

if __name__ == '__main__':
    unittest.main()
