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
