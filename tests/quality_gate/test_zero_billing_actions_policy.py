"""Repository contract for zero-additional-billing GitHub Actions.

Every active workflow is classified exactly once. Automatic hosted-runner jobs
must be explicitly opt-in before runner allocation, except bounded essential
staging/security checks. Pull-request-target jobs
must keep privileged execution on trusted/base code and treat PR content as data.
"""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
WORKFLOWS = ROOT / ".github" / "workflows"

A_MANUAL_RELEASE = "A"
B_MANUAL_UTILITY = "B"
C_SELF_HOSTED = "C"
D_AUTOMATIC_OPT_IN = "D"
E_RETIRED_HISTORICAL = "E"
F_BUDGETED_SELF_CHECK = "F"
G_ESSENTIAL_SECURITY = "G"

WORKFLOW_CLASSIFICATION = {
    "agents_pulse.yml": D_AUTOMATIC_OPT_IN,
    "ai_collaboration_bridge.yml": D_AUTOMATIC_OPT_IN,
    "android_target_guard.yml": D_AUTOMATIC_OPT_IN,
    "app_size_guard.yml": D_AUTOMATIC_OPT_IN,
    "architectural_memory_sync.yml": D_AUTOMATIC_OPT_IN,
    "auto-merge.yml": D_AUTOMATIC_OPT_IN,
    "auto-rebase.yml": D_AUTOMATIC_OPT_IN,
    "auto_multilingual_builder.yml": B_MANUAL_UTILITY,
    "auto_release_tagger.yml": D_AUTOMATIC_OPT_IN,
    "autonomous_arbiter_gate.yml": D_AUTOMATIC_OPT_IN,
    "build.yml": B_MANUAL_UTILITY,
    "build_aab.yml": A_MANUAL_RELEASE,
    "build_apk.yml": A_MANUAL_RELEASE,
    "cleanup_old_artifacts.yml": D_AUTOMATIC_OPT_IN,
    "content_expansion_bot.yml": D_AUTOMATIC_OPT_IN,
    "elastic-worker-factory.yml": B_MANUAL_UTILITY,
    "hermes-relay.yml": B_MANUAL_UTILITY,
    "language_registry_guard.yml": F_BUDGETED_SELF_CHECK,
    "local_release.yml": C_SELF_HOSTED,
    "performance_guard.yml": D_AUTOMATIC_OPT_IN,
    "polyglot_ci.yml": D_AUTOMATIC_OPT_IN,
    "pr_architectural_guard.yml": D_AUTOMATIC_OPT_IN,
    "privacy_policy_health_check.yml": D_AUTOMATIC_OPT_IN,
    "project-record-engineering-ci.yml": D_AUTOMATIC_OPT_IN,
    "project-record-recovery.yml": D_AUTOMATIC_OPT_IN,
    "project-record-sync.yml": D_AUTOMATIC_OPT_IN,
    "quality_gate_ci.yml": B_MANUAL_UTILITY,
    "recovery-checkpoint.yml": D_AUTOMATIC_OPT_IN,
    "security_audit.yml": G_ESSENTIAL_SECURITY,
    "staging_self_check.yml": F_BUDGETED_SELF_CHECK,
    "smart_triage_labeler.yml": D_AUTOMATIC_OPT_IN,
    "sync_store_metadata.yml": B_MANUAL_UTILITY,
    "trigger_signed_build.yml": D_AUTOMATIC_OPT_IN,
    "weekly_maintenance.yml": D_AUTOMATIC_OPT_IN,
    "worker_release_apk.yml": A_MANUAL_RELEASE,
}

AUTO_ONLY = (
    "ai_collaboration_bridge.yml",
    "app_size_guard.yml",
    "architectural_memory_sync.yml",
    "auto-merge.yml",
    "autonomous_arbiter_gate.yml",
    "performance_guard.yml",
    "pr_architectural_guard.yml",
    "project-record-engineering-ci.yml",
    "project-record-recovery.yml",
    "smart_triage_labeler.yml",
)

AUTO_AND_MANUAL = (
    "agents_pulse.yml",
    "android_target_guard.yml",
    "auto-rebase.yml",
    "cleanup_old_artifacts.yml",
    "content_expansion_bot.yml",
    "privacy_policy_health_check.yml",
    "project-record-sync.yml",
    "recovery-checkpoint.yml",
    "weekly_maintenance.yml",
)

RELEASE_AUTOMATION = (
    "auto_release_tagger.yml",
    "trigger_signed_build.yml",
)

PR_TARGET = {
    "ai_collaboration_bridge.yml",
    "auto-merge.yml",
    "auto_release_tagger.yml",
    "pr_architectural_guard.yml",
    "smart_triage_labeler.yml",
    "trigger_signed_build.yml",
}

OPT_IN = "vars.GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED == 'true'"
RELEASE_OPT_IN = "vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED == 'true'"


def _text(name: str) -> str:
    return (WORKFLOWS / name).read_text(encoding="utf-8")


def _active_workflows() -> set[str]:
    return {
        path.name
        for path in WORKFLOWS.glob("*.y*ml")
        if not path.name.endswith(".disabled")
    }


def _run_blocks(text: str) -> str:
    lines = text.splitlines()
    blocks = []
    index = 0
    while index < len(lines):
        line = lines[index]
        stripped = line.lstrip()
        if stripped == "run: |":
            indent = len(line) - len(stripped)
            index += 1
            block = []
            while index < len(lines):
                candidate = lines[index]
                if candidate.strip() and len(candidate) - len(candidate.lstrip()) <= indent:
                    break
                block.append(candidate)
                index += 1
            blocks.extend(block)
            continue
        index += 1
    return "\n".join(blocks)


