"""Security audit must execute and reject any failed or skipped security stage."""
import os
import subprocess

import pytest

from security_topology import active_workflows


def test_security_is_essential_and_checks_complete_history():
    workflow = active_workflows()["security_audit.yml"]
    assert "pull_request" in workflow.triggers
    assert "schedule" not in workflow.triggers
    assert workflow.permissions["contents"] == "read"
    assert len(workflow.jobs) == 1
    job = workflow.jobs[0]
    assert not job.condition
    assert job.runs_on == "ubuntu-latest"
    assert "timeout-minutes: 15" in job.raw
    checkout = next(s for s in job.steps if s.uses and s.uses.startswith("actions/checkout@"))
    assert checkout.with_values["fetch-depth"] == "0"
    assert checkout.with_values["persist-credentials"] == "false"
    scan = next(s for s in job.steps if "tool/git_secret_audit.py" in s.run)
    assert "sha256sum --check --status" in scan.run
    assert "--gitleaks" in scan.run


@pytest.mark.parametrize("stage", ["POLICY_OUTCOME", "OSV_OUTCOME", "SECRETS_OUTCOME"])
@pytest.mark.parametrize("outcome", ["failure", "skipped", "cancelled", ""])
def test_decision_fails_closed_for_every_incomplete_stage(tmp_path, stage, outcome):
    assert decision(tmp_path, **{stage: outcome}) != 0


def test_decision_passes_only_when_all_security_stages_succeed(tmp_path):
    assert decision(tmp_path) == 0


def decision(tmp_path, **overrides):
    workflow = active_workflows()["security_audit.yml"]
    step = next(s for s in workflow.jobs[0].steps if s.name == "Enforce security decision")
    assert "if: always()" in step.raw
    for stage in ("policy", "osv", "secrets"):
        assert "steps." + stage + ".outcome" in step.raw
    env = dict(os.environ, POLICY_OUTCOME="success", OSV_OUTCOME="success",
               SECRETS_OUTCOME="success", GITHUB_STEP_SUMMARY=str(tmp_path / "summary"))
    env.update(overrides)
    return subprocess.run(["bash", "-c", step.run], env=env, capture_output=True).returncode
