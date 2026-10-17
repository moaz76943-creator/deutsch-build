import os
import tempfile
import unittest
from unittest.mock import patch
from tools.agent_contract.guard import TaskLedger, ScopeGuard, TaskState

class TestTaskLedger(unittest.TestCase):
    def test_claim_paths_prefix_spoof(self):
        self.ledger.claim_paths("task1", ["docs/project-record/file1.md"])
        success, msg = self.ledger.claim_paths("task2", ["docs/project-record-spoofed/file2.md"])
        self.assertTrue(success) # Should not overlap because they are in different directories

    def setUp(self):
        self.temp_file = tempfile.NamedTemporaryFile(delete=False)
        self.ledger = TaskLedger(ledger_path=self.temp_file.name)

    def tearDown(self):
        os.remove(self.temp_file.name)

    def test_claim_paths_success(self):
        success, msg = self.ledger.claim_paths("task1", ["docs/project-record/file1.md"])
        self.assertTrue(success)
        self.assertEqual(msg, "Success")

    def test_claim_paths_overlap_descendant(self):
        self.ledger.claim_paths("task1", ["docs/project-record/"])
        success, msg = self.ledger.claim_paths("task2", ["docs/project-record/nested/file.md"])
        self.assertFalse(success)
        self.assertIn("Overlap detected", msg)

    def test_claim_paths_overlap_ancestor(self):
        self.ledger.claim_paths("task1", ["docs/project-record/nested/file.md"])
        success, msg = self.ledger.claim_paths("task2", ["docs/project-record/"])
        self.assertFalse(success)
        self.assertIn("Overlap detected", msg)

    def test_claim_paths_no_overlap(self):
        self.ledger.claim_paths("task1", ["docs/project-record/dir1/"])
        success, msg = self.ledger.claim_paths("task2", ["docs/project-record/dir2/"])
        self.assertTrue(success)

    def test_transition_state(self):
        self.ledger.claim_paths("task1", ["docs/"])
        success, msg = self.ledger.transition_state("task1", TaskState.ACTIVE)
        self.assertTrue(success)

        # Verify state is active in ledger
        with open(self.temp_file.name, 'r') as f:
            content = f.read()
            self.assertIn('"state": "ACTIVE"', content)


class TestScopeGuard(unittest.TestCase):
    def setUp(self):
        self.allowed = ["AGENTS.md", "docs/project-record/**", "tools/agent_contract/**"]
        self.guard = ScopeGuard("task1", "dummy_sha", self.allowed)

    @patch('subprocess.run')
    def test_verify_base_sha_valid(self, mock_run):
        mock_run.return_value.returncode = 0
        success, msg = self.guard.verify_base_sha()
        self.assertTrue(success)

    @patch('subprocess.run')
    def test_verify_base_sha_stale(self, mock_run):
        mock_run.return_value.returncode = 1
        success, msg = self.guard.verify_base_sha()
        self.assertFalse(success)
        self.assertIn("Stale base SHA", msg)

    def test_check_paths_allowed_permitted(self):
        changed = ["docs/project-record/SESSION_OPERATING_CONTRACT.md", "tools/agent_contract/guard.py"]
        success, msg, permitted, denied = self.guard.check_paths_allowed(changed)
        self.assertTrue(success)
        self.assertEqual(len(denied), 0)
        self.assertEqual(len(permitted), 2)

    def test_check_paths_allowed_forbidden(self):
        changed = ["lib/main.dart", "android/app/build.gradle"]
        success, msg, permitted, denied = self.guard.check_paths_allowed(changed)
        self.assertFalse(success)
        self.assertEqual(len(denied), 2)
        self.assertEqual(len(permitted), 0)

    def test_check_paths_allowed_traversal(self):
        # Attempt directory traversal to escape allowed path
        changed = ["tools/agent_contract/../../lib/main.dart"]
        success, msg, permitted, denied = self.guard.check_paths_allowed(changed)
        self.assertFalse(success)
        self.assertEqual(len(denied), 1)
        self.assertEqual(len(permitted), 0)


    def test_check_paths_allowed_symlink_escape(self):
        # Create a symlink that escapes the allowed paths
        original_realpath = os.path.realpath
        def fake_realpath(path):
            if "symlink" in path:
                return "/mock/lib/main.dart"
            return original_realpath(path.replace("/**", ""))

        with patch('os.path.realpath', side_effect=fake_realpath):
            guard = ScopeGuard("task1", "dummy_sha", ["/mock/docs/project-record/**"])
            changed = ["/mock/docs/project-record/symlink_to_lib"]
            success, msg, permitted, denied = guard.check_paths_allowed(changed)
            self.assertFalse(success)
            self.assertEqual(len(denied), 1)
            self.assertEqual(denied[0], "/mock/docs/project-record/symlink_to_lib")

    def test_check_paths_allowed_prefix_spoof(self):
        # Attempt to spoof a directory prefix
        changed = ["docs/project-record-spoofed/file.md"]
        success, msg, permitted, denied = self.guard.check_paths_allowed(changed)
        self.assertFalse(success)
        self.assertEqual(len(denied), 1)
        self.assertEqual(len(permitted), 0)

if __name__ == '__main__':
    unittest.main()
