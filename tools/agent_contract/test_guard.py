import unittest
import os
import json
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

if __name__ == '__main__':
    unittest.main()
