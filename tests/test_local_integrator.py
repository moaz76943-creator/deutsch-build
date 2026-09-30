import sys
from pathlib import Path

from tools.automation.local_integrator import apply_next, verify_tree


def _git(repo: Path, *args: str) -> str:
    import subprocess
    result = subprocess.run(["git", *args], cwd=repo, check=True, capture_output=True, text=True)
    return result.stdout.strip()


def _write(repo: Path, path: str, content: str) -> None:
    target = repo / path
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(content, encoding="utf-8")


def _commit(repo: Path, message: str) -> str:
    _git(repo, "add", ".")
    _git(repo, "commit", "-m", message)
    return _git(repo, "rev-parse", "HEAD")


def _repo(tmp_path: Path) -> tuple[Path, str]:
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-b", "main")
    _git(repo, "config", "user.email", "integrator-tests@example.invalid")
    _git(repo, "config", "user.name", "Integrator Tests")
    _write(repo, "README.md", "base\n")
    base = _commit(repo, "base")
    return repo, base


def test_clean_sequential_integration_uses_topological_order(tmp_path):
    repo, base = _repo(tmp_path)

    _git(repo, "checkout", "-b", "candidate-a", base)
    _write(repo, "tools/automation/a.py", "A = 1\n")
    candidate_a = _commit(repo, "candidate a")

    _git(repo, "checkout", "main")
    _git(repo, "checkout", "-b", "candidate-b", base)
    _write(repo, "tools/automation/b.py", "B = 1\n")
    _commit(repo, "candidate b")
    _git(repo, "checkout", "main")

    kwargs = dict(
        repo=repo,
        backlog={"tasks": []},
        dependencies={1: frozenset(), 2: frozenset({1})},
        pr_branches={1: "candidate-a", 2: "candidate-b"},
        gatekeeper_command=(sys.executable, "-c", "raise SystemExit(0)"),
    )

    first = apply_next(**kwargs)
    assert first["status"] == "INTEGRATED"
    assert first["pr_number"] == 1
    assert first["merge_mode"] == "fast-forward"
    assert _git(repo, "rev-parse", "HEAD") == candidate_a
    assert (repo / "tools/automation/a.py").exists()

    second = apply_next(**kwargs)
    assert second["status"] == "INTEGRATED"
    assert second["pr_number"] == 2
    assert second["merge_mode"] == "merge"
    assert (repo / "tools/automation/a.py").exists()
    assert (repo / "tools/automation/b.py").exists()
    assert verify_tree(repo)["clean"] is True


def test_gatekeeper_failure_restores_original_head_and_tree(tmp_path):
    repo, base = _repo(tmp_path)
    _git(repo, "checkout", "-b", "candidate-regression", base)
    _write(repo, "tools/automation/regression.py", "BROKEN = True\n")
    _commit(repo, "regression")
    _git(repo, "checkout", "main")

    before_tree = _git(repo, "rev-parse", "HEAD^{tree}")
    result = apply_next(
        repo=repo,
        backlog={"tasks": []},
        dependencies={1: frozenset()},
        pr_branches={1: "candidate-regression"},
        gatekeeper_command=(sys.executable, "-c", "raise SystemExit(7)"),
    )

    assert result["status"] == "ROLLED_BACK_GATE_FAILURE"
    assert result["gatekeeper_exit_code"] == 7
    assert result["rolled_back"] is True
    assert _git(repo, "rev-parse", "HEAD") == base
    assert _git(repo, "rev-parse", "HEAD^{tree}") == before_tree
    assert not (repo / "tools/automation/regression.py").exists()
    assert _git(repo, "status", "--porcelain") == ""
