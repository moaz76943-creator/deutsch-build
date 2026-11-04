import unittest
import subprocess
import os
import tempfile
from pathlib import Path
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

    def test_corrupt_ledger_fails_closed_without_rewriting_it(self):
        original = b'{}' + bytes([10]) + b'{"tasks": {"J001": {"state": "ACTIVE"}}}' + bytes([10])
        with open(self.ledger_path, 'wb') as handle:
            handle.write(original)
        result = main(["--task-id", "T1", "--base-sha", "abc",
                       "--transition", "CLAIM", "--paths", "AGENTS.md",
                       "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(result, 1)
        self.assertEqual(Path(self.ledger_path).read_bytes(), original)
        report = json.loads(Path(self.report_path).read_text())
        self.assertTrue(any("Invalid ledger JSON" in issue for issue in report["blockers"]))

    def test_blocked_claim_does_not_rewrite_ledger(self):
        original = b'{  "T1": { "state": "ACTIVE", "paths": ["AGENTS.md"], "timestamp": 9999999999 } }' + bytes([10])
        Path(self.ledger_path).write_bytes(original)
        result = main(["--task-id", "T2", "--base-sha", "abc",
                       "--transition", "CLAIM", "--paths", "AGENTS.md",
                       "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(result, 1)
        self.assertEqual(Path(self.ledger_path).read_bytes(), original)

    def test_valid_json_with_legacy_nested_tasks_is_not_overwritten(self):
        original = json.dumps({"tasks": {"J001": {"state": "ACTIVE"}}}, indent=2).encode()
        Path(self.ledger_path).write_bytes(original)
        result = main(["--task-id", "T1", "--base-sha", "abc",
                       "--transition", "CLAIM", "--paths", "AGENTS.md",
                       "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(result, 1)
        self.assertEqual(Path(self.ledger_path).read_bytes(), original)

    def test_default_ledger_does_not_write_tracked_project_record(self):
        from tools.agent_contract.guard import default_state_dir
        with patch.dict(os.environ, {"XDG_STATE_HOME": self.temp_dir.name}):
            state_dir = default_state_dir()
            self.assertEqual(state_dir, Path(self.temp_dir.name) / "deutsch-agent-contract")
        self.assertNotEqual(state_dir / "task_ledger.json",
                            Path(guard.REPO_ROOT) / "docs/project-record/task_ledger.json")

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
            self.assertTrue(any("T1" in b for b in report["blockers"]))

    def test_overlapping_directory_claims(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["tools/agent_contract/"], "timestamp": time.time()}}, f)

        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--paths", "tools/agent_contract/guard.py", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.report_path) as f:
            report = json.load(f)
            self.assertTrue(any("Path overlaps with active claim by T1" in b for b in report["blockers"]))

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

    @patch('subprocess.check_output')
    def test_expired_claim_cannot_be_stolen_without_owner_release(self, mock_check_output):
        mock_check_output.return_value = " M AGENTS.md\n"
        original = json.dumps({"T1": {"state": "ACTIVE", "paths": ["AGENTS.md"],
                                      "timestamp": time.time() - 4000}})
        with open(self.ledger_path, "w") as f:
            f.write(original)
        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM",
                    "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 1)
        with open(self.ledger_path) as f:
            self.assertEqual(f.read(), original)
        with open(self.report_path) as f:
            self.assertTrue(any("owner evidence" in b for b in json.load(f)["blockers"]))

    @patch('subprocess.check_output')
    def test_expired_claim_is_safely_recovered_without_owner_evidence(self, mock_check_output):
        mock_check_output.return_value = ""
        original = {"T1": {"state": "ACTIVE", "paths": ["AGENTS.md"],
                           "timestamp": time.time() - 4000}}
        with open(self.ledger_path, "w") as f:
            json.dump(original, f)
        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM",
                    "--paths", "AGENTS.md", "--ledger", self.ledger_path, "--report", self.report_path])
        self.assertEqual(res, 0)
        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CANCELLED")
            self.assertEqual(ledger["T2"]["state"], "CLAIM")
            self.assertIn("AGENTS.md", ledger["T2"]["paths"])

    def test_expired_owner_does_not_block_independent_paths(self):
        owner = {"state": "ACTIVE", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": owner}, f)
        res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM",
                    "--paths", "tools/agent_contract/guard.py", "--ledger", self.ledger_path,
                    "--report", self.report_path])
        self.assertEqual(res, 0)
        with open(self.ledger_path) as f:
            self.assertEqual(json.load(f)["T1"], owner)

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
