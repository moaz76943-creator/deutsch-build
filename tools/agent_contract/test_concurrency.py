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
        # We simulate a delay during one agent's claim so another fails immediately due to lock or ledger overlap
        # Since we use an external python script call, we'll write a wrapper script to do the delay.
        wrapper_path = os.path.join(self.temp_dir.name, "delayed_guard.py")
        with open(wrapper_path, "w") as f:
            f.write("""import sys, time
from tools.agent_contract.guard import main
import tools.agent_contract.guard as guard
original_process = guard.process_ledger
def slow_process(parsed, ledger_data):
    time.sleep(1)
    return original_process(parsed, ledger_data)
guard.process_ledger = slow_process
sys.exit(main())
""")

        results = []
        def slow_claim_task(task_id, paths):
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            cmd = [
                "python3", wrapper_path,
                "--task-id", task_id,
                "--base-sha", "abc",
                "--transition", "CLAIM",
                "--ledger", self.ledger_path,
                "--report", report_path
            ]
            if paths:
                cmd.extend(["--paths"] + paths)
            env = os.environ.copy()
            env["PYTHONPATH"] = os.getcwd()
            res = subprocess.run(cmd, capture_output=True, text=True, env=env)
            results.append((task_id, res.returncode, res.stderr))

        def fast_claim_task(task_id, paths):
            time.sleep(0.5)
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            res, stderr = run_guard(task_id, "abc", "CLAIM", paths, self.ledger_path, report_path)
            results.append((task_id, res, stderr))

        t1 = threading.Thread(target=slow_claim_task, args=("T1", ["AGENTS.md"]))
        t2 = threading.Thread(target=fast_claim_task, args=("T2", ["AGENTS.md"]))
        t1.start()
        t2.start()
        t1.join()
        t2.join()

        successes = [r for r in results if r[1] == 0]
        failures = [r for r in results if r[1] == 1]
        self.assertEqual(len(successes), 1)
        self.assertEqual(len(failures), 1)

    def test_crashes(self):
        # Simulate crash by writing a lock file and leaving it (since python releases locks on exit, we can't truly leave an fcntl lock)
        # However, we can test that an orphaned .tmp file is ignored or properly handled on a fresh invocation.
        tmp_path = f"{self.ledger_path}.tmp"
        with open(tmp_path, "w") as f:
            json.dump({"T_CRASH": {"state": "CLAIM", "paths": ["AGENTS.md"], "timestamp": time.time()}}, f)

        res, stderr = run_guard("T1", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, os.path.join(self.temp_dir.name, "r.json"))
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertIn("T1", ledger)
            self.assertNotIn("T_CRASH", ledger)

    def test_outdated_merge_bases(self):
        # Agent 1 completes task, sets latest base sha
        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "new_sha"}}, f)

        # We need to mock the git merge-base call in run_guard, but it runs as a subprocess.
        # Instead, we will simulate a stale lock recovery or similar.
        # For outdated base sha, the logic is checked against git in the subprocess.
        # So we can't easily mock git in the system without overriding the PATH.
        # We'll just verify the logic works if we set up a mock script.
        wrapper_path = os.path.join(self.temp_dir.name, "mock_git_guard.py")
        with open(wrapper_path, "w") as f:
            f.write("""import sys
import subprocess
from tools.agent_contract.guard import main
import tools.agent_contract.guard as guard
def mock_check_call(args, **kwargs):
    if args[0] == 'git' and args[1] == 'merge-base':
        raise subprocess.CalledProcessError(1, 'git')
    return subprocess.check_call(args, **kwargs)
guard.subprocess.check_call = mock_check_call
sys.exit(main())
""")

        report_path = os.path.join(self.temp_dir.name, "report_stale.json")
        cmd = [
            "python3", wrapper_path,
            "--task-id", "T1",
            "--base-sha", "old_sha",
            "--transition", "CLAIM",
            "--paths", "AGENTS.md",
            "--ledger", self.ledger_path,
            "--report", report_path
        ]
        env = os.environ.copy()
        env["PYTHONPATH"] = os.getcwd()
        res = subprocess.run(cmd, capture_output=True, text=True, env=env)
        self.assertEqual(res.returncode, 1)
        self.assertIn("Stale branch-base SHA detected", res.stderr)

if __name__ == '__main__':
    unittest.main()
