from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]

def test_v363_release_contract_declares_review_queue():
    pubspec=(ROOT/'pubspec.yaml').read_text(encoding='utf-8')
    gradle=(ROOT/'android/app/build.gradle').read_text(encoding='utf-8')
    tool=(ROOT/'tool/content_quality_gate.py').read_text(encoding='utf-8')
    docs=(ROOT/'docs/V363_REVIEW_QUEUE.md').read_text(encoding='utf-8')
    assert 'version:' in pubspec
    assert 'versionCode ' in gradle
    assert 'versionName "' in gradle
    assert 'def filter_queue' in tool
    assert '--severity' in tool and '--category' in tool and '--content-id' in tool
    assert 'structured, reviewable queue' in docs
