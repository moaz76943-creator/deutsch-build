from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_gradle_wrapper_integrity_gate_is_wired_everywhere():
    lock = (ROOT / 'toolchain.lock').read_text(encoding='utf-8')
    ci = (ROOT / '.github' / 'workflows' / 'build-apk.yml').read_text(encoding='utf-8')
    guard = (ROOT / 'scripts' / 'build_guard.sh').read_text(encoding='utf-8')
    security = (ROOT / 'tool' / 'security_audit.py').read_text(encoding='utf-8')
    assert 'GRADLE_WRAPPER_JAR_SHA256=' in lock
    assert 'python3 tool/gradle_wrapper_integrity.py' in ci
    assert 'gradle_wrapper_integrity.py' in guard
    assert 'gradle_wrapper_integrity.py' in security


def test_release_ci_does_not_mutate_or_generate_wrapper_files():
    ci = (ROOT / '.github' / 'workflows' / 'build-apk.yml').read_text(encoding='utf-8')
    assert 'gradle wrapper --gradle-version "$GRADLE_VERSION"' not in ci
    assert 'cp android/gradlew "$RUNNER_TEMP/gradlew.before"' not in ci
    assert 'cp "$RUNNER_TEMP/gradlew.before" android/gradlew' not in ci


def test_wrapper_checksum_is_immutable_sha256_literal():
    lock = (ROOT / 'toolchain.lock').read_text(encoding='utf-8')
    import re
    match = re.search(r'^GRADLE_WRAPPER_JAR_SHA256=([0-9a-f]{64})$', lock, re.M)
    assert match, 'toolchain must pin the Gradle wrapper JAR with a full SHA-256'


def test_integrity_function_accepts_matching_temp_wrapper(tmp_path):
    import hashlib
    import importlib.util
    spec = importlib.util.spec_from_file_location('gradle_wrapper_integrity', ROOT / 'tool' / 'gradle_wrapper_integrity.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    verify_wrapper = module.verify_wrapper

    payload = b'known-wrapper-payload'
    (tmp_path / 'android/gradle/wrapper').mkdir(parents=True)
    (tmp_path / 'android/gradle/wrapper/gradle-wrapper.jar').write_bytes(payload)
    digest = hashlib.sha256(payload).hexdigest()
    (tmp_path / 'toolchain.lock').write_text(
        f'GRADLE_WRAPPER_JAR_SHA256={digest}\n', encoding='utf-8'
    )
    ok, message = verify_wrapper(tmp_path)
    assert ok
    assert digest in message


def test_integrity_function_rejects_tampered_wrapper(tmp_path):
    import importlib.util
    spec = importlib.util.spec_from_file_location('gradle_wrapper_integrity', ROOT / 'tool' / 'gradle_wrapper_integrity.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    verify_wrapper = module.verify_wrapper

    (tmp_path / 'android/gradle/wrapper').mkdir(parents=True)
    (tmp_path / 'android/gradle/wrapper/gradle-wrapper.jar').write_bytes(b'tampered')
    (tmp_path / 'toolchain.lock').write_text(
        'GRADLE_WRAPPER_JAR_SHA256=' + '0' * 64 + '\n', encoding='utf-8'
    )
    ok, message = verify_wrapper(tmp_path)
    assert not ok
    assert 'SHA-256 mismatch' in message
