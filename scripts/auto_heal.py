import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import fcntl
from pathlib import PurePosixPath
import sys
import tempfile
import time

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
            except json.JSONDecodeError as exc:
                raise ValueError("Scope ledger corrupted; manual reconciliation required") from exc

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
            except json.JSONDecodeError as exc:
                raise ValueError("Scope ledger corrupted; manual reconciliation required") from exc
            for path in paths:
                if path in data.get("leases", {}) and data["leases"][path]["agent_id"] == agent_id:
                    data["leases"][path]["status"] = status
            self.lock_fd.seek(0)
            self.lock_fd.truncate()
            json.dump(data, self.lock_fd)
        finally:
            self._release_lock()


class AutoHealExecutor:
    def __init__(self, plan_path, attempts_file=".auto_heal_attempts.json", failures_file=".auto_heal_failures.json"):
        self.plan_path = plan_path
        self.attempts_file = attempts_file
        self.failures_file = failures_file
        self.plan = self._load_plan()
        self.agent_id = "AutoHeal_J093"
        self.guard = ScopeGuard()
        self.failures_ledger_path = failures_ledger_path
        self.backup_dir = tempfile.mkdtemp(prefix="auto_heal_backup_")
        self.attempts_file = attempts_file
        self.failures_file = failures_file

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
        if not isinstance(plan.get("base_sha"), str) or not re.fullmatch(r"[0-9a-f]{40}", plan["base_sha"]):
            raise ValueError("Plan rejected: Invalid base_sha; expected exact 40-character commit SHA.")
        if "allowed_paths" not in plan:
            plan["allowed_paths"] = []
        return plan

    def _verify_base_sha(self):
        try:
            current_sha = subprocess.check_output(
                ["git", "rev-parse", "HEAD"], stderr=subprocess.DEVNULL
            ).decode().strip()
        except (OSError, subprocess.CalledProcessError) as exc:
            raise RuntimeError("Cannot verify git HEAD for repair plan") from exc
        if current_sha != self.plan["base_sha"]:
            raise ValueError(
                f"BASE_SHA mismatch: expected {self.plan['base_sha']}, got {current_sha}"
            )

    def _backup_slot(self, path):
        # A path is evidence about the source, never a relative backup target.
        return os.path.join(self.backup_dir, hashlib.sha256(os.fsencode(path)).hexdigest())

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
                shutil.copy2(path, self._backup_slot(path))

    def _restore_files(self):
        for path in self.plan.get("allowed_paths", []):
            src = self._backup_slot(path)
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

    @staticmethod
    def _atomic_json_write(path, value):
        directory = os.path.dirname(os.path.abspath(path))
        fd, temporary = tempfile.mkstemp(prefix=".auto_heal.", suffix=".tmp", dir=directory)
        try:
            with os.fdopen(fd, 'w') as stream:
                json.dump(value, stream)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)

    def _check_and_increment_attempt(self):
        plan_id = self.plan.get('plan_id', 'unknown')
        try:
            if os.path.exists(self.attempts_file):
                with open(self.attempts_file, 'r') as f:
                    data = json.load(f)
            else:
                data = {}
        except (json.JSONDecodeError, UnicodeError) as exc:
            raise ValueError("Attempt history corrupted; manual reconciliation required") from exc

        if not isinstance(data, dict):
            raise ValueError("Attempt history corrupted; expected a JSON object")
        attempts = data.get(plan_id, 0)
        if type(attempts) is not int or attempts < 0:
            raise ValueError("Attempt history corrupted; invalid counter")
        if attempts >= 2:
            raise ValueError(f"Execution blocked: maximum attempts (2) exceeded for plan {plan_id}.")

        data[plan_id] = attempts + 1
        self._atomic_json_write(self.attempts_file, data)

    def _record_failure(self, error_message):
        plan_id = self.plan.get('plan_id', 'unknown')
        if os.path.exists(self.failures_file):
            with open(self.failures_file, 'r') as stream:
                data = json.load(stream)
        else:
            data = {}
        if not isinstance(data, dict):
            raise ValueError("Failure history corrupted; expected a JSON object")
        failures = data.setdefault(plan_id, [])
        if not isinstance(failures, list):
            raise ValueError("Failure history corrupted; expected a failure list")
        failures.append(str(error_message))
        self._atomic_json_write(self.failures_file, data)

    def _record_failure_safely(self, error):
        try:
            self._record_failure(error)
        except Exception as logging_error:
            print(f"Warning: failure evidence unavailable: {type(logging_error).__name__}", file=sys.stderr)

    def execute(self):
        print(f"Executing plan: {self.plan.get('plan_id', 'unknown')}")

        try:
            self._check_and_increment_attempt()
        except (ValueError, OSError) as e:
            print(e)
            self._record_failure_safely(e)
            sys.exit(1)

        self._verify_base_sha()

        try:
            self.guard.claim(self.agent_id, paths)
            self.guard.update_status(self.agent_id, paths, "ACTIVE")
        except (ValueError, OSError) as e:
            print(f"Failed to claim leases: {e}")
            self._record_failure_safely(e)
            sys.exit(1)

        try:
            self._backup_files()
        except Exception as exc:
            # No repair operation has been applied yet. Release ownership
            # without restoring incomplete backups over existing learner files.
            try:
                self.guard.update_status(self.agent_id, paths, "CANCELLED")
            finally:
                self._record_failure_safely(exc)
            print(f"Backup failed; no files modified: {type(exc).__name__}")
            sys.exit(1)

        try:
            for op in self.plan.get("operations", []):
                self._apply_operation(op)

            if not self._run_gate():
                raise RuntimeError("Verification failed.")

            if self.plan.get("commit"):
                self._commit_changes()
            self.guard.update_status(self.agent_id, paths, "COMPLETE")
            print("Execution and verification successful.")
        except Exception as e:
            print(f"Error during execution: {e}. Rolling back...")
            try:
                self.rollback()
            finally:
                self._record_failure_safely(e)
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

        plan_id = self.plan.get("plan_id")
        if plan_id:
            failures = []
            if os.path.exists(self.failures_file):
                try:
                    with open(self.failures_file, 'r') as f:
                        failures = json.load(f)
                except json.JSONDecodeError:
                    pass
            failures.append({"plan_id": plan_id, "timestamp": time.time()})
            with open(self.failures_file, 'w') as f:
                json.dump(failures, f)

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
            if not path:
                raise ValueError("FTS5 rebuild requires an allowed artifact path")
            script = "tools/language_pack_sqlite.py"
            if not os.path.isfile(script):
                raise FileNotFoundError("FTS5 builder unavailable; refusing to mutate artifact")
            subprocess.check_call(
                [sys.executable, script, "--rebuild-fts5", path],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )

        elif op_type == "regenerate_artifact":
            if not path:
                raise ValueError("Artifact regeneration requires an allowed path")
            directory = os.path.dirname(os.path.abspath(path))
            os.makedirs(directory, exist_ok=True)
            fd, temp_path = tempfile.mkstemp(prefix=f".{os.path.basename(path)}.", suffix=".tmp", dir=directory)
            try:
                with os.fdopen(fd, 'w') as stream:
                    stream.write(op.get("content", "regenerated"))
                    stream.flush()
                    os.fsync(stream.fileno())
                os.replace(temp_path, path)
            finally:
                if os.path.exists(temp_path):
                    os.unlink(temp_path)
        else:
            raise ValueError(f"Unknown operation type: {op_type}")

    def _commit_changes(self):
        branch = self.plan.get("branch", "auto-heal-branch")
        print(f"Creating isolated commit on branch {branch}...")
        subprocess.check_call(["git", "checkout", "-b", branch])
        for path in self.plan.get("allowed_paths", []):
            subprocess.check_call(["git", "add", path])
        msg = f"Fix({self.plan.get('plan_id', 'unknown')}): Auto-heal repair"
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
