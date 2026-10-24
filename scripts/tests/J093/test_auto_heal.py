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
        self.plan_path = os.path.join(self.test_dir, "plan.json")
        self.target_file = os.path.join(self.test_dir, "target.dart")

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
        if os.path.exists(".auto_heal_evidence.json"):
            os.remove(".auto_heal_evidence.json")

    def test_dry_run(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.dry_run()

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_success(self, mock_gate):
        mock_gate.return_value = True
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("good_path", content)

        with open(self.ledger_path, 'r') as f:
            ledger = json.load(f)
        self.assertEqual(ledger["leases"][self.target_file]["status"], "COMPLETE")

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_execute_failure_rollback(self, mock_gate):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertIn("bad_path", content)

        with open(self.ledger_path, 'r') as f:
            ledger = json.load(f)
        self.assertEqual(ledger["leases"][self.target_file]["status"], "CANCELLED")

    def test_blocked_if_gate_missing(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        with patch('os.path.exists', side_effect=lambda p: False if p == "scripts/verify_contracts.py" else True):
            self.assertFalse(executor._run_gate())

    def test_unauthorized_plan(self):
        del self.plan_data["signature"]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        with self.assertRaises(Exception) as context:
            auto_heal.AutoHealExecutor(self.plan_path)
        self.assertIn("Missing signature", str(context.exception))

    @patch('auto_heal.subprocess.check_call')
    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_commit(self, mock_gate, mock_check_call):
        mock_gate.return_value = True
        self.plan_data["commit"] = True
        self.plan_data["branch"] = "test-branch"
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path

        executor.execute()

        calls = mock_check_call.call_args_list
        self.assertEqual(calls[0][0][0], ["git", "checkout", "-b", "test-branch"])
        self.assertEqual(calls[1][0][0], ["git", "add", self.target_file])
        self.assertEqual(calls[2][0][0], ["git", "commit", "-m", "Fix(J093-TEST): Auto-heal repair [skip ci]"])

    def test_scope_guard_collision(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path

        # Pre-claim the lease with another agent
        executor.guard.claim("OtherAgent", [self.target_file])

        # Now try to claim it with our executor
        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = Exception("SystemExit")
            with self.assertRaises(Exception):
                executor.execute()

    def test_bounded_attempts(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.evidence_path = os.path.join(self.test_dir, ".auto_heal_evidence.json")

        # Manually set attempts to max
        with open(executor.evidence_path, 'w') as f:
            json.dump({self.plan_data["plan_id"]: {"attempts": executor.max_attempts}}, f)

        with patch('sys.exit') as mock_exit:
            mock_exit.side_effect = SystemExit(1)
            with self.assertRaises(SystemExit):
                executor.execute()

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_failure_records_evidence(self, mock_gate):
        mock_gate.return_value = False
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path
        executor.evidence_path = os.path.join(self.test_dir, ".auto_heal_evidence.json")

        with self.assertRaises(SystemExit):
            executor.execute()

        with open(executor.evidence_path, 'r') as f:
            evidence = json.load(f)
        self.assertEqual(evidence[self.plan_data["plan_id"]]["attempts"], 1)

    def test_strict_unicity_check(self):
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        # Test zero occurrences
        with open(self.target_file, 'w') as f:
            f.write("import 'something_else';\n")

        with self.assertRaises(ValueError) as context:
            executor._apply_operation(self.plan_data["operations"][0])
        self.assertIn("Strict unicity check failed", str(context.exception))

        # Test multiple occurrences
        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\nimport 'bad_path';\n")

        with self.assertRaises(ValueError) as context:
            executor._apply_operation(self.plan_data["operations"][0])
        self.assertIn("Strict unicity check failed", str(context.exception))

    @patch('os.replace')
    def test_atomic_write(self, mock_replace):
        executor = auto_heal.AutoHealExecutor(self.plan_path)

        # Restore target file to valid state for operation
        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\n")

        # It should call os.replace after writing to tmp file
        executor._apply_operation(self.plan_data["operations"][0])
        mock_replace.assert_called_once_with(self.target_file + ".tmp", self.target_file)

if __name__ == '__main__':
    unittest.main()
