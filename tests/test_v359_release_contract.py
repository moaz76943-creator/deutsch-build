from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v359_release_contract_declares_atomic_audio_content_publication():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android' / 'app' / 'build.gradle').read_text(encoding='utf-8')
    tool = (ROOT / 'tool' / 'content_ingestion.py').read_text(encoding='utf-8')
    docs = (ROOT / 'docs' / 'V359_AUDIO_CONTENT_PUBLICATION.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert "versionName " in gradle
    assert 'publish-batch' in tool
    assert 'atomically publish' in tool
    assert 'batch.json' in docs
