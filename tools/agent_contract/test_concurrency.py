import unittest
import subprocess
import os
import tempfile
import json
import time
import threading

def run_guard(task_id, base_sha, transition, paths, ledger_path, report_path):
    # Determine absolute path to guard.py
    guard_script = os.path.abspath(os.path.join(os.path.dirname(__file__), "guard.py"))
    cmd = [
        "python3", guard_script,
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

        # Initialize a temporary Git repository so guard.py git operations work
        self.git_dir = os.path.join(self.temp_dir.name, "repo")
        os.makedirs(self.git_dir)
        subprocess.run(["git", "init"], cwd=self.git_dir, check=True, capture_output=True)
        subprocess.run(["git", "config", "user.email", "test@example.com"], cwd=self.git_dir, check=True)
        subprocess.run(["git", "config", "user.name", "Test User"], cwd=self.git_dir, check=True)
        # Create an initial commit
        with open(os.path.join(self.git_dir, "initial.txt"), "w") as f:
            f.write("init")
        subprocess.run(["git", "add", "initial.txt"], cwd=self.git_dir, check=True)
        subprocess.run(["git", "commit", "-m", "Initial commit"], cwd=self.git_dir, check=True)

        # Patch the working directory so guard.py runs in the temp git repo
        self.original_cwd = os.getcwd()
        os.chdir(self.git_dir)

    def tearDown(self):
        os.chdir(self.original_cwd)
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
        # T1 claims the path but time has passed well beyond LOCK_TTL_SECONDS
        with open(self.ledger_path, "w") as f:
            json.dump({
                "T1": {
                    "state": "CLAIM",
                    "paths": ["AGENTS.md"],
                    "timestamp": time.time() - 4000  # Older than LOCK_TTL_SECONDS (3600)
                }
            }, f)

        # T2 attempts to claim the same path
        report_path = os.path.join(self.temp_dir.name, "report_T2.json")
        res, stderr = run_guard("T2", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)

        # T2 should succeed because T1's lock was stale
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "BLOCKED")
            self.assertIn("Stale lock recovered", ledger["T1"]["recovery_evidence"])
            self.assertEqual(ledger["T2"]["state"], "CLAIM")
            self.assertIn("AGENTS.md", ledger["T2"]["paths"])

    def test_crashes(self):
        # Create a python script that acquires the lock and sleeps
        sleeper_script = os.path.join(self.temp_dir.name, "sleeper.py")
        with open(sleeper_script, "w") as f:
            f.write(f"""
import fcntl
import time
with open('{self.ledger_path}', 'a+') as f:
    fcntl.flock(f, fcntl.LOCK_EX)
    print("Locked")
    time.sleep(10)
""")

        # Run sleeper in background
        proc = subprocess.Popen(["python3", sleeper_script], stdout=subprocess.PIPE, text=True)
        # Wait for it to acquire lock
        proc.stdout.readline()

        # Kill it abruptly
        proc.kill()
        proc.wait()
        proc.stdout.close()

        # Now try to make a claim. The lock should have been released by the OS.
        report_path = os.path.join(self.temp_dir.name, "report_crash.json")
        res, stderr = run_guard("T1", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)

        self.assertEqual(res, 0)
        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T1"]["state"], "CLAIM")

    def test_outdated_merge_bases(self):
        # We need sequential commits in our git repo
        # Commit 1
        with open(os.path.join(self.git_dir, "file1.txt"), "w") as f:
            f.write("commit1")
        subprocess.run(["git", "add", "file1.txt"], cwd=self.git_dir, check=True)
        subprocess.run(["git", "commit", "-m", "Commit 1"], cwd=self.git_dir, check=True)
        sha1 = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=self.git_dir, text=True).strip()

        # Commit 2
        with open(os.path.join(self.git_dir, "file2.txt"), "w") as f:
            f.write("commit2")
        subprocess.run(["git", "add", "file2.txt"], cwd=self.git_dir, check=True)
        subprocess.run(["git", "commit", "-m", "Commit 2"], cwd=self.git_dir, check=True)
        sha2 = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=self.git_dir, text=True).strip()

        # Commit 3
        with open(os.path.join(self.git_dir, "file3.txt"), "w") as f:
            f.write("commit3")
        subprocess.run(["git", "add", "file3.txt"], cwd=self.git_dir, check=True)
        subprocess.run(["git", "commit", "-m", "Commit 3"], cwd=self.git_dir, check=True)
        sha3 = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=self.git_dir, text=True).strip()

        # T1 claims and completes its task, setting latest_base_sha to sha2
        report_path = os.path.join(self.temp_dir.name, "report_T1.json")
        res1, _ = run_guard("T1", sha1, "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)
        self.assertEqual(res1, 0)

        # Manually set the transition state because we are not writing actual files in the temp git repo for ACTIVE/COMPLETE
        with open(self.ledger_path, "r") as f:
            ledger = json.load(f)
        ledger["_metadata"] = {"latest_base_sha": sha2}
        with open(self.ledger_path, "w") as f:
            json.dump(ledger, f)

        # T2 attempts to start a task with sha1 as its base_sha
        report_path2 = os.path.join(self.temp_dir.name, "report_T2.json")
        res2, _ = run_guard("T2", sha1, "CLAIM", ["docs/project-record/T2.md"], self.ledger_path, report_path2)

        self.assertEqual(res2, 1) # Should fail because sha1 is ancestor of latest_base_sha (sha2), meaning it's a stale branch

        with open(report_path2, "r") as f:
            report = json.load(f)
        self.assertTrue(any("Stale branch-base SHA detected" in b for b in report["blockers"]))

        # T3 attempts to start a task with sha3 as its base_sha
        report_path3 = os.path.join(self.temp_dir.name, "report_T3.json")
        res3, _ = run_guard("T3", sha3, "CLAIM", ["docs/project-record/T3.md"], self.ledger_path, report_path3)
        self.assertEqual(res3, 0) # Should succeed because sha3 is not an ancestor of sha2 (latest_base_sha)

if __name__ == '__main__':
    unittest.main()
