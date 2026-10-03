import importlib.util
import json
from pathlib import Path

import pytest

MODULE_PATH = Path(__file__).parents[1] / "tools" / "automation" / "run_pipeline.py"
spec = importlib.util.spec_from_file_location("run_pipeline", MODULE_PATH)
module = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(module)

PipelineOrchestrator = module.PipelineOrchestrator
PipelineToolError = module.PipelineToolError
main = module.main


def _write_executable(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def _repo(tmp_path: Path, *, status: str = "PENDING") -> Path:
    root = tmp_path
    automation = root / "tools" / "automation"
    gatekeeper = root / "tools" / "gatekeeper"
    automation.mkdir(parents=True)
    gatekeeper.mkdir(parents=True)
    state = {
        "schema_version": 1,
        "tasks": [
            {
                "task_id": "TASK-1",
                "status": status,
                "branch": "feature/task-1",
                "commit_sha": "a" * 40 if status == "COMPLETED" else "",
                "test_count": 1 if status == "COMPLETED" else 0,
                "dependent_tasks": [],
            }
        ],
    }
    (automation / "pipeline_state.json").write_text(json.dumps(state), encoding="utf-8")
    (automation / "backlog.json").write_text(
        json.dumps(
            {
                "schema_version": 1,
                "tasks": [
                    {
                        "task_id": "TASK-1",
                        "status": "PENDING" if status == "PENDING" else status,
                        "branch": "feature/task-1",
                        "prerequisites": [],
                        "allowed_paths": ["lib/task/**"],
                    }
                ],
            }
        ),
        encoding="utf-8",
    )

    _write_executable(
        automation / "state_manager.py",
        '''#!/usr/bin/env python3
import argparse, json
from pathlib import Path
p=argparse.ArgumentParser(); p.add_argument("--state", type=Path); p.add_argument("command")
a=p.parse_args()
if (a.state.parent.parent.parent / "fail_state").exists(): raise SystemExit(4)
data=json.loads(a.state.read_text())
assert data.get("schema_version")==1 and isinstance(data.get("tasks"), list)
with (a.state.parent.parent.parent / "tool_calls.log").open("a") as h: h.write("state_manager validate\\n")
print(json.dumps({"valid": True, "task_count": len(data["tasks"])}))
''',
    )
    _write_executable(
        automation / "autonomous_daemon.py",
        '''#!/usr/bin/env python3
import argparse, json, os, tempfile
from pathlib import Path
p=argparse.ArgumentParser(); p.add_argument("--backlog", type=Path); p.add_argument("--state-file", type=Path); p.add_argument("--claims", type=Path); p.add_argument("--dispatch-dir", type=Path); p.add_argument("--dry-run", action="store_true"); p.add_argument("--poll-once", action="store_true")
a=p.parse_args(); root=a.state_file.parent.parent.parent
if (root / "fail_daemon").exists(): raise SystemExit(5)
state=json.loads(a.state_file.read_text()); task=next((x for x in state["tasks"] if x["status"]=="PENDING"), None)
with (root / "tool_calls.log").open("a") as h: h.write("daemon dry\\n" if a.dry_run else "daemon commit\\n")
if task is None:
    print(json.dumps({"state":"NO_CANDIDATE"})); raise SystemExit(0)
if a.dry_run:
    print(json.dumps({"state":"DRY_RUN","task_id":task["task_id"]})); raise SystemExit(0)
task["status"]="IN_PROGRESS"
fd,name=tempfile.mkstemp(dir=a.state_file.parent,prefix=".pipeline.",suffix=".tmp")
with os.fdopen(fd,"w") as h: json.dump(state,h)
os.replace(name,a.state_file)
print(json.dumps({"state":"DISPATCHED","task_id":task["task_id"]}))
''',
    )
    _write_executable(
        automation / "runtime.py",
        '''#!/usr/bin/env python3
import subprocess, sys
from pathlib import Path
component=sys.argv[1]
script={
    "state": Path(__file__).with_name("state_manager.py"),
    "dispatch": Path(__file__).with_name("autonomous_daemon.py"),
}[component]
raise SystemExit(subprocess.run([sys.executable, str(script), *sys.argv[2:]]).returncode)
''',
    )
    _write_executable(
        gatekeeper / "gatekeeper.py",
        '''#!/usr/bin/env python3
import argparse, json
from pathlib import Path
p=argparse.ArgumentParser(); p.add_argument("--repo-root", type=Path); p.add_argument("--report", type=Path); p.add_argument("--full", action="store_true")
a=p.parse_args(); root=a.repo_root.resolve()
with (root / "tool_calls.log").open("a") as h: h.write("gatekeeper full\\n")
if (root / "fail_gate").exists():
    print(json.dumps({"overall_status":"failed"})); raise SystemExit(6)
summary={"overall_status":"passed","suites":[{"name":"python","status":"passed"}]}
a.report.parent.mkdir(parents=True, exist_ok=True); a.report.write_text(json.dumps(summary))
print(json.dumps(summary))
''',
    )
    return root


def _state(root: Path):
    return json.loads((root / "tools" / "automation" / "pipeline_state.json").read_text())


def test_idle_cycle_is_idempotent_and_runs_gate(tmp_path):
    root = _repo(tmp_path, status="IN_PROGRESS")
    before = _state(root)

    first = PipelineOrchestrator(repo_root=root).cycle()
    second = PipelineOrchestrator(repo_root=root).cycle()

    assert first["state"] == "IDLE"
    assert second["state"] == "IDLE"
    assert first["gate"]["overall_status"] == "passed"
    assert _state(root) == before


def test_complete_cycle_exits_cleanly_without_mutation(tmp_path):
    root = _repo(tmp_path, status="COMPLETED")
    before = _state(root)

    result = PipelineOrchestrator(repo_root=root).cycle()

    assert result["state"] == "COMPLETE"
    assert _state(root) == before


def test_simulated_tick_gates_before_atomic_task_transition(tmp_path):
    root = _repo(tmp_path, status="PENDING")

    result = PipelineOrchestrator(repo_root=root).cycle()

    assert result["state"] == "DISPATCHED"
    assert result["task_id"] == "TASK-1"
    assert result["gate"]["overall_status"] == "passed"
    assert _state(root)["tasks"][0]["status"] == "IN_PROGRESS"
    calls = (root / "tool_calls.log").read_text().splitlines()
    assert calls == [
        "state_manager validate",
        "daemon dry",
        "gatekeeper full",
        "daemon commit",
        "state_manager validate",
    ]


@pytest.mark.parametrize("sentinel", ["fail_state", "fail_daemon", "fail_gate"])
def test_auxiliary_nonzero_is_reported_as_failure_without_unsafe_transition(tmp_path, sentinel):
    root = _repo(tmp_path, status="PENDING")
    (root / sentinel).touch()

    with pytest.raises(PipelineToolError):
        PipelineOrchestrator(repo_root=root).cycle()

    assert _state(root)["tasks"][0]["status"] == "PENDING"
    assert main(["--cycle", "--repo-root", str(root)]) == 1
