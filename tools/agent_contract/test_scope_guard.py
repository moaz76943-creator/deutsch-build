import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

from tools.agent_contract import scope_guard

class TestScopeGuard(unittest.TestCase):
    def setUp(self):
        # Use a temporary ledger file for tests
        self.test_ledger_file = Path(__file__).parent / ".test_scope_guard_ledger.json"
        scope_guard.LEDGER_FILE = self.test_ledger_file
        if self.test_ledger_file.exists():
            os.remove(self.test_ledger_file)

    def tearDown(self):
        if self.test_ledger_file.exists():
            os.remove(self.test_ledger_file)

    def test_is_path_allowed(self):
        # Allowed exact
        self.assertTrue(scope_guard.is_path_allowed("AGENTS.md"))

        # Allowed wildcard
        self.assertTrue(scope_guard.is_path_allowed("docs/project-record/TEST.md"))
        self.assertTrue(scope_guard.is_path_allowed("tools/agent_contract/scope_guard.py"))

        # Denied paths
        self.assertFalse(scope_guard.is_path_allowed("lib/main.dart"))
        self.assertFalse(scope_guard.is_path_allowed("android/app/build.gradle"))
        self.assertFalse(scope_guard.is_path_allowed("assets/test.png"))

        # Path traversal attempts
        self.assertFalse(scope_guard.is_path_allowed("../lib/main.dart"))
        self.assertFalse(scope_guard.is_path_allowed("tools/agent_contract/../../lib/main.dart"))

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_claim_success(self, mock_verify):
        mock_verify.return_value = True
        scope_guard.cmd_claim("J001", "fake_sha", ["tools/agent_contract/scope_guard.py"])

        ledger = scope_guard.Ledger(self.test_ledger_file)
        task = ledger.get_task("J001")
        self.assertIsNotNone(task)
        self.assertEqual(task["state"], "CLAIM")
        self.assertEqual(task["base_sha"], "fake_sha")
        self.assertIn("tools/agent_contract/scope_guard.py", task["paths"])

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_claim_overlapping(self, mock_verify):
        mock_verify.return_value = True
        scope_guard.cmd_claim("J001", "fake_sha", ["tools/agent_contract/scope_guard.py"])

        # Try to claim same path with different task
        with self.assertRaises(scope_guard.ScopeGuardError) as context:
            scope_guard.cmd_claim("J002", "fake_sha", ["tools/agent_contract/scope_guard.py"])

        self.assertIn("Paths overlap", str(context.exception))

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_claim_forbidden_path(self, mock_verify):
        mock_verify.return_value = True
        with self.assertRaises(scope_guard.ScopeGuardError) as context:
            scope_guard.cmd_claim("J003", "fake_sha", ["lib/main.dart"])

        self.assertIn("forbidden or outside Allowed Paths", str(context.exception))

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_stale_base_sha(self, mock_verify):
        mock_verify.return_value = False
        with self.assertRaises(scope_guard.ScopeGuardError) as context:
            scope_guard.cmd_claim("J004", "stale_sha", ["AGENTS.md"])

        self.assertIn("invalid or stale", str(context.exception))

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_transition(self, mock_verify):
        mock_verify.return_value = True
        scope_guard.cmd_claim("J005", "fake_sha", ["AGENTS.md"])

        scope_guard.cmd_transition("J005", "ACTIVE")
        ledger = scope_guard.Ledger(self.test_ledger_file)
        self.assertEqual(ledger.get_task("J005")["state"], "ACTIVE")

        scope_guard.cmd_transition("J005", "COMPLETE")
        ledger = scope_guard.Ledger(self.test_ledger_file); self.assertEqual(ledger.get_task("J005")["state"], "COMPLETE")

        with self.assertRaises(scope_guard.ScopeGuardError):
            scope_guard.cmd_transition("J005", "INVALID_STATE")

    @patch('tools.agent_contract.scope_guard.get_changed_files')
    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_verify_success(self, mock_verify, mock_get_changed):
        mock_verify.return_value = True
        # Note: the ledger only matches literal strings or prefixes if claim has /**
        scope_guard.cmd_claim("J006", "fake_sha", ["tools/agent_contract/**"])

        mock_get_changed.return_value = ["tools/agent_contract/test_scope_guard.py"]

        # Should not raise exception
        scope_guard.cmd_verify("J006")

    @patch('tools.agent_contract.scope_guard.get_changed_files')
    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_verify_unauthorized_changes(self, mock_verify, mock_get_changed):
        mock_verify.return_value = True
        scope_guard.cmd_claim("J007", "fake_sha", ["tools/agent_contract/**"])

        # Simulate changed file outside claim
        mock_get_changed.return_value = ["tools/agent_contract/scope_guard.py", "lib/main.dart"]

        with self.assertRaises(scope_guard.ScopeGuardError) as context:
            scope_guard.cmd_verify("J007")

        self.assertIn("Unauthorized modifications", str(context.exception))
        self.assertIn("lib/main.dart", str(context.exception))

    @patch('tools.agent_contract.scope_guard.verify_base_sha')
    def test_claim_overlapping_directory(self, mock_verify):
        mock_verify.return_value = True
        scope_guard.cmd_claim("J008", "fake_sha", ["tools/agent_contract/**"])

        # Try to claim specific file inside directory
        with self.assertRaises(scope_guard.ScopeGuardError) as context:
            scope_guard.cmd_claim("J009", "fake_sha", ["tools/agent_contract/scope_guard.py"])

        self.assertIn("Paths overlap", str(context.exception))

if __name__ == '__main__':
    unittest.main()
