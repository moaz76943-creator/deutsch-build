import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import PurePosixPath

from tools.automation.scope_guard import ScopeGuard


class AutoHealExecutor:
    def __init__(self, plan_path, evidence_path=".auto_heal_evidence.json"):
        self.plan_path = plan_path
        self.evidence_path = evidence_path
        self.plan = self._load_plan()
        self.agent_id = "AutoHeal_J093"
        self.guard = ScopeGuard(owner=self.agent_id)
        self.backup_dir = tempfile.mkdtemp(prefix="auto_heal_backup_")
        self.max_attempts = 3

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

    def _read_evidence(self):
        if not os.path.exists(self.evidence_path):
            return {}
        try:
            with open(self.evidence_path, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return {}

    def _write_evidence(self, data):
        with open(self.evidence_path, 'w') as f:
            json.dump(data, f)

    def _check_and_increment_attempts(self, plan_id):
        evidence = self._read_evidence()
        entry = evidence.get(plan_id, {"attempts": 0, "last_error": None})
        if entry["attempts"] >= self.max_attempts:
            raise RuntimeError(f"BLOCKED: Max attempts ({self.max_attempts}) reached for {plan_id}.")

        entry["attempts"] += 1
        evidence[plan_id] = entry
        self._write_evidence(evidence)

    def _record_error(self, plan_id, error_msg):
        evidence = self._read_evidence()
        if plan_id not in evidence:
            evidence[plan_id] = {"attempts": 1, "last_error": None}
        evidence[plan_id]["last_error"] = str(error_msg)
        self._write_evidence(evidence)

    def _run_gate(self):
        gate_script = "tools/verification/j095_gate.py"
        if not os.path.exists(gate_script):
            msg = "BLOCKED: J095 gate or required tools are unavailable."
            print(msg)
            plan_id = self.plan.get('plan_id', 'unknown')
            self._record_error(plan_id, msg)
            return False
        try:
            subprocess.check_call([sys.executable, gate_script], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return True
        except subprocess.CalledProcessError as e:
            plan_id = self.plan.get('plan_id', 'unknown')
            self._record_error(plan_id, f"Gate failed: {e}")
            return False

    def dry_run(self):
        print(f"Dry run for plan: {self.plan.get('plan_id', 'unknown')}")
        self._verify_base_sha()
        for op in self.plan.get("operations", []):
            print(f"Would execute: {op.get('type')} on {op.get('path', 'unknown')}")

    def execute(self):
        plan_id = self.plan.get('plan_id', 'unknown')
        print(f"Executing plan: {plan_id}")

        try:
            self._check_and_increment_attempts(plan_id)
        except RuntimeError as e:
            print(e)
            sys.exit(1)

        self._verify_base_sha()
        paths = self.plan.get("allowed_paths", [])

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

        attempts = attempts_data.get(plan_id, 0)
        if attempts >= self.MAX_ATTEMPTS:
            print(f"Failed: Max attempts ({self.MAX_ATTEMPTS}) reached for plan {plan_id}.")

            # Record failure
            failures_data = {}
            if os.path.exists(self.failures_file):
                try:
                    with open(self.failures_file, 'r') as f:
                        failures_data = json.load(f)
                except Exception:
                    pass
            failures_data[plan_id] = {"reason": f"Max attempts ({self.MAX_ATTEMPTS}) reached"}
            with open(self.failures_file, 'w') as f:
                json.dump(failures_data, f)

            sys.exit(1)

        self._verify_base_sha()

        try:
            for path in paths:
                self.guard.add_allowed_path(path)
                if not self.guard.request_ownership(path):
                    raise ValueError(f"Path ownership denied for: {path}")
        except ValueError as e:
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
                print("Verification failed. Rolling back...")
                self.rollback()
                sys.exit(1)

            print("Execution and verification successful.")

            if self.plan.get("commit"):
                self._commit_changes()
            self.guard.update_status(self.agent_id, paths, "COMPLETE")
            print("Execution and verification successful.")
        except Exception as e:
            print(f"Error during execution: {e}. Rolling back...")
            self._record_error(plan_id, e)
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
            count = content.count(op["old_import"])
            if count != 1:
                raise ValueError(f"Import replacement failed: '{op['old_import']}' found {count} times (must be exactly 1).")
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
            if path:
                os.makedirs(os.path.dirname(path), exist_ok=True)
                tmp_path = f"{path}.tmp"
                with open(tmp_path, 'w') as f:
                    f.write(op.get("content", "regenerated"))
                os.replace(tmp_path, path)
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
