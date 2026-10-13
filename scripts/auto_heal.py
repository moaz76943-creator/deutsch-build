#!/usr/bin/env python3
import argparse
import sys
import os
import subprocess
import json

def check_required_gates():
    try:
        from tools.agent_contract.guard import ScopeGuard
    except ImportError:
        print("BLOCKED: ScopeGuard required but not available.")
        sys.exit(1)

    try:
        import j095_verification_gate
    except ImportError:
        print("BLOCKED: J095 gate or required tools are unavailable.")
        sys.exit(1)

def track_attempt(plan_id):
    state_file = f".auto_heal_{plan_id}_state.json"
    state = {"attempts": 0}
    if os.path.exists(state_file):
        with open(state_file, "r") as f:
            state = json.load(f)

    state["attempts"] += 1

    with open(state_file, "w") as f:
        json.dump(state, f)

    return state["attempts"]

def get_attempts(plan_id):
    state_file = f".auto_heal_{plan_id}_state.json"
    if os.path.exists(state_file):
        with open(state_file, "r") as f:
            return json.load(f).get("attempts", 0)
    return 0

def check_allowed_paths(paths, target_file):
    if not target_file:
        return True

    allowed = [p.strip() for p in paths.split(",")]
    target_abs = os.path.abspath(target_file)
    for path in allowed:
        path_abs = os.path.abspath(path)
        if target_abs.startswith(path_abs) or target_abs == path_abs:
            return True
    return False

def rebuild_fts5():
    print("Rebuilding SQLite FTS5 indexes from validated sources.")
    try:
        subprocess.run(["python3", "tools/content_population_factory.py"], check=True)
    except subprocess.CalledProcessError:
        print("Failed to rebuild FTS5 indexes")
        sys.exit(1)

def regenerate_artifacts():
    print("Regenerating broken disposable artifacts atomically.")
    try:
        subprocess.run(["./scripts/build_deutsch.sh"], check=True)
    except subprocess.CalledProcessError:
        print("Failed to regenerate artifacts")
        sys.exit(1)

def repair_flutter_import(target_file, old_import, new_import):
    if not target_file or not old_import or not new_import:
        print("Missing required arguments for repair_flutter_import")
        sys.exit(1)

    if not os.path.exists(target_file):
        print(f"Target file {target_file} not found")
        sys.exit(1)

    with open(target_file, "r") as f:
        content = f.read()

    # Verify uniqueness
    if content.count(old_import) != 1:
        print("BLOCKED: old_import does not uniquely exist in target file.")
        sys.exit(1)

    content = content.replace(old_import, new_import)

    with open(target_file, "w") as f:
        f.write(content)
    print(f"Repaired Flutter import in {target_file}")

def verify_base_sha(base_sha):
    if not base_sha:
        return
    try:
        subprocess.run(["git", "merge-base", "--is-ancestor", base_sha, "HEAD"], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print("BASE_SHA verified.")
    except subprocess.CalledProcessError:
        print(f"Failed to verify BASE_SHA: {base_sha}")
        sys.exit(1)

def execute_operation(operation, args):
    if operation == "rebuild_fts5":
        rebuild_fts5()
    elif operation == "regenerate_artifacts":
        regenerate_artifacts()
    elif operation == "repair_flutter_import":
        if not check_allowed_paths(args.allowed_paths, args.target_file):
             print(f"Target file {args.target_file} is not within allowed paths: {args.allowed_paths}")
             sys.exit(1)
        repair_flutter_import(args.target_file, args.old_import, args.new_import)
    else:
        print(f"Unknown deterministic operation: {operation}")
        sys.exit(1)

def cmd_dry_run(args):
    print("Dry run mode...")
    verify_base_sha(args.base_sha)
    print(f"Would execute operation: {args.operation}")

def cmd_execute(args):
    check_required_gates()
    from tools.agent_contract.guard import ScopeGuard
    verify_base_sha(args.base_sha)
    guard = ScopeGuard(args.allowed_paths.split(","))
    guard.verify(args.base_sha)

    attempts = track_attempt(args.plan_id)
    if attempts > 3:
        print(f"Failed: Max attempts (3) reached for plan {args.plan_id}. Persistent failure evidence recorded.")
        sys.exit(1)

    print(f"Executing operation: {args.operation} (Attempt {attempts}/3)")
    execute_operation(args.operation, args)

def cmd_verify(args):
    check_required_gates()
    print("Verifying operation...")
    verify_base_sha(args.base_sha)

    # Run targeted tests and the required verification gate
    try:
        subprocess.run(["python3", "tool/verify.py"], check=True)
        print("Verification passed.")
    except subprocess.CalledProcessError:
        print("Verification failed")
        sys.exit(1)

    # Create isolated commit
    branch_name = f"auto-heal-{args.plan_id}"
    try:
        # Check if we are already on a branch or similar to isolate
        subprocess.run(["git", "checkout", "-b", branch_name], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        # Add allowed paths
        allowed_paths = [p.strip() for p in args.allowed_paths.split(",")]
        subprocess.run(["git", "add"] + allowed_paths, check=True)

        # Commit with [skip ci]
        commit_msg = f"Auto-heal: Apply deterministic repair for {args.plan_id} [skip ci]"
        subprocess.run(["git", "commit", "-m", commit_msg], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

        print(f"Successfully created isolated commit on branch {branch_name}")
    except subprocess.CalledProcessError as e:
        print("Verification: Could not create isolated commit. Maybe no changes to commit?")

def cmd_rollback(args):
    print("Rolling back isolated repair delta...")
    allowed_paths = [p.strip() for p in args.allowed_paths.split(",")]

    try:
        subprocess.run(["git", "restore"] + allowed_paths, check=True)
        print("Rollback complete.")
    except subprocess.CalledProcessError:
        print("Failed to run git restore.")
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Local Autonomous Self-Healing Executor")
    parser.add_argument("command", choices=["dry-run", "execute", "verify", "rollback"], help="Command to run")
    parser.add_argument("--plan-id", required=True, help="Repair plan identity (e.g. J091-001)")
    parser.add_argument("--allowed-paths", required=True, help="Comma-separated allowed paths")
    parser.add_argument("--base-sha", required=True, help="Base commit SHA for verification")
    parser.add_argument("--operation", required=True, choices=["rebuild_fts5", "regenerate_artifacts", "repair_flutter_import"], help="Allowlisted repair operation")
    parser.add_argument("--target-file", help="Target file for repair_flutter_import")
    parser.add_argument("--old-import", help="Old import string to replace")
    parser.add_argument("--new-import", help="New import string to use")

    # In case no args, print help
    if len(sys.argv) == 1:
        parser.print_help()
        sys.exit(1)

    args = parser.parse_args()

    if args.command == "dry-run":
        cmd_dry_run(args)
    elif args.command == "execute":
        cmd_execute(args)
    elif args.command == "verify":
        cmd_verify(args)
    elif args.command == "rollback":
        cmd_rollback(args)

if __name__ == "__main__":
    main()
