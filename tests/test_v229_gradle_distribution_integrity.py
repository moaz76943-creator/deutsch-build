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


def test_properties_reject_merge_conflict_that_overrides_distribution_url(tmp_path):
    module = _module()
    props = tmp_path / 'gradle-wrapper.properties'
    lock = ROOT / 'toolchain.lock'
    props.write_text(
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-8.14.5-all.zip\n'
        'distributionSha256Sum=62c3769155d7d17ea05084ad498067824c1804568a408a6faa78a5ef95ed67a8\n'
        '=======\n'
        'distributionUrl=https://services.gradle.org/distributions/gradle-8.13-bin.zip\n'
        '>>>>>>> origin/other\n',
        encoding='utf-8',
    )
    ok, message = module.verify_distribution_properties(props, lock)
    assert not ok
    assert 'merge conflict markers' in message


def test_properties_reject_duplicate_distribution_url(tmp_path):
    module = _module()
    props = tmp_path / 'gradle-wrapper.properties'
    lock = ROOT / 'toolchain.lock'
    props.write_text(
        'distributionUrl=https\\://services.gradle.org/distributions/gradle-8.14.5-all.zip\n'
        'distributionSha256Sum=62c3769155d7d17ea05084ad498067824c1804568a408a6faa78a5ef95ed67a8\n'
        'distributionUrl=https://services.gradle.org/distributions/gradle-8.13-bin.zip\n',
        encoding='utf-8',
    )
    ok, message = module.verify_distribution_properties(props, lock)
    assert not ok
    assert 'exactly one distributionUrl' in message


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
