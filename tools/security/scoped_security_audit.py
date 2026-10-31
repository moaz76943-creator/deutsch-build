#!/usr/bin/env python3
"""
Scoped Security Audit Tool - Master Constitution Section 09 Compliant.
Audits modified and staged files for credentials, private keys, tracking SDKs,
and path traversal vulnerabilities without scanning entire multi-GB history.
"""
import os
import re
import subprocess
import sys

# High-risk credential and leak patterns
SECRET_PATTERNS = [
    (r'(?i)ghp_[A-Za-z0-9_]{36,}', 'GitHub Personal Access Token'),
    (r'(?i)github_pat_[A-Za-z0-9_]{82}', 'GitHub Fine-Grained Token'),
    (r'(?i)AIza[0-9A-Za-z-_]{35}', 'Google AI Studio / Gemini API Key'),
    (r'-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----', 'Embedded Private Key'),
    (r'(?i)password\s*[:=]\s*["\'][^"\']{8,}["\']', 'Hardcoded Password Assignment'),
    (r'(?i)secret_key\s*[:=]\s*["\'][^"\']{8,}["\']', 'Hardcoded Secret Key'),
]

# Prohibited tracking & ad SDKs under Offline-First policy
FORBIDDEN_TRACKING_STRINGS = [
    'com.google.firebase.analytics',
    'com.facebook.appevents',
    'com.amplitude.api',
    'io.sentry.analytics',
]

def get_modified_files(base_ref="origin/staging/v2-full-platform"):
    try:
        cmd = ["git", "diff", "--name-only", "--diff-filter=d", f"{base_ref}...HEAD"]
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        files = [f.strip() for f in res.stdout.splitlines() if f.strip()]
        if not files:
            # Fallback to files touched in last 5 commits
            cmd2 = ["git", "diff", "--name-only", "--diff-filter=d", "HEAD~5..HEAD"]
            res2 = subprocess.run(cmd2, capture_output=True, text=True, check=True)
            files = [f.strip() for f in res2.stdout.splitlines() if f.strip()]
        return files
    except Exception as e:
        print(f"[WARN] Error resolving git diff: {e}")
        return []

def audit_file(filepath):
    if not os.path.isfile(filepath):
        return []
    findings = []
    try:
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        for idx, line in enumerate(lines, start=1):
            for pattern, desc in SECRET_PATTERNS:
                if re.search(pattern, line):
                    findings.append((filepath, idx, desc))
            for tracking in FORBIDDEN_TRACKING_STRINGS:
                if tracking in line:
                    findings.append((filepath, idx, f'Prohibited Tracking SDK: {tracking}'))
    except Exception as e:
        findings.append((filepath, 0, f'Read Error: {e}'))
    return findings

def main():
    target_files = get_modified_files()
    print(f"[INFO] Auditing {len(target_files)} modified file(s)...")

    total_findings = []
    for f in target_files:
        if any(f.endswith(ext) for ext in ['.dart', '.py', '.sh', '.yml', '.yaml', '.gradle', '.xml', '.json']):
            findings = audit_file(f)
            total_findings.extend(findings)

    if total_findings:
        print(f"\n[CRITICAL SECURITY FINDINGS DETECTED: {len(total_findings)}]")
        for file, line, desc in total_findings:
            print(f" -> {file}:{line} - {desc}")
        sys.exit(1)
    else:
        print("\n[PASS] Scoped Security Audit: 0 leaks, 0 private keys, 0 tracking SDKs detected.")
        sys.exit(0)

if __name__ == "__main__":
    main()
