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

    def test_delayed_commits(self):
        # T1 claims path, delays, then T2 tries to claim and is blocked.
        report_path1 = os.path.join(self.temp_dir.name, "report_T1.json")
        res1, _ = run_guard("T1", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path1)
        self.assertEqual(res1, 0)

        # T2 tries to claim while T1 is active
        report_path2 = os.path.join(self.temp_dir.name, "report_T2.json")
        res2, _ = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path2)
        self.assertEqual(res2, 1)

        # T1 cancels its claim
        res3, _ = run_guard("T1", "abc", "CANCELLED", ["AGENTS.md"], self.ledger_path, report_path1)
        self.assertEqual(res3, 0)

        # Now T2 should succeed
        res4, _ = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path2)
        self.assertEqual(res4, 0)

    def test_crashes(self):
        # Simulate a stale lock by manually editing the ledger to put it in the past
        import time
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}}, f)

        report_path2 = os.path.join(self.temp_dir.name, "report_T2.json")
        res, _ = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path2)
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "BLOCKED")
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    def test_outdated_merge_bases(self):
        # Setting latest base SHA to a valid format but non-existent SHA
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "non_existent_sha_latest"}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T1.json")
        res, _ = run_guard("T1", "invalid_stale_sha_12345", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)
        self.assertEqual(res, 1)

        with open(report_path) as f:
            report = json.load(f)
            self.assertTrue(any("Stale branch-base SHA detected" in b for b in report["blockers"]))

if __name__ == '__main__':
    unittest.main()
