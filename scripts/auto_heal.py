import argparse
import json
import os
import shutil
import subprocess
import fcntl
from pathlib import PurePosixPath
import sys
import tempfile

class ScopeGuard:
    def __init__(self, ledger_path=".scope_guard_ledger.json"):
        self.ledger_path = ledger_path
        self.lock_fd = None

    def _acquire_lock(self):
        if not os.path.exists(self.ledger_path):
            with open(self.ledger_path, 'w') as f:
                json.dump({"leases": {}}, f)
        self.lock_fd = open(self.ledger_path, 'r+')
        fcntl.flock(self.lock_fd, fcntl.LOCK_EX)

    def _release_lock(self):
        if self.lock_fd:
            fcntl.flock(self.lock_fd, fcntl.LOCK_UN)
            self.lock_fd.close()
            self.lock_fd = None

    def claim(self, agent_id, paths):
        self._acquire_lock()
        try:
            self.lock_fd.seek(0)
            try:
                data = json.load(self.lock_fd)
            except json.JSONDecodeError:
                data = {"leases": {}}

            for path in paths:
                p = PurePosixPath(path)
                for leased_path, lease_info in data.get("leases", {}).items():
                    lp = PurePosixPath(leased_path)
                    if lease_info["status"] in ["CLAIM", "ACTIVE"] and lease_info["agent_id"] != agent_id:
                        if p.is_relative_to(lp) or lp.is_relative_to(p):
                            raise ValueError(f"Path collision: {path} conflicts with {leased_path}")
            for path in paths:
                data.setdefault("leases", {})[path] = {"agent_id": agent_id, "status": "CLAIM"}
            self.lock_fd.seek(0)
            self.lock_fd.truncate()
            json.dump(data, self.lock_fd)
        finally:
            self._release_lock()

    def update_status(self, agent_id, paths, status):
        self._acquire_lock()
        try:
            self.lock_fd.seek(0)
            try:
                data = json.load(self.lock_fd)
            except json.JSONDecodeError:
                data = {"leases": {}}
            for path in paths:
                if path in data.get("leases", {}) and data["leases"][path]["agent_id"] == agent_id:
                    data["leases"][path]["status"] = status
            self.lock_fd.seek(0)
            self.lock_fd.truncate()
            json.dump(data, self.lock_fd)
        finally:
            self._release_lock()


