from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def test_ui_v35_does_not_depend_on_legacy_german_quality_facade():
    for path in (ROOT / 'lib' / 'ui_v35').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        assert "services/quality.dart" not in text
        assert 'ContentQuality.' not in text


def test_ui_v35_does_not_depend_on_global_privacy_settings_facade():
    for path in (ROOT / 'lib' / 'ui_v35').rglob('*.dart'):
        text = path.read_text(encoding='utf-8')
        assert 'PrivacySettings.' not in text
        assert 'PrivacySettings.' not in text


def test_privacy_settings_has_injectable_contract():
    source = (ROOT / 'lib' / 'services' / 'privacy_settings.dart').read_text(encoding='utf-8')
    assert 'abstract interface class PrivacySettingsStore' in source
    assert 'final class LocalPrivacySettingsStore' in source
