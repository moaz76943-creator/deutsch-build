import unittest
from tools.automation.repair_planner import RepairPlanner, RepairPlannerError

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

    def test_plan_repair_ambiguous(self):
        plan = self.planner.plan_repair("ambiguous dependency upgrade required for stale generated FTS5 index", "tools/automation/indexer.py")
        self.assertEqual(plan["status"], "BLOCKED_AMBIGUOUS_REPAIR")

    def test_plan_repair_repeated_loop(self):
        plan = self.planner.plan_repair("stale generated FTS5 index", "tools/automation/indexer.py", previous_attempts=1)
        self.assertEqual(plan["status"], "BLOCKED_REPEATED_LOOP")

    def test_plan_repair_repeated_loop_with_new_condition(self):
        plan = self.planner.plan_repair("stale generated FTS5 index", "tools/automation/indexer.py", previous_attempts=1, is_new_condition=True)
        self.assertEqual(plan["status"], "READY")

if __name__ == '__main__':
    unittest.main()
