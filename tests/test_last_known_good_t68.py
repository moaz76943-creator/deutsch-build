"""Static fail-closed contracts for T68: the previous known-good pack stays
available until the replacement is installed, and a failed replacement can be
rolled back. The Dart suite is not run locally (no Flutter SDK); these
contracts pin the installer's behavior at source level."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "lib/core/storage/atomic_database_installer.dart"


def _src() -> str:
    return INSTALLER.read_text(encoding="utf-8")


def test_last_known_good_path_is_reserved_next_to_target() -> None:
    src = _src()
    assert "lastKnownGoodPath" in src
    assert "'$targetPath.lastknowngood'" in src


def test_backup_happens_before_atomic_replacement() -> None:
    src = _src()
    backup = src.index("await targetFile.rename(backupPath);")
    install = src.index("await tempFile.rename(targetPath);")
    assert backup < install


def test_stale_backup_is_rotated_not_leaked() -> None:
    src = _src()
    assert "if (await backupFile.exists())" in src
    assert "await backupFile.delete();" in src


def test_failed_replacement_restores_last_known_good() -> None:
    src = _src()
    # On rename failure the backup is moved back onto the target.
    assert "await backupFile.rename(targetPath);" in src
    assert "} catch (_) {" in src


def test_restore_api_reinstalls_backup_over_target() -> None:
    src = _src()
    assert "static Future<bool> restoreLastKnownGood" in src
    assert "if (!await backup.exists())" in src
    assert "return false;" in src
    assert "await backup.rename(targetPath);" in src


def test_installer_never_deletes_the_last_known_good_backup() -> None:
    src = _src()
    # The backup is a live safety copy: after install, nothing in the success
    # path removes it. Only rotation before the next backup and restore do.
    success = src[src.index("return DatabaseInstallResult("):src.rindex("} catch (e) {")]
    assert "backupFile.delete()" not in success
    assert "backupFile.rename" not in success
