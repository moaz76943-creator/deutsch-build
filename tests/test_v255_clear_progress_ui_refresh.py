from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACCOUNT = (ROOT / 'lib/ui_v35/account_pages.dart').read_text()
APP = (ROOT / 'lib/ui_v35/app.dart').read_text()


def test_settings_reports_successful_clear_to_owner_so_stale_progress_is_not_rendered():
    assert 'final VoidCallback? onCleared;' in ACCOUNT
    # allow variations of the constructor signature due to newly added arguments
    assert 'SettingsV35({super.key, required this.repo, required this.privacySettings, this.neuroSettings, this.onCleared});' in ACCOUNT or 'SettingsV35({super.key, required this.repo, required this.privacySettings, this.onCleared});' in ACCOUNT
    reset = ACCOUNT[ACCOUNT.index('Future<void> _reset'):ACCOUNT.index('  @override Widget build', ACCOUNT.index('Future<void> _reset'))]
    assert 'await repo.clearLocalData();' in reset
    assert 'onCleared?.call();' in reset
    assert reset.index('await repo.clearLocalData();') < reset.index('onCleared?.call();')


def test_home_passes_its_refresh_boundary_to_settings():
    assert 'SettingsV35(repo: widget.repo, privacySettings: widget.dependencies.privacySettings, neuroSettings: widget.dependencies.neuroSettings, onCleared: refresh)' in APP or 'SettingsV35(repo: widget.repo, privacySettings: widget.dependencies.privacySettings, onCleared: refresh)' in APP
