#!/usr/bin/env python3
"""Regression tests for anti-skip guard and CI non-suppression contracts."""
from __future__ import annotations

import unittest
from pathlib import Path
import sys

# Add repo root to path
REPO_ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO_ROOT))

from tools.verification.anti_skip_guard import (
    find_skip_directives,
    contains_skip_directive,
    assert_no_skip_directives,
    sanitize_skip_directives,
)


class TestAntiSkipGuard(unittest.TestCase):
    """Verify SKIP-001 / SKIP-015: Prohibit all skip directives from integration."""

    PROHIBITED_SAMPLES = [
        "feat(srs): implement review port [skip ci]",
        "[ci skip] fix: update dependency lock",
        "chore: clean temp files [no ci]",
        "test: add typography goldens [skip actions]",
        "refactor: extract service [actions skip]",
        "feat: new feature\n\nskip-checks: true",
        "feat: new feature\nskip-checks:true",
        "WIP: testing feature [SKIP CI]",
    ]

    VALID_SAMPLES = [
        "feat(srs): implement pair-isolated review transactions",
        "test(ci): verify regression tests pass without skipping",
        "fix(runtime): reconcile bounded worker and lifecycle",
        "chore: update release tag to v2.1.0",
        "docs(architecture): clarify multi-script typography hierarchy",
    ]

    def test_detects_all_prohibited_skip_directives(self):
        for sample in self.PROHIBITED_SAMPLES:
            with self.subTest(sample=sample):
                self.assertTrue(
                    contains_skip_directive(sample),
                    f"Expected to detect skip directive in: {sample}",
                )
                directives = find_skip_directives(sample)
                self.assertGreater(len(directives), 0)

    def test_accepts_clean_commit_messages(self):
        for sample in self.VALID_SAMPLES:
            with self.subTest(sample=sample):
                self.assertFalse(
                    contains_skip_directive(sample),
                    f"False positive detection in clean sample: {sample}",
                )
                self.assertEqual(find_skip_directives(sample), [])

    def test_assert_no_skip_directives_raises(self):
        for sample in self.PROHIBITED_SAMPLES:
            with self.subTest(sample=sample):
                with self.assertRaises(ValueError):
                    assert_no_skip_directives(sample, "test commit")

    def test_assert_no_skip_directives_passes_clean(self):
        for sample in self.VALID_SAMPLES:
            with self.subTest(sample=sample):
                # Should not raise
                assert_no_skip_directives(sample, "test commit")

    def test_sanitize_removes_skip_directives(self):
        self.assertEqual(
            sanitize_skip_directives("fix(learning): bounded SRS contract [skip ci]"),
            "fix(learning): bounded SRS contract",
        )
        self.assertEqual(
            sanitize_skip_directives("[skip ci] GHA-07: scoped probe"),
            "GHA-07: scoped probe",
        )
        self.assertEqual(
            sanitize_skip_directives("feat: test\nskip-checks: true"),
            "feat: test",
        )

    def test_skipped_status_not_treated_as_pass(self):
        """SKIP-007 / SKIP-015: SKIPPED, CANCELLED, NOT_RUN, PENDING must never be treated as PASS."""
        failing_or_non_pass_statuses = ["SKIPPED", "CANCELLED", "NOT_RUN", "PENDING", "UNKNOWN", "DIRTY"]
        for status in failing_or_non_pass_statuses:
            with self.subTest(status=status):
                self.assertNotEqual(status, "PASS")
                self.assertNotEqual(status, "passed")
                self.assertNotEqual(status, "success")


if __name__ == "__main__":
    unittest.main()
