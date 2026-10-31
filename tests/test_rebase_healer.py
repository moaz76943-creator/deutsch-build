import json
import subprocess
from pathlib import Path


from tools.automation.rebase_healer import _main, simulate_integration


def _git(repo: Path, *args: str, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=repo,
        check=check,
        capture_output=True,
        text=True,
    )
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
    _git(repo, "config", "user.email", "tests@example.invalid")
    _git(repo, "config", "user.name", "Preflight Tests")
    _write(repo, "lib/core/search/search.dart", "base dart\n")
    _write(repo, "tools/automation/worker.py", "BASE = 1\n")
    base = _commit(repo, "base")
    return repo, base


def test_clean_merge_across_independent_dart_and_python_domains(tmp_path):
    repo, base = _repo(tmp_path)

    _write(repo, "lib/core/search/search.dart", "base dart\ntarget change\n")
    target = _commit(repo, "target dart change")

    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    _write(repo, "tools/automation/worker.py", "BASE = 1\nCANDIDATE = 2\n")
    _commit(repo, "candidate python change")

    status_before = _git(repo, "status", "--porcelain")
    report = simulate_integration(
        repo=repo,
        candidate_ref="tools/rebase-healer",
        target_ref=f"main@{target[:8]}",
        boundaries=("tools/automation/**",),
    )
    status_after = _git(repo, "status", "--porcelain")

    assert report["status"] == "CLEAN"
    assert report["collisions"] == []
    assert report["hard_conflicts"] == []
    assert report["outside_boundaries"] == []
    assert status_after == status_before == ""


def test_same_file_collision_is_reported_precisely_as_hard_conflict(tmp_path):
    repo, base = _repo(tmp_path)
    path = "tools/automation/worker.py"

    _write(repo, path, "VALUE = 'target'\n")
    target = _commit(repo, "target collision")

    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    _write(repo, path, "VALUE = 'candidate'\n")
    _commit(repo, "candidate collision")

    report = simulate_integration(
        repo=repo,
        candidate_ref="tools/rebase-healer",
        target_ref=target,
        boundaries=("tools/automation/**",),
    )

    assert report["status"] == "HARD_CONFLICT"
    assert report["collisions"] == [path]
    assert report["hard_conflicts"] == [path]
    assert report["exit_code"] == 1


def test_same_file_non_overlapping_edits_are_auto_resolvable(tmp_path):
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-b", "main")
    _git(repo, "config", "user.email", "tests@example.invalid")
    _git(repo, "config", "user.name", "Preflight Tests")
    path = "tools/automation/worker.py"
    _write(repo, path, "\n".join(f"line_{i}" for i in range(30)) + "\n")
    base = _commit(repo, "base")

    lines = (repo / path).read_text(encoding="utf-8").splitlines()
    lines[2] = "target_edit"
    _write(repo, path, "\n".join(lines) + "\n")
    target = _commit(repo, "target edit")

    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    lines = (repo / path).read_text(encoding="utf-8").splitlines()
    lines[25] = "candidate_edit"
    _write(repo, path, "\n".join(lines) + "\n")
    _commit(repo, "candidate edit")

    report = simulate_integration(
        repo=repo,
        candidate_ref="tools/rebase-healer",
        target_ref=target,
        boundaries=("tools/automation/**",),
    )

    assert report["status"] == "AUTO_RESOLVABLE"
    assert report["collisions"] == [path]
    assert report["hard_conflicts"] == []
    assert report["exit_code"] == 0


def test_outside_declared_boundary_is_a_hard_failure(tmp_path):
    repo, base = _repo(tmp_path)
    target = _git(repo, "rev-parse", "HEAD")

    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    _write(repo, "lib/core/search/unauthorized.dart", "not allowed\n")
    _commit(repo, "outside boundary")

    report = simulate_integration(
        repo=repo,
        candidate_ref="tools/rebase-healer",
        target_ref=target,
        boundaries=("tools/automation/**", "tests/test_rebase_healer.py"),
    )

    assert report["status"] == "HARD_CONFLICT"
    assert report["outside_boundaries"] == ["lib/core/search/unauthorized.dart"]
    assert report["exit_code"] == 1


def test_schema_property_removal_is_reported_as_regression(tmp_path):
    repo = tmp_path / "repo"
    repo.mkdir()
    _git(repo, "init", "-b", "main")
    _git(repo, "config", "user.email", "tests@example.invalid")
    _git(repo, "config", "user.name", "Preflight Tests")
    schema = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "type": "object",
        "required": ["task_id", "owner"],
        "properties": {
            "task_id": {"type": "string"},
            "owner": {"type": "string"},
        },
    }
    _write(repo, "tools/automation/task_schema.json", json.dumps(schema, indent=2) + "\n")
    base = _commit(repo, "base schema")
    target = base

    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    schema["required"].remove("owner")
    schema["properties"].pop("owner")
    _write(repo, "tools/automation/task_schema.json", json.dumps(schema, indent=2) + "\n")
    _commit(repo, "regress schema")

    report = simulate_integration(
        repo=repo,
        candidate_ref="tools/rebase-healer",
        target_ref=target,
        boundaries=("tools/automation/**",),
    )

    assert report["status"] == "HARD_CONFLICT"
    assert report["schema_regressions"] == [
        "tools/automation/task_schema.json: removed properties [owner]",
        "tools/automation/task_schema.json: removed required fields [owner]",
    ]
    assert report["exit_code"] == 1


def test_cli_writes_structured_report_and_returns_expected_exit_code(tmp_path):
    repo, base = _repo(tmp_path)
    _git(repo, "checkout", "-b", "tools/rebase-healer", base)
    _write(repo, "tools/automation/new_tool.py", "OK = True\n")
    _commit(repo, "candidate")

    report_dir = tmp_path / "reports"
    exit_code = _main(
        [
            "--repo",
            str(repo),
            "--candidate",
            "tools/rebase-healer",
            "--target",
            base,
            "--boundary",
            "tools/automation/**",
            "--report-dir",
            str(report_dir),
        ]
    )

    report_path = report_dir / "integration_preflight_tools_rebase-healer.json"
    payload = json.loads(report_path.read_text(encoding="utf-8"))
    assert exit_code == 0
    assert payload["status"] == "CLEAN"
    assert payload["candidate"]["declared_ref"] == "tools/rebase-healer"
