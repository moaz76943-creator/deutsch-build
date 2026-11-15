"""CLI security contracts: truthful exit codes, redaction, safe path and literal handling."""
from __future__ import annotations

import importlib.util
from pathlib import Path
import subprocess
import sys

import pytest

ROOT = Path(__file__).resolve().parents[1]
CLI_PATH = ROOT / "tool" / "polyglot_cli.py"

SPEC = importlib.util.spec_from_file_location("polyglot_cli", CLI_PATH)
CLI = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CLI)


def test_security_scan_exits_nonzero_when_findings_exist(monkeypatch, capsys, tmp_path):
    """A finding must never be reported with a success exit code."""
    leak = tmp_path / "leak.txt"
    leak.write_text("token=ghp_" + "a" * 36 + "\n", encoding="utf-8")
    monkeypatch.setattr(CLI, "ROOT", tmp_path)

    code = CLI.cmd_security_scan(gitleaks=None)

    assert code == 1
    output = capsys.readouterr().out
    # The location is actionable; the secret value must never be echoed.
    assert "leak.txt" in output
    assert "a" * 36 not in output


def test_security_scan_is_clean_for_a_clean_tree(monkeypatch, tmp_path, capsys):
    (tmp_path / "app.dart").write_text("const appName = 'deutsch';\n", encoding="utf-8")
    monkeypatch.setattr(CLI, "ROOT", tmp_path)

    assert CLI.cmd_security_scan(gitleaks=None) == 0
    assert "[OK]" in capsys.readouterr().out


def test_security_scan_prefers_the_maintained_scanner(monkeypatch, tmp_path):
    """The weak pattern list is a fallback, not the primary detector."""
    calls = {}

    def fake_run(command, **kwargs):
        calls["command"] = command
        return subprocess.CompletedProcess(
            command,
            0,
            stdout='{"status": "NO_FINDINGS_IN_FETCHED_HISTORY", "findings": []}',
            stderr="",
        )

    monkeypatch.setattr(subprocess, "run", fake_run)
    assert CLI.cmd_security_scan(gitleaks="/usr/local/bin/gitleaks") == 0
    assert str(ROOT / "tool" / "git_secret_audit.py") in " ".join(calls["command"])


def test_security_scan_propagates_incomplete_audits(monkeypatch):
    def fake_run(command, **kwargs):
        return subprocess.CompletedProcess(command, 2, stdout="", stderr="boom")

    monkeypatch.setattr(subprocess, "run", fake_run)
    assert CLI.cmd_security_scan(gitleaks="/usr/local/bin/gitleaks") == 2


@pytest.mark.parametrize(
    "module_id",
    ["../../etc/passwd", "/abs/module", "a/b", "Module", "", "x" * 65, "de-DE", "de DE"],
)
def test_module_identifier_rejects_traversal_and_absolute_paths(module_id):
    with pytest.raises(ValueError):
        CLI.validate_module_identifier(module_id)


def test_module_identifier_accepts_flat_snake_case():
    assert CLI.validate_module_identifier("daily_drill") == "daily_drill"


@pytest.mark.parametrize("lang", ["de", "pt-BR", "zh-Hant-TW", "../de", "de/../x", ""])
def test_language_code_validation(lang):
    try:
        result = CLI.validate_language_code(lang)
    except ValueError:
        assert ".." in lang or "/" in lang or lang == ""
        return
    assert result == lang


def test_resolved_module_path_stays_inside_the_owned_directory():
    resolved = CLI.resolve_module_path("daily_drill")
    owned = (ROOT / "lib/src/core/polyglot/modules").resolve()
    assert resolved.parent == owned
    assert resolved.name == "daily_drill.dart"


@pytest.mark.parametrize(
    "raw,expected",
    [
        ("plain", "'plain'"),
        ("it's", "'it\\'s'"),
        (r"back\slash", "'back\\\\slash'"),
        ("price $amount", "'price \\$amount'"),
        ("line\nbreak", "'line\\nbreak'"),
        ("tab\tstop", "'tab\\tstop'"),
    ],
)
def test_dart_string_literal_encodes_interpolation_and_escapes(raw, expected):
    assert CLI.dart_string_literal(raw) == expected


def test_add_module_uses_encoded_literals_and_refuses_overwrite(monkeypatch, tmp_path):
    monkeypatch.setattr(CLI, "ROOT", tmp_path)
    title = 'a $b \'c\' \\ d'
    assert CLI.cmd_add_module("daily_drill", "de", title) == 0

    written = (tmp_path / "lib/src/core/polyglot/modules/daily_drill.dart").read_text(encoding="utf-8")
    # Interpolation and quote escaping must survive into generated Dart.
    assert "\\$b" in written
    assert "\\'c\\'" in written
    assert "\\\\ d" in written

    with pytest.raises(ValueError):
        CLI.cmd_add_module("daily_drill", "de", "again")


def test_cli_entry_point_returns_failure_for_safe_but_invalid_input():
    result = subprocess.run(
        [sys.executable, str(CLI_PATH), "add-module", "--id", "../escape", "--title", "x"],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 1
    assert "[FAIL]" in result.stdout
