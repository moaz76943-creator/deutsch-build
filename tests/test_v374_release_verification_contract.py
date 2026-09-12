from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_fast_and_release_scripts_exist_and_have_distinct_modes():
    fast = (ROOT / 'scripts/check-fast.sh').read_text()
    release = (ROOT / 'scripts/check-release.sh').read_text()
    assert 'tool/verify.py fast' in fast
    for required in ('pytest', 'security_audit.py', 'quality_audit.py', 'architecture_audit.py', 'privacy_audit.py', 'accessibility_audit.py', 'weakness_gate.py', 'content_compiler.py'):
        assert required in release
    assert 'tool/verify.py release' in release

def test_report_contract_mentions_skipped_checks():
    source = (ROOT / 'tool/verify.py').read_text()
    for field in ('changed', 'selected', 'skipped', 'passed', 'failed', 'security', 'content', 'compiler', 'warnings'):
        assert field in source


def test_v374_release_version_contract():
    pubspec = (ROOT / 'pubspec.yaml').read_text()
    gradle = (ROOT / 'android/app/build.gradle').read_text()
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
