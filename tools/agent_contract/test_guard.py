import unittest
import os
import json
<<<<<<< HEAD
import shutil
import tempfile
import sys
from unittest.mock import patch, MagicMock
import subprocess

from tools.agent_contract import guard

class TestGuardSubsystem(unittest.TestCase):
    def setUp(self):
        # Create a temporary directory for tests
        self.test_dir = tempfile.mkdtemp()
        self.ledger_path = os.path.join(self.test_dir, 'task_ledger.json')

        # Patch the ledger path in the guard module
        self.patcher = patch('tools.agent_contract.guard.LEDGER_PATH', self.ledger_path)
        self.patcher.start()

    def tearDown(self):
        self.patcher.stop()
        shutil.rmtree(self.test_dir)

    def test_claim_task_success(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])
        ledger = guard.load_ledger()
        self.assertIn('TASK-001', ledger)
        self.assertEqual(ledger['TASK-001']['state'], 'CLAIM')
        self.assertEqual(ledger['TASK-001']['base_sha'], 'abcdef123')
        self.assertEqual(ledger['TASK-001']['allowed_paths'], ['docs/project-record/*'])

    def test_parallel_claim_overlap(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])

        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stderr', new_callable=lambda: open(os.devnull, 'w')):
                guard.claim_task('TASK-002', 'def456', ['docs/project-record/task_ledger.json'])
        self.assertEqual(cm.exception.code, 1)

    def test_parallel_claim_no_overlap(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])
        guard.claim_task('TASK-002', 'def456', ['tools/agent_contract/*'])

        ledger = guard.load_ledger()
        self.assertIn('TASK-001', ledger)
        self.assertIn('TASK-002', ledger)

    def test_claim_overlap_with_completed_task(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])
        guard.transition_task('TASK-001', 'ACTIVE')
        guard.transition_task('TASK-001', 'COMPLETE')

        # Should succeed because TASK-001 is complete
        guard.claim_task('TASK-002', 'def456', ['docs/project-record/*'])

        ledger = guard.load_ledger()
        self.assertIn('TASK-002', ledger)

    def test_transition_success(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])
        guard.transition_task('TASK-001', 'ACTIVE')
        ledger = guard.load_ledger()
        self.assertEqual(ledger['TASK-001']['state'], 'ACTIVE')

    def test_invalid_transition(self):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])
        # CLAIM -> COMPLETE is invalid
        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stderr', new_callable=lambda: open(os.devnull, 'w')):
                guard.transition_task('TASK-001', 'COMPLETE')
        self.assertEqual(cm.exception.code, 1)

    def test_transition_nonexistent_task(self):
        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stderr', new_callable=lambda: open(os.devnull, 'w')):
                guard.transition_task('TASK-999', 'ACTIVE')
        self.assertEqual(cm.exception.code, 1)

    def test_path_allowed_valid(self):
        self.assertTrue(guard._is_path_allowed('docs/project-record/some_file.md', ['docs/project-record/*']))
        self.assertTrue(guard._is_path_allowed('AGENTS.md', ['AGENTS.md']))

    def test_path_allowed_forbidden(self):
        self.assertFalse(guard._is_path_allowed('lib/main.dart', ['*']))
        self.assertFalse(guard._is_path_allowed('android/app/build.gradle', ['android/*']))

    def test_path_allowed_traversal(self):
        self.assertFalse(guard._is_path_allowed('../outside.txt', ['*']))
        self.assertFalse(guard._is_path_allowed('docs/../lib/main.dart', ['docs/*']))

    @patch('subprocess.check_call')
    @patch('subprocess.check_output')
    def test_validate_success(self, mock_check_output, mock_check_call):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])

        # Mock git commands
        mock_check_call.return_value = 0

        def mock_git_output(args, **kwargs):
            if 'diff' in args:
                return b'docs/project-record/task_ledger.json\n'
            if 'ls-files' in args:
                return b''
            return b''

        mock_check_output.side_effect = mock_git_output

        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stdout', new_callable=lambda: open(os.devnull, 'w')):
                guard.validate_task('TASK-001')
        self.assertEqual(cm.exception.code, 0)

    @patch('subprocess.check_call')
    @patch('subprocess.check_output')
    def test_validate_unauthorized_modification(self, mock_check_output, mock_check_call):
        guard.claim_task('TASK-001', 'abcdef123', ['docs/project-record/*'])

        # Mock git commands
        mock_check_call.return_value = 0

        def mock_git_output(args, **kwargs):
            if 'diff' in args:
                return b'lib/main.dart\n' # Forbidden and not in allowed paths
            if 'ls-files' in args:
                return b''
            return b''

        mock_check_output.side_effect = mock_git_output

        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stderr', new_callable=lambda: open(os.devnull, 'w')):
                with patch('sys.stdout', new_callable=lambda: open(os.devnull, 'w')):
                    guard.validate_task('TASK-001')
        self.assertEqual(cm.exception.code, 1)

    @patch('subprocess.check_call')
    def test_validate_stale_base_sha(self, mock_check_call):
        guard.claim_task('TASK-001', 'invalid_sha', ['docs/project-record/*'])

        mock_check_call.side_effect = subprocess.CalledProcessError(128, 'git')

        with self.assertRaises(SystemExit) as cm:
            with patch('sys.stderr', new_callable=lambda: open(os.devnull, 'w')):
                guard.validate_task('TASK-001')
        self.assertEqual(cm.exception.code, 1)
=======
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
>>>>>>> pr-179

if __name__ == '__main__':
    unittest.main()
