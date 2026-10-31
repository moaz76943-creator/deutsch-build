from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
RELEASE = ROOT / 'lib/services/release.dart'
ACCOUNT = ROOT / 'lib/ui_v35/account_pages.dart'
APP = ROOT / 'lib/ui/app.dart'


def test_admin_tools_default_closed_at_compile_time():
    text = RELEASE.read_text(encoding='utf-8')
    assert re.search(
        r"bool\.fromEnvironment\(\s*'DEUTSCH_ADMIN_TOOLS'\s*,\s*defaultValue:\s*false\s*,?\s*\)",
        text,
        re.DOTALL,
    )


def test_v35_settings_gates_quality_center():
    text = ACCOUNT.read_text(encoding='utf-8')
    assert re.search(
        r'if\s*\(adminToolsEnabled\)\s*FilledButton\.icon',
        text,
        re.DOTALL,
    )
    assert "QualityV35()" in text


def test_legacy_settings_gates_quality_center():
    text = APP.read_text(encoding='utf-8')
    assert 'if (adminToolsEnabled)' in text
    assert 'FilledButton.icon' in text
    assert 'QualityPage()' in text
