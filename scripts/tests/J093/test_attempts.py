import unittest
import os
import json
import tempfile
import shutil
from unittest.mock import patch
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../../')))
import auto_heal

class TestAutoHealAttempts(unittest.TestCase):
    def setUp(self):
        self.test_dir = tempfile.mkdtemp()
        self.ledger_path = os.path.join(self.test_dir, ".scope_guard_ledger.json")
        self.plan_path = os.path.join(self.test_dir, "plan.json")
        self.target_file = os.path.join(self.test_dir, "target.dart")

        self.attempts_file = os.path.join(self.test_dir, ".auto_heal_attempts.json")
        self.failures_file = os.path.join(self.test_dir, ".auto_heal_failures.json")

        os.environ["AUTO_HEAL_ATTEMPTS_FILE"] = self.attempts_file
        os.environ["AUTO_HEAL_FAILURES_FILE"] = self.failures_file

        with open(self.target_file, 'w') as f:
            f.write("import 'bad_path';\n")

        self.plan_data = {
            "plan_id": "J093-TEST-ATTEMPTS",
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
        if "AUTO_HEAL_ATTEMPTS_FILE" in os.environ:
            del os.environ["AUTO_HEAL_ATTEMPTS_FILE"]
        if "AUTO_HEAL_FAILURES_FILE" in os.environ:
            del os.environ["AUTO_HEAL_FAILURES_FILE"]

    @patch('auto_heal.AutoHealExecutor._run_gate')
    def test_max_attempts(self, mock_gate):
        mock_gate.return_value = False

        # Run 3 times, should fail and rollback each time
        for i in range(3):
            executor = auto_heal.AutoHealExecutor(self.plan_path)
            executor.guard.ledger_path = self.ledger_path
            with self.assertRaises(SystemExit):
                executor.execute()

            with open(self.attempts_file, 'r') as f:
                attempts = json.load(f)
            self.assertEqual(attempts["J093-TEST-ATTEMPTS"], i + 1)

        # 4th time should be blocked before execution
        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor.guard.ledger_path = self.ledger_path
        with self.assertRaises(SystemExit):
            executor.execute()

        with open(self.failures_file, 'r') as f:
            failures = json.load(f)
        self.assertIn("Max attempts (3) reached", failures["J093-TEST-ATTEMPTS"]["reason"])

    def test_atomic_regenerate_artifact(self):
        self.plan_data["operations"] = [
            {
                "type": "regenerate_artifact",
                "path": self.target_file,
                "content": "new_atomic_content"
            }
        ]
        with open(self.plan_path, 'w') as f:
            json.dump(self.plan_data, f)

        executor = auto_heal.AutoHealExecutor(self.plan_path)
        executor._apply_operation(self.plan_data["operations"][0])

        with open(self.target_file, 'r') as f:
            content = f.read()
        self.assertEqual(content, "new_atomic_content")

if __name__ == '__main__':
    unittest.main()
