import unittest
from unittest.mock import patch, MagicMock
import sys

# Replace agent_contract.guard usage with our new ScopeGuard test integration
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
        self.planner = RepairPlanner(owner="test_owner")

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

    def test_duplicate_attempt_prevented(self):
        sig = "Error: stale fts5 index detected"
        self.planner.generate_plan(sig, dry_run=True)

        with self.assertRaisesRegex(ValueError, "Duplicate attempt blocked"):
            self.planner.generate_plan(sig, dry_run=True)

    def test_verified_condition_allows_duplicate_attempt(self):
        sig = "Error: stale fts5 index detected"
        self.planner.generate_plan(sig, dry_run=True)

        # Should not raise exception
        self.planner.generate_plan(sig, dry_run=True, verified_condition=True)

    def test_unsafe_paths_rejected(self):
        sig1 = "Error: stale fts5 index detected in /etc/passwd.txt"
        sig2 = "Error: corrupted artifact at ../../home/user/secret.txt"

        with self.assertRaisesRegex(ValueError, "Unsafe path detected"):
            self.planner.generate_plan(sig1)
        with self.assertRaisesRegex(ValueError, "Unsafe path detected"):
            self.planner.generate_plan(sig2)

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    def test_invalid_ownership(self, mock_request_ownership):
        mock_request_ownership.return_value = False

        sig = "module not found: sys.py"
        with self.assertRaisesRegex(RuntimeError, "Failed to acquire lock for sys.py"):
            self.planner.generate_plan(sig, dry_run=False)

    @patch('tools.automation.scope_guard.ScopeGuard.request_ownership')
    def test_plan_generation_and_ownership(self, mock_request_ownership):
        mock_request_ownership.return_value = True

        sig = "module not found: src/main.py"
        paths = ["src/main.py"]

        plan = self.planner.generate_plan(sig, dry_run=False)

        self.assertIn("plan_id", plan)
        self.assertEqual(plan["category"], RESOLVABLE_IMPORT)
        self.assertEqual(plan["paths"], paths)
        self.assertEqual(plan["transformation"], "fix_import_path")
        self.assertIn("rollback_metadata", plan)
        self.assertFalse(plan["dry_run"])

        # Test dry_run
        sig_dry = "corrupted build artifact found src/build.zip"
        plan_dry = self.planner.generate_plan(sig_dry, dry_run=True)
        self.assertTrue(plan_dry["dry_run"])

if __name__ == '__main__':
    unittest.main()
