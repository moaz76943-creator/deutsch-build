"""Canonical security gate for the current production/release topology."""
from __future__ import annotations

import base64
import re
import subprocess

from security_topology import (
    ANDROID_NS,
    ROOT,
    active_workflows,
    assert_active_build_delivery_boundaries,
    effective_permissions,
    extract_braced_block,
    granted_manifest_permissions,
    manifest_permissions,
    manifest_root,
)

MAIN_MANIFEST = ROOT / "android/app/src/main/AndroidManifest.xml"
RELEASE_MANIFEST = ROOT / "android/app/src/release/AndroidManifest.xml"
MAIN_ACTIVITY = ROOT / "android/app/src/main/kotlin/com/deutschbilarabi/app/MainActivity.kt"
PRONUNCIATION_PROBE = ROOT / "android/app/src/main/kotlin/com/deutschbilarabi/app/AndroidPronunciationSignalProbe.kt"
GRADLE = ROOT / "android/app/build.gradle"
SIGNING_GRADLE = ROOT / "android/release-signing.gradle"
A_MANUAL_RELEASE = "A"
B_MANUAL_UTILITY = "B"
C_SELF_HOSTED = "C"
D_AUTOMATIC_OPT_IN = "D"

WORKFLOW_CLASS = {
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
    "local_release.yml": C_SELF_HOSTED,
    "performance_guard.yml": D_AUTOMATIC_OPT_IN,
    "pr_architectural_guard.yml": D_AUTOMATIC_OPT_IN,
    "privacy_policy_health_check.yml": D_AUTOMATIC_OPT_IN,
    "project-record-engineering-ci.yml": D_AUTOMATIC_OPT_IN,
    "project-record-recovery.yml": D_AUTOMATIC_OPT_IN,
    "project-record-sync.yml": D_AUTOMATIC_OPT_IN,
    "quality_gate_ci.yml": B_MANUAL_UTILITY,
    "recovery-checkpoint.yml": D_AUTOMATIC_OPT_IN,
    "security_audit.yml": "G",
    "staging_self_check.yml": "F",
    "smart_triage_labeler.yml": D_AUTOMATIC_OPT_IN,
    "sync_store_metadata.yml": B_MANUAL_UTILITY,
    "trigger_signed_build.yml": D_AUTOMATIC_OPT_IN,
    "weekly_maintenance.yml": D_AUTOMATIC_OPT_IN,
    "worker_release_apk.yml": A_MANUAL_RELEASE,
}

AUTOMATIC_TRIGGERS = {
    "push",
    "pull_request",
    "pull_request_target",
    "schedule",
    "workflow_run",
    "issues",
    "issue_comment",
    "pull_request_review",
}
RELEASE_AUTOMATION = {"auto_release_tagger.yml", "trigger_signed_build.yml"}
NONESSENTIAL_OPT_IN = "vars.GITHUB_ACTIONS_NONESSENTIAL_AUTOMATION_ENABLED == 'true'"
RELEASE_OPT_IN = "vars.GITHUB_ACTIONS_RELEASE_AUTOMATION_ENABLED == 'true'"
PR_TARGET = {
    "ai_collaboration_bridge.yml",
    "auto-merge.yml",
    "auto_release_tagger.yml",
    "pr_architectural_guard.yml",
    "smart_triage_labeler.yml",
    "trigger_signed_build.yml",
}
PR_TARGET_PERMISSION_CEILING = {
    "ai_collaboration_bridge.yml": {
        "contents": "read",
        "issues": "write",
        "pull-requests": "write",
    },
    # Guarded auto-merge needs contents:write to squash-merge an approved PR
    # and actions:read to verify exact-head/base run receipts. It is safe under
    # pull_request_target because the trusted job performs no checkout and
    # reads no untrusted-head source (asserted below).
    "auto-merge.yml": {
        "contents": "write",
        "pull-requests": "write",
        "actions": "read",
    },
    "auto_release_tagger.yml": {
        "contents": "write",
        "pull-requests": "read",
        "actions": "none",
        "checks": "none",
        "id-token": "none",
    },
    "pr_architectural_guard.yml": {
        "contents": "read",
        "actions": "none",
        "checks": "none",
        "id-token": "none",
        "issues": "write",
        "pull-requests": "read",
    },
    "smart_triage_labeler.yml": {
        "contents": "read",
        "pull-requests": "write",
        "issues": "write",
    },
    "trigger_signed_build.yml": {
        "contents": "read",
        "checks": "read",
        "pull-requests": "read",
        "actions": "none",
        "id-token": "none",
    },
}
PERMISSION_RANK = {"none": 0, "read": 1, "write": 2}
HOSTED_RUNNERS = ("ubuntu-", "windows-", "macos-")


