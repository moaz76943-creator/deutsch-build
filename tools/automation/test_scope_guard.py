"""Regression tests for authenticated ownership checks in the existing ScopeGuard."""
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tools.automation.scope_guard import ScopeGuard


class ScopeGuardLedgerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.repo = Path(self.tmp.name) / "repo"
        (self.repo / "src").mkdir(parents=True)
        (self.repo / "src" / "main.py").write_text("x = 1")
        self.ledger = Path(self.tmp.name) / "ledger.json"
        self.guard = ScopeGuard(owner="RepairPlanner", repo_root=self.repo, ledger_path=self.ledger)
        self.guard.add_allowed_path("src/**")

    def tearDown(self):
        self.tmp.cleanup()

    def test_missing_ledger_fails_closed(self):
        self.assertFalse(self.guard.request_ownership("src/main.py"))

    def test_corrupt_ledger_fails_closed_without_changes(self):
        original = b'{}' + bytes([10]) + b'{"tasks": {}}'
        self.ledger.write_bytes(original)
        self.assertFalse(self.guard.request_ownership("src/main.py"))
        self.assertEqual(self.ledger.read_bytes(), original)

    def test_foreign_active_claim_blocks_same_file(self):
        self.ledger.write_text(json.dumps({
            "RepairPlanner": {"state": "ACTIVE", "paths": ["src/main.py"]},
            "OtherAgent": {"state": "CLAIM", "paths": ["src/main.py"]},
        }))
        self.assertFalse(self.guard.request_ownership("src/main.py"))

    def test_self_owned_active_claim_allows_scoped_file(self):
        self.ledger.write_text(json.dumps({
            "RepairPlanner": {"state": "ACTIVE", "paths": ["src/"], "timestamp": 9999999999}
        }))
        self.assertTrue(self.guard.request_ownership("src/main.py"))
        self.assertFalse(self.guard.request_ownership("../outside.txt"))

    def test_expired_self_claim_does_not_authorize_mutation(self):
        import time
        self.ledger.write_text(json.dumps({
            "RepairPlanner": {"state": "ACTIVE", "paths": ["src/main.py"],
                              "timestamp": time.time() - 7200}
        }))
        self.assertFalse(self.guard.request_ownership("src/main.py"))

    def test_unclaimed_scope_is_not_a_lock(self):
        self.ledger.write_text("{}")
        self.assertFalse(self.guard.request_ownership("src/main.py"))

    def test_default_path_is_outside_repository(self):
        with patch.dict("os.environ", {"XDG_STATE_HOME": self.tmp.name}):
            guard = ScopeGuard(owner="RepairPlanner", repo_root=self.repo)
        self.assertEqual(guard.ledger_path, Path(self.tmp.name) / "deutsch-agent-contract" / "task_ledger.json")


if __name__ == "__main__":
    unittest.main()