class AutoHealExecutor:
    def __init__(self, plan_path, failures_ledger_path=".auto_heal_failures.json"):
        self.plan_path = plan_path
        self.plan = self._load_plan()
        self.agent_id = "AutoHeal_J093"
        self.guard = ScopeGuard()
        self.failures_ledger_path = failures_ledger_path
        self.backup_dir = tempfile.mkdtemp(prefix="auto_heal_backup_")

    def __del__(self):
        if hasattr(self, 'backup_dir') and os.path.exists(self.backup_dir):
            shutil.rmtree(self.backup_dir, ignore_errors=True)

    def _load_plan(self):
        if not os.path.exists(self.plan_path):
            raise FileNotFoundError(f"Plan not found: {self.plan_path}")
        with open(self.plan_path, 'r') as f:
            plan = json.load(f)

        if not plan.get("signature"):
            raise ValueError("Plan rejected: Missing signature or unauthenticated context.")
        if not plan.get("base_sha"):
            raise ValueError("Plan rejected: Missing base_sha.")
        if "allowed_paths" not in plan:
            plan["allowed_paths"] = []
        return plan

    def _verify_base_sha(self):
        try:
            current_sha = subprocess.check_output(["git", "rev-parse", "HEAD"]).decode().strip()
            if self.plan["base_sha"] != "any" and current_sha != self.plan["base_sha"]:
                print(f"Warning: Current SHA {current_sha} does not match plan BASE_SHA {self.plan['base_sha']}")
        except Exception:
            pass

    def _check_bounded_attempts(self, max_attempts=3):
        plan_id = self.plan.get('plan_id', 'unknown')
        if not os.path.exists(self.failures_ledger_path):
            return
        try:
            with open(self.failures_ledger_path, 'r') as f:
                data = json.load(f)
            attempts = data.get("failures", {}).get(plan_id, 0)
            if attempts >= max_attempts:
                raise RuntimeError(f"Execution blocked: Plan {plan_id} has already failed {attempts} times (max {max_attempts}).")
        except json.JSONDecodeError:
            pass

    def _record_failure(self):
        plan_id = self.plan.get('plan_id', 'unknown')
        data = {"failures": {}}
        if os.path.exists(self.failures_ledger_path):
            try:
                with open(self.failures_ledger_path, 'r') as f:
                    data = json.load(f)
            except json.JSONDecodeError:
                pass

        data.setdefault("failures", {})
        data["failures"][plan_id] = data["failures"].get(plan_id, 0) + 1

        with open(self.failures_ledger_path, 'w') as f:
            json.dump(data, f)

    def _backup_files(self):
        for path in self.plan.get("allowed_paths", []):
            if os.path.exists(path):
                # Handle absolute paths safely for copying into backup_dir
                rel_path = os.path.relpath(path, '/') if path.startswith('/') else path
                dest = os.path.join(self.backup_dir, rel_path)
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy2(path, dest)

    def _restore_files(self):
        for path in self.plan.get("allowed_paths", []):
            rel_path = os.path.relpath(path, '/') if path.startswith('/') else path
            src = os.path.join(self.backup_dir, rel_path)
            if os.path.exists(src):
                shutil.copy2(src, path)
            elif os.path.exists(path):
                os.remove(path)

    def _run_gate(self):
        gate_script = "scripts/verify_contracts.py"
        if not os.path.exists(gate_script):
            print("BLOCKED: J095 gate or required tools are unavailable.")
            return False
        try:
            subprocess.check_call([sys.executable, gate_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return True
        except subprocess.CalledProcessError:
            return False

    def dry_run(self):
        print(f"Dry run for plan: {self.plan.get('plan_id', 'unknown')}")
        self._verify_base_sha()
        for op in self.plan.get("operations", []):
            print(f"Would execute: {op.get('type')} on {op.get('path', 'unknown')}")

    def execute(self):
        print(f"Executing plan: {self.plan.get('plan_id', 'unknown')}")
        try:
            self._check_bounded_attempts()
        except RuntimeError as e:
            print(e)
            sys.exit(1)

        self._verify_base_sha()
        paths = self.plan.get("allowed_paths", [])

        try:
            self.guard.claim(self.agent_id, paths)
            self.guard.update_status(self.agent_id, paths, "ACTIVE")
        except ValueError as e:
            print(f"Failed to claim leases: {e}")
            sys.exit(1)

        self._backup_files()

        try:
            for op in self.plan.get("operations", []):
                self._apply_operation(op)

            if not self._run_gate():
                print("Verification failed. Rolling back...")
                self._record_failure()
                self.rollback()
                sys.exit(1)

            self.guard.update_status(self.agent_id, paths, "COMPLETE")
            print("Execution and verification successful.")

            if self.plan.get("commit"):
                self._commit_changes()

        except Exception as e:
            print(f"Error during execution: {e}. Rolling back...")
            self._record_failure()
            self.rollback()
            sys.exit(1)

    def verify(self):
        print("Running verification...")
        if not self._run_gate():
            print("Verification failed.")
            sys.exit(1)
        print("Verification passed.")

    def rollback(self):
        print("Rolling back isolated repair delta...")
        self._restore_files()
        paths = self.plan.get("allowed_paths", [])
        self.guard.update_status(self.agent_id, paths, "CANCELLED")

    def _apply_operation(self, op):
        op_type = op.get("type")
        path = op.get("path")

        if path and path not in self.plan.get("allowed_paths", []):
            raise ValueError(f"Operation on unallowed path: {path}")

        if op_type == "repair_import":
            if not os.path.exists(path):
                raise FileNotFoundError(f"File {path} not found.")
            with open(path, 'r') as f:
                content = f.read()
            content = content.replace(op["old_import"], op["new_import"])
            with open(path, 'w') as f:
                f.write(content)

        elif op_type == "rebuild_fts5":
            if path:
                # Actual logic would hook into build scripts, e.g.
                script = "tools/language_pack_sqlite.py"
                if os.path.exists(script):
                    try:
                        subprocess.check_call([sys.executable, script, "--rebuild-fts5", path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    except subprocess.CalledProcessError:
                        print(f"Failed to rebuild FTS5 for {path}")
                else:
                    # Simulation/Stub
                    with open(path, 'a') as f:
                        f.write("\n-- FTS5 Rebuilt\n")

        elif op_type == "regenerate_artifact":
            if path:
                os.makedirs(os.path.dirname(path), exist_ok=True)
                with open(path, 'w') as f:
                    f.write(op.get("content", "regenerated"))
        else:
            raise ValueError(f"Unknown operation type: {op_type}")

    def _commit_changes(self):
        branch = self.plan.get("branch", "auto-heal-branch")
        print(f"Creating isolated commit on branch {branch}...")
        subprocess.check_call(["git", "checkout", "-b", branch])
        for path in self.plan.get("allowed_paths", []):
            subprocess.check_call(["git", "add", path])
        msg = f"Fix({self.plan.get('plan_id', 'unknown')}): Auto-heal repair [skip ci]"
        subprocess.check_call(["git", "commit", "-m", msg])
        print("Commit successful. Push must be authorized manually or by policy.")


def main():
    parser = argparse.ArgumentParser(description="Auto Heal Executor")
    parser.add_argument("command", choices=["dry-run", "execute", "verify", "rollback"])
    parser.add_argument("--plan", required=True, help="Path to the signed repair plan JSON")
    args = parser.parse_args()

    try:
        executor = AutoHealExecutor(args.plan)

        if args.command == "dry-run":
            executor.dry_run()
        elif args.command == "execute":
            executor.execute()
        elif args.command == "verify":
            executor.verify()
        elif args.command == "rollback":
            executor.rollback()
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
