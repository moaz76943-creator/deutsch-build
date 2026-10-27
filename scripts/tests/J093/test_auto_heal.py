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
        self.attempts_file = os.path.join(self.test_dir, ".auto_heal_attempts.json")

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
        shutil.rmtree(self.test_dir)

    def test_dry_run(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.dry_run()

    @patch('auto_heal.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_success(self, mock_gate, mock_request_ownership):
        mock_gate.return_value = True
        mock_request_ownership.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("good_path", content)

    @patch('auto_heal.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_failure_rollback(self, mock_gate, mock_request_ownership):
        mock_gate.return_value = False
        mock_request_ownership.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("bad_path", content)

        # Verify attempt was recorded
        with open(self.attempts_file, 'r') as f:
            data = json.load(f)
        self.assertEqual(data["J093-TEST"]["attempts"], 1)

    def test_blocked_if_gate_missing(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        with patch('os.path.exists', side_effect=lambda p: False if p == "scripts/verify_contracts.py" else True):
            self.assertFalse(executor._run_gate())

    def test_unauthorized_plan(self):
        del self.plan_data["signature"]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        with self.assertRaises(Exception) as context:
            auto_heal.AutoHealExecutor(self.plan_path)
        self.assertIn("Missing signature", str(context.exception))

    @patch('auto_heal.ScopeGuard.request_ownership')
    @patch('auto_heal.subprocess.check_call')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_commit(self, mock_gate, mock_check_call, mock_request_ownership):
        mock_gate.return_value = True
        mock_request_ownership.return_value = True
        self.plan_data["commit"] = True
        self.plan_data["branch"] = "test-branch"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        executor.execute()

        calls = mock_check_call.call_args_list
        self.assertEqual(calls[0][0][0], ["git", "checkout", "-b", "test-branch"])
        self.assertEqual(calls[1][0][0], ["git", "add", self.target_file])
        self.assertEqual(calls[2][0][0], ["git", "commit", "-m", "Fix(J093-TEST): Auto-heal repair [skip ci]"])

    @patch('auto_heal.ScopeGuard.request_ownership')
    def test_scope_guard_collision(self, mock_request_ownership):
        mock_request_ownership.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception):
                executor.execute()

    @patch('auto_heal.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_max_attempts(self, mock_gate, mock_request_ownership):
        mock_gate.return_value = False
        mock_request_ownership.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file

        # Simulate 3 failures
        for _ in range(3):
            try:
                executor.execute()
            except SystemExit:
                pass

        # 4th attempt should hit max limit block immediately
        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExitMax")
            with self.assertRaises(Exception) as ctx:
                executor.execute()
            self.assertEqual(str(ctx.exception), "SystemExitMax")

        with open(self.attempts_file, 'r') as f:
            data = json.load(f)
        self.assertEqual(data["J093-TEST"]["attempts"], 3)

    @patch('auto_heal.os.rename')
    def test_atomic_regeneration(self, mock_rename):
        artifact_path = os.path.join(self.test_dir, "test_artifact.txt")
        self.plan_data["operations"] = [
            {
                "type": "regenerate_artifact",
                "path": artifact_path,
                "content": "new_content"
            }
        ]
        self.plan_data["allowed_paths"].append(artifact_path)
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.attempts_file = self.attempts_file
        executor._apply_operation(self.plan_data["operations"][0])

        # Assert temporary file was written
        with open(f"{artifact_path}.tmp", 'r') as f:
            self.assertEqual(f.read(), "new_content")

        mock_rename.assert_called_once_with(f"{artifact_path}.tmp", artifact_path)

if __name__ == '__main__':
    unittest.main()
