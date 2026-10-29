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

    def test_delayed_commits(self):
        # Simulate an agent holding a lock that expires due to TTL
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time() - 4000}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T2.json")
        res, stderr = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "BLOCKED")
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    def test_crashes(self):
        # Simulate an OS lock held by a crashing process and verify the next can claim
        # Since Python's fcntl releases the lock when the process crashes, we simulate a crash
        # by simply writing an incomplete ledger without the lock and ensuring a new guard can still run
        # and lock the file properly.
        with open(self.ledger_path, "w") as f:
            json.dump({"T1": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        report_path = os.path.join(self.temp_dir.name, "report_T2.json")
        res, stderr = run_guard("T2", "abc", "CLAIM", ["docs/project-record/test.txt"], self.ledger_path, report_path)
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T2"]["state"], "CLAIM")

    def test_outdated_merge_bases(self):
        # Setup metadata so we can trigger the 'is_stale_base_sha' check via fake git calls
        # Since git calls are hard to mock cross-process, we'll run a local git repo initialization
        # to test real outdated merge bases.
        repo_dir = tempfile.TemporaryDirectory()
        cwd = os.getcwd()
        try:
            os.chdir(repo_dir.name)
            subprocess.run(["git", "init"], capture_output=True)
            subprocess.run(["git", "config", "user.email", "test@example.com"], capture_output=True)
            subprocess.run(["git", "config", "user.name", "Test User"], capture_output=True)

            with open("test.txt", "w") as f:
                f.write("A")
            subprocess.run(["git", "add", "test.txt"], capture_output=True)
            subprocess.run(["git", "commit", "-m", "A"], capture_output=True)
            sha_A = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()

            with open("test.txt", "w") as f:
                f.write("B")
            subprocess.run(["git", "add", "test.txt"], capture_output=True)
            subprocess.run(["git", "commit", "-m", "B"], capture_output=True)
            sha_B = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()

            # Now set the ledger to think sha_B is the latest
            with open(self.ledger_path, "w") as f:
                json.dump({"_metadata": {"latest_base_sha": sha_B}}, f)

            # Attempt to claim with sha_A, which is older and thus stale
            # Note: We use the actual guard.py script by pointing to its absolute path from cwd
            guard_script = os.path.join(cwd, "tools/agent_contract/guard.py")
            report_path = os.path.join(self.temp_dir.name, "report_T1.json")
            cmd = [
                "python3", guard_script,
                "--task-id", "T1",
                "--base-sha", sha_A,
                "--transition", "CLAIM",
                "--paths", "AGENTS.md",
                "--ledger", self.ledger_path,
                "--report", report_path
            ]
            res = subprocess.run(cmd, capture_output=True, text=True)
            self.assertEqual(res.returncode, 1)
            self.assertIn("Stale branch-base SHA detected", res.stderr)
        finally:
            os.chdir(cwd)
            repo_dir.cleanup()

if __name__ == '__main__':
    unittest.main()
