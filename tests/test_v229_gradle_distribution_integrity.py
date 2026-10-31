from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _module():
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        'gradle_wrapper_integrity', ROOT / 'tool' / 'gradle_wrapper_integrity.py'
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_properties_pin_expected_locked_gradle_distribution():
    module = _module()
    props = ROOT / 'android' / 'gradle' / 'wrapper' / 'gradle-wrapper.properties'
    ok, message = module.verify_distribution_properties(props, ROOT / 'toolchain.lock')
    assert ok, message


def test_properties_reject_unpinned_or_wrong_distribution(tmp_path):
    module = _module()
    props = tmp_path / 'gradle-wrapper.properties'
    lock = tmp_path / 'toolchain.lock'
    lock.write_text(
        'GRADLE_VERSION=8.13\n'
        'GRADLE_DISTRIBUTION_SHA256=' + 'a' * 64 + '\n', encoding='utf-8'
    )
    props.write_text(
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-8.13-all.zip\n'
        'distributionSha256Sum=' + 'b' * 64 + '\n', encoding='utf-8'
    )
    ok, message = module.verify_distribution_properties(props, lock)
    assert not ok
    assert 'distributionSha256Sum mismatch' in message
