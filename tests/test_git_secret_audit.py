"""Exercise real Git history and the real Gitleaks binary when installed."""
import importlib.util
import json
from pathlib import Path
import shutil
import secrets
import string
import subprocess

import pytest

SPEC = importlib.util.spec_from_file_location(
    "git_secret_audit", Path(__file__).resolve().parents[1] / "tool/git_secret_audit.py"
)
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


def git(repo, *args):
    return subprocess.run(
        ["git", *args], cwd=repo, check=True, capture_output=True, text=True,
    ).stdout.strip()


@pytest.fixture
def repo(tmp_path):
    git(tmp_path, "init")
    git(tmp_path, "config", "user.name", "Audit fixture")
    git(tmp_path, "config", "user.email", "audit@example.invalid")
    git(tmp_path, "commit", "--allow-empty", "-m", "initial")
    return tmp_path


def test_missing_scanner_fails_closed(repo):
    code, report = AUDIT.audit(repo, str(repo / "missing-gitleaks"))
    assert code == 2
    assert report["status"] == "INCOMPLETE"


def test_shallow_clone_is_not_a_clean_audit(repo, tmp_path_factory):
    clone = tmp_path_factory.mktemp("shallow") / "repo"
    subprocess.run(
        ["git", "clone", "--depth=1", repo.as_uri(), str(clone)],
        check=True, capture_output=True,
    )
    code, report = AUDIT.audit(clone, "unused")
    assert code == 2
    assert report["status"] == "INCOMPLETE"


def test_deleted_credential_on_another_ref_is_detected_without_disclosure(repo):
    scanner = shutil.which("gitleaks")
    if not scanner:
        pytest.skip("Install Gitleaks to exercise its real history scanner")
    clean = git(repo, "rev-parse", "HEAD")
    # Synthetic scanner fixture, assembled to avoid a credential-shaped literal.
    credential = "gh" + "p_" + "".join(
        secrets.choice(string.ascii_letters + string.digits) for _ in range(36)
    )
    (repo / "removed.env").write_text("TOKEN=" + credential + " # gitleaks:allow\n")
    git(repo, "add", ".")
    git(repo, "commit", "-m", "historical credential fixture")
    leaked = git(repo, "rev-parse", "HEAD")
    git(repo, "rm", "removed.env")
    git(repo, "commit", "-m", "delete credential")
    git(repo, "branch", "historical-branch")
    git(repo, "checkout", "--detach", clean)
    (repo / ".gitleaksignore").write_text(f"{leaked}:removed.env:github-pat:1\n")
    (repo / ".gitleaks.toml").write_text('[allowlist]\npaths = [".*"]\n')
    code, report = AUDIT.audit(repo, scanner)
    assert code == 1
    assert any(f["File"] == "removed.env" and f["Commit"] == leaked
               for f in report["findings"])
    serialized = json.dumps(report)
    assert credential not in serialized
    assert "TOKEN=" not in serialized
    assert report["publication_approved"] is False


def test_clean_history_does_not_approve_publication(repo):
    scanner = shutil.which("gitleaks")
    if not scanner:
        pytest.skip("Install Gitleaks to exercise its real history scanner")
    code, report = AUDIT.audit(repo, scanner)
    assert code == 0
    assert report["finding_count"] == 0
    assert report["publication_approved"] is False



def _synthetic_scanner(repo, *, report_text=None, exit_code=0, noise=""):
    """Imitate the Gitleaks JSON contract without storing a real credential."""
    executable = repo / "synthetic-gitleaks"
    script = [
        "#!/usr/bin/env python3",
        "import pathlib, sys",
        "path = pathlib.Path(sys.argv[sys.argv.index('--report-path') + 1])",
    ]
    if report_text is not None:
        script.append(f"path.write_text({report_text!r}, encoding='utf-8')")
    if noise:
        script.extend((f"print({noise!r})", f"print({noise!r}, file=sys.stderr)"))
    script.append(f"sys.exit({exit_code})")
    executable.write_text("\n".join(script) + "\n", encoding="utf-8")
    executable.chmod(0o700)
    return str(executable)


def test_synthetic_clean_report_passes_without_approving_publication(repo):
    code, report = AUDIT.audit(repo, _synthetic_scanner(repo, report_text="[]"))
    assert code == 0
    assert report["status"] == "NO_FINDINGS_IN_FETCHED_HISTORY"
    assert report["publication_approved"] is False


def test_synthetic_secret_is_detected_and_never_printed(repo, capsys):
    marker = "SYNTHETIC_DO_NOT_DISCLOSE_FIXTURE"
    result = [{"RuleID": "generic-api-key", "File": "fixture.txt",
               "StartLine": 1, "Commit": "0" * 40, "Secret": marker}]
    scanner = _synthetic_scanner(
        repo, report_text=json.dumps(result), exit_code=10, noise=marker,
    )
    code, report = AUDIT.audit(repo, scanner)
    assert code == 1
    assert report["status"] == "FINDINGS"
    assert report["finding_count"] == 1
    assert marker not in json.dumps(report)
    assert marker not in capsys.readouterr().out
    assert "Secret" not in report["findings"][0]


@pytest.mark.parametrize("report_text,exit_code", [
    ("{bad-json", 10),
    ('{"unexpected": "object"}', 0),
    ('[{"RuleID":"x"}]', 10),
    ("[]", 10),
])
def test_malformed_or_inconsistent_scanner_report_is_incomplete(
    repo, report_text, exit_code,
):
    scanner = _synthetic_scanner(repo, report_text=report_text, exit_code=exit_code)
    code, report = AUDIT.audit(repo, scanner)
    assert code == 2
    assert report["status"] == "INCOMPLETE"
    assert "findings" not in report


def test_missing_report_is_incomplete_and_scanner_output_is_redacted(repo, capsys):
    marker = "SYNTHETIC_STDERR_SECRET_FIXTURE"
    scanner = _synthetic_scanner(repo, report_text=None, noise=marker)
    code, report = AUDIT.audit(repo, scanner)
    assert code == 2
    assert report["status"] == "INCOMPLETE"
    output = capsys.readouterr()
    assert marker not in output.out + output.err


def test_security_audit_workflow_does_not_upload_secret_reports():
    workflow = (Path(__file__).resolve().parents[1] /
                ".github/workflows/security_audit.yml").read_text(encoding="utf-8")
    assert "upload-artifact" not in workflow
    assert "--redact=100" in workflow or "tool/git_secret_audit.py" in workflow
