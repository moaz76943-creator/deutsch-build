"""Regression contracts for the private CI and staging merge boundary."""
from pathlib import Path
import json
import os
import subprocess
import tempfile
import textwrap
import unittest

ROOT = Path(__file__).resolve().parents[1]
STAGING = ROOT / ".github/workflows/staging_self_check.yml"
AUTOMERGE = ROOT / ".github/workflows/auto-merge.yml"
SECURITY = ROOT / ".github/workflows/security_audit.yml"


class PrivateCIMergeContractTest(unittest.TestCase):
    def test_workflow_run_missing_pr_is_safe(self):
        text = AUTOMERGE.read_text(encoding="utf-8")
        self.assertIn(
            "commits/$run_head/pulls", text
        )
        self.assertIn(
            "if: steps.pr.outputs.number != ''", text
        )

    def test_missing_association_reaches_exact_head_canonical_fallback(self):
        text = AUTOMERGE.read_text(encoding="utf-8")
        condition = text.split("    if: >-", 1)[1].split("    runs-on:", 1)[0]
        self.assertNotIn("pull_requests[0]", condition)
        self.assertIn("github.event.workflow_run.event == 'pull_request'", condition)
        script = textwrap.dedent(text.split("        run: |\n", 1)[1].split(
            "\n      - name: Verify exact-head", 1)[0])
        head = "a" * 40
        for base, candidate_head, expected in (
            ("staging/v2-full-platform", head, "number=7"),
            ("main", head, ""),
            ("staging/v2-full-platform", "b" * 40, ""),
        ):
            with self.subTest(base=base, candidate_head=candidate_head), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                (root / "event.json").write_text(json.dumps({"workflow_run": {
                    "head_sha": head, "pull_requests": []}}))
                (root / "candidates.json").write_text(json.dumps([{
                    "number": 7, "state": "open", "head": {"sha": candidate_head},
                    "base": {"ref": base}}]))
                gh = root / "gh"
                gh.write_text('#!/bin/sh\ncat "$TEST_CANDIDATES"\n')
                gh.chmod(0o755)
                output = root / "output"
                output.touch()
                subprocess.run(["bash", "-c", script], check=True, capture_output=True, env={
                    **os.environ, "PATH": f"{root}:{os.environ['PATH']}",
                    "GITHUB_EVENT_NAME": "workflow_run", "GITHUB_EVENT_PATH": str(root / "event.json"),
                    "GITHUB_REPOSITORY": "moaz76943-creator/deutsch-build",
                    "GITHUB_OUTPUT": str(output), "TEST_CANDIDATES": str(root / "candidates.json"),
                })
                result = output.read_text()
                if expected:
                    self.assertIn(expected, result)
                else:
                    self.assertEqual(result, "")

    def test_merge_workflow_has_one_unambiguous_permission_per_scope(self):
        text = AUTOMERGE.read_text(encoding="utf-8")
        self.assertEqual(text.count("\npermissions:\n"), 1)
        permission_block = text.split("\npermissions:\n", 1)[1].split("\n\n", 1)[0]
        lines = [line.strip() for line in permission_block.splitlines() if line.strip()]
        keys = [line.split(":", 1)[0] for line in lines]
        self.assertEqual(len(keys), len(set(keys)), "Duplicate YAML permission keys invalidate the workflow")
        self.assertEqual(set(lines), {
            "contents: write",
            "pull-requests: write",
            "actions: read",
        })

    def test_staging_checkout_has_one_with_mapping(self):
        text = STAGING.read_text(encoding="utf-8")
        checkout = text.split("- name: Checkout pull request", 1)[1].split(
            "- name: Detect Flutter-impacting changes", 1
        )[0]
        self.assertEqual(
            checkout.count("\n        with:"), 1,
            "Duplicate 'with' keys make GitHub Actions refuse the entire workflow",
        )
        self.assertIn("fetch-depth: 0", checkout)
        self.assertIn("persist-credentials: false", checkout)

    def test_ci_is_read_only_and_never_merges_on_one_green_check(self):
        text = STAGING.read_text(encoding="utf-8")
        self.assertIn("contents: read", text)
        self.assertNotIn("contents: write", text)
        self.assertNotIn("gh pr merge", text)
        self.assertIn("cancel-in-progress: true", text)
        # All staging PRs must be eligible for the lightweight required receipt.
        self.assertNotIn("\n    paths:", text)
        # Avoid grep -q SIGPIPE on large paginated filename streams.
        self.assertNotIn("| grep -Eq", text)
        self.assertIn("| grep -E", text)

    def test_merge_requires_independent_review_and_exact_head_checks(self):
        text = AUTOMERGE.read_text(encoding="utf-8")
        self.assertIn("reviewDecision", text)
        self.assertIn("APPROVED", text)
        self.assertIn("headRefOid", text)
        self.assertIn("staging_self_check.yml", text)
        self.assertIn("security_audit.yml", text)
        self.assertIn("--squash", text)
        self.assertIn("--match-head-commit", text)
        self.assertNotIn("gh pr merge --merge", text)

    def test_merge_gate_retriggers_on_new_commits_reviews_and_receipts(self):
        text = AUTOMERGE.read_text(encoding="utf-8")
        self.assertIn("types: [labeled, reopened, ready_for_review, synchronize]", text)
        self.assertIn("pull_request_review:", text)
        self.assertIn("workflow_run:", text)
        self.assertIn('workflows: ["Staging self-check", "Security Audit"]', text)
        self.assertIn("author_association", text)

    def test_security_scan_is_independent_and_targets_pr_head(self):
        text = SECURITY.read_text(encoding="utf-8")
        self.assertIn("github.event.pull_request.head.sha || github.sha", text)
        self.assertIn("tool/git_secret_audit.py", text)
        self.assertIn("if: always()", text)

    def test_ci_has_failure_stage_summary_without_exposing_logs(self):
        text = STAGING.read_text(encoding="utf-8")
        self.assertIn("GITHUB_STEP_SUMMARY", text)
        self.assertIn("SOURCE_FAILURE", text)
        self.assertIn("DEPENDENCY_FAILURE", text)
        self.assertIn("INFRASTRUCTURE_FAILURE", text)


if __name__ == "__main__":
    unittest.main()
