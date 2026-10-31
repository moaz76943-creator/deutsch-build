from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v362_release_contract_declares_canonical_duplicate_gate():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    tool = (ROOT / 'tool/content_quality_gate.py').read_text(encoding='utf-8')
    ingestion = (ROOT / 'tool/content_ingestion.py').read_text(encoding='utf-8')
    docs = (ROOT / 'docs/V362_CANONICAL_DUPLICATE_GATE.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
    assert 'def _normalize_german' in tool
    assert 'existing_content_path=content_path' in ingestion
    assert 'review-only' in docs
