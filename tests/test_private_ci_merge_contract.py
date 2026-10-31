"""Regression contracts for the private CI and staging merge boundary."""
from pathlib import Path
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