def test_android_manifest_and_root_window_are_fail_closed():
    main_permissions = manifest_permissions(MAIN_MANIFEST)
    release_permissions = manifest_permissions(RELEASE_MANIFEST)

    granted = granted_manifest_permissions(MAIN_MANIFEST)
    assert granted == {"android.permission.RECORD_AUDIO"}
    assert "android.permission.INTERNET" not in granted
    assert "android.permission.POST_NOTIFICATIONS" not in granted
    assert "android.permission.INTERNET" not in granted_manifest_permissions(RELEASE_MANIFEST)

    notification_node = release_permissions.get("android.permission.POST_NOTIFICATIONS")
    if notification_node is not None:
        assert notification_node == "remove"

    application = manifest_root(MAIN_MANIFEST).find("application")
    assert application is not None
    assert application.attrib[f"{{{ANDROID_NS}}}allowBackup"] == "false"
    assert application.attrib[f"{{{ANDROID_NS}}}usesCleartextTraffic"] == "false"

    activity = MAIN_ACTIVITY.read_text(encoding="utf-8")
    on_create = extract_braced_block(activity, "override fun onCreate")
    assert "window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)" in on_create


def test_record_audio_permission_has_a_single_local_pronunciation_justification():
    probe = PRONUNCIATION_PROBE.read_text(encoding="utf-8")
    activity = MAIN_ACTIVITY.read_text(encoding="utf-8")

    request = extract_braced_block(probe, "private fun requestPermission")
    capture = extract_braced_block(probe, "private fun captureFeatures")
    assert "arrayOf(Manifest.permission.RECORD_AUDIO)" in request
    assert "AudioRecord(" in capture
    assert "MediaRecorder.AudioSource.VOICE_RECOGNITION" in capture
    assert "Manifest.permission.RECORD_AUDIO" in probe
    assert "PackageManager.PERMISSION_GRANTED" in probe
    assert "AndroidPronunciationSignalProbe.CHANNEL_NAME" in activity

    forbidden_probe_imports = ("package:http/", "java.net.", "okhttp")
    assert not any(value in probe for value in forbidden_probe_imports)


def test_tracked_source_contains_no_signing_key_material_or_literal_credentials():
    proc = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        capture_output=True,
        check=True,
    )
    tracked = [
        ROOT / raw.decode("utf-8")
        for raw in proc.stdout.split(b"\0")
        if raw
    ]

    forbidden_extensions = {".jks", ".keystore", ".p12", ".pfx"}
    forbidden_files = [
        path.relative_to(ROOT).as_posix()
        for path in tracked
        if path.suffix.lower() in forbidden_extensions
    ]
    assert not forbidden_files, forbidden_files

    private_key_markers = []
    private_key_pattern = re.compile(
        r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----"
    )
    for path in tracked:
        if not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            continue
        if private_key_pattern.search(text):
            private_key_markers.append(path.relative_to(ROOT).as_posix())
    assert not private_key_markers, private_key_markers

    credential_names = (
        "releaseStorePassword",
        "releaseKeyPassword",
        "RELEASE_STORE_PASSWORD",
        "RELEASE_KEY_PASSWORD",
        "ANDROID_KEYSTORE_PASSWORD",
        "ANDROID_KEY_PASSWORD",
        "CM_KEYSTORE_PASSWORD",
        "CM_KEY_PASSWORD",
        "OPENAI_API_KEY",
        "GEMINI_API_KEY",
        "CODEMAGIC_API_TOKEN",
        "TELEGRAM_BOT_TOKEN",
        "GOOGLE_PLAY_SERVICE_ACCOUNT_JSON",
        "RELEASE_KEYSTORE_BASE64",
        "ANDROID_KEYSTORE_BASE64",
        "CM_KEYSTORE_BASE64",
    )
    # Shell parameter expansion such as \${TOKEN:?Missing TOKEN} is a
    # runtime reference, not an assignment. Exclude only that syntax while
    # retaining literal assignment detection everywhere else.
    credential_alternation = "|".join(map(re.escape, credential_names))
    assignment = re.compile(
        r"(?<!\$\{)\b(" + credential_alternation + r")\b"
        r"\s*[:=]\s*(?:['\"]([^'\"]+)['\"]|([^\s#]+))"
    )
    excluded_roots = ("assets/", "content/", "docs/", "tests/")
    source_suffixes = {
        ".dart", ".gradle", ".json", ".kt", ".kts", ".properties",
        ".py", ".sh", ".toml", ".yaml", ".yml",
    }
    offenders: list[str] = []
    encoded_keystores: list[str] = []

    for path in tracked:
        rel = path.relative_to(ROOT).as_posix()
        if (
            rel.startswith(excluded_roots)
            or path.suffix.lower() not in source_suffixes
            or not path.is_file()
        ):
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for number, line in enumerate(text.splitlines(), 1):
            match = assignment.search(line)
            if match:
                value = (match.group(2) or match.group(3) or "").strip().rstrip(",")
                dynamic = (
                    not value
                    or value in {"null", "None", "''", '""'}
                    or "$" in value
                    or value.startswith(("System.", "os.", "config[", "result["))
                )
                if not dynamic:
                    offenders.append(f"{rel}:{number}:{match.group(1)}")
        for blob in re.findall(
            r"(?<![A-Za-z0-9+/])[A-Za-z0-9+/]{1368,}={0,2}(?![A-Za-z0-9+/])",
            text,
        ):
            try:
                decoded = base64.b64decode(blob, validate=True)
            except Exception:
                continue
            if len(decoded) >= 1024:
                encoded_keystores.append(rel)

    assert not offenders, offenders
    assert not encoded_keystores, encoded_keystores


