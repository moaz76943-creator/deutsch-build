import unittest
import os
<<<<<<< HEAD
import subprocess
import sys
import tempfile
import shutil

class TestAutoHeal(unittest.TestCase):
    def setUp(self):
        self.script_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "auto_heal.py")
        self.verify_path = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "verify_contracts.py")

        self.mock_verify = tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=".py")
        self.mock_verify.write('print("✅ Mock Verify Passed")\n')
        self.mock_verify.close()

    def tearDown(self):
        if os.path.exists(self.mock_verify.name):
            os.remove(self.mock_verify.name)

    def test_dry_run(self):
        result = subprocess.run([sys.executable, self.script_path, "dry-run", "--context-signature", "J093_AUTHORIZED"], capture_output=True, text=True)
        self.assertIn("Dry run executed.", result.stdout)
        self.assertEqual(result.returncode, 0)

    def test_unauthenticated_context(self):
        result = subprocess.run(
            [sys.executable, self.script_path, "dry-run", "--context-signature", "INVALID"],
            capture_output=True, text=True
        )
        self.assertIn("BLOCKED: Unauthenticated local task context.", result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_rollback_requires_base_sha(self):
        result = subprocess.run(
            [sys.executable, self.script_path, "rollback", "--allowed-paths", "scripts/auto_heal.py", "--context-signature", "J093_AUTHORIZED"],
            capture_output=True, text=True
        )
        self.assertIn("No base SHA provided for rollback.", result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_execute_requires_plan_id(self):
        result = subprocess.run(
            [sys.executable, self.script_path, "execute", "--allowed-paths", "scripts/auto_heal.py", "--context-signature", "J093_AUTHORIZED"],
            capture_output=True, text=True
        )
        self.assertIn("BLOCKED: --plan-id is required for execution.", result.stdout)
        self.assertEqual(result.returncode, 1)

    def test_max_attempts_blocked(self):
        # Create failure evidence
        sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
        import auto_heal
        if os.path.exists(auto_heal.EVIDENCE_FILE):
            os.remove(auto_heal.EVIDENCE_FILE)

        for _ in range(3):
            auto_heal.log_failure("plan_limit", "failed")

        result = subprocess.run(
            [sys.executable, self.script_path, "execute", "--plan-id", "plan_limit", "--context-signature", "J093_AUTHORIZED"],
            capture_output=True, text=True
        )
        self.assertIn("BLOCKED: Max attempts", result.stdout)
        self.assertEqual(result.returncode, 1)
        if os.path.exists(auto_heal.EVIDENCE_FILE):
            os.remove(auto_heal.EVIDENCE_FILE)

    def test_repair_import_function(self):
        sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
        import auto_heal

        with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
            f.write("import 'package:old_path/widget.dart';")
            temp_name = f.name

        success = auto_heal.repair_import(temp_name, "package:old_path/widget.dart", "package:new_path/widget.dart")
        self.assertTrue(success)

        with open(temp_name, 'r') as f:
            content = f.read()
        self.assertIn("package:new_path/widget.dart", content)
        os.remove(temp_name)

    def test_rebuild_fts5(self):
        sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
        import auto_heal

        with tempfile.NamedTemporaryFile(mode='w', delete=False) as f:
            f.write("mock source content")
            source_name = f.name

        dest_name = source_name + "_dest"

        success = auto_heal.rebuild_fts5(source_name, dest_name)
        self.assertTrue(success)
        self.assertTrue(os.path.exists(dest_name))

        os.remove(source_name)
        os.remove(dest_name)

    def test_regenerate_artifacts(self):
        sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
        import auto_heal

        with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix=".py") as f:
            f.write('print("Regenerating...")\n')
            script_name = f.name

        success = auto_heal.regenerate_artifacts(script_name)
        self.assertTrue(success)

        os.remove(script_name)
=======
import sys
import subprocess
import json
import tempfile
from unittest.mock import patch, MagicMock

# First, test the BLOCKED behavior when module is missing
class TestAutoHealBlocked(unittest.TestCase):
    @patch.dict("sys.modules", {"j095_verification_gate": None})
    def test_missing_j095_blocked(self):
        result = subprocess.run(["python3", "scripts/auto_heal.py", "execute", "--plan-id", "test", "--allowed-paths", ".", "--base-sha", "test", "--operation", "rebuild_fts5"], capture_output=True, text=True)
        self.assertIn("BLOCKED", result.stdout)
        self.assertEqual(result.returncode, 1)

class TestAutoHealCLI(unittest.TestCase):
    def setUp(self):
        # We patch sys.modules to mock j095 gate and ScopeGuard so we can actually run the code for positive tests
        self.patcher_j095 = patch.dict("sys.modules", {"j095_verification_gate": MagicMock()})
        self.patcher_j095.start()

        self.patcher_scope = patch.dict("sys.modules", {"tools.agent_contract.guard": MagicMock()})
        self.patcher_scope.start()

        # Patch subprocess to not run actual git commands
        self.patcher_sub = patch("subprocess.run")
        self.mock_subprocess = self.patcher_sub.start()

        self.plan_id = "test-plan-001"
        self.state_file = f".auto_heal_{self.plan_id}_state.json"

        # Make sure test state file does not exist initially
        if os.path.exists(self.state_file):
            os.remove(self.state_file)

    def tearDown(self):
        self.patcher_j095.stop()
        self.patcher_scope.stop()
        self.patcher_sub.stop()

        if os.path.exists(self.state_file):
            os.remove(self.state_file)

    def test_dry_run(self):
        from scripts.auto_heal import cmd_dry_run

        class Args:
            base_sha = "abcd123"
            operation = "rebuild_fts5"

        cmd_dry_run(Args())
        self.mock_subprocess.assert_called_with(["git", "merge-base", "--is-ancestor", "abcd123", "HEAD"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    def test_bounded_attempts(self):
        from scripts.auto_heal import cmd_execute

        class Args:
            plan_id = self.plan_id
            base_sha = "abcd123"
            allowed_paths = "some/path"
            operation = "rebuild_fts5"

        # Try 3 times, should succeed
        for i in range(3):
            cmd_execute(Args())

        # 4th time should fail and sys.exit(1)
        with self.assertRaises(SystemExit) as cm:
            cmd_execute(Args())

        self.assertEqual(cm.exception.code, 1)

    def test_rollback(self):
        from scripts.auto_heal import cmd_rollback

        class Args:
            allowed_paths = "path1, path2"

        cmd_rollback(Args())
        self.mock_subprocess.assert_called_with(["git", "restore", "path1", "path2"], check=True)

    def test_repair_flutter_import(self):
        from scripts.auto_heal import cmd_execute

        # Create a temp dir for disposable fixtures
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_target_file = os.path.join(temp_dir, "test_file.dart")
            old_import_str = "import 'package:old_package/old.dart';"
            new_import_str = "import 'package:new_package/new.dart';"

            with open(temp_target_file, "w") as f:
                f.write(old_import_str)

            class Args:
                plan_id = self.plan_id
                base_sha = "abcd123"
                allowed_paths = temp_dir
                operation = "repair_flutter_import"
                target_file = temp_target_file
                old_import = old_import_str
                new_import = new_import_str

            cmd_execute(Args())

            with open(temp_target_file, "r") as f:
                content = f.read()

            self.assertEqual(content, new_import_str)
>>>>>>> pr-121

if __name__ == '__main__':
    unittest.main()
