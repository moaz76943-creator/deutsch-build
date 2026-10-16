import unittest
import os
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

if __name__ == '__main__':
    unittest.main()
