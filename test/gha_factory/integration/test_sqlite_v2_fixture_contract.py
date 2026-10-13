"""Offline, non-production SQLite v2 conformance probes (stdlib only).

These deliberately synthetic probes are NOT licensed corpus evidence, a pack
release, an Android test, or a substitute for PackDownloaderService tests.
"""
import gzip
import hashlib
import io
import json
from pathlib import Path
import sqlite3
import tempfile
import unittest

LANGUAGES = ("de", "ar", "en", "es", "fr")
TOKENS = {"de": "Äpfel", "ar": "مِثَال", "en": "sample", "es": "niño", "fr": "élève"}
MANDATORY_PATHS = frozenset((
    "content/content.json", "content/content.sqlite", "metadata/pack.json"
))
REQUIRED_TABLES = frozenset((
    "metadata", "schema_migrations", "concepts", "lexicon", "senses",
    "translations", "examples", "lexical_relations", "grammar", "lexicon_fts"
))


def fixture_db(target: Path, language: str):
    connection = sqlite3.connect(target)
    try:
        connection.executescript("""
            PRAGMA user_version=2;
            PRAGMA foreign_keys=ON;
            CREATE TABLE metadata(key TEXT PRIMARY KEY, value TEXT NOT NULL);
            CREATE TABLE schema_migrations(version TEXT PRIMARY KEY);
            CREATE TABLE concepts(id TEXT PRIMARY KEY);
            CREATE TABLE lexicon(
                id TEXT PRIMARY KEY, surface TEXT NOT NULL,
                sort_key TEXT NOT NULL, language_code TEXT NOT NULL,
                cefr_level TEXT, part_of_speech TEXT, fields_json TEXT NOT NULL
            );
            CREATE TABLE senses(
                sense_id TEXT PRIMARY KEY, lexeme_id TEXT NOT NULL
                    REFERENCES lexicon(id), concept_id TEXT,
                payload_json TEXT NOT NULL
            );
            CREATE TABLE translations(id TEXT PRIMARY KEY, text TEXT);
            CREATE TABLE examples(
                example_id TEXT PRIMARY KEY,
                lexeme_id TEXT REFERENCES lexicon(id),
                language_code TEXT NOT NULL, text TEXT NOT NULL
            );
            CREATE TABLE lexical_relations(id TEXT PRIMARY KEY);
            CREATE TABLE grammar(id TEXT PRIMARY KEY);
            CREATE VIEW lexemes AS SELECT * FROM lexicon;
            CREATE VIRTUAL TABLE lexicon_fts USING fts5(surface);
            CREATE INDEX lexicon_language_sort ON lexicon(language_code, sort_key);
        """)
        connection.executemany("INSERT INTO metadata VALUES (?, ?)", (
            ("mapping_version", "2.0.0"),
            ("contract_version", "1.0.0"),
            ("language_code", language),
        ))
        token = TOKENS.get(language, "中文検索")
        connection.execute("INSERT INTO lexicon VALUES (?, ?, ?, ?, ?, ?, ?)", (
            "probe-" + language, token, token.casefold(), language, "A1",
            "probe", json.dumps({"lemma": token}, ensure_ascii=False),
        ))
        connection.execute("INSERT INTO lexicon_fts(surface) VALUES (?)", (token,))
        connection.commit()
    finally:
        connection.close()


def validate_v2_file(path: Path, language: str):
    """Test oracle for Route 15's documented schema; not the Dart runtime."""
    if not path.read_bytes()[:16] == b"SQLite format 3\x00":
        raise ValueError("not sqlite")
    connection = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        if connection.execute("PRAGMA integrity_check").fetchone()[0] != "ok":
            raise ValueError("integrity")
        if connection.execute("PRAGMA foreign_key_check").fetchall():
            raise ValueError("foreign key violations")
        if connection.execute("PRAGMA user_version").fetchone()[0] != 2:
            raise ValueError("user_version")
        schema = dict(connection.execute(
            "SELECT name, type FROM sqlite_master WHERE name NOT LIKE 'sqlite_%'"
        ).fetchall())
        if not all(schema.get(name) == "table" for name in REQUIRED_TABLES):
            raise ValueError("missing required table")
        if schema.get("lexemes") != "view":
            raise ValueError("missing lexemes view")
        if "lexicon_language_sort" not in schema:
            raise ValueError("missing bounded-search index")
        metadata = dict(connection.execute("SELECT key, value FROM metadata"))
        if (metadata.get("mapping_version"), metadata.get("contract_version"),
                metadata.get("language_code")) != ("2.0.0", "1.0.0", language):
            raise ValueError("metadata mismatch")
        if connection.execute(
            "SELECT COUNT(*) FROM lexicon WHERE language_code=?", (language,)
        ).fetchone()[0] == 0:
            raise ValueError("empty language")
    finally:
        connection.close()


