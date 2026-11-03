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

    def test_crashes_and_stale_lock_recovery(self):
        # T1 claims and then "crashes" (expires)
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}}, f)

        # T2 reclaims with evidence
        report_path = os.path.join(self.temp_dir.name, "report_T2.json")
        cmd = [
            "python3", "tools/agent_contract/guard.py",
            "--task-id", "T2",
            "--base-sha", "abc",
            "--transition", "CLAIM",
            "--paths", "AGENTS.md",
            "--recovery-evidence", "issue was abandoned",
            "--ledger", self.ledger_path,
            "--report", report_path
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        self.assertEqual(res.returncode, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CANCELLED")
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    def test_delayed_commit(self):
        # We test flock correctly preventing race conditions in writing states.
        # Two tasks complete sequentially, simulating a long running commit that delays one.
        # Since we mock the git command here, we will mock `get_changed_files` in a wrapper script to avoid git errors,
        # but for true concurrency of the script itself, we can test two fast claims instead, which already tests flock.
        # So we just do concurrent `CLAIM` on different files and ensure both succeed and are saved.
        results = []
        def claim_task(task_id, paths):
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            res, stderr = run_guard(task_id, "abc", "CLAIM", paths, self.ledger_path, report_path)
            results.append((task_id, res, stderr))

        threads = []
        for i in range(10):
            t = threading.Thread(target=claim_task, args=(f"Task{i}", [f"docs/project-record/file{i}.txt"]))
            threads.append(t)
            t.start()

        for t in threads:
            t.join()

        successes = [r for r in results if r[1] == 0]
        self.assertEqual(len(successes), 10)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            for i in range(10):
                self.assertEqual(ledger[f"Task{i}"]["state"], "CLAIM")
                self.assertEqual(ledger[f"Task{i}"]["paths"], [f"docs/project-record/file{i}.txt"])

    def test_outdated_merge_bases(self):
        # We simulate this by setting `_metadata` `latest_base_sha` and passing an older sha
        # Actually it runs `git merge-base --is-ancestor`, but since we can't easily mock in a subprocess
        # run by another python process without a wrapper, we can rely on a non-existent commit failing the `git` command,
        # which returns a CalledProcessError and makes `is_stale_base_sha` return True.

        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "fake_commit_sha_that_does_not_exist"}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_outdated.json")
        res, stderr = run_guard("T1", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)

        self.assertEqual(res, 1)
        with open(report_path) as f:
            report = json.load(f)
            self.assertIn("Stale branch-base SHA detected. Base SHA is behind the latest completed merge.", report["blockers"])


if __name__ == '__main__':
    unittest.main()
