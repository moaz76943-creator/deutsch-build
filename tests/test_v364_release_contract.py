from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_v364_release_contract_declares_batch_diff_preview():
    pubspec = (ROOT / 'pubspec.yaml').read_text(encoding='utf-8')
    gradle = (ROOT / 'android/app/build.gradle').read_text(encoding='utf-8')
    tool = (ROOT / 'tool/content_diff.py').read_text(encoding='utf-8')
    docs = (ROOT / 'docs/V364_BATCH_DIFF_PREVIEW.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
    assert 'def preview_batch' in tool
    assert '--source' in tool and '--content' in tool and '--verbs' in tool and '--audio-manifest' in tool
    assert 'read-only' in docs
