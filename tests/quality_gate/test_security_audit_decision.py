"""Security audit must execute and reject any failed or skipped security stage."""
import os
import subprocess
import sys
import textwrap

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


def policy(tmp_path, source, lock='packages:\n'):
    workflow = active_workflows()['security_audit.yml']
    text = workflow.path.read_text()
    script = textwrap.dedent(text.split("python3 - <<'PY'\n", 1)[1].split('\n          PY', 1)[0])
    (tmp_path / 'lib').mkdir(exist_ok=True)
    (tmp_path / 'lib/example.dart').write_text(source)
    (tmp_path / 'pubspec.lock').write_text(lock)
    return subprocess.run([sys.executable, '-c', script], cwd=tmp_path,
                          capture_output=True, text=True,
                          env={**os.environ, 'GITHUB_STEP_SUMMARY': str(tmp_path / 'summary')})


def test_audio_amplitude_and_adjust_comments_are_not_tracking_sdks(tmp_path):
    result = policy(tmp_path, '// Adjust waveform envelope. Amplitude micro-perturbation.\n'
                    'final amplitude = 0.25;\n')
    assert result.returncode == 0, result.stdout + result.stderr


@pytest.mark.parametrize('source', [
    "import 'package:amplitude_flutter/amplitude.dart';",
    'Amplitude.getInstance().logEvent(event);',
    'final analytics = Amplitude(config);',
    "import 'package:adjust_sdk/adjust.dart';",
    'Adjust.start(config);',
    'Adjust.initSdk(config);',
    "import 'package:http/http.dart';",
    'final client = HttpClient();',
])
def test_real_tracking_and_network_capabilities_still_block(tmp_path, source):
    assert policy(tmp_path, source).returncode != 0


def test_tracking_dependency_stays_blocking_without_source_reference(tmp_path):
    lock = 'packages:\n  amplitude_flutter:\n    dependency: "direct main"\n'
    assert policy(tmp_path, '', lock).returncode != 0


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
