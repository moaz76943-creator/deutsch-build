import unittest
import subprocess
import os
import tempfile
import json
import time
import threading

def run_guard(task_id, base_sha, state, paths, ledger_path, temp_dir):
    env = os.environ.copy()
    env["PYTHONPATH"] = os.path.abspath(".")
    wrapper_path = os.path.join(temp_dir, f"wrapper_{task_id}.py")
    with open(wrapper_path, "w") as f:
        f.write(f"""
import sys
import fcntl
from pathlib import Path
from tools.agent_contract.guard import main, ScopeGuard
import tools.agent_contract.guard

class TestScopeGuard(ScopeGuard):
    def __init__(self, repo_root="."):
        super().__init__(repo_root)
        self.ledger_path = Path("{ledger_path}")
        self.lock_path = Path("{ledger_path}.lock")

tools.agent_contract.guard.ScopeGuard = TestScopeGuard

sys.argv = [
    "guard.py",
    "transition",
    "--task-id", "{task_id}",
    "--state", "{state}"
]
{"sys.argv.extend(['--paths'] + " + str(paths) + ")" if paths else ""}

if __name__ == '__main__':
    main()
""")

    res = subprocess.run(["python3", wrapper_path], capture_output=True, text=True, env=env)
    return res.returncode, res.stdout, res.stderr

class TestGuardConcurrency(unittest.TestCase):
    def setUp(self):
        self.temp_dir = tempfile.TemporaryDirectory()
        self.ledger_path = os.path.join(self.temp_dir.name, "ledger.json")
        with open(self.ledger_path, "w") as f:
            json.dump({"tasks": {}}, f)

    def tearDown(self):
        self.temp_dir.cleanup()

    def test_concurrent_claims(self):
        results = []
        def claim_task(task_id, paths):
            res, stdout, stderr = run_guard(task_id, "abc", "CLAIM", paths, self.ledger_path, self.temp_dir.name)
            results.append((task_id, res, stdout, stderr))

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
            tasks = ledger.get("tasks", {})
            self.assertEqual(len([k for k, v in tasks.items() if v.get("state") == "CLAIM"]), 2)
            self.assertEqual(tasks["T3"]["state"], "CLAIM")

            t1_t2_claims = [k for k, v in tasks.items() if k in ["T1", "T2"] and v.get("state") == "CLAIM"]
            self.assertEqual(len(t1_t2_claims), 1)

if __name__ == '__main__':
    unittest.main()
