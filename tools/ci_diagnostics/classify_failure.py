#!/usr/bin/env python3
import json, sys

def classify_check(run):
    name = run.get('name', 'unknown')
    status = run.get('status', '')
    conclusion = run.get('conclusion', '')
    output = run.get('output', {}) or {}
    text = (output.get('text', '') or '') + ' ' + (output.get('title', '') or '') + ' ' + (output.get('summary', '') or '')

    if conclusion != 'failure':
        return name, conclusion, "NONE", "Check did not fail"

    lower_text = text.lower()
    if 'blobnotfound' in lower_text or ('runner' in lower_text and 'not assigned' in lower_text):
        return name, conclusion, "INFRASTRUCTURE_FAILURE", "Runner unallocated or log expired before capture"
    elif 'gitleaks' in lower_text or 'secret' in lower_text:
        return name, conclusion, "POLICY_FAILURE", "Git history secret scan policy finding"
    elif 'pub get' in lower_text or 'dependency' in lower_text or 'osv-scanner' in lower_text:
        return name, conclusion, "DEPENDENCY_FAILURE", "Dependency resolution or security database mismatch"
    elif 'test' in lower_text and ('failed' in lower_text or 'error' in lower_text):
        return name, conclusion, "SOURCE_FAILURE", "Unit/widget test regression in code"
    else:
        return name, conclusion, "UNKNOWN_SOURCE_FAILURE", "Failure during workflow execution step"

if __name__ == "__main__":
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            data = json.load(f)
    else:
        data = json.load(sys.stdin)

    runs = data.get('check_runs', [])
    print(f"Total Checks Evaluated: {len(runs)}")
    has_infra = False
    for r in runs:
        if r.get('conclusion') == 'failure':
            name, concl, cat, reason = classify_check(r)
            print(f"[{cat}] Job: {name} | Reason: {reason}")
            if cat == "INFRASTRUCTURE_FAILURE":
                has_infra = True

    if has_infra:
        print("\nANTI_BLIND_RETRY_ACTION: HALT — Do NOT re-run CI blindly without infrastructure trigger fix.")
    else:
        print("\nANTI_BLIND_RETRY_ACTION: QUALIFIED_RETRY_ALLOWED — Failure is deterministic in source/policy.")