def test_release_signing_is_mandatory_and_worker_materialization_is_ephemeral():
    gradle = GRADLE.read_text(encoding="utf-8")
    signing = SIGNING_GRADLE.read_text(encoding="utf-8")

    fail_closed = extract_braced_block(
        gradle,
        "if (releaseTaskRequested && !hasReleaseSigning)",
    )
    release_block = extract_braced_block(gradle, "release {")
    secure_block = extract_braced_block(gradle, "secureRelease {")

    assert "throw new GradleException" in fail_closed
    assert "releaseStoreFile" in fail_closed
    assert "releaseStorePassword" in fail_closed
    assert "releaseKeyAlias" in fail_closed
    assert "releaseKeyPassword" in fail_closed
    assert "signingConfig signingConfigs.secureRelease" in release_block
    assert "signingConfigs.debug" not in gradle
    assert "if (hasReleaseSigning)" in secure_block
    assert "releaseStorePassword: null" in signing
    assert "releaseKeyPassword: null" in signing

    worker = active_workflows()["worker_release_apk.yml"]
    signing_step = next(
        step
        for job in worker.jobs
        for step in job.steps
        if step.name == "Configure release signing"
    )
    assert "prepare_release_signing --ephemeral" in signing_step.run
    assert "runner.temp" in signing_step.raw
    assert "~/.gradle" not in signing_step.raw
    assert "gradle.properties" not in signing_step.raw


def test_all_active_workflows_obey_current_zero_billing_and_supply_chain_policy():
    assert_active_build_delivery_boundaries()
    workflows = active_workflows()
    assert set(workflows) == set(WORKFLOW_CLASS)
    assert len(workflows) == 32

    for name, workflow in workflows.items():
        category = WORKFLOW_CLASS[name]
        automatic = bool(workflow.triggers & AUTOMATIC_TRIGGERS)

        if category in {A_MANUAL_RELEASE, B_MANUAL_UTILITY}:
            assert "workflow_dispatch" in workflow.triggers, name
            assert not automatic, name

        if category == C_SELF_HOSTED:
            assert workflow.jobs, name
            for job in workflow.jobs:
                assert "self-hosted" in job.runs_on, f"{name}/{job.key}"
                assert not any(host in job.runs_on for host in HOSTED_RUNNERS), name

        if category == D_AUTOMATIC_OPT_IN:
            gate = RELEASE_OPT_IN if name in RELEASE_AUTOMATION else NONESSENTIAL_OPT_IN
            if not automatic:
                assert workflow.triggers <= {"workflow_dispatch"}, name
            for job in workflow.jobs:
                if any(host in job.runs_on for host in HOSTED_RUNNERS):
                    assert gate in job.condition, f"{name}/{job.key}"

        for ref in workflow.action_refs:
            if ref.startswith("./"):
                continue
            assert "@" in ref, f"{name}: {ref}"
            target = ref.rsplit("@", 1)[1]
            assert re.fullmatch(r"[0-9a-f]{40}", target), f"{name}: {ref}"


