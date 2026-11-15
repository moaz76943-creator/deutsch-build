"""Static fail-closed contracts for T65: unique staging paths and
crash-safe cleanup in the atomic database installer."""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "lib/core/storage/atomic_database_installer.dart"
MAINTENANCE = ROOT / "lib/services/storage_maintenance_service.dart"


def test_installer_uses_unique_staging_name_not_fixed_tmp() -> None:
    source = INSTALLER.read_text(encoding="utf-8")
    # The fixed '$targetPath.tmp' staging File must be gone entirely.
    assert "File('$targetPath.tmp')" not in source
    assert "'$targetPath.tmp';" not in source
    assert "_uniqueTempPath" in source
    assert "microsecondsSinceEpoch" in source
    assert "pid" in source
    assert "Random.secure()" in source


def test_staging_name_stays_in_target_directory_for_atomic_rename() -> None:
    source = INSTALLER.read_text(encoding="utf-8")
    # Unique temp must live next to the target so rename(2) is a
    # same-filesystem atomic move.
    assert "'$targetPath.tmp." in source
    assert "_uniqueTempPath" in source


def test_installer_sweeps_only_stale_temp_debris() -> None:
    source = INSTALLER.read_text(encoding="utf-8")
    assert "_sweepStaleTemps" in source
    assert "staleTempAge" in source
    assert "DateTime.now().subtract(staleTempAge)" in source
    # Directories and symlinks must never be removed by the sweep.
    assert "dir.list(followLinks: false)" in source
    assert "entity is! File" in source
    # Sweep must be best-effort and never block a valid install.
    assert "await _sweepStaleTemps(targetPath);" in source


def test_installer_never_deletes_live_temp_from_under_concurrent_install() -> None:
    source = INSTALLER.read_text(encoding="utf-8")
    # Deletion in the sweep is gated on mtime being older than the cutoff.
    assert "stat.modified.isBefore(cutoff)" in source


def test_installer_cleans_up_its_own_unique_temp_on_failure() -> None:
    source = INSTALLER.read_text(encoding="utf-8")
    assert "await tempFile.delete();" in source
    # On the failure path the unique temp is removed, never the target.
    catch_block = source[source.rindex("} catch (e) {"):]
    assert "tempFile.delete()" in catch_block
    assert "rename" not in catch_block.split("tempFile.delete()", 1)[0]


def test_maintenance_recognizes_unique_temp_debris_as_partial() -> None:
    source = MAINTENANCE.read_text(encoding="utf-8")
    assert "_basename(lower).contains('.tmp.')" in source
    assert "_basename(" in source
