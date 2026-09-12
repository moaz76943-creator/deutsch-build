from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v361_release_contract_declares_review_only_quality_gate():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    tool = (ROOT / 'tool/content_quality_gate.py').read_text(encoding='utf-8')
    docs = (ROOT / 'docs/V361_CONTENT_QUALITY_GATE.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
    assert 'def review_batch' in tool
    assert 'review_only' in docs
    assert 'sentence/sentenceAr' in docs
