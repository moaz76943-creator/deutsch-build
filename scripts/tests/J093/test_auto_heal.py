import unittest
import os
import sys
import json
import tempfile
import subprocess
import shutil
from io import StringIO
from unittest.mock import patch
sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))
import auto_heal

class TestAutoHeal(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.repo_dir = os.path.join(self.temp_dir, "test_repo")
        os.makedirs(self.repo_dir)
        self.test_file_path = os.path.join(self.repo_dir, "test_file.dart")
        self.unrelated_file_path = os.path.join(self.repo_dir, "unrelated_file.dart")

        with open(self.test_file_path, "w") as f:
            f.write("import 'package:old/old.dart';\n")
        with open(self.unrelated_file_path, "w") as f:
            f.write("import 'package:unrelated/unrelated.dart';\n")

        subprocess.run(["git", "init"], cwd=self.repo_dir, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=self.repo_dir, capture_output=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=self.repo_dir, capture_output=True)
        subprocess.run(["git", "add", "."], cwd=self.repo_dir, capture_output=True)
        subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=self.repo_dir, capture_output=True)

        # Modify the unrelated file so there are uncommitted changes to verify isolation
        with open(self.unrelated_file_path, "w") as f:
            f.write("import 'package:unrelated/modified.dart';\n")

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    @patch.dict(os.environ, {"J095_GATE_MISSING": "1"})
    def test_j095_gate_missing(self):
        with self.assertRaises(SystemExit) as cm:
            auto_heal.check_j095_gate()
        self.assertEqual(cm.exception.code, 1)

    def test_validation_failure(self):
        with self.assertRaises(ValueError) as cm:
            auto_heal.validate_context("INVALID_SIG", "VALID_LEASE", [self.test_file_path])
        self.assertIn("Invalid authentication context", str(cm.exception))

    def test_successful_execute_repair(self):
        operations = [{"type": "repair_flutter_import", "file": self.test_file_path, "search": "package:old/old.dart", "replace": "package:new/new.dart"}]
        args = ["execute", "--plan-id", "P123", "--base-sha", "HEAD", "--signature", "VALID_SIG", "--lease-id", "VALID_LEASE", "--allowed-paths", self.test_file_path, "--operations", json.dumps(operations)]

        with patch("sys.argv", ["auto_heal.py"] + args):
            with self.assertRaises(SystemExit) as cm:
                auto_heal.main()
            self.assertEqual(cm.exception.code, 0)

        with open(self.test_file_path, "r") as f:
            content = f.read()
        self.assertIn("package:new/new.dart", content)
        self.assertNotIn("package:old/old.dart", content)

    def test_unsupported_operation_rollback(self):
        operations = [{"type": "unsupported_op"}]
        args = ["execute", "--plan-id", "P123", "--base-sha", "HEAD", "--signature", "VALID_SIG", "--lease-id", "VALID_LEASE", "--allowed-paths", self.test_file_path, "--operations", json.dumps(operations)]

        # Modify the file first to check rollback if we theoretically did something before failure
        # Here we just verify failure is caught and sys.exit(1) is called
        with patch("sys.argv", ["auto_heal.py"] + args), patch("sys.stderr", new_callable=StringIO) as mock_err:
             with self.assertRaises(SystemExit) as cm:
                 auto_heal.main()
             self.assertEqual(cm.exception.code, 1)
             self.assertIn("Execution failed persistently after retries", mock_err.getvalue())
             self.assertIn("Attempt 3 failed", mock_err.getvalue())

        # File should remain unchanged
        with open(self.test_file_path, "r") as f:
             content = f.read()
        self.assertIn("package:old/old.dart", content)

    def test_create_commit_isolation(self):
         operations = [{"type": "repair_flutter_import", "file": self.test_file_path, "search": "package:old/old.dart", "replace": "package:new/new.dart"}]
         args = ["execute", "--plan-id", "P123", "--base-sha", "HEAD", "--signature", "VALID_SIG", "--lease-id", "VALID_LEASE", "--allowed-paths", self.test_file_path, "--operations", json.dumps(operations), "--create-commit"]

         # change to repo dir to allow git commands
         original_cwd = os.getcwd()
         os.chdir(self.repo_dir)
         try:
             with patch("sys.argv", ["auto_heal.py"] + args):
                 with self.assertRaises(SystemExit) as cm:
                     auto_heal.main()
                 self.assertEqual(cm.exception.code, 0)

             # Verify the commit message
             result = subprocess.run(["git", "log", "-1", "--pretty=%B"], capture_output=True, text=True)
             self.assertIn("Auto-heal repair P123 [skip ci]", result.stdout)

             # Verify isolation: the unrelated file should still have uncommitted changes in the working tree
             result = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
             self.assertIn(" M unrelated_file.dart", result.stdout)
         finally:
             os.chdir(original_cwd)

    def test_rollback_command(self):
        # Checkout the base SHA using git command as now implemented in rollback
        args = ["rollback", "--plan-id", "P123", "--base-sha", "HEAD", "--signature", "VALID_SIG", "--lease-id", "VALID_LEASE", "--allowed-paths", self.test_file_path, "--operations", "[]"]
        original_cwd = os.getcwd()
        os.chdir(self.repo_dir)
        try:
             with patch("sys.argv", ["auto_heal.py"] + args):
                 with self.assertRaises(SystemExit) as cm:
                     auto_heal.main()
                 self.assertEqual(cm.exception.code, 0)
        finally:
             os.chdir(original_cwd)

    def test_verify_command(self):
        args = ["verify", "--plan-id", "P123", "--base-sha", "HEAD", "--signature", "VALID_SIG", "--lease-id", "VALID_LEASE", "--allowed-paths", self.test_file_path, "--operations", "[]"]
        with patch("sys.argv", ["auto_heal.py"] + args):
             with self.assertRaises(SystemExit) as cm:
                 auto_heal.main()
             self.assertEqual(cm.exception.code, 0)

if __name__ == '__main__':
    unittest.main()
