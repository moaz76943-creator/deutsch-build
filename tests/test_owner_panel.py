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
    assert "المسارات التقنية (30)" in page


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


def test_untrusted_api_rows_never_claim_a_false_zero():
    def malformed(path):
        if "/pulls?" in path:
            return [{"title": "missing PR number"}]
        if "/actions/runs" in path:
            return {"workflow_runs": [{"id": "not-an-id", "name": "bad"}]}
        if "/actions/workflows" in path:
            return {"workflows": [{"id": None, "name": "bad"}]}
        return fake_api(path)

    snapshot = collect_snapshot(malformed)
    for key in ("pulls", "runs", "workflows"):
        assert snapshot["observations"][key]["status"] == "UNAVAILABLE"
    assert "لا تعتبرها صفرًا" in render(snapshot)


def test_page_limited_workflow_counts_are_not_exact_totals():
    def capped(path):
        if "/actions/runs" in path:
            return {"workflow_runs": [{"id": i, "name": "CI"} for i in range(1, 101)]}
        if "/actions/workflows" in path:
            return {"workflows": [{"id": i, "name": "CI"} for i in range(1, 101)]}
        return fake_api(path)

    snapshot = collect_snapshot(capped)
    assert snapshot["observations"]["runs"]["truncated"] is True
    assert snapshot["observations"]["workflows"]["truncated"] is True
    assert render(snapshot).count("100+") >= 2


def test_offline_snapshot_cannot_label_invalid_head_as_live():
    snapshot = collect_snapshot(fake_api)
    snapshot["observations"]["head"]["items"] = {"sha": "invalid"}
    with pytest.raises(SnapshotError):
        render(snapshot)


def test_pr_inventory_reads_all_pages_and_retains_exact_head():
    calls = []
    def paginated(path):
        calls.append(path)
        if '/pulls?' in path:
            page = int(path.split('page=')[-1])
            if page == 1:
                return [{'number': i, 'head': {'sha': SHA}, 'base': {'ref': INTEGRATION_BRANCH}}
                        for i in range(1, 101)]
            return [{'number': 101, 'head': {'sha': '3' * 40}, 'base': {'ref': 'main'}}]
        return fake_api(path)
    report = collect_snapshot(paginated)
    pulls = report['observations']['pulls']
    assert len(pulls['items']) == 101
    assert pulls['truncated'] is False
    assert pulls['items'][-1]['head_sha'] == '3' * 40
    assert any('page=2' in p for p in calls)
    assert 'WRONG_BASE' in render(report)


def test_offline_cli_relabels_saved_live_observations_as_cached(tmp_path):
    source = tmp_path / 'snapshot.json'
    source.write_text(json.dumps(collect_snapshot(fake_api)))
    dest = tmp_path / 'owner.html'
    subprocess.run(['python', 'tools/dashboard/owner_panel.py', '--snapshot', str(source),
                    '--output', str(dest)], check=True)
    page = dest.read_text()
    assert 'CACHED' in page
    assert 'data-observation="LIVE"' not in page
    assert 'data-observation="CACHED"' in page


def test_snapshot_has_capture_time():
    from datetime import datetime
    snapshot = collect_snapshot(fake_api)
    captured = datetime.fromisoformat(snapshot['captured_at'].replace('Z', '+00:00'))
    assert captured.tzinfo is not None
    assert snapshot['captured_at'] in render(snapshot)
