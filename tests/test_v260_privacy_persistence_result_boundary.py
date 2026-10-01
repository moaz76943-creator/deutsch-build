from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
PRIVACY = ROOT / 'lib/services/privacy_settings.dart'
PROGRESS = ROOT / 'lib/ui_v35/progress_pages.dart'


def test_privacy_writes_expose_persistence_result_and_ui_does_not_lie_about_failure():
    privacy = PRIVACY.read_text(encoding='utf-8')
    progress = PROGRESS.read_text(encoding='utf-8')

    assert 'static Future<bool> setCloudAi(bool value)' in privacy
    assert 'static Future<bool> setSpeech(bool value)' in privacy
    assert 'Future<bool> _writeBool(String key, bool value) async' in privacy
    assert 'Future<bool> _writeBool(String key, bool value) async' in privacy
    assert 'final saved = await widget.privacySettings.setCloudAi(v);' in progress
    assert 'final saved = await widget.privacySettings.setSpeech(v);' in progress
    assert re.search(
        r'if\s*\(saved\s*&&\s*mounted\)\s*setState\(\(\)\s*=>\s*cloud\s*=\s*v\);',
        progress,
    )
    assert re.search(
        r'if\s*\(saved\s*&&\s*mounted\)\s*setState\(\(\)\s*=>\s*speech\s*=\s*v\);',
        progress,
    )
