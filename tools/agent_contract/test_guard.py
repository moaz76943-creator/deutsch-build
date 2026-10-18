import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from tools.agent_contract.guard import ScopeGuard, VALID_TRANSITIONS

class MockScopeGuard(ScopeGuard):
    def __init__(self, repo_root="."):
        super().__init__(repo_root)
        self.mock_ancestor_result = True
        self.mock_head_sha = "current_sha"
        self.mock_git_changes = []

    def is_ancestor(self, ancestor_sha: str, descendant_sha: str) -> bool:
        if ancestor_sha == descendant_sha:
            return True
        if ancestor_sha == "old_sha" and descendant_sha == "new_sha":
            return False
        return self.mock_ancestor_result

    def get_head_sha(self) -> str:
        return self.mock_head_sha

    def get_git_changes(self, base_sha: str, target_sha: str) -> list[str]:
        return self.mock_git_changes

class TestScopeGuard(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.mkdtemp()
        self.guard = MockScopeGuard(repo_root=self.temp_dir)

        self.ledger_data = {
            "tasks": {
                "J001": {
                    "state": "ACTIVE",
                    "allowed_paths": [
                        "AGENTS.md",
                        "docs/project-record/**",
                        "tools/agent_contract/**"
                    ]
                },
                "J002": {
                    "state": "ACTIVE",
                    "allowed_paths": [
                        "lib/**"
                    ]
                }
            }
        }
        self.guard.ledger_path.parent.mkdir(parents=True, exist_ok=True)
        with open(self.guard.ledger_path, "w") as f:
            json.dump(self.ledger_data, f)

        os.makedirs(os.path.join(self.temp_dir, "tools/agent_contract"), exist_ok=True)
        os.makedirs(os.path.join(self.temp_dir, "lib"), exist_ok=True)
        os.makedirs(os.path.join(self.temp_dir, "outside_repo"), exist_ok=True)
        os.makedirs(os.path.join(self.temp_dir, "docs/project-record"), exist_ok=True)
        os.makedirs(os.path.join(self.temp_dir, "docs/project-record-hacked"), exist_ok=True)

    def tearDown(self):
        shutil.rmtree(self.temp_dir)

    def test_paths_overlap(self):
        self.assertTrue(self.guard.paths_overlap("docs/project-record/**", "docs/project-record/file.txt"))
        self.assertTrue(self.guard.paths_overlap("docs/project-record/file.txt", "docs/project-record/**"))
        self.assertTrue(self.guard.paths_overlap("AGENTS.md", "AGENTS.md"))
        self.assertFalse(self.guard.paths_overlap("lib/**", "docs/**"))
        self.assertFalse(self.guard.paths_overlap("AGENTS.md", "docs/**"))
        self.assertFalse(self.guard.paths_overlap("tools/agent_contract/**", "tools/agent_contract_new/**"))

    def test_prefix_matching_vulnerability(self):
        # Prevent allowed path "docs/project-record/**" from authorizing "docs/project-record-hacked/secret"
        self.assertFalse(self.guard.is_path_allowed("docs/project-record-hacked/secret.txt", ["docs/project-record/**"]))
        self.assertTrue(self.guard.is_path_allowed("docs/project-record/secret.txt", ["docs/project-record/**"]))

    def test_parallel_claims_conflict(self):
        res = self.guard.transition("J003", "CLAIM", ["docs/project-record/**"])
        self.assertEqual(res["status"], "REJECTED")
        self.assertIn("Conflict", res["reason"])

    def test_parallel_claims_success(self):
        res = self.guard.transition("J003", "CLAIM", ["assets/**"])
        self.assertEqual(res["status"], "SUCCESS")

    def test_symlink_escape(self):
        symlink_path = os.path.join(self.temp_dir, "tools/agent_contract/escape_link")
        target_path = os.path.join(self.temp_dir, "lib/secret.dart")

        try:
            os.symlink(target_path, symlink_path)
            self.assertFalse(self.guard.is_path_allowed("tools/agent_contract/escape_link", ["tools/agent_contract/**"]))
        except OSError:
            pass

    def test_path_traversal(self):
        self.assertFalse(self.guard.is_path_allowed("tools/agent_contract/../../lib/main.dart", ["tools/agent_contract/**"]))

    def test_stale_base_sha(self):
        # Without explicit changed_files, validate tests git ancestor.
        res = self.guard.validate("J001", "old_sha", current_sha="new_sha")
        self.assertEqual(res["status"], "REJECTED")
        self.assertIn("STALE_BASE_SHA", res["blockers"])
        self.assertEqual(res["BASE_SHA"], "old_sha")
        self.assertEqual(res["RESULT_SHA"], "new_sha")

    def test_invalid_state_transition(self):
        res = self.guard.transition("J001", "CLAIM")
        self.assertEqual(res["status"], "REJECTED")

        self.guard.transition("J001", "BLOCKED")
        res = self.guard.transition("J001", "COMPLETE")
        self.assertEqual(res["status"], "REJECTED")

    def test_unauthorized_modifications(self):
        res = self.guard.validate("J001", "sha", ["tools/agent_contract/guard.py", "lib/main.dart"])
        self.assertEqual(res["status"], "REJECTED")
        self.assertIn("lib/main.dart", res["denied"])
        self.assertIn("tools/agent_contract/guard.py", res["permitted"])
        self.assertIn("UNAUTHORIZED_MODIFICATION", res["blockers"])

    def test_authorized_modifications(self):
        res = self.guard.validate("J001", "sha", ["AGENTS.md", "docs/project-record/task_ledger.json"])
        self.assertEqual(res["status"], "APPROVED")
        self.assertEqual(len(res["permitted"]), 2)
        self.assertEqual(res["BASE_SHA"], "sha")

    def test_get_git_changes_mock(self):
        self.guard.mock_git_changes = ["AGENTS.md"]
        res = self.guard.validate("J001", "sha", current_sha="sha")
        self.assertEqual(res["status"], "APPROVED")
        self.assertEqual(res["permitted"], ["AGENTS.md"])

if __name__ == '__main__':
    unittest.main()
