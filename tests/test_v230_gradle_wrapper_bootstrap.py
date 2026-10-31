from pathlib import Path
import hashlib
import importlib.util

ROOT = Path(__file__).resolve().parents[1]


def _module():
    spec = importlib.util.spec_from_file_location(
        'gradle_wrapper_bootstrap', ROOT / 'tool' / 'gradle_wrapper_bootstrap.py'
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def test_bootstrap_rejects_wrong_digest_without_writing(tmp_path):
    module = _module()
    target = tmp_path / 'gradle-wrapper.jar'
    payload = b'official-wrapper-payload'
    wrong_sha = '0' * 64
    ok, message = module.write_verified_wrapper(target, payload, wrong_sha)
    assert not ok
    assert 'SHA-256 mismatch' in message
    assert not target.exists()


def test_bootstrap_writes_only_matching_digest(tmp_path):
    module = _module()
    target = tmp_path / 'gradle-wrapper.jar'
    payload = b'official-wrapper-payload'
    digest = hashlib.sha256(payload).hexdigest()
    ok, message = module.write_verified_wrapper(target, payload, digest)
    assert ok
    assert digest in message
    assert target.read_bytes() == payload


def test_bootstrap_metadata_is_pinned_to_official_gradle_source():
    module = _module()
    assert module.WRAPPER_URL == 'https://raw.githubusercontent.com/gradle/gradle/v8.13.0/gradle/wrapper/gradle-wrapper.jar'
    assert module.EXPECTED_SHA256 == '16caeaf66d57a0d1d2087fef6a97efa62de8da69afa5b908f40db35afc4342da'
