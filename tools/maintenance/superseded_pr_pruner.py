#!/usr/bin/env python3
"""
Superseded PR Pruner - Master Constitution Section 06 & 12 Compliant:
'Close historical duplicate PRs only after verifying substitution,
strictly without dropping unmerged unique features or code.'
"""
import json
import subprocess
import sys

def audit_and_prune_duplicates(repo_name: str, base_branch: str, dry_run: bool = True):
    print(f"[INFO] Scanning {repo_name} for duplicate or zero-diff candidate PRs...")

    cmd = [
        "gh", "pr", "list",
        "--repo", repo_name,
        "--base", base_branch,
        "--state", "open",
        "--limit", "50",
        "--json", "number,title,headRefName,headRefOid,changedFiles,isDraft"
    ]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        prs = json.loads(res.stdout)
    except Exception as e:
        print(f"[WARN] Error querying open PRs: {e}")
        return 0, 0

    closed_count = 0
    retained_count = 0

    for pr in prs:
        num = pr['number']
        title = pr['title']
        changed = pr.get('changedFiles', 0)
        is_draft = pr.get('isDraft', False)

        # Rule 1: Zero-diff PRs are unconditionally safe to close
        if changed == 0:
            print(f"[-] Candidate for closure (0 changed files): PR #{num} - '{title}'")
            if not dry_run:
                close_cmd = [
                    "gh", "pr", "close", str(num),
                    "--repo", repo_name,
                    "--comment", "Closed by Polyglot T059 Pruner: Verified 0 changed files against base."
                ]
                subprocess.run(close_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            closed_count += 1
            continue

        # Rule 2: Non-zero diffs are safely retained for review
        retained_count += 1

    print(f"[AUDIT COMPLETE] Pruned/Eligible: {closed_count} | Retained for Review: {retained_count}")
    return closed_count, retained_count

if __name__ == "__main__":
    repo = sys.argv[1] if len(sys.argv) > 1 else "moaz76943-creator/deutsch-build"
    base = sys.argv[2] if len(sys.argv) > 2 else "staging/v2-full-platform"
    audit_and_prune_duplicates(repo, base, dry_run=False)
