from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
ACCOUNT = (ROOT / 'lib/ui_v35/account_pages.dart').read_text()
APP = (ROOT / 'lib/ui_v35/app.dart').read_text()


def test_settings_reports_successful_clear_to_owner_so_stale_progress_is_not_rendered():
    assert 'final VoidCallback? onCleared;' in ACCOUNT
    assert re.search(
        r'const SettingsV35\(\{.*?required this\.repo\s*,.*?'
        r'required this\.privacySettings\s*,.*?this\.onCleared\s*,?.*?\}\);',
        ACCOUNT,
        re.DOTALL,
    )
    reset = ACCOUNT[ACCOUNT.index('Future<void> _reset'):ACCOUNT.index('  @override', ACCOUNT.index('Future<void> _reset'))]
    assert 'await repo.clearLocalData();' in reset
    assert 'onCleared?.call();' in reset
    assert reset.index('await repo.clearLocalData();') < reset.index('onCleared?.call();')


def test_home_passes_its_refresh_boundary_to_settings():
    assert re.search(
        r'SettingsV35\(\s*repo:\s*widget\.repo\s*,.*?'
        r'privacySettings:\s*widget\.dependencies\.privacySettings\s*,.*?'
        r'onCleared:\s*refresh\s*,?\s*\)',
        APP,
        re.DOTALL,
    )
