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

        t1 = threading.Thread(target=claim_task, args=("T1", ["tools/agent_contract/guard.py"]))
        t2 = threading.Thread(target=claim_task, args=("T2", ["tools/agent_contract/guard.py"]))
        t3 = threading.Thread(target=claim_task, args=("T3", ["tools/agent_contract/README.md"]))

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
        # We want to verify that when one agent holds the lock (simulating a delayed commit or long operation),
        # another agent will block and wait, rather than fail or overwrite.
        lock_path = f"{self.ledger_path}.lock"
        script = f"""
import fcntl
import time

fd = open('{lock_path}', 'w')
fcntl.flock(fd, fcntl.LOCK_EX)
time.sleep(2)
fcntl.flock(fd, fcntl.LOCK_UN)
"""
        # Start a subprocess that holds the lock for 2 seconds
        lock_holder = subprocess.Popen(["python3", "-c", script])

        # Give it a tiny bit to acquire the lock
        time.sleep(0.5)

        start_time = time.time()

        report_path = os.path.join(self.temp_dir.name, "report_T1.json")
        res, stderr = run_guard("T1", "abc", "CLAIM", ["tools/agent_contract/guard.py"], self.ledger_path, report_path)

        end_time = time.time()
        duration = end_time - start_time

        # Ensure the subprocess completes
        lock_holder.wait()

        # The run_guard call should succeed, but only after waiting for the lock.
        # Since the subprocess held it for ~1.5 more seconds, duration should be >= 1 second.
        self.assertEqual(res, 0)
        self.assertGreaterEqual(duration, 1.0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CLAIM")

    def test_crashes(self):
        # Simulate a crash by acquiring the lock in a separate python process and exiting without releasing
        lock_path = f"{self.ledger_path}.lock"
        script = f"""
import fcntl
import os
import time

fd = open('{lock_path}', 'w')
fcntl.flock(fd, fcntl.LOCK_EX)
# Exit immediately, OS will release the lock
os._exit(1)
"""
        subprocess.run(["python3", "-c", script])

        # Now run guard, it should successfully acquire the lock and update ledger
        report_path = os.path.join(self.temp_dir.name, "report_crash.json")
        res, stderr = run_guard("T1", "abc", "CLAIM", ["tools/agent_contract/test_concurrency.py"], self.ledger_path, report_path)
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CLAIM")

    def test_outdated_merge_bases(self):
        # Inject an initial metadata to simulate a completed task
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "completed_sha"}}, f)

        # Try to run a task with an older sha. Since we can't easily mock `subprocess.check_call`
        # in the separate `run_guard` process directly, we can pass a dummy SHA that git doesn't know.
        # `git merge-base --is-ancestor completed_sha old_sha` will fail if old_sha is not a descendant,
        # or if they are invalid SHAs.
        # Actually, let's write a small script to override git command or just let it fail.
        # If we pass a bogus SHA, `git merge-base` will fail (return non-zero), making `is_stale_base_sha` return True.

        report_path = os.path.join(self.temp_dir.name, "report_outdated.json")
        res, stderr = run_guard("T1", "bogus_old_sha", "CLAIM", ["tools/agent_contract/guard.py"], self.ledger_path, report_path)
        self.assertEqual(res, 1)

        with open(report_path) as f:
            report = json.load(f)
            self.assertTrue(any("Stale branch-base SHA detected" in b for b in report["blockers"]))

if __name__ == '__main__':
    unittest.main()
