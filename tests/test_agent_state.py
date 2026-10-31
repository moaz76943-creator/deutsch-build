from __future__ import annotations

import json
import multiprocessing
from pathlib import Path

import pytest

from tools.automation.state_manager import (
    StateLedgerError,
    load_state,
    main,
    read_task,
    update_task,
    validate_state,
)


def _ledger(*tasks: dict) -> dict:
    return {"schema_version": 1, "tasks": list(tasks)}


def _task(task_id: str, *, dependencies: list[str] | None = None) -> dict:
    return {
        "task_id": task_id,
        "status": "PENDING",
        "branch": f"feature/{task_id.lower()}",
        "commit_sha": "",
        "test_count": 0,
        "dependent_tasks": dependencies or [],
    }


def _write(path: Path, value: dict) -> None:
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def _concurrent_update(path: str, task_id: str, sha: str, test_count: int) -> None:
    update_task(Path(path), task_id, "IN_PROGRESS", sha, test_count)


def test_validate_accepts_required_state_shape_and_seed_file():
    root = Path(__file__).resolve().parents[1]
    seed = load_state(root / "tools" / "automation" / "pipeline_state.json")

    validate_state(seed)
    assert seed["schema_version"] == 1
    assert seed["tasks"]
    for task in seed["tasks"]:
        assert set(task) == {
            "task_id",
            "status",
            "branch",
            "commit_sha",
            "test_count",
            "dependent_tasks",
        }


def test_validate_rejects_dangling_dependency_and_cycle():
    dangling = _ledger(_task("A", dependencies=["MISSING"]))
    with pytest.raises(StateLedgerError, match="dangling dependency"):
        validate_state(dangling)

    cyclic = _ledger(
        _task("A", dependencies=["B"]),
        _task("B", dependencies=["A"]),
    )
    with pytest.raises(StateLedgerError, match="dependency cycle"):
        validate_state(cyclic)


def test_update_records_monotonic_progress_and_valid_transitions(tmp_path: Path):
    path = tmp_path / "state.json"
    _write(path, _ledger(_task("A")))

    active = update_task(path, "A", "IN_PROGRESS", "a" * 40, 3)
    assert active["status"] == "IN_PROGRESS"
    assert active["commit_sha"] == "a" * 40
    assert active["test_count"] == 3

    completed = update_task(path, "A", "COMPLETED", "b" * 40, 8)
    assert completed["status"] == "COMPLETED"
    assert completed["commit_sha"] == "b" * 40
    assert completed["test_count"] == 8

    persisted = load_state(path)
    assert persisted["tasks"][0] == completed


def test_gated_task_can_resume_but_completed_task_cannot_regress(tmp_path: Path):
    path = tmp_path / "state.json"
    _write(path, _ledger(_task("A"), _task("B")))

    update_task(path, "A", "GATED", "a" * 40, 1)
    resumed = update_task(path, "A", "IN_PROGRESS", "b" * 40, 2)
    assert resumed["status"] == "IN_PROGRESS"

    update_task(path, "B", "IN_PROGRESS", "c" * 40, 1)
    update_task(path, "B", "COMPLETED", "d" * 40, 2)
    with pytest.raises(StateLedgerError, match="invalid transition"):
        update_task(path, "B", "IN_PROGRESS", "e" * 40, 3)


def test_update_rejects_unknown_task_status_sha_and_test_regression(tmp_path: Path):
    path = tmp_path / "state.json"
    _write(path, _ledger(_task("A")))

    with pytest.raises(StateLedgerError, match="unknown task"):
        update_task(path, "NOPE", "IN_PROGRESS", "a" * 40, 1)
    with pytest.raises(StateLedgerError, match="invalid status"):
        update_task(path, "A", "DONE", "a" * 40, 1)
    with pytest.raises(StateLedgerError, match="commit sha"):
        update_task(path, "A", "IN_PROGRESS", "not-a-sha", 1)
    with pytest.raises(StateLedgerError, match="test count"):
        update_task(path, "A", "IN_PROGRESS", "a" * 40, -1)

    update_task(path, "A", "IN_PROGRESS", "a" * 40, 5)
    with pytest.raises(StateLedgerError, match="cannot decrease"):
        update_task(path, "A", "IN_PROGRESS", "b" * 40, 4)


def test_read_returns_task_state_and_prerequisite_snapshots(tmp_path: Path):
    path = tmp_path / "state.json"
    prerequisite = _task("A")
    prerequisite.update(status="COMPLETED", commit_sha="a" * 40, test_count=5)
    _write(path, _ledger(prerequisite, _task("B", dependencies=["A"])))

    result = read_task(path, "B")
    assert result["task"]["task_id"] == "B"
    assert result["task"]["dependent_tasks"] == ["A"]
    assert result["prerequisites"] == [prerequisite]


def test_concurrent_process_updates_are_serialized_without_lost_writes(tmp_path: Path):
    path = tmp_path / "state.json"
    tasks = [_task(f"T{i}") for i in range(8)]
    _write(path, _ledger(*tasks))

    context = multiprocessing.get_context("spawn")
    processes = [
        context.Process(
            target=_concurrent_update,
            args=(str(path), f"T{i}", f"{i + 1:040x}", i + 1),
        )
        for i in range(8)
    ]
    for process in processes:
        process.start()
    for process in processes:
        process.join(timeout=10)
        assert process.exitcode == 0

    final = load_state(path)
    validate_state(final)
    by_id = {task["task_id"]: task for task in final["tasks"]}
    assert all(by_id[f"T{i}"]["status"] == "IN_PROGRESS" for i in range(8))
    assert [by_id[f"T{i}"]["test_count"] for i in range(8)] == list(range(1, 9))


def test_cli_update_read_and_validate_emit_machine_readable_json(tmp_path: Path, capsys):
    path = tmp_path / "state.json"
    _write(path, _ledger(_task("A")))

    assert main(["--state", str(path), "update", "--task-id", "A", "--status", "IN_PROGRESS", "--sha", "a" * 40, "--tests", "4"]) == 0
    update_payload = json.loads(capsys.readouterr().out)
    assert update_payload["task_id"] == "A"
    assert update_payload["status"] == "IN_PROGRESS"

    assert main(["--state", str(path), "read", "--task-id", "A"]) == 0
    read_payload = json.loads(capsys.readouterr().out)
    assert read_payload["task"]["task_id"] == "A"
    assert read_payload["prerequisites"] == []

    assert main(["--state", str(path), "validate"]) == 0
    validate_payload = json.loads(capsys.readouterr().out)
    assert validate_payload == {"valid": True, "task_count": 1}
