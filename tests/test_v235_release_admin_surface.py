from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / 'lib/services/release.dart'
ACCOUNT = ROOT / 'lib/ui_v35/account_pages.dart'
APP = ROOT / 'lib/ui/app.dart'


def test_admin_tools_default_closed_at_compile_time():
    text = RELEASE.read_text(encoding='utf-8')
    assert "bool.fromEnvironment('DEUTSCH_ADMIN_TOOLS', defaultValue: false)" in text


def test_v35_settings_gates_quality_center():
    text = ACCOUNT.read_text(encoding='utf-8')
    marker = "if (adminToolsEnabled) FilledButton.icon"
    assert marker in text
    assert "QualityV35()" in text


def test_legacy_settings_gates_quality_center():
    text = APP.read_text(encoding='utf-8')
    assert 'if (adminToolsEnabled)' in text
    assert 'FilledButton.icon' in text
    assert 'QualityPage()' in text
