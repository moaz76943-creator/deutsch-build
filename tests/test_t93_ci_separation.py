"""T93 contracts: fast targeted checks separated from expensive full checks.

Asserts that polyglot_ci.yml keeps the cheap Python audit unconditional,
runs the expensive Flutter SDK/analyze/test steps only when non-docs
content changed, and cancels redundant same-ref runs via concurrency.
This test does not trigger GitHub Actions or call the network.
"""
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WORKFLOW = ROOT / ".github" / "workflows" / "polyglot_ci.yml"

EXPENSIVE_STEPS = (
    "Resolve pinned toolchain",
    "Set up Flutter SDK",
    "Install Dependencies & Analyze",
    "Run Unified Polyglot Test Suite",
)


class T93CISeparationContracts(unittest.TestCase):
    def setUp(self):
        self.text = WORKFLOW.read_text(encoding="utf-8")

    def test_required_check_name_and_job_are_unchanged(self):
        self.assertIn("name: Polyglot Unified CI & Security Gate", self.text)
        self.assertIn("  verify:", self.text)

    def test_concurrency_cancels_redundant_runs_on_same_ref(self):
        self.assertIn("concurrency:", self.text)
        self.assertIn("group: polyglot-ci-${{ github.ref }}", self.text)
        self.assertIn("cancel-in-progress: true", self.text)

    def test_python_audit_steps_are_unconditional(self):
        # The cheap audit must never be hidden behind the change gate.
        start = self.text.index("- name: Run Zero-Secrets & Status Audit")
        end = self.text.index("Detect code changes")
        region = self.text[start:end]
        self.assertIn("python3 tool/polyglot_cli.py status", region)
        self.assertIn("python3 tool/polyglot_cli.py security-scan", region)
        self.assertNotIn("if:", region)

    def test_change_detection_gates_every_expensive_step(self):
        for name in EXPENSIVE_STEPS:
            with self.subTest(step=name):
                idx = self.text.index(f"- name: {name}")
                step = self.text[idx:idx + 400]
                header = step.split("run:", 1)[0]
                self.assertIn("if: steps.changes.outputs.code == 'true'", header,
                              f"{name} is not gated on the change detection")

    def test_detection_defaults_unknown_diff_to_expensive_full_path(self):
        detect = self.text[self.text.index("- name: Detect code changes"):
                           self.text.index("- name: Notice fast path")]
        self.assertIn('changed="(unknown)"', detect)
        self.assertIn("echo \"code=true\" >> \"$GITHUB_OUTPUT\"", detect)
        self.assertIn("echo \"code=false\" >> \"$GITHUB_OUTPUT\"", detect)

    def test_detection_classifies_docs_only_paths_as_fast_path(self):
        detect = self.text[self.text.index("- name: Detect code changes"):
                           self.text.index("- name: Notice fast path")]
        self.assertIn(r"grep -qvE '^(docs/|reports/|[^/]*\.md$|LICENSE|NOTICE)'",
                      detect)


if __name__ == "__main__":
    unittest.main()
