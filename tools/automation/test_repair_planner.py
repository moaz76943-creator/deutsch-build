import unittest
from unittest.mock import patch, MagicMock
import sys

from tools.automation.repair_planner import (
    RepairPlanner,
    STALE_FTS5,
    CORRUPTED_ARTIFACT,
    RESOLVABLE_IMPORT,
    TOOLCHAIN_STATE,
    MANIFEST_MISMATCH
)

class TestRepairPlanner(unittest.TestCase):
    def setUp(self):
        self.planner = RepairPlanner()

    def test_classify_known_failures(self):
        self.assertEqual(self.planner.classify_failure("Error: stale fts5 index detected"), STALE_FTS5)
        self.assertEqual(self.planner.classify_failure("corrupted build artifact found"), CORRUPTED_ARTIFACT)
        self.assertEqual(self.planner.classify_failure("module not found: sys"), RESOLVABLE_IMPORT)
        self.assertEqual(self.planner.classify_failure("Fatal: toolchain state error"), TOOLCHAIN_STATE)
        self.assertEqual(self.planner.classify_failure("manifest mismatch in dependencies"), MANIFEST_MISMATCH)

    def test_reject_unknown_failure(self):
        with self.assertRaisesRegex(ValueError, "BLOCKED_UNKNOWN_FAILURE"):
            self.planner.classify_failure("Something went completely wrong")

    def test_reject_ambiguous_dependency(self):
        with self.assertRaisesRegex(ValueError, "Ambiguous fix rejected"):
            self.planner.classify_failure("Security vulnerability in ambiguous dependency upgrade")

    @patch('tools.automation.scope_guard.ScopeGuard')
    def test_duplicate_attempt_prevented(self, MockGuard):
        sig = "Error: stale fts5 index detected"
        self.planner.generate_plan(sig)

        with self.assertRaisesRegex(ValueError, "Duplicate attempt blocked"):
            self.planner.generate_plan(sig)

        # new_input=True bypasses the check
        self.planner.generate_plan(sig, new_input=True)

    @patch('tools.automation.scope_guard.ScopeGuard')
    def test_unsafe_paths_rejected(self, MockGuard):
        # We need paths to be extracted correctly in regex
        # The regex in repair_planner is r"([a-zA-Z0-9_\-\./]+\.[a-zA-Z0-9]+)"
        # /etc/passwd has no extension, let's use /etc/passwd.txt
        sig1 = "Error: stale fts5 index detected in /etc/passwd.txt"
        sig2 = "Error: corrupted artifact at ../../home/user/secret.txt"

        with self.assertRaisesRegex(ValueError, "Unsafe path detected"):
            self.planner.generate_plan(sig1)
        with self.assertRaisesRegex(ValueError, "Unsafe path detected"):
            self.planner.generate_plan(sig2)

    @patch('tools.automation.scope_guard.ScopeGuard')
    def test_invalid_ownership(self, MockGuard):
        mock_guard_instance = MagicMock()
        mock_guard_instance.request_ownership.return_value = False
        MockGuard.return_value = mock_guard_instance

        sig = "module not found: sys.py"
        with self.assertRaisesRegex(RuntimeError, "Failed to acquire lock"):
            self.planner.generate_plan(sig, dry_run=False)

    @patch('tools.automation.scope_guard.ScopeGuard')
    def test_plan_generation_and_ownership(self, MockGuard):
        mock_guard_instance = MagicMock()
        mock_guard_instance.request_ownership.return_value = True
        MockGuard.return_value = mock_guard_instance

        sig = "module not found: src/main.py"
        paths = ["src/main.py"]

        plan = self.planner.generate_plan(sig, dry_run=False)

        self.assertIn("plan_id", plan)
        self.assertEqual(plan["category"], RESOLVABLE_IMPORT)
        self.assertEqual(plan["allowed_paths"], paths)
        self.assertEqual(plan["operations"], [{"type": "fix_import_path", "path": "src/main.py"}])
        self.assertEqual(plan["signature"], sig)
        self.assertIn("base_sha", plan)
        self.assertIn("rollback_metadata", plan)
        self.assertFalse(plan["dry_run"])

        # Test dry_run
        sig_dry = "corrupted build artifact found src/build.zip"
        plan_dry = self.planner.generate_plan(sig_dry, dry_run=True)
        self.assertTrue(plan_dry["dry_run"])

if __name__ == '__main__':
    unittest.main()
