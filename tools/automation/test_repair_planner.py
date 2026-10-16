import os
import tempfile
import unittest
from pathlib import Path
from tools.automation.repair_planner import RepairPlanner, RepairPlannerError
from tools.automation.scope_guard import ScopeGuard


class TestRepairPlanner(unittest.TestCase):
    def setUp(self):
        self.planner = RepairPlanner()

    def test_classify_known_failure(self):
        code = self.planner.classify_failure("Error: stale generated FTS5 index found")
        self.assertEqual(code, "STALE_FTS5_INDEX")

    def test_classify_unknown_failure(self):
        code = self.planner.classify_failure("Error: segfault in core")
        self.assertIsNone(code)

    def test_plan_repair_known_safe(self):
        plan = self.planner.plan_repair("stale generated FTS5 index", "tools/automation/indexer.py")
        self.assertEqual(plan["status"], "READY")
        self.assertEqual(plan["failure_code"], "STALE_FTS5_INDEX")
        self.assertEqual(plan["target_path"], "tools/automation/indexer.py")

    def test_plan_repair_unknown_failure(self):
        plan = self.planner.plan_repair("segfault in core", "tools/automation/indexer.py")
        self.assertEqual(plan["status"], "BLOCKED_UNKNOWN_FAILURE")

    def test_plan_repair_unsafe_path(self):
        plan = self.planner.plan_repair("stale generated FTS5 index", "lib/core/indexer.dart")
        self.assertEqual(plan["status"], "BLOCKED_UNSAFE_PATH")

    def test_plan_repair_rejects_traversal_and_noncanonical_paths(self):
        escapes = (
            "tools/automation/../../lib/main.dart",
            "tools/automation/../other/file.py",
            "tools/automation//indexer.py",
            "tools/automation/./indexer.py",
            "tools\\automation\\indexer.py",
            "/tools/automation/indexer.py",
            "tools/automation/indexer.py\x00.txt",
            "",
        )
        for bad in escapes:
            with self.subTest(path=bad):
                plan = self.planner.plan_repair("stale generated FTS5 index", bad)
                self.assertEqual(plan["status"], "BLOCKED_UNSAFE_PATH")

    def test_scope_guard_rejects_symlink_escape(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            auto_dir = root / "tools" / "automation"
            auto_dir.mkdir(parents=True)
            outside = root / "secret.txt"
            outside.write_text("secret", encoding="utf-8")
            escape_link = auto_dir / "escape.py"
            os.symlink(outside, escape_link)

            guard = ScopeGuard("test-owner", repo_root=root)
            guard.add_allowed_path("tools/automation/**")
            self.assertTrue(guard.request_ownership("tools/automation/nested/ok.py"))
            self.assertFalse(guard.request_ownership("tools/automation/escape.py"))

    def test_plan_repair_ambiguous(self):
        plan = self.planner.plan_repair(
            "ambiguous dependency upgrade required for stale generated FTS5 index",
            "tools/automation/indexer.py",
        )
        self.assertEqual(plan["status"], "BLOCKED_AMBIGUOUS_REPAIR")

    def test_plan_repair_repeated_loop(self):
        plan = self.planner.plan_repair(
            "stale generated FTS5 index",
            "tools/automation/indexer.py",
            previous_attempts=1,
        )
        self.assertEqual(plan["status"], "BLOCKED_REPEATED_LOOP")

    def test_plan_repair_repeated_loop_with_new_condition(self):
        plan = self.planner.plan_repair(
            "stale generated FTS5 index",
            "tools/automation/indexer.py",
            previous_attempts=1,
            is_new_condition=True,
        )
        self.assertEqual(plan["status"], "READY")


if __name__ == "__main__":
    unittest.main()
