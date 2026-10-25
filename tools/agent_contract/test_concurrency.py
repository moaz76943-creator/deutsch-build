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
        results = []
        def delayed_run_guard(delay, task_id, base_sha, transition, paths):
            time.sleep(delay)
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            res, stderr = run_guard(task_id, base_sha, transition, paths, self.ledger_path, report_path)
            results.append((task_id, res, stderr))

        def claim_task(task_id, paths):
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            res, stderr = run_guard(task_id, "abc", "CLAIM", paths, self.ledger_path, report_path)
            results.append((task_id, res, stderr))

        t1 = threading.Thread(target=delayed_run_guard, args=(0.1, "T1", "abc", "CLAIM", ["AGENTS.md"]))
        t2 = threading.Thread(target=claim_task, args=("T2", ["docs/project-record/file.txt"]))

        t1.start()
        t2.start()

        t1.join()
        t2.join()

        successes = [r for r in results if r[1] == 0]
        self.assertEqual(len(successes), 2)

    def test_crashes(self):
        crash_data = {
            "T_CRASH": {
                "state": "CLAIM",
                "paths": ["AGENTS.md"],
                "timestamp": time.time() - 4000
            }
        }
        with open(self.ledger_path, "w") as f:
            json.dump(crash_data, f)
            f.write("\n")

        report_path = os.path.join(self.temp_dir.name, "report_T_NEW.json")
        res, stderr = run_guard("T_NEW", "abc", "CLAIM", ["AGENTS.md"], self.ledger_path, report_path)
        self.assertEqual(res, 0)

        with open(self.ledger_path) as f:
            ledger = json.load(f)
            self.assertEqual(ledger["T_CRASH"]["state"], "BLOCKED")
            self.assertEqual(ledger["T_NEW"]["state"], "CLAIM")

    def test_outdated_merge_bases(self):
        mock_git_path = os.path.join(self.temp_dir.name, "git")
        with open(mock_git_path, "w") as f:
            f.write("#!/usr/bin/env python3\n")
            f.write("import sys\n")
            f.write("if 'merge-base' in sys.argv and 'latest_sha' in sys.argv and 'stale_sha' in sys.argv:\n")
            f.write("    sys.exit(1)\n")
            f.write("sys.exit(0)\n")
        os.chmod(mock_git_path, 0o755)

        with open(self.ledger_path, "w") as f:
            json.dump({"_metadata": {"latest_base_sha": "latest_sha"}}, f)
            f.write("\n")

        results = []
        def claim_task_with_env(task_id, base_sha, paths):
            report_path = os.path.join(self.temp_dir.name, f"report_{task_id}.json")
            cmd = [
                "python3", "tools/agent_contract/guard.py",
                "--task-id", task_id,
                "--base-sha", base_sha,
                "--transition", "CLAIM",
                "--ledger", self.ledger_path,
                "--report", report_path,
                "--paths"
            ] + paths

            env = os.environ.copy()
            env["PATH"] = self.temp_dir.name + os.pathsep + env.get("PATH", "")

            res = subprocess.run(cmd, capture_output=True, text=True, env=env)
            results.append((task_id, res.returncode, res.stderr))

        t1 = threading.Thread(target=claim_task_with_env, args=("T_STALE", "stale_sha", ["docs/project-record/1.txt"]))
        t2 = threading.Thread(target=claim_task_with_env, args=("T_VALID", "valid_sha", ["docs/project-record/2.txt"]))

        t1.start()
        t2.start()

        t1.join()
        t2.join()

        t_stale_res = next(r for r in results if r[0] == "T_STALE")
        t_valid_res = next(r for r in results if r[0] == "T_VALID")

        self.assertEqual(t_stale_res[1], 1)
        self.assertEqual(t_valid_res[1], 0)

if __name__ == '__main__':
    unittest.main()
