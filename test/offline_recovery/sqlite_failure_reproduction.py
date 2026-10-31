"""Disposable SQLite fault reproduction for DEUTSCH-IMPROVE-05.

Run: python3 -m unittest test/offline_recovery/sqlite_failure_reproduction.py -v
Only proves SQLite/POSIX failure mechanisms; does NOT execute Flutter/Dart.
Uses Python 3 standard library and never touches actual app/user databases.
"""
from __future__ import annotations

import hashlib
import os
from pathlib import Path
import sqlite3
import tempfile
import unittest


def digest(file: Path) -> str:
    return hashlib.sha256(file.read_bytes()).hexdigest()


class SqliteFailureReproduction(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix="deutsch_improve05_")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.installed = self.root / "fr.sqlite"
        with sqlite3.connect(self.installed) as db:
            db.execute("PRAGMA journal_mode=DELETE")
            db.execute("PRAGMA foreign_keys=ON")
            db.execute("CREATE TABLE parent(id INTEGER PRIMARY KEY)")
            db.execute(
                "CREATE TABLE child("
                "id INTEGER PRIMARY KEY, "
                "parent_id INTEGER NOT NULL REFERENCES parent(id))"
            )
            db.execute("INSERT INTO parent(id) VALUES(1)")
            db.execute("INSERT INTO child(id,parent_id) VALUES(1,1)")
            db.execute("PRAGMA user_version=1")

    def test_integrity_check_misses_orphaned_foreign_key(self) -> None:
        candidate = self.root / "candidate.sqlite"
        candidate.write_bytes(self.installed.read_bytes())
        before = digest(self.installed)
        with sqlite3.connect(candidate) as db:
            db.execute("PRAGMA foreign_keys=OFF")
            db.execute("DELETE FROM parent WHERE id=1")
            db.execute("PRAGMA user_version=2")
            self.assertEqual(
                db.execute("PRAGMA integrity_check").fetchone()[0], "ok"
            )
            self.assertEqual(
                len(db.execute("PRAGMA foreign_key_check").fetchall()), 1
            )
        self.assertEqual(digest(self.installed), before)
        with sqlite3.connect(self.installed) as db:
            self.assertEqual(db.execute("PRAGMA foreign_key_check").fetchall(), [])
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 1)

    def test_failed_review_transaction_does_not_change_either_pair(self) -> None:
        progress = self.root / "user_progress_v2.db"
        with sqlite3.connect(progress) as db:
            db.execute(
                "CREATE TABLE srs_progress("
                "lexeme_id TEXT, target_language_code TEXT, "
                "repetition_count INTEGER, user_note TEXT, "
                "PRIMARY KEY(lexeme_id,target_language_code))"
            )
            db.executemany(
                "INSERT INTO srs_progress VALUES(?,?,?,?)",
                [
                    ("shared", "de", 2, "keep-notes"),
                    ("shared", "tr", 7, "keep-other-pair"),
                ],
            )
            db.execute(
                "CREATE TRIGGER abort_review BEFORE UPDATE ON srs_progress "
                "WHEN NEW.target_language_code='de' BEGIN "
                "SELECT RAISE(ABORT, 'simulated write failure'); END"
            )
            db.commit()  # Persist fixture before fault injection.
            before = db.execute(
                "SELECT * FROM srs_progress ORDER BY target_language_code"
            ).fetchall()
            with self.assertRaises(sqlite3.IntegrityError):
                with db:
                    db.execute(
                        "UPDATE srs_progress SET repetition_count=3 "
                        "WHERE lexeme_id=? AND target_language_code=?",
                        ("shared", "de"),
                    )
            self.assertEqual(
                db.execute(
                    "SELECT * FROM srs_progress ORDER BY target_language_code"
                ).fetchall(),
                before,
            )

    def test_interrupted_rename_leaves_last_good_in_backup(self) -> None:
        backup = self.installed.with_name(self.installed.name + ".bak")
        before = digest(self.installed)
        os.replace(self.installed, backup)  # Simulated crash boundary.
        self.assertFalse(self.installed.exists())
        self.assertTrue(backup.exists())
        self.assertEqual(digest(backup), before)
        # Model expected recovery behavior, not the Dart implementation.
        os.replace(backup, self.installed)
        self.assertEqual(digest(self.installed), before)
        self.assertFalse(backup.exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
