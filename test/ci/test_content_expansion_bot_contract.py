import unittest
from pathlib import Path
import re

class ContentExpansionBotContractTests(unittest.TestCase):
    def setUp(self):
        self.repo_root = Path(__file__).resolve().parents[2]
        self.workflow_path = self.repo_root / '.github' / 'workflows' / 'content_expansion_bot.yml'
        self.assertTrue(self.workflow_path.exists(), f"Workflow not found at {self.workflow_path}")
        self.content = self.workflow_path.read_text(encoding='utf-8')

    def test_checkout_ref_pinned_to_staging(self):
        """TASK-002: Workflow must check out staging/v2-full-platform, not main."""
        self.assertIn("ref: staging/v2-full-platform", self.content)
        self.assertNotIn("ref: main", self.content)

    def test_pr_base_pinned_to_staging(self):
        """TASK-004: PR creation must explicitly target staging/v2-full-platform."""
        self.assertIn("--base staging/v2-full-platform", self.content)
        self.assertNotIn("--base main", self.content)

    def test_commit_message_and_title_do_not_skip_ci(self):
        """TASK-003: Commit message and PR title must not disable CI."""
        skip_pattern = re.compile(r'\[(?:skip ci|ci skip|no ci|skip actions|actions skip)\]', re.IGNORECASE)
        # Verify no commit command includes skip ci
        commit_lines = [line for line in self.content.splitlines() if 'git commit' in line]
        self.assertTrue(commit_lines, "Expected at least one git commit command")
        for line in commit_lines:
            self.assertIsNone(skip_pattern.search(line), f"Commit command skips CI: {line}")

        # Verify PR title does not include skip ci
        title_lines = [line for line in self.content.splitlines() if '--title' in line]
        for line in title_lines:
            self.assertIsNone(skip_pattern.search(line), f"PR title skips CI: {line}")

    def test_all_pr_creators_pin_staging_in_private_repo(self):
        """TASK-004: All PR generators in private repo must target staging/v2-full-platform."""
        workflows_dir = self.repo_root / '.github' / 'workflows'
        for yml_file in workflows_dir.glob('*.yml'):
            text = yml_file.read_text(encoding='utf-8')
            if 'gh pr create' in text:
                self.assertIn(
                    'staging/v2-full-platform',
                    text,
                    f"Workflow {yml_file.name} creates PR without explicit staging/v2-full-platform base"
                )
                self.assertNotIn(
                    '--base main',
                    text,
                    f"Workflow {yml_file.name} incorrectly targets main"
                )

if __name__ == '__main__':
    unittest.main()
