"""Static fail-closed contracts for T70: shared content-pack storage is
physically separated from user learning state, progress, and private data.

The Dart suite is not run locally (no Flutter SDK); these contracts pin the
source-level layout so a content pack can never again be installed into the
private databases directory, and learner state can never be written into a
pack root.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB_SERVICE = ROOT / "lib/services/database_service.dart"
PACK_DOWNLOADER = ROOT / "lib/services/pack_downloader_service.dart"
ADMISSION = ROOT / "lib/core/storage/pack_admission_service.dart"
BACKUP = ROOT / "lib/services/progress_backup_service.dart"


def _src(file: Path) -> str:
    return file.read_text(encoding="utf-8")


def test_content_pack_root_resolves_under_app_support_packs() -> None:
    src = _src(DB_SERVICE)
    assert "_contentPackStorageRoot" in src
    assert "getApplicationSupportDirectory()" in src
    assert "path.join(support.path, 'packs')" in src


def test_bundled_german_pack_installs_into_pack_root_not_databases_dir() -> None:
    src = _src(DB_SERVICE)
    # The German pack target is derived from the pack root, never from
    # getDatabasesPath().
    body = src[
        src.index("Future<String> _ensureGermanDatabase"):src.index(
            "Future<String> _installedPackPath"
        )
    ]
    assert "getDatabasesPath()" not in body.split("legacy")[0]
    assert "path.join(packsDir.path, _germanDatabaseFileName)" in body


def test_legacy_databases_dir_copy_is_retired_only_when_canonical() -> None:
    src = _src(DB_SERVICE)
    legacy = src[src.index("// Retire the pre-T70 legacy copy"):]
    assert "getDatabasesPath()" in legacy
    assert "_constantTimeHexEquals(legacyHash, germanGoldenSha256)" in legacy
    assert "await legacy.delete();" in legacy


def test_private_progress_db_stays_in_private_databases_dir() -> None:
    src = _src(DB_SERVICE)
    body = src[
        src.index("Future<Database> _initProgressDb"):src.index(
            "Future<Database> _initProgressDb"
        )
        + 1500
    ]
    assert "getDatabasesPath()" in body
    assert "_initProgressDb('user_progress_v2.db')" in src


def test_pack_admission_refuses_private_progress_paths() -> None:
    src = _src(ADMISSION)
    assert "progress" in src


def test_downloader_installs_packs_beside_support_root_never_progress_db() -> None:
    src = _src(PACK_DOWNLOADER)
    assert "path.join(packsDir.path, '$contentLanguageCode.sqlite')" in src
    # The installer target is never the application documents directory.
    assert "getApplicationDocumentsDirectory" not in src


def test_progress_backup_archives_only_learner_database() -> None:
    src = _src(BACKUP)
    assert "_databaseName = 'user_progress_v2.db'" in src
    # No pack storage root leaks into the private backup archive.
    assert "'packs'" not in src
    assert "language_packs" not in src
