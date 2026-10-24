import unittest
import subprocess
import os
import tempfile
import json
import time
import threading
from unittest.mock import patch

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

    def test_delayed_commits_and_crashes(self):
        # T1 claims a file
        report_t1 = os.path.join(self.temp_dir.name, "report_t1.json")
        res1, _ = run_guard("T1", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_t1)
        self.assertEqual(res1, 0)

        # Simulate a crash and delay by modifying the ledger timestamp
        with open(self.ledger_path, "r") as f:
            ledger = json.load(f)
        ledger["T1"]["timestamp"] = time.time() - 4000
        with open(self.ledger_path, "w") as f:
            json.dump(ledger, f)

        # T2 claims the same file, which should succeed due to T1's stale lock
        report_t2 = os.path.join(self.temp_dir.name, "report_t2.json")
        res2, _ = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_t2)
        self.assertEqual(res2, 0)

        # T1 recovers and tries to COMPLETE, but should be denied as it is now BLOCKED
        res1_complete, _ = run_guard("T1", "abc", "COMPLETE", [], self.ledger_path, report_t1)
        self.assertEqual(res1_complete, 1)

        with open(self.ledger_path, "r") as f:
            ledger = json.load(f)
        self.assertEqual(ledger["T1"]["state"], "BLOCKED")
        self.assertEqual(ledger["T2"]["state"], "CLAIM")

    @patch('subprocess.check_call')
    def test_outdated_merge_bases(self, mock_check_call):
        # Simulate a completed task T1 that updates the base SHA to 'def'
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "def"}}, f)

        # Mock check_call to raise error since 'abc' is not a descendant of 'def'
        mock_check_call.side_effect = subprocess.CalledProcessError(1, 'git')

        # T2 tries to CLAIM with an outdated base SHA 'abc', should fail
        report_t2 = os.path.join(self.temp_dir.name, "report_t2.json")
        res2_claim, _ = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_t2)
        self.assertEqual(res2_claim, 1)

        # Check report for the error message
        with open(report_t2, "r") as f:
            report = json.load(f)
        self.assertIn("Stale branch-base SHA detected. Base SHA is behind the latest completed merge.", report["blockers"])


if __name__ == '__main__':
    unittest.main()