def test_active_workflow_inventory_is_classified_exactly_once():
    active = _active_workflows()
    assert active == set(WORKFLOW_CLASSIFICATION), (
        f"unclassified={sorted(active - set(WORKFLOW_CLASSIFICATION))}; "
        f"stale={sorted(set(WORKFLOW_CLASSIFICATION) - active)}"
    )
    assert set(WORKFLOW_CLASSIFICATION.values()) <= {
        A_MANUAL_RELEASE,
        B_MANUAL_UTILITY,
        C_SELF_HOSTED,
        D_AUTOMATIC_OPT_IN,
        E_RETIRED_HISTORICAL,
        F_BUDGETED_SELF_CHECK,
        G_ESSENTIAL_SECURITY,
    }


def test_manual_release_and_utility_workflows_are_explicit_only():
    for name, category in WORKFLOW_CLASSIFICATION.items():
        if category not in {A_MANUAL_RELEASE, B_MANUAL_UTILITY}:
            continue
        text = _text(name)
        assert "workflow_dispatch:" in text, name
        for automatic in (
            "\n  push:",
            "\n  pull_request:",
            "\n  pull_request_target:",
            "\n  schedule:",
            "\n  workflow_run:",
        ):
            assert automatic not in text, (
                f"{name}: unexpected automatic trigger {automatic.strip()}"
            )


def test_self_hosted_workflows_never_default_to_github_hosted_compute():
    for name, category in WORKFLOW_CLASSIFICATION.items():
        if category != C_SELF_HOSTED:
            continue
        text = _text(name)
        assert "runs-on: [self-hosted" in text, name
        assert "runs-on: ubuntu-latest" not in text, name


def test_automatic_hosted_workflows_are_opt_in_before_runner_allocation():
    for name in AUTO_ONLY:
        text = _text(name)
        assert "runs-on: ubuntu-latest" in text, name
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


def test_special_automation_keeps_local_gate_in_addition_to_central_policy():
    agents = _text("agents_pulse.yml")
    assert "vars.AGENTS_PULSE_ENABLED == 'true'" in agents
    assert "vars.AGENTS_PULSE_ZERO_COST_APPROVED == 'true'" in agents
    assert OPT_IN in agents

    memory = _text("architectural_memory_sync.yml")
    assert "vars.ARCHITECTURE_LEDGER_SYNC_ENABLED == 'true'" in memory
    assert "vars.ARCHITECTURE_LEDGER_BILLING_APPROVED == 'true'" in memory
    assert OPT_IN in memory


def test_sensitive_release_automation_has_separate_explicit_opt_in():
    for name in RELEASE_AUTOMATION:
        text = _text(name)
        assert RELEASE_OPT_IN in text, name
        jobs = text.split("\njobs:\n", 1)[1]
        assert jobs.index(RELEASE_OPT_IN) < jobs.index("runs-on: ubuntu-latest"), name


def test_pull_request_target_inventory_and_privileged_context_are_fail_closed():
    detected = {
        name
        for name in _active_workflows()
        if "pull_request_target:" in _text(name)
    }
    assert detected == PR_TARGET

    for name in sorted(PR_TARGET):
        text = _text(name)
        jobs = text.split("\njobs:\n", 1)[1]
        gate = RELEASE_OPT_IN if name in RELEASE_AUTOMATION else OPT_IN
        assert gate in jobs, name
        assert jobs.index(gate) < jobs.index("runs-on: ubuntu-latest"), name

        # PR-head files may be fetched as inert API data, but privileged jobs
        # must never check out or execute the PR-head revision.
        assert "ref: ${{ github.event.pull_request.head" not in text, name
        assert "ref: ${{ github.head_ref" not in text, name

        # Untrusted title/body values must not be interpolated into shell source.
        run_source = _run_blocks(text)
        assert "${{ github.event.pull_request.title" not in run_source, name
        assert "${{ github.event.pull_request.body" not in run_source, name

        assert "actions: write" not in text, name
        assert "checks: write" not in text, name
        assert "id-token: write" not in text, name

    auto_release = _text("auto_release_tagger.yml")
    assert "ref: main" in auto_release
    assert "contents: write" in auto_release

    ai_bridge = _text("ai_collaboration_bridge.yml")
    assert "ref: ${{ github.event.pull_request.base.sha }}" in ai_bridge
    assert ai_bridge.index("Validate trusted actor") < ai_bridge.index(
        "Validate provider secrets"
    )
    for association in ("OWNER", "MEMBER", "COLLABORATOR"):
        assert association in ai_bridge

    trigger = _text("trigger_signed_build.yml")
    assert "uses: actions/checkout@" not in trigger
    assert "github.event.pull_request.merged == true" in trigger


def test_budgeted_staging_self_check_fits_private_minutes():
    text = _text("staging_self_check.yml")
    assert "pull_request:" in text
    assert "staging/v2-full-platform" in text
    assert "cancel-in-progress: true" in text
    assert "timeout-minutes: 20" in text
    assert "paths:" in text
    assert "\n  schedule:" not in text
    assert "\n  push:" not in text
    assert "macos" not in text
    assert "ubuntu-latest" in text
    assert "source toolchain.lock" in text
    assert "dart analyze lib/" in text
    assert "flutter test --reporter compact" in text
    assert "targetSdk 36" in text
    assert OPT_IN not in text
    assert text.index("flutter test --reporter compact") < text.index("gh pr merge")