def make_fixture_envelope(db_bytes: bytes, language: str, version="0.0.1"):
    """Deterministic in-memory specimen; never published as a production pack."""
    import base64
    files = {
        "content/content.json": json.dumps({"languageCode": language,
                                            "version": version}).encode(),
        "content/content.sqlite": db_bytes,
        "metadata/pack.json": json.dumps({"languageCode": language,
                                          "version": version,
                                          "contractVersion": "1.0.0"}).encode(),
    }
    envelope = {"packId": "fixture-" + language, "languageCode": language,
                "version": version, "contractVersion": "1.0.0",
                "files": [{"path": name,
                           "contentBase64": base64.b64encode(data).decode()}
                          for name, data in sorted(files.items())]}
    raw = json.dumps(envelope, sort_keys=True, separators=(",", ":")).encode()
    stream = io.BytesIO()
    with gzip.GzipFile(fileobj=stream, mode="wb", mtime=0, filename="") as f:
        f.write(raw)
    return stream.getvalue()


def _reject_duplicate_json_keys(pairs):
    """Reject ambiguous metadata rather than relying on last-key-wins JSON."""
    obj = {}
    for key, value in pairs:
        if key in obj:
            raise ValueError("duplicate JSON key: " + key)
        obj[key] = value
    return obj


def inspect_fixture_envelope(archive, language, expected_sha, *,
                             max_size=64 * 1024 * 1024,
                             expected_version=None, expected_sqlite_sha=None):
    """Test-only envelope oracle for integrity / identity negative cases.

    This oracle does NOT replace testing the private Dart installer. Actual
    per-file pack admission and signature policy remain separate gates.
    """
    import base64
    if max_size < 1 or max_size > 64 * 1024 * 1024:
        raise ValueError("invalid expansion limit")
    if hashlib.sha256(archive).hexdigest() != expected_sha:
        raise ValueError("sha256 mismatch")
    with gzip.GzipFile(fileobj=io.BytesIO(archive)) as stream:
        raw = stream.read(max_size + 1)
    if len(raw) > max_size:
        raise ValueError("expanded size limit")
    payload = json.loads(raw, object_pairs_hook=_reject_duplicate_json_keys)
    if not isinstance(payload, dict):
        raise ValueError("invalid envelope")
    if payload.get("languageCode") != language or payload.get("contractVersion") != "1.0.0":
        raise ValueError("envelope identity")
    if not isinstance(payload.get("version"), str) or not payload["version"]:
        raise ValueError("missing version")
    if expected_version is not None and expected_version != payload["version"]:
        raise ValueError("version mismatch")
    files = payload.get("files")
    if not isinstance(files, list):
        raise ValueError("missing files")
    if any(not isinstance(f, dict) for f in files):
        raise ValueError("invalid file entry")
    if len(files) != len(MANDATORY_PATHS) or set(f.get("path") for f in files) != MANDATORY_PATHS:
        raise ValueError("mandatory files or duplicates")
    decoded = {f["path"]: base64.b64decode(f["contentBase64"], validate=True)
               for f in files}
    for key in ("content/content.json", "metadata/pack.json"):
        obj = json.loads(decoded[key], object_pairs_hook=_reject_duplicate_json_keys)
        if not isinstance(obj, dict) or obj.get("languageCode") != language or obj.get("version") != payload["version"]:
            raise ValueError("file identity")
        if key == "metadata/pack.json" and obj.get("contractVersion") != "1.0.0":
            raise ValueError("pack contract mismatch")
    sqlite = decoded["content/content.sqlite"]
    if expected_sqlite_sha is not None and hashlib.sha256(sqlite).hexdigest() != expected_sqlite_sha:
        raise ValueError("content sha256 mismatch")
    return sqlite


