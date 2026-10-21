import json
import os
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

from tools.agent_contract.scope_guard import ScopeGuard, ScopeGuardError, LEDGER_PATH

class TestScopeGuard(unittest.TestCase):
    def setUp(self):
        self.repo_root = Path(os.getcwd())
        self.ledger_path = self.repo_root / LEDGER_PATH
        # Clear ledger before each test
        if self.ledger_path.exists():
            os.remove(self.ledger_path)

        self.guard = ScopeGuard(self.repo_root)

    def tearDown(self):
        if self.ledger_path.exists():
            os.remove(self.ledger_path)

    def test_allowed_paths(self):
        self.assertTrue(self.guard._is_path_allowed("AGENTS.md"))
        self.assertTrue(self.guard._is_path_allowed("docs/project-record/SESSION_OPERATING_CONTRACT.md"))
        self.assertTrue(self.guard._is_path_allowed("tools/agent_contract/scope_guard.py"))

        self.assertFalse(self.guard._is_path_allowed("lib/main.dart"))
        self.assertFalse(self.guard._is_path_allowed("android/build.gradle"))
        self.assertFalse(self.guard._is_path_allowed("assets/images/logo.png"))

    def test_path_traversal_prevention(self):
        # Even if someone tries to trick the path, it resolves to absolute first
        self.assertFalse(self.guard._is_path_allowed("../out_of_repo.txt"))
        self.assertFalse(self.guard._is_path_allowed("docs/project-record/../../lib/main.dart"))

    @patch('tools.agent_contract.scope_guard.subprocess.run')
    def test_stale_base_sha_blocked(self, mock_run):
        # Simulate git merge-base --is-ancestor failing
        import subprocess
        mock_run.side_effect = subprocess.CalledProcessError(1, ['git'])

        with self.assertRaises(ScopeGuardError) as context:
            self.guard.transition_task("T1", "CLAIM", "stale_sha", ["AGENTS.md"])

        self.assertIn("Stale branch-base SHA detected. Base SHA 'stale_sha' is behind the latest completed merge.", str(context.exception))

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.subprocess.run')
    def test_validate_changes_allowed(self, mock_run, mock_check_stale):
        mock_run.side_effect = [
            MagicMock(stdout="AGENTS.md\ntools/agent_contract/scope_guard.py\n", returncode=0),
            MagicMock(stdout="", returncode=0),
            MagicMock(stdout="", returncode=0)
        ]

        self.guard.transition_task("T1", "CLAIM", "HEAD~1", ["AGENTS.md", "tools/agent_contract/scope_guard.py"])
        changed = self.guard.validate_changes("T1", "HEAD~1")
        self.assertEqual(len(changed), 2)
        self.assertIn("AGENTS.md", changed)

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.subprocess.run')
    def test_validate_changes_denied_global(self, mock_run, mock_check_stale):
        mock_run.side_effect = [
            MagicMock(stdout="lib/main.dart\ntools/agent_contract/scope_guard.py\n", returncode=0),
            MagicMock(stdout="", returncode=0),
            MagicMock(stdout="", returncode=0)
        ]

        # Manually set ledger to bypass transition claim checks for the test
        self.guard.ledger["T1"] = {"state": "ACTIVE", "paths": ["tools/agent_contract/scope_guard.py"], "base_sha": "HEAD~1"}
        with self.assertRaises(ScopeGuardError) as context:
            self.guard.validate_changes("T1", "HEAD~1")

        self.assertIn("Unauthorized file modifications detected", str(context.exception))
        self.assertIn("lib/main.dart", str(context.exception))

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.subprocess.run')
    def test_validate_changes_denied_unclaimed(self, mock_run, mock_check_stale):
        # Even if globally allowed, if task didn't claim it, it should be blocked
        mock_run.side_effect = [
            MagicMock(stdout="AGENTS.md\ntools/agent_contract/scope_guard.py\n", returncode=0),
            MagicMock(stdout="", returncode=0),
            MagicMock(stdout="", returncode=0)
        ]

        self.guard.transition_task("T1", "CLAIM", "HEAD~1", ["AGENTS.md"])
        with self.assertRaises(ScopeGuardError) as context:
            self.guard.validate_changes("T1", "HEAD~1")

        self.assertIn("Unauthorized file modifications detected", str(context.exception))
        self.assertIn("tools/agent_contract/scope_guard.py", str(context.exception))

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.ScopeGuard.validate_changes')
    def test_active_does_not_wipe_claims(self, mock_validate, mock_check_stale):
        mock_validate.return_value = []
        self.guard.transition_task("T1", "CLAIM", "sha123", ["AGENTS.md"])
        self.assertEqual(self.guard.ledger["T1"]["paths"], ["AGENTS.md"])

        # Transition to ACTIVE without providing paths should retain original claims
        self.guard.transition_task("T1", "ACTIVE", "sha123")
        self.assertEqual(self.guard.ledger["T1"]["paths"], ["AGENTS.md"])

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    def test_claim_unauthorized_path(self, mock_check_stale):
        with self.assertRaises(ScopeGuardError) as context:
            self.guard.transition_task("T1", "CLAIM", "sha123", ["lib/main.dart"])

        self.assertIn("Cannot claim unauthorized path: lib/main.dart", str(context.exception))

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    def test_parallel_claims_no_overlap(self, mock_check_stale):
        self.guard.transition_task("T1", "CLAIM", "sha123", ["docs/project-record/doc1.md"])

        # Should succeed because paths don't overlap
        self.guard.transition_task("T2", "CLAIM", "sha123", ["tools/agent_contract/test.py"])

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    def test_parallel_claims_with_overlap(self, mock_check_stale):
        self.guard.transition_task("T1", "CLAIM", "sha123", ["docs/project-record/doc1.md", "AGENTS.md"])

        with self.assertRaises(ScopeGuardError) as context:
            self.guard.transition_task("T2", "CLAIM", "sha123", ["AGENTS.md"])

        self.assertIn("Overlapping claim with task T1 on paths: AGENTS.md", str(context.exception))

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.ScopeGuard.validate_changes')
    def test_valid_transitions(self, mock_validate, mock_check_stale):
        mock_validate.return_value = []

        self.guard.transition_task("T1", "CLAIM", "sha123", ["AGENTS.md"])
        self.guard.transition_task("T1", "ACTIVE", "sha123")
        self.guard.transition_task("T1", "BLOCKED", "sha123")
        self.guard.transition_task("T1", "ACTIVE", "sha123")
        self.guard.transition_task("T1", "COMPLETE", "sha123")

    @patch('tools.agent_contract.scope_guard.ScopeGuard._check_stale_base_sha')
    @patch('tools.agent_contract.scope_guard.ScopeGuard.validate_changes')
    def test_invalid_transitions(self, mock_validate, mock_check_stale):
        mock_validate.return_value = []
        self.guard.transition_task("T1", "CLAIM", "sha123", ["AGENTS.md"])

        with self.assertRaises(ScopeGuardError) as context:
            self.guard.transition_task("T1", "COMPLETE", "sha123")

        self.assertIn("Invalid transition from CLAIM to COMPLETE", str(context.exception))

        self.guard.transition_task("T1", "ACTIVE", "sha123")
        self.guard.transition_task("T1", "COMPLETE", "sha123")

        with self.assertRaises(ScopeGuardError) as context:
            self.guard.transition_task("T1", "ACTIVE", "sha123")

        self.assertIn("Invalid transition from COMPLETE to ACTIVE", str(context.exception))

if __name__ == '__main__':
    unittest.main()
