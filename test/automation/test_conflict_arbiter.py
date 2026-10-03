from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path

from tools.agents.conflict_arbiter import attempt_auto_rebase, tree_dry_run


def git(repo: Path, *args: str) -> str:
    proc = subprocess.run(
        ["git", "-C", str(repo), *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return proc.stdout.strip()


class ConflictArbiterTest(unittest.TestCase):
    def make_repo(self) -> Path:
        root = Path(tempfile.mkdtemp(prefix="arbiter-test-"))
        git(root, "init", "-q")
        git(root, "config", "user.email", "arbiter@example.invalid")
        git(root, "config", "user.name", "Arbiter Test")
        (root / "base.txt").write_text("base\n", encoding="utf-8")
        git(root, "add", "base.txt")
        git(root, "commit", "-qm", "base")
        git(root, "branch", "-M", "main")
        return root

    def test_tree_dry_run_reports_clean_parallel_branch(self) -> None:
        repo = self.make_repo()
        git(repo, "checkout", "-qb", "feature")
        (repo / "feature.txt").write_text("feature\n", encoding="utf-8")
        git(repo, "add", "feature.txt")
        git(repo, "commit", "-qm", "feature")
        git(repo, "checkout", "-q", "main")
        (repo / "main.txt").write_text("main\n", encoding="utf-8")
        git(repo, "add", "main.txt")
        git(repo, "commit", "-qm", "main")

        result = tree_dry_run(repo, "main", "feature")

        self.assertTrue(result.clean)
        self.assertEqual([], result.collided_paths)
        self.assertRegex(result.tree_sha or "", r"^[0-9a-f]{40}$")

    def test_tree_dry_run_identifies_conflicting_path(self) -> None:
        repo = self.make_repo()
        (repo / "shared.txt").write_text("ancestor\n", encoding="utf-8")
        git(repo, "add", "shared.txt")
        git(repo, "commit", "-qm", "shared ancestor")
        git(repo, "checkout", "-qb", "feature")
        (repo / "shared.txt").write_text("feature\n", encoding="utf-8")
        git(repo, "commit", "-am", "feature change", "-q")
        git(repo, "checkout", "-q", "main")
        (repo / "shared.txt").write_text("main\n", encoding="utf-8")
        git(repo, "commit", "-am", "main change", "-q")

        result = tree_dry_run(repo, "main", "feature")

        self.assertFalse(result.clean)
        self.assertEqual(["shared.txt"], result.collided_paths)
        self.assertIn("CONFLICT", result.diagnostics)

    def test_auto_rebase_preview_succeeds_without_moving_source_ref(self) -> None:
        repo = self.make_repo()
        git(repo, "checkout", "-qb", "feature")
        (repo / "feature.txt").write_text("feature\n", encoding="utf-8")
        git(repo, "add", "feature.txt")
        git(repo, "commit", "-qm", "feature")
        original = git(repo, "rev-parse", "feature")
        git(repo, "checkout", "-q", "main")
        (repo / "main.txt").write_text("main\n", encoding="utf-8")
        git(repo, "add", "main.txt")
        git(repo, "commit", "-qm", "main")

        result = attempt_auto_rebase(repo, "main", "feature", apply=False)

        self.assertTrue(result.success)
        self.assertFalse(result.applied)
        self.assertNotEqual(original, result.rebased_head)
        self.assertEqual(original, git(repo, "rev-parse", "feature"))

    def test_auto_rebase_reports_unmerged_paths_on_conflict(self) -> None:
        repo = self.make_repo()
        (repo / "shared.txt").write_text("ancestor\n", encoding="utf-8")
        git(repo, "add", "shared.txt")
        git(repo, "commit", "-qm", "shared ancestor")
        git(repo, "checkout", "-qb", "feature")
        (repo / "shared.txt").write_text("feature\n", encoding="utf-8")
        git(repo, "commit", "-am", "feature change", "-q")
        git(repo, "checkout", "-q", "main")
        (repo / "shared.txt").write_text("main\n", encoding="utf-8")
        git(repo, "commit", "-am", "main change", "-q")

        result = attempt_auto_rebase(repo, "main", "feature", apply=False)

        self.assertFalse(result.success)
        self.assertFalse(result.applied)
        self.assertEqual(["shared.txt"], result.collided_paths)


if __name__ == "__main__":
    unittest.main()
