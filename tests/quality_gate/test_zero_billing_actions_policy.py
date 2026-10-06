"""Repository contract for zero-additional-billing GitHub Actions.

Automatic hosted-runner workflows must be explicitly opt-in before runner
allocation. Workflows that also support workflow_dispatch must remain manually
usable without enabling global automatic automation.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"

AUTO_ONLY = (
    "app_size_guard.yml",
    "auto-merge.yml",
    "autonomous_arbiter_gate.yml",
    "performance_guard.yml",
    "project-record-engineering-ci.yml",
    "project-record-recovery.yml",
    "security_audit.yml",
)

AUTO_AND_MANUAL = (
    "android_target_guard.yml",
    "auto-rebase.yml",
    "cleanup_old_artifacts.yml",
    "content_expansion_bot.yml",
    "privacy_policy_health_check.yml",
    "project-record-sync.yml",
    "recovery-checkpoint.yml",
    "weekly_maintenance.yml",
)

OPT_IN = "vars.GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED == 'true'"


def _text(name: str) -> str:
    return (WORKFLOWS / name).read_text(encoding="utf-8")


def test_automatic_hosted_workflows_are_opt_in_before_runner_allocation():
    for name in AUTO_ONLY:
        text = _text(name)
        assert "runs-on: ubuntu-latest" in text
        jobs = text.split("\njobs:\n", 1)[1]
        assert OPT_IN in jobs, name
        assert jobs.index(OPT_IN) < jobs.index("runs-on: ubuntu-latest"), name


def test_scheduled_or_push_workflows_keep_manual_execution_without_auto_billing():
    for name in AUTO_AND_MANUAL:
        text = _text(name)
        assert "workflow_dispatch:" in text, name
        jobs = text.split("\njobs:\n", 1)[1]
        assert "github.event_name == 'workflow_dispatch'" in jobs, name
        assert OPT_IN in jobs, name
        assert jobs.index(OPT_IN) < jobs.index("runs-on: ubuntu-latest"), name


def test_sensitive_release_automation_has_separate_explicit_opt_in():
    for name in ("auto_release_tagger.yml", "trigger_signed_build.yml"):
        text = _text(name)
        assert "vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED == 'true'" in text
        jobs = text.split("\njobs:\n", 1)[1]
        assert jobs.index("vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED") < jobs.index("runs-on: ubuntu-latest")
