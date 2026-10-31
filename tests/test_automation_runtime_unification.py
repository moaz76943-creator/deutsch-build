from pathlib import Path

from tools.automation import runtime


def test_runtime_is_single_cli_router(monkeypatch):
    calls = []

    monkeypatch.setattr(runtime.dispatcher, "main", lambda argv=None: calls.append(("planner", argv)) or 11)
    monkeypatch.setattr(runtime.autonomous_daemon, "main", lambda argv=None: calls.append(("dispatch", argv)) or 12)
    monkeypatch.setattr(runtime.state_manager, "main", lambda argv=None: calls.append(("state", argv)) or 13)

    assert runtime.main(["planner", "--json"]) == 11
    assert runtime.main(["dispatch", "--dry-run"]) == 12
    assert runtime.main(["state", "validate"]) == 13
    assert calls == [
        ("planner", ["--json"]),
        ("dispatch", ["--dry-run"]),
        ("state", ["validate"]),
    ]


def test_pipeline_invokes_only_the_canonical_runtime_entrypoint():
    root = Path(__file__).resolve().parents[1]
    source = (root / "tools" / "automation" / "run_pipeline.py").read_text(encoding="utf-8")

    assert 'self.runtime = self.automation_dir / "runtime.py"' in source
    assert 'self.state_manager = self.automation_dir / "state_manager.py"' not in source
    assert 'self.daemon = self.automation_dir / "autonomous_daemon.py"' not in source
    assert '["state", "--state", str(self.state_file), "validate"]' in source
    assert '"dispatch",' in source
