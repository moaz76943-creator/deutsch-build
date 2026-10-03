from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_fast_and_release_scripts_exist_and_have_distinct_modes():
    fast = (ROOT / 'scripts/check-fast.sh').read_text()
    release = (ROOT / 'scripts/check-release.sh').read_text()
    assert 'tool/verify.py fast' in fast
    assert 'scripts/local_quality_gate.sh' in release
    assert 'tool/verify.py release' in release


def test_canonical_local_quality_gate_owns_branch_verification():
    gate = (ROOT / 'scripts/local_quality_gate.sh').read_text()
    for required in (
        'python3 -m pytest -q tests',
        'tool/gradle_wrapper_integrity.py',
        'tool/v233_build_path_compatibility.py',
        'tool/security_audit.py',
        'tool/privacy_audit.py',
        'tool/quality_audit.py',
        'tool/accessibility_audit.py',
        'tool/architecture_audit.py',
        'tool/weakness_gate.py',
        'tool/content_compiler.py',
        'flutter pub get --enforce-lockfile',
        'flutter analyze',
        'flutter test',
    ):
        assert required in gate
    assert 'flutter build apk' not in gate
    assert 'flutter build appbundle' not in gate


def test_ci_calls_single_quality_gate_and_unsafe_pr_automation_is_removed():
    assert not (ROOT / '.github/workflows/auto-approve-and-fix.yml').exists()
    assert not (ROOT / '.github/workflows/auto_merge.yml').exists()

    guarded = (ROOT / '.github/workflows/auto-merge.yml').read_text()
    assert "github.event.pull_request.draft == false" in guarded
    assert "github.event.pull_request.head.repo.full_name == github.repository" in guarded
    assert "contains(github.event.pull_request.labels.*.name, 'automerge')" in guarded

    for workflow in (
        '.github/workflows/engineering-ci.yml',
        '.github/workflows/quality.yml',
        '.github/workflows/build-apk.yml',
    ):
        text = (ROOT / workflow).read_text()
        assert 'scripts/local_quality_gate.sh' in text
        assert 'dart fix --apply' not in text
        assert 'dart format .' not in text
        assert 'git-auto-commit-action' not in text
        assert 'gh pr review' not in text


def test_pr_ci_checks_out_exact_head_and_preserves_required_context_names():
    engineering = (ROOT / '.github/workflows/engineering-ci.yml').read_text()
    quality = (ROOT / '.github/workflows/quality.yml').read_text()
    exact_head = "ref: ${{ github.event.pull_request.head.sha }}"
    assert engineering.count(exact_head) == 2
    assert quality.count(exact_head) == 1
    assert "if: github.event_name == 'pull_request'" in engineering
    assert "if: github.event_name != 'pull_request'" in engineering
    assert "if: github.event_name == 'pull_request'" in quality
    assert "if: github.event_name != 'pull_request'" in quality
    assert 'name: Python engineering gates' in engineering
    assert 'name: Flutter Android readiness' in engineering
    assert 'flutter build apk --debug --target-platform android-arm64' in engineering
    assert 'flutter build apk --release' not in engineering


def test_report_contract_mentions_skipped_checks():
    source = (ROOT / 'tool/verify.py').read_text()
    for field in (
        'changed',
        'selected',
        'skipped',
        'passed',
        'failed',
        'security',
        'content',
        'compiler',
        'warnings',
    ):
        assert field in source


def test_v374_release_version_contract():
    pubspec = (ROOT / 'pubspec.yaml').read_text()
    gradle = (ROOT / 'android/app/build.gradle').read_text()
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle

# Exact-head CI trigger for GREEN-CI-LIQUIDATION-20261003.
# Reverification trigger after CI safety workflows were removed from main.\n