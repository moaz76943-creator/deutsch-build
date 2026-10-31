from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_release_ci_bootstraps_missing_wrapper_before_signing_secret_exposure():
    ci = (ROOT / '.github' / 'workflows' / 'build-apk.yml').read_text(encoding='utf-8')
    bootstrap = 'python3 tool/gradle_wrapper_bootstrap.py'
    signing = 'Materialize release signing material'
    assert bootstrap in ci
    assert ci.index(bootstrap) < ci.index(signing)


def test_wrapper_bootstrap_is_not_allowed_to_use_project_data_as_request_input():
    script = (ROOT / 'tool' / 'gradle_wrapper_bootstrap.py').read_text(encoding='utf-8')
    assert 'https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar' in script
    assert 'EXPECTED_SHA256' in script
    assert 'GITHUB_TOKEN' not in script
    assert 'ANDROID_STORE_PASSWORD' not in script
