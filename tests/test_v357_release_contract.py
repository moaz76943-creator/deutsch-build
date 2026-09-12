from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v357_release_contract_declares_bulk_apply_pipeline():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android' / 'app' / 'build.gradle').read_text(encoding='utf-8')
    tool = (ROOT / 'tool' / 'content_ingestion.py').read_text(encoding='utf-8')
    docs = (ROOT / 'docs' / 'V357_BULK_APPLY_PIPELINE.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
    assert 'apply-batch' in tool
    assert 'content_compiler.py' in docs
