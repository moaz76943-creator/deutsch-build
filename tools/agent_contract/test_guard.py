import unittest
import subprocess
import os
import tempfile
import json
import time
from unittest.mock import patch, MagicMock
from tools.agent_contract.guard import main
from tools.agent_contract import guard

class TestGuard(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "ledger.json")
        self.report_path = os.path.join(self.temp_dir.name, "report.json")
        with open(self.ledger_path, "w") as f:
            json.dump({}, f)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_allowed_paths_explicit(self):
        res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "AGENTS.md", "docs/project-record/file.txt", "tools/agent_contract/guard.py", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 0)

    def test_claim_without_paths(self):
        res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertIn("Paths must be provided for initial CLAIM.", report["blockers"])

    def test_denied_paths(self):
        res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "lib/main.dart", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertIn("lib/main.dart", report["denied_paths"])
            self.assertIn("Changes to forbidden paths detected.", report["blockers"])

    def test_path_escape(self):
        res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "tools/agent_contract/../../lib/main.dart", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertIn("tools/agent_contract/../../lib/main.dart", report["denied_paths"])

    def test_overlapping_claims(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertTrue(any("AGENTS.md" in b and "T1" in b for b in report["blockers"]))

    def test_overlapping_directory_claims(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["tools/agent_contract/"], "timestamp": time.time()}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "tools/agent_contract/guard.py", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertTrue(any("tools/agent_contract/guard.py overlaps with tools/agent_contract/" in b for b in report["blockers"]))

    def test_invalid_transition(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "COMPLETE", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("Invalid transition from CLAIM to COMPLETE", report["blockers"])

        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "BLOCKED", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "COMPLETE", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("Invalid transition from BLOCKED to COMPLETE", report["blockers"])

    def test_modify_unclaimed_file_on_complete(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "ACTIVE", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md', 'tools/agent_contract/guard.py']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "COMPLETE", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertTrue(any("tools/agent_contract/guard.py modified but not originally claimed." in b for b in report["blockers"]))

    def test_stale_lock_recovery(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "BLOCKED")
            self.assertIn("Stale lock recovered", ledger["T1"]["recovery_evidence"])
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    @patch('subprocess.check_call')
    def test_stale_base_sha(self, mock_check_call):
        mock_check_call.side_effect = subprocess.CalledProcessError(1, 'git')
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "def456"}}, f)

        res = main(["--task-id", "T1", "--base-sha", "abc1234", "--transition", "CLAIM", "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertIn("Stale branch-base SHA detected. Base SHA is behind the latest completed merge.", report["blockers"])

    def test_explicit_cancellation(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CANCELLED", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 0)
            with open(self.ledger_path) as f:
                ledger = json.load(f)
                self.assertEqual(ledger["T1"]["state"], "CANCELLED")

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 0)

    def test_task_dependency_blocked(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "tools/agent_contract/guard.py", "--depends-on", "T1", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertTrue(any("Task depends on T1 which is in state CLAIM" in b for b in report["blockers"]))

    def test_task_dependency_allowed(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "COMPLETE", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "tools/agent_contract/guard.py", "--depends-on", "T1", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 0)

    def test_canonical_paths_do_not_depend_on_process_cwd(self):
        repo = Path(self.temp_dir.name) / "repo"
        allowed = repo / "tools" / "agent_contract"
        allowed.mkdir(parents=True)
        (allowed / "guard.py").write_text("fixture")
        original_cwd = os.getcwd()
        try:
            os.chdir(self.temp_dir.name)
            with patch.object(guard, "REPO_ROOT", str(repo)):
                self.assertTrue(guard.is_path_allowed("tools/agent_contract/guard.py"))
                self.assertTrue(guard.is_path_allowed("tools/agent_contract/"))
        finally:
            os.chdir(original_cwd)

    def test_symlink_within_allowed_scope_is_denied(self):
        repo = Path(self.temp_dir.name) / "repo"
        allowed = repo / "tools" / "agent_contract"
        allowed.mkdir(parents=True)
        (allowed / "target.py").write_text("fixture")
        (allowed / "shortcut.py").symlink_to(allowed / "target.py")
        with patch.object(guard, "REPO_ROOT", str(repo)):
            self.assertFalse(guard.is_path_allowed("tools/agent_contract/shortcut.py"))

    def test_parent_navigation_inside_allowed_scope_is_denied(self):
        repo = Path(self.temp_dir.name) / "repo"
        (repo / "tools" / "agent_contract").mkdir(parents=True)
        with patch.object(guard, "REPO_ROOT", str(repo)):
            self.assertFalse(guard.is_path_allowed("tools/agent_contract/../agent_contract/guard.py"))

if __name__ == '__main__':
    unittest.main()