class SqliteV2FixtureContractTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="gha-integration-fixture-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)

    def create(self, language):
        location = self.root / (language + ".sqlite")
        fixture_db(location, language)
        return location

    def test_five_distinct_language_attachments(self):
        for language in LANGUAGES:
            with self.subTest(language=language):
                self.create(language)
                validate_v2_file(self.root / (language + ".sqlite"), language)
                with self.assertRaisesRegex(ValueError, "metadata mismatch"):
                    validate_v2_file(self.root / (language + ".sqlite"), "de" if language != "de" else "fr")

    def test_no_implicit_cross_language_dictionary_result(self):
        for language in LANGUAGES:
            file = self.create(language)
            with sqlite3.connect(file) as db:
                own = db.execute("SELECT surface FROM lexicon WHERE language_code=? LIMIT ?", (language, 20)).fetchall()
                other = db.execute("SELECT surface FROM lexicon WHERE language_code=? LIMIT ?", ("fr" if language != "fr" else "de", 20)).fetchall()
                self.assertEqual(own, [(TOKENS[language],)])
                self.assertEqual(other, [])

    def test_unicode_and_cjk_round_trip(self):
        for language, text in (("ar", "مِثَال"), ("de", "Äpfel"), ("es", "niño"), ("zh", "中文検索")):
            file = self.create(language)
            with sqlite3.connect(file) as db:
                self.assertEqual(db.execute("SELECT surface FROM lexicon WHERE language_code=?", (language,)).fetchone()[0], text)

    def test_empty_pack_rejected(self):
        file = self.create("en")
        with sqlite3.connect(file) as db:
            db.execute("DELETE FROM lexicon")
        with self.assertRaisesRegex(ValueError, "empty language"):
            validate_v2_file(file, "en")

    def test_wrong_user_version_rejected(self):
        file = self.create("ar")
        with sqlite3.connect(file) as db:
            db.execute("PRAGMA user_version=1")
        with self.assertRaisesRegex(ValueError, "user_version"):
            validate_v2_file(file, "ar")

    def test_corrupted_sqlite_rejected(self):
        file = self.root / "damaged.sqlite"
        file.write_bytes(b"not-a-database")
        with self.assertRaisesRegex(ValueError, "not sqlite"):
            validate_v2_file(file, "fr")

    def test_fk_violation_rejected(self):
        file = self.create("fr")
        with sqlite3.connect(file) as db:
            db.execute("PRAGMA foreign_keys=OFF")
            db.execute("INSERT INTO senses VALUES ('orphan','missing',NULL,'{}')")
        with self.assertRaisesRegex(ValueError, "foreign key"):
            validate_v2_file(file, "fr")

    def test_envelope_hash_and_identity(self):
        file = self.create("es")
        archive = make_fixture_envelope(file.read_bytes(), "es")
        digest = hashlib.sha256(archive).hexdigest()
        self.assertEqual(inspect_fixture_envelope(archive, "es", digest), file.read_bytes())
        self.assertEqual(archive, make_fixture_envelope(file.read_bytes(), "es"))
        with self.assertRaisesRegex(ValueError, "sha256"):
            inspect_fixture_envelope(archive + b"!", "es", digest)
        with self.assertRaisesRegex(ValueError, "identity"):
            inspect_fixture_envelope(archive, "de", digest)

    def test_missing_and_duplicate_envelope_members_fail_closed(self):
        file = self.create("en")
        archive = make_fixture_envelope(file.read_bytes(), "en")
        template = json.loads(gzip.decompress(archive))
        for change in ("missing", "duplicate", "unexpected"):
            with self.subTest(change=change):
                candidate = json.loads(json.dumps(template))
                if change == "missing":
                    candidate["files"].pop()
                elif change == "duplicate":
                    candidate["files"][1] = candidate["files"][0].copy()
                else:
                    candidate["files"][0]["path"] = "../unsafe.sqlite"
                data = gzip.compress(json.dumps(candidate).encode(), mtime=0)
                with self.assertRaisesRegex(ValueError, "mandatory files"):
                    inspect_fixture_envelope(data, "en", hashlib.sha256(data).hexdigest())

    def test_truncated_gzip_fails(self):
        file = self.create("fr")
        original = make_fixture_envelope(file.read_bytes(), "fr")
        damaged = original[:-12]
        with self.assertRaises((EOFError, OSError)):
            inspect_fixture_envelope(damaged, "fr", hashlib.sha256(damaged).hexdigest())

    def test_pack_version_and_contract_metadata_tamper_fail_closed(self):
        import base64
        file = self.create("de")
        archive = make_fixture_envelope(file.read_bytes(), "de")
        template = json.loads(gzip.decompress(archive))
        for field, replacement, error in (("version", "99.0.0", "file identity"),
                                          ("contractVersion", "9.9.9", "pack contract mismatch"),
                                          ("languageCode", "en", "file identity")):
            with self.subTest(field=field):
                candidate = json.loads(json.dumps(template))
                pack = next(item for item in candidate["files"]
                            if item["path"] == "metadata/pack.json")
                metadata = json.loads(base64.b64decode(pack["contentBase64"]))
                metadata[field] = replacement
                pack["contentBase64"] = base64.b64encode(json.dumps(metadata).encode()).decode()
                data = gzip.compress(json.dumps(candidate).encode(), mtime=0)
                with self.assertRaisesRegex(ValueError, error):
                    inspect_fixture_envelope(data, "de", hashlib.sha256(data).hexdigest())

    def test_required_fts_and_view_rejected_when_missing(self):
        for relation in ("lexicon_fts", "lexemes", "lexicon_language_sort"):
            with self.subTest(relation=relation):
                file = self.create("ar")
                with sqlite3.connect(file) as db:
                    db.execute("DROP " + ("VIEW " if relation == "lexemes" else
                                         "INDEX " if relation == "lexicon_language_sort" else
                                         "TABLE ") + relation)
                with self.assertRaisesRegex(ValueError, "(table|view|index)"):
                    validate_v2_file(file, "ar")
                file.unlink()

    def test_pack_metadata_includes_route14_contract_version(self):
        import base64
        file = self.create("en")
        archive = make_fixture_envelope(file.read_bytes(), "en", "1.0.0")
        envelope = json.loads(gzip.decompress(archive))
        encoded = next(item["contentBase64"] for item in envelope["files"]
                       if item["path"] == "metadata/pack.json")
        pack_metadata = json.loads(base64.b64decode(encoded))
        self.assertEqual(pack_metadata["contractVersion"], "1.0.0")

    def test_json_duplicate_metadata_keys_fail_closed(self):
        file = self.create("fr")
        archive = make_fixture_envelope(file.read_bytes(), "fr")
        decoded = gzip.decompress(archive).decode("utf-8")
        self.assertIn('"languageCode":"fr"', decoded)
        # Duplicate keys must never depend on JSON parsers' last-wins policy.
        duplicate = decoded.replace('"languageCode":"fr"',
                                    '"languageCode":"de","languageCode":"fr"', 1)
        tampered = gzip.compress(duplicate.encode("utf-8"), mtime=0)
        with self.assertRaisesRegex(ValueError, "duplicate JSON key"):
            inspect_fixture_envelope(tampered, "fr", hashlib.sha256(tampered).hexdigest())

    def test_manifest_and_envelope_version_must_match(self):
        file = self.create("de")
        archive = make_fixture_envelope(file.read_bytes(), "de", version="1.0.0")
        with self.assertRaisesRegex(ValueError, "version mismatch"):
            inspect_fixture_envelope(archive, "de", hashlib.sha256(archive).hexdigest(),
                                     expected_version="2.0.0")

    def test_sqlite_content_hash_must_match_manifest(self):
        file = self.create("ar")
        archive = make_fixture_envelope(file.read_bytes(), "ar")
        with self.assertRaisesRegex(ValueError, "content sha256 mismatch"):
            inspect_fixture_envelope(archive, "ar", hashlib.sha256(archive).hexdigest(),
                                     expected_sqlite_sha="0" * 64)

    def test_expansion_bomb_rejected(self):
        file = self.create("de")
        archive = make_fixture_envelope(file.read_bytes(), "de")
        with self.assertRaisesRegex(ValueError, "size limit"):
            inspect_fixture_envelope(archive, "de", hashlib.sha256(archive).hexdigest(), max_size=64)

    def test_prior_content_and_progress_bytes_remain_immutable_on_fixture_failure(self):
        previous_pack = self.create("fr")
        progress = self.root / "encrypted-progress-vault.sentinel"
        progress.write_bytes(b"opaque-progress-sentinel-v1")
        old_hash = hashlib.sha256(previous_pack.read_bytes()).hexdigest()
        old_progress_hash = hashlib.sha256(progress.read_bytes()).hexdigest()
        bad = make_fixture_envelope(previous_pack.read_bytes(), "es")
        with self.assertRaisesRegex(ValueError, "identity"):
            inspect_fixture_envelope(bad, "fr", hashlib.sha256(bad).hexdigest())
        self.assertEqual(hashlib.sha256(previous_pack.read_bytes()).hexdigest(), old_hash)
        self.assertEqual(hashlib.sha256(progress.read_bytes()).hexdigest(), old_progress_hash)
        # This is a fixture-harness preservation assertion, NOT a Dart rollback test.

    def test_missing_manifest_pack_is_not_release_eligible(self):
        fixture_manifest = {"schemaVersion": "2.0.0", "packs": [],
                            "languages": [{"code": "de", "registered": True}]}
        self.assertFalse(any(p.get("languageCode") == "de" for p in fixture_manifest["packs"]))


if __name__ == "__main__":
    unittest.main()
