#!/usr/bin/env python3
"""Scan every fetched Git ref with Gitleaks; emit metadata, never secret values.

Fetch all branches, tags and PR heads before publication review. This command
does not audit GitHub logs, artifacts, LFS payloads, personal data or rights.
Exit codes: 0 no findings, 1 findings requiring triage, 2 incomplete audit.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import subprocess
import tempfile


def audit(repository: Path, gitleaks: str) -> tuple[int, dict]:
    try:
        shallow = subprocess.run(
            ["git", "rev-parse", "--is-shallow-repository"],
            cwd=repository, capture_output=True, text=True, check=True,
        ).stdout.strip()
        if shallow != "false":
            return 2, {"status": "INCOMPLETE", "reason": "Full Git history is required"}
        refs = subprocess.run(
            ["git", "for-each-ref", "--format=%(refname)"],
            cwd=repository, capture_output=True, text=True, check=True,
        ).stdout.splitlines()
        git_directory = subprocess.run(
            ["git", "rev-parse", "--absolute-git-dir"],
            cwd=repository, capture_output=True, text=True, check=True,
        ).stdout.strip()
        with tempfile.TemporaryDirectory(prefix="git-secret-audit-") as directory:
            temporary = Path(directory)
            report = temporary / "findings.json"
            # Ignore repository/env allowlists and inline suppression comments.
            # Historical credentials must remain visible until resolved.
            config = temporary / "gitleaks.toml"
            config.write_text("[extend]\nuseDefault = true\n", encoding="utf-8")
            ignore = temporary / ".gitleaksignore"
            ignore.write_text("", encoding="utf-8")
            result = subprocess.run(
                # Gitleaks also loads <source>/.gitleaksignore even when an
                # explicit ignore path is supplied. Scan the Git directory
                # from a clean cwd so worktree suppressions cannot hide leaks.
                [gitleaks, "git", git_directory,
                 "--log-opts=--all --full-history", "--redact=100",
                 "--ignore-gitleaks-allow", "--gitleaks-ignore-path", str(ignore),
                 "--config", str(config), "--max-archive-depth=3",
                 "--report-format=json", "--report-path", str(report),
                 "--exit-code=10", "--no-banner", "--timeout=600"],
                cwd=temporary, capture_output=True, text=True, timeout=660,
            )
            # Raw scanner output may contain source context; never relay it.
            if result.returncode not in (0, 10) or not report.is_file():
                return 2, {"status": "INCOMPLETE", "reason": "Gitleaks could not complete"}
            findings = json.loads(report.read_text(encoding="utf-8"))
            if not isinstance(findings, list) or bool(findings) != (result.returncode == 10):
                return 2, {"status": "INCOMPLETE", "reason": "Inconsistent Gitleaks report"}
            safe = [
                {key: finding[key] for key in ("RuleID", "File", "StartLine", "Commit")}
                for finding in findings
            ]
        return (1 if safe else 0), {
            "status": "FINDINGS" if safe else "NO_FINDINGS_IN_FETCHED_HISTORY",
            "ref_count": len(refs), "finding_count": len(safe), "findings": safe,
            "publication_approved": False,
        }
    except (OSError, subprocess.SubprocessError, ValueError, KeyError, TypeError):
        return 2, {"status": "INCOMPLETE", "reason": "Git/scanner unavailable or invalid report"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--gitleaks", default="gitleaks")
    args = parser.parse_args()
    code, report = audit(args.repo, args.gitleaks)
    print(json.dumps(report, ensure_ascii=True, indent=2))
    return code


if __name__ == "__main__":
    raise SystemExit(main())
