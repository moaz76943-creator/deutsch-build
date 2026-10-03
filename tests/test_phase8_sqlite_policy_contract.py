from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "lib"

MIGRATED = [
    "lib/services/database_migration_helper.dart",
    "lib/services/grammar_hub_service.dart",
    "lib/services/user_customization_service.dart",
    "lib/services/smart_mistakes_ledger.dart",
    "lib/services/dynamic_ui_variations.dart",
    "lib/features/verb_matrix/data/database.dart",
    "lib/features/sentence_bridge_puzzle/data/database.dart",
    "lib/features/reverse_quiz_mode/data/database.dart",
    "lib/features/semantic_color_tagging/semantic_color_tagging.dart",
    "lib/features/progress/domain/services/streak_milestones_engine.dart",
]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def test_unified_policy_owns_connection_pragmas_and_platform_factory():
    policy = read("lib/services/sqlite_policy.dart")
    assert "PRAGMA foreign_keys" in policy
    assert "PRAGMA busy_timeout" in policy
    assert "sqflite.databaseFactory" in policy
    assert "resolvePath" in policy
    assert "openWritable" in policy
    assert "openReadOnly" in policy


def test_migrated_sqlite_consumers_do_not_open_connections_directly():
    for relative in MIGRATED:
        text = read(relative)
        assert ".openDatabase(" not in text, relative
        assert not re.search(r"(?<![.A-Za-z0-9_])openDatabase\s*\(", text), relative
        assert (
            "sqlite_policy.dart" in text
            or "DatabaseMigrationHelper.open" in text
        ), relative


def test_lib_has_no_bare_sqflite_open_database_escape_hatch():
    offenders = []
    bare = re.compile(r"(?<![.A-Za-z0-9_])openDatabase\s*\(")
    for path in LIB.rglob("*.dart"):
        text = path.read_text(encoding="utf-8")
        if bare.search(text):
            offenders.append(path.relative_to(ROOT).as_posix())
    assert offenders == []


def test_encrypted_pack_database_remains_separate_from_plain_policy():
    policy = read("lib/services/sqlite_policy.dart")
    encrypted = read("lib/services/pack_database_security.dart")
    assert "sqflite_sqlcipher" not in policy
    assert "sqflite_sqlcipher" in encrypted
    assert "PackDatabaseOpener" in encrypted