def test_pull_request_target_workflows_never_execute_untrusted_head_and_use_least_privilege():
    workflows = active_workflows()
    detected = {
        name for name, workflow in workflows.items()
        if "pull_request_target" in workflow.triggers
    }
    assert detected == PR_TARGET

    for name in sorted(PR_TARGET):
        workflow = workflows[name]
        ceiling = PR_TARGET_PERMISSION_CEILING[name]
        for job in workflow.jobs:
            if any(host in job.runs_on for host in HOSTED_RUNNERS):
                gate = RELEASE_OPT_IN if name in RELEASE_AUTOMATION else NONESSENTIAL_OPT_IN
                assert gate in job.condition, f"{name}/{job.key}"

            permissions = effective_permissions(workflow, job)
            assert permissions, f"{name}/{job.key}: explicit permissions required"
            for scope, level in permissions.items():
                assert scope in ceiling, f"{name}/{job.key}: unexpected permission {scope}"
                assert level in PERMISSION_RANK, f"{name}/{job.key}:{scope}"
                assert PERMISSION_RANK[level] <= PERMISSION_RANK[ceiling[scope]], (
                    f"{name}/{job.key}:{scope} exceeds {ceiling[scope]}"
                )

            for step in job.steps:
                if step.uses and step.uses.startswith("actions/checkout@"):
                    ref = step.with_values.get("ref", "")
                    assert "pull_request.head" not in ref, f"{name}/{step.name}"
                    assert "github.head_ref" not in ref, f"{name}/{step.name}"
                assert "${{ github.event.pull_request.title" not in step.run, name
                assert "${{ github.event.pull_request.body" not in step.run, name

        custom_secret_steps = [
            (job, index, step)
            for job in workflow.jobs
            for index, step in enumerate(job.steps)
            if "secrets." in step.raw and "secrets.GITHUB_TOKEN" not in step.raw
        ]
        for job, index, step in custom_secret_steps:
            if "github.event.pull_request.merged == true" in job.condition:
                continue
            earlier_names = {candidate.name for candidate in job.steps[:index]}
            assert "Validate trusted actor" in earlier_names, (
                f"{name}/{step.name}: custom secret available before trust validation"
            )


def test_auto_merge_merjob_never_executes_repository_code_when_writing_contents():
    workflow = active_workflows()["auto-merge.yml"]
    assert "pull_request_target" in workflow.triggers
    text = workflow.path.read_text(encoding="utf-8")
    # contents:write is only used by the guarded squash merge; the trusted
    # pull_request_target context must not materialize any repository source.
    assert "actions/checkout" not in text
    merge_steps = [
        step
        for job in workflow.jobs
        for step in job.steps
        if "gh pr merge" in step.run
    ]
    assert merge_steps, "squash merge step missing"
    for step in merge_steps:
        run = step.run
        assert "--squash" in run
        assert "gh pr merge --merge" not in run
        if "--match-head-commit" in run:
            assert "gh pr merge --auto" not in run
        else:
            # Legacy guarded auto-merge: GitHub itself serializes behind
            # required checks via --auto against branch protection.
            assert "gh pr merge --auto --squash" in run
    # Elevated merge receipts (new guarded version) are asserted when present.
    if "reviewDecision" in text:
        assert "runs?head_sha=" in text
        assert "security_audit.yml" in text
        assert "staging_self_check.yml" in text
        assert "--match-head-commit" in text


def test_legacy_security_audit_is_only_a_compatibility_notice():
    text = (ROOT / "tool/security_audit.py").read_text(encoding="utf-8")
    assert "HISTORICAL / NON-CANONICAL" in text
    assert "test_current_topology_security_gate.py" in text
    assert "checks=[" not in text


def test_worker_release_signing_credentials_remain_step_scoped_and_ephemeral():
    worker = active_workflows()["worker_release_apk.yml"]
    configure_step = next(
        step
        for job in worker.jobs
        for step in job.steps
        if step.name == "Configure release signing"
    )
    build_step = next(
        step
        for job in worker.jobs
        for step in job.steps
        if step.name == "Build signed ARM64 release APK"
    )
    verify_step = next(
        step
        for job in worker.jobs
        for step in job.steps
        if step.name == "Verify release artifact"
    )

    assert "prepare_release_signing --ephemeral" in configure_step.run
    assert "bash scripts/signing_guard.sh --ephemeral" in build_step.run
    assert "-Dorg.gradle.daemon=false" in build_step.raw
    assert 'bash scripts/apk_verify.sh "$APK" release --ephemeral' in verify_step.run

    password_names = (
        "ORG_GRADLE_PROJECT_releaseStorePassword",
        "ORG_GRADLE_PROJECT_releaseKeyPassword",
    )
    for job in worker.jobs:
        for step in job.steps:
            if "$GITHUB_ENV" not in step.run:
                continue
            for line in step.run.splitlines():
                if "$GITHUB_ENV" in line:
                    assert not any(name in line for name in password_names)
