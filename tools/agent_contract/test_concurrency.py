import unittest
import subprocess
import os
import tempfile
import json
import time
import threading

def run_guard(task_id, base_sha, transition, paths, ledger_path, report_path):
    cmd = [
        "python3", "tools/agent_contract/guard.py",
        "--task-id", task_id,
        "--base-sha", base_sha,
        "--transition", transition,
        "--ledger", ledger_path,
        "--report", report_path
    ]
    if paths:
        cmd.extend(["--paths"] + paths)
    res = subprocess.run(cmd, capture_output=True, text=True)
    return res.returncode, res.stderr

from unittest.mock import patch
import tools.agent_contract.guard as guard

class TestGuardConcurrency(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "ledger.json")
        with open(self.ledger_path, "w") as f:
            json.dump({}, f)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_concurrent_claims(self):
        results = []
        def claim_task(task_id, paths):
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            res, stderr = run_guard(task_id, "abc", "CLAIM", paths, self.ledger_path, report_path)
            results.append((task_id, res, stderr))

        t1 = threading.Thread(target=claim_task, args=("T1", ["AGENTS.md"]))
        t2 = threading.Thread(target=claim_task, args=("T2", ["AGENTS.md"]))
        t3 = threading.Thread(target=claim_task, args=("T3", ["docs/project-record/test.txt"]))

        t1.start()
        t2.start()
        t3.start()

        t1.join()
        t2.join()
        t3.join()

        successes = [r for r in results if r[1] == 0]
        failures = [r for r in results if r[1] == 1]

        self.assertEqual(len(successes), 2)
        self.assertEqual(len(failures), 1)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(len([k for k, v in ledger.items() if v.get("state") == "CLAIM"]), 2)
            self.assertEqual(ledger["T3"]["state"], "CLAIM")

            t1_t2_claims = [k for k, v in ledger.items() if k in ["T1", "T2"] and v.get("state") == "CLAIM"]
            self.assertEqual(len(t1_t2_claims), 1)

    def test_delayed_commits(self):
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "ACTIVE", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T2.json")
        res, stderr = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)

        self.assertEqual(res, 1)
        self.assertIn("overlaps with active claim by T1", stderr)

    @patch('subprocess.check_output')
    def test_crashes_and_stale_recovery(self, mock_check_output):
        mock_check_output.return_value = ""
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "ACTIVE", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T2.json")

        res = guard.main([
            "--task-id", "T2",
            "--base-sha", "abc",
            "--transition", "CLAIM",
            "--paths", "AGENTS.md",
            "--ledger", self.ledger_path,
            "--report", report_path
        ])

        self.assertEqual(res, 0)
        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CANCELLED")
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    @patch('subprocess.check_call')
    def test_outdated_merge_bases(self, mock_check_call):
        mock_check_call.side_effect = subprocess.CalledProcessError(1, 'git')
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "def456"}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T1.json")

        res = guard.main([
            "--task-id", "T1",
            "--base-sha", "abc",
            "--transition", "CLAIM",
            "--paths", "AGENTS.md",
            "--ledger", self.ledger_path,
            "--report", report_path
        ])

        self.assertEqual(res, 1)
        with open(report_path) as f:
            report = json.load(f)
            self.assertTrue(any("Stale branch-base SHA detected" in b for b in report["blockers"]))

if __name__ == '__main__':
    unittest.main()
