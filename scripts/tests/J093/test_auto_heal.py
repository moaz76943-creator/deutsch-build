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
        self.ledger_path = os.path.join(self.test_dir, ".scope_guard_ledger.json")
        self.failures_ledger_path = os.path.join(self.test_dir, ".auto_heal_failures.json")
        self.plan_path = os.path.join(self.test_dir, "plan.json")
        self.target_file = os.path.join(self.test_dir, "target.dart")

        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\n")

        if os.path.exists(".auto_heal_attempts.json"):
            os.remove(".auto_heal_attempts.json")

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
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.dry_run()

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_success(self, mock_gate, mock_ownership):
        mock_gate.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("good_path", content)

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_failure_rollback(self, mock_gate, mock_ownership):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("bad_path", content)

    def test_blocked_if_gate_missing(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)

        with patch('os.path.exists', side_effect=lambda p: False if p == "scripts/verify_contracts.py" else True):
            self.assertFalse(executor._run_gate())

    def test_unauthorized_plan(self):
        del self.plan_data["signature"]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        with self.assertRaises(Exception) as context:
            auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        self.assertIn("Missing signature", str(context.exception))

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    @patch('auto_heal.subprocess.check_call')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_commit(self, mock_gate, mock_check_call, mock_ownership):
        mock_gate.return_value = True
        mock_ownership.return_value = True
        self.plan_data["commit"] = True
        self.plan_data["branch"] = "test-branch"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        calls = mock_check_call.call_args_list
        self.assertEqual(calls[0][0][0], ["git", "checkout", "-b", "test-branch"])
        self.assertEqual(calls[1][0][0], ["git", "add", self.target_file])
        self.assertEqual(calls[2][0][0], ["git", "commit", "-m", "Fix(J093-TEST): Auto-heal repair [skip ci]"])

    def test_scope_guard_collision(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

    @patch('auto_heal.AutoHealExecutor._run_gate')
    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    def test_bounded_attempts(self, mock_ownership, mock_gate):
        mock_ownership.return_value = True
        mock_gate.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        for _ in range(3):
            executor.execute()

        with self.assertRaises(SystemExit):
            executor.execute()

        if os.path.exists(".auto_heal_attempts.json"):
            os.remove(".auto_heal_attempts.json")

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_bounded_attempts_enforced(self, mock_gate):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path, self.failures_ledger_path)
        executor.guard.ledger_path = self.ledger_path

        # Simulate max failures
        for _ in range(3):
            with self.assertRaises(SystemExit):
                executor.execute()

        # The next execute should fail immediately due to bounded attempts
        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception) as context:
                executor.execute()

if __name__ == '__main__':
    unittest.main()
