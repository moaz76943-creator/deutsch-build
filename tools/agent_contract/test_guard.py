import json
import os
import subprocess
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

# Import the module to test
import tools.agent_contract.guard as guard

class TestScopeGuard(unittest.TestCase):

    def setUp(self):
        # Create a temporary directory for the ledger and tests
        self.test_dir = tempfile.TemporaryDirectory()
        self.ledger_file = os.path.join(self.test_dir.name, ".ledger.json")
        # Override the LEDGER_FILE path in the module
        self.original_ledger_file = guard.LEDGER_FILE
        guard.LEDGER_FILE = self.ledger_file

        # Patch subprocess to not actually call git unless we want it to
        self.subprocess_run_patcher = patch('subprocess.run')
        self.mock_run = self.subprocess_run_patcher.start()

        # Setup default mock behavior for git
        self.mock_run.return_value = MagicMock(
            stdout="",
            returncode=0
        )

    def tearDown(self):
        self.test_dir.cleanup()
        guard.LEDGER_FILE = self.original_ledger_file
        self.subprocess_run_patcher.stop()

    def test_path_allowed(self):
        self.assertTrue(guard.is_path_allowed("AGENTS.md"))
        self.assertTrue(guard.is_path_allowed("docs/project-record/TEST.md"))
        self.assertTrue(guard.is_path_allowed("tools/agent_contract/guard.py"))

        self.assertFalse(guard.is_path_allowed("lib/main.dart"))
        self.assertFalse(guard.is_path_allowed("android/app/build.gradle"))
        self.assertFalse(guard.is_path_allowed("package.json"))

    def test_path_traversal_blocked(self):
        # Create a symlink to test escape attempts
        symlink_path = Path("tools/agent_contract/sneaky_link")
        if not symlink_path.exists():
            try:
                os.symlink("../../lib", symlink_path)
            except OSError:
                pass # Might not have permission, ignore

        if symlink_path.exists():
            self.assertFalse(guard.is_path_allowed("tools/agent_contract/sneaky_link/main.dart"))
            os.remove(symlink_path)

        self.assertFalse(guard.is_path_allowed("tools/agent_contract/../../lib/main.dart"))

    def test_path_collision(self):
        ledger = {
            "TASK-1": {
                "state": "ACTIVE",
                "paths": ["tools/agent_contract/"]
            }
        }

        # Same path
        self.assertEqual(
            guard.check_path_collision(ledger, "TASK-2", ["tools/agent_contract/guard.py"]),
            "tools/agent_contract/guard.py"
        )

        # Different path
        self.assertIsNone(
            guard.check_path_collision(ledger, "TASK-2", ["docs/project-record/"])
        )

        # Collision with completed task (should be allowed)
        ledger["TASK-1"]["state"] = "COMPLETE"
        self.assertIsNone(
            guard.check_path_collision(ledger, "TASK-2", ["tools/agent_contract/guard.py"])
        )

    def test_stale_base_sha(self):
        self.mock_run.side_effect = subprocess.CalledProcessError(
            returncode=128, cmd=['git', 'cat-file', '-e', 'BADSHA^{commit}']
        )

        with self.assertRaisesRegex(guard.ScopeGuardException, "Invalid or stale BASE_SHA"):
            guard.validate_base_sha("BADSHA")

    @patch('sys.exit')
    @patch('builtins.print')
    def test_valid_state_transitions(self, mock_print, mock_exit):
        base_sha = "validsha"
        self.mock_run.return_value.stdout = "" # No changed files

        # CLAIM
        guard.process_claim("TASK-1", base_sha, "CLAIM", ["tools/agent_contract/"])
        mock_exit.assert_not_called()

        # ACTIVE
        guard.process_claim("TASK-1", base_sha, "ACTIVE", [])
        mock_exit.assert_not_called()

        # COMPLETE
        guard.process_claim("TASK-1", base_sha, "COMPLETE", [])
        mock_exit.assert_not_called()

        # Read ledger to verify state
        with open(self.ledger_file, 'r') as f:
            ledger = json.load(f)
            self.assertEqual(ledger["TASK-1"]["state"], "COMPLETE")

    @patch('sys.exit')
    @patch('builtins.print')
    def test_invalid_state_transition(self, mock_print, mock_exit):
        base_sha = "validsha"
        self.mock_run.return_value.stdout = ""

        # Start CLAIM
        guard.process_claim("TASK-1", base_sha, "CLAIM", ["tools/agent_contract/"])

        # Invalid transition: CLAIM -> COMPLETE
        guard.process_claim("TASK-1", base_sha, "COMPLETE", [])

        # Check that it errored out
        mock_exit.assert_called_with(1)

        # Find the error message
        found_error = False
        for call in mock_print.call_args_list:
            args, _ = call
            try:
                msg = json.loads(args[0])
                if msg.get("status") == "error" and "Invalid state transition" in msg.get("message", ""):
                    found_error = True
            except:
                pass
        self.assertTrue(found_error)

    @patch('sys.exit')
    @patch('builtins.print')
    def test_unauthorized_modification(self, mock_print, mock_exit):
        base_sha = "validsha"

        def mock_subprocess_run(args, **kwargs):
            if args[0] == 'git' and args[1] == 'diff':
                return MagicMock(stdout="lib/main.dart\n", returncode=0)
            elif args[0] == 'git' and args[1] == 'status':
                return MagicMock(stdout="", returncode=0)
            return MagicMock(stdout="", returncode=0)

        self.mock_run.side_effect = mock_subprocess_run

        guard.process_claim("TASK-1", base_sha, "CLAIM", ["tools/agent_contract/"])

        mock_exit.assert_called_with(1)
        found_error = False
        for call in mock_print.call_args_list:
            args, _ = call
            try:
                msg = json.loads(args[0])
                if msg.get("status") == "error" and "Unauthorized file modification" in msg.get("message", ""):
                    found_error = True
            except:
                pass
        self.assertTrue(found_error)

if __name__ == '__main__':
    unittest.main()
