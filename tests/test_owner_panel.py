import json
import re
import subprocess
from pathlib import Path

import pytest

from tools.dashboard.owner_panel import (
    LANES, REPOSITORY, INTEGRATION_BRANCH, SnapshotError,
    collect_snapshot, render, validate_snapshot, write_atomic,
)

SHA = "2" * 40


def fake_api(path):
    if "/git/ref/" in path:
        return {"object": {"sha": SHA}}
    if "/pulls?" in path:
        return [{"number": 53, "title": '<img src=x onerror=alert(1)>', "draft": True,
                 "base": {"ref": INTEGRATION_BRANCH}}]
    if "/actions/runs" in path:
        return {"workflow_runs": [{"id": 42, "name": "CI", "status": "completed", "conclusion": "skipped"}]}
    if "/actions/workflows" in path:
        return {"workflows": [{"id": 77, "name": "Unit checks", "state": "active"}]}
    raise AssertionError(path)


def test_live_snapshot_renders_escaped_content_and_pr_links():
    report = collect_snapshot(fake_api)
    page = render(report)
    assert len(LANES) >= 20
    assert "&lt;img src=x onerror=alert(1)&gt;" in page
    assert '<img src=x onerror=alert(1)>' not in page
    assert 'href="https://github.com/moaz76943-creator/deutsch-build/pull/53"' in page
    assert "skipped" in page
    assert "DRAFT" in page
    assert SHA[:12] in page
    assert "المسارات التقنية (20)" in page


def test_failed_api_does_not_fake_zero_or_success():
    def offline(_):
        raise SnapshotError("disconnected")
    report = collect_snapshot(offline)
    page = render(report)
    assert all(item["status"] == "UNAVAILABLE" for item in report["observations"].values())
    assert "UNAVAILABLE" in page
    assert "لا تعتبرها صفرًا" in page


def test_invalid_identity_rejected():
    report = collect_snapshot(fake_api)
    report["repository"] = "attacker/public"
    with pytest.raises(SnapshotError):
        render(report)
    report["repository"] = REPOSITORY
    report["branch"] = "main"
    with pytest.raises(SnapshotError):
        validate_snapshot(report)


def test_invalid_head_does_not_forge_live_sha():
    def no_head(path):
        if "/git/ref/" in path:
            return {"object": {"sha": "not a sha"}}
        return fake_api(path)
    report = collect_snapshot(no_head)
    assert report["observations"]["head"]["status"] == "UNAVAILABLE"
    assert "UNAVAILABLE" in render(report)


def test_atomic_output_and_secure_mode(tmp_path):
    dest = tmp_path / "private" / "owner.html"
    write_atomic(dest, "first")
    write_atomic(dest, "second")
    assert dest.read_text() == "second"
    assert dest.stat().st_mode & 0o777 == 0o600


def test_gh_error_is_redacted(monkeypatch):
    from tools.dashboard.owner_panel import github_api
    def raise_error(*args, **kwargs):
        raise subprocess.CalledProcessError(1, args[0], stderr="secret-token")
    monkeypatch.setattr(subprocess, "run", raise_error)
    with pytest.raises(SnapshotError) as err:
        github_api("/repos/owner/repo")
    assert "secret-token" not in str(err.value)
