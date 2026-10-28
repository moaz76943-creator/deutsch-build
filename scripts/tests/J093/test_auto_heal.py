import unittest
import os
import json
import tempfile
import shutil
from unittest.mock import patch, MagicMock
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
import auto_heal

class TestAutoHeal(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.plan_path = os.path.join(self.test_dir, "plan.json")
        self.target_file = os.path.join(self.test_dir, "target.dart")

        # Patch attempts file to be isolated in test_dir
        self.attempts_file = os.path.join(self.test_dir, ".auto_heal_attempts.json")
        self.patcher = patch.object(auto_heal.AutoHealExecutor, '_get_attempts_file', return_value=self.attempts_file)
        self.patcher.start()

        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\n")

        self.plan_data = {
            "plan_id": "J093-TEST",
            "signature": "valid",
            "base_sha": "any",
            "allowed_paths": [self.target_file],
            "operations": [
                {
                    "type": "repair_import",
                    "path": self.target_file,
                    "old_import": "bad_path",
                    "new_import": "good_path"
                }
            ]
        }

        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

    def tearDown(self):
        self.patcher.stop()
        shutil.rmtree(self.test_dir)

    @patch('auto_heal.ScopeGuard')
    def test_dry_run(self, mock_guard_class):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.dry_run()

    @patch('auto_heal.ScopeGuard')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_success(self, mock_gate, mock_guard_class):
        mock_gate.return_value = True
        mock_guard = mock_guard_class.return_value
        mock_guard.request_ownership.return_value = True

        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("good_path", content)
        mock_guard.request_ownership.assert_called_with(self.target_file)

        # Verify attempt logic incremented
        with open(self.attempts_file, 'r') as f:
            attempts_data = json.load(f)
        self.assertEqual(attempts_data["J093-TEST"]["attempts"], 1)

    @patch('auto_heal.ScopeGuard')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_failure_rollback(self, mock_gate, mock_guard_class):
        mock_gate.return_value = False
        mock_guard = mock_guard_class.return_value
        mock_guard.request_ownership.return_value = True

        executor = auto_heal.AutoHealExecutor(self.plan_path)

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("bad_path", content)

        # Verify failure recorded
        with open(self.attempts_file, 'r') as f:
            attempts_data = json.load(f)
        self.assertIn("Verification failed.", attempts_data["J093-TEST"]["failures"][0])

    @patch('auto_heal.ScopeGuard')
    def test_blocked_if_gate_missing(self, mock_guard_class):
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        with patch('os.path.exists', side_effect=lambda p: False if p == "scripts/verify_contracts.py" else True):
            self.assertFalse(executor._run_gate())

    @patch('auto_heal.ScopeGuard')
    def test_unauthorized_plan(self, mock_guard_class):
        del self.plan_data["signature"]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        with self.assertRaises(Exception) as context:
            auto_heal.AutoHealExecutor(self.plan_path)
        self.assertIn("Missing signature", str(context.exception))

    @patch('auto_heal.ScopeGuard')
    @patch('auto_heal.subprocess.check_call')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_commit(self, mock_gate, mock_check_call, mock_guard_class):
        mock_gate.return_value = True
        mock_guard = mock_guard_class.return_value
        mock_guard.request_ownership.return_value = True

        self.plan_data["commit"] = True
        self.plan_data["branch"] = "test-branch"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)

        executor.execute()

        calls = mock_check_call.call_args_list
        self.assertEqual(calls[0][0][0], ["git", "checkout", "-b", "test-branch"])
        self.assertEqual(calls[1][0][0], ["git", "add", self.target_file])
        self.assertEqual(calls[2][0][0], ["git", "commit", "-m", "Fix(J093-TEST): Auto-heal repair [skip ci]"])

    @patch('auto_heal.ScopeGuard')
    def test_scope_guard_collision(self, mock_guard_class):
        mock_guard = mock_guard_class.return_value
        mock_guard.request_ownership.return_value = False

        executor = auto_heal.AutoHealExecutor(self.plan_path)

        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception):
                executor.execute()

        # Verify failure recorded
        with open(self.attempts_file, 'r') as f:
            attempts_data = json.load(f)
        self.assertIn("Failed to claim lease", attempts_data["J093-TEST"]["failures"][0])

    @patch('auto_heal.ScopeGuard')
    def test_bounded_attempts_limit(self, mock_guard_class):
        # Preset attempts to 3
        with open(self.attempts_file, 'w') as f:
            json.dump({"J093-TEST": {"attempts": 3, "failures": []}}, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)

        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception):
                executor.execute()


if __name__ == '__main__':
    unittest.main()
