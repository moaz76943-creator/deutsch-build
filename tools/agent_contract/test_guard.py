import unittest
import subprocess
import os
import tempfile
import json
from unittest.mock import patch
from tools.agent_contract.guard import main

class TestGuard(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "ledger.json")
        self.report_path = os.path.join(self.temp_dir.name, "report.json")

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_allowed_paths(self):
        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md', 'docs/project-record/file.txt', 'tools/agent_contract/guard.py']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 0)

    def test_denied_paths(self):
        with patch('tools.agent_contract.guard.get_changed_files', return_value=['lib/main.dart']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("lib/main.dart", report["denied_paths"])
                self.assertIn("Changes to forbidden paths detected.", report["blockers"])

    def test_path_escape(self):
        with patch('tools.agent_contract.guard.get_changed_files', return_value=['tools/agent_contract/../../lib/main.dart']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "CLAIM", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("tools/agent_contract/../../lib/main.dart", report["denied_paths"])

    def test_overlapping_claims(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"]}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md']):
            res = main(["--task-id", "T2", "--base-sha", "abc", "--transition", "CLAIM", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("File AGENTS.md is currently claimed by T1", report["blockers"])

    def test_invalid_transition(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"]}}, f)

        with patch('tools.agent_contract.guard.get_changed_files', return_value=['AGENTS.md']):
            res = main(["--task-id", "T1", "--base-sha", "abc", "--transition", "COMPLETE", "--ledger", self.ledger_path, "--report", self.report_path])
            self.assertEqual(res, 1)
            with open(self.report_path) as f:
                report = json.load(f)
                self.assertIn("Invalid transition from CLAIM to COMPLETE", report["blockers"])

if __name__ == '__main__':
    unittest.main()
