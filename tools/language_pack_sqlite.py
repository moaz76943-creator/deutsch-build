"""SQLite materialization for deterministic offline language packs."""

from __future__ import annotations

import json
import sqlite3
import tempfile
from pathlib import Path
from typing import Any, Mapping

try:
    from tools.german_linguistic_qa import assert_german_sqlite
except ModuleNotFoundError:
    from german_linguistic_qa import assert_german_sqlite


_CEFR_LEVELS = {"unknown", "A1", "A2", "B1", "B2", "C1", "C2"}


def build_sqlite_bytes(
    document: Mapping[str, Any],
    *,
    sqlite_schema_version: int,
    canonical_schema_version: int,
) -> bytes:
    with tempfile.TemporaryDirectory(prefix="language_pack_sqlite_") as temp:
        path = Path(temp) / "content.sqlite"
        connection = sqlite3.connect(path)
        try:
            connection.execute("PRAGMA page_size=4096")
            connection.execute("PRAGMA journal_mode=OFF")
            connection.execute("PRAGMA synchronous=OFF")
            connection.execute("PRAGMA foreign_keys=ON")
            connection.execute(
                "CREATE TABLE metadata (key TEXT PRIMARY KEY, value TEXT NOT NULL)"
            )
            connection.execute(
                "CREATE TABLE localization ("
                "key TEXT PRIMARY KEY, text TEXT NOT NULL, direction TEXT NOT NULL)"
            )
            # Legacy flat table remains during the Phase-2 transition so the
            # verified Phase-1 runtime can continue reading the same pack.
            connection.execute(
                "CREATE TABLE lexicon ("
                "id TEXT PRIMARY KEY, surface TEXT NOT NULL, "
                "part_of_speech TEXT NOT NULL, direction TEXT NOT NULL, "
                "fields_json TEXT NOT NULL)"
            )
            connection.execute(
                "CREATE TABLE grammar ("
                "id TEXT PRIMARY KEY, title_key TEXT NOT NULL, tree_json TEXT NOT NULL)"
            )
            connection.execute(
                "CREATE TABLE concepts ("
                "concept_id TEXT PRIMARY KEY, sense_id TEXT NOT NULL, "
                "lemma TEXT NOT NULL, part_of_speech TEXT NOT NULL, "
                "register TEXT NOT NULL, cefr TEXT NOT NULL, "
                "surface TEXT NOT NULL, direction TEXT NOT NULL, "
                "semantic_tags_json TEXT NOT NULL DEFAULT '[]', "
                "legacy_fields_json TEXT NOT NULL DEFAULT '{}')"
            )
            connection.execute(
                "CREATE TABLE german_nouns ("
                "concept_id TEXT PRIMARY KEY REFERENCES concepts(concept_id) ON DELETE CASCADE, "
                "gender TEXT NOT NULL, plural TEXT, declension_class TEXT NOT NULL, "
                "nominative_singular TEXT NOT NULL, accusative_singular TEXT NOT NULL, "
                "dative_singular TEXT NOT NULL, genitive_singular TEXT NOT NULL, "
                "nominative_plural TEXT, accusative_plural TEXT, "
                "dative_plural TEXT, genitive_plural TEXT)"
            )
            connection.execute(
                "CREATE TABLE german_verbs ("
                "concept_id TEXT PRIMARY KEY REFERENCES concepts(concept_id) ON DELETE CASCADE, "
                "infinitive TEXT NOT NULL, separable_prefix TEXT, inseparable_prefix TEXT, "
                "reflexivity TEXT NOT NULL, auxiliary TEXT NOT NULL, "
                "participle_ii TEXT, preterite TEXT, imperative TEXT)"
            )
            connection.execute(
                "CREATE TABLE verb_valency_frames ("
                "concept_id TEXT NOT NULL REFERENCES german_verbs(concept_id) ON DELETE CASCADE, "
                "frame_id TEXT NOT NULL, governed_case TEXT, preposition TEXT, "
                "preposition_case TEXT, semantic_role TEXT NOT NULL, "
                "object_required INTEGER NOT NULL CHECK (object_required IN (0, 1)), "
                "PRIMARY KEY (concept_id, frame_id))"
            )
            connection.execute(
                "CREATE TABLE german_verb_forms ("
                "concept_id TEXT NOT NULL REFERENCES german_verbs(concept_id) ON DELETE CASCADE, "
                "tense TEXT NOT NULL, person_key TEXT NOT NULL, form TEXT NOT NULL, "
                "PRIMARY KEY (concept_id, tense, person_key))"
            )
            connection.execute(
                "CREATE TABLE german_word_families ("
                "family_id TEXT PRIMARY KEY, "
                "base_concept_id TEXT NOT NULL "
                "REFERENCES concepts(concept_id) ON DELETE CASCADE)"
            )
            connection.execute(
                "CREATE TABLE german_word_family_members ("
                "family_id TEXT NOT NULL "
                "REFERENCES german_word_families(family_id) ON DELETE CASCADE, "
                "concept_id TEXT NOT NULL "
                "REFERENCES concepts(concept_id) ON DELETE CASCADE, "
                "relation_type TEXT NOT NULL, prefix TEXT, suffix TEXT, "
                "semantic_distance TEXT NOT NULL, pedagogical_level TEXT NOT NULL, "
                "interference_risk INTEGER NOT NULL "
                "CHECK (interference_risk IN (0, 1)), "
                "PRIMARY KEY (family_id, concept_id))"
            )
            connection.execute(
                "CREATE INDEX idx_concepts_lemma ON concepts(lemma)"
            )
            connection.execute(
                "CREATE INDEX idx_concepts_sense ON concepts(sense_id)"
            )
            connection.execute(
                "CREATE INDEX idx_valency_prep "
                "ON verb_valency_frames(preposition, preposition_case)"
            )
            connection.execute(
                "CREATE INDEX idx_word_family_member_concept "
                "ON german_word_family_members(concept_id)"
            )
            connection.execute(
                "CREATE INDEX idx_word_family_distance "
                "ON german_word_family_members(family_id, semantic_distance)"
            )

            pack = document["pack"]
            content_rows = len(document["lexicon"])
            verb_rows = sum(
                len(entry["fields"].get("verbRows", []))
                for entry in document["lexicon"]
            )
            metadata = {
                "schemaVersion": str(document["schemaVersion"]),
                "canonicalSchemaVersion": str(canonical_schema_version),
                "contentRows": str(content_rows),
                "verbRows": str(verb_rows),
                "packId": pack["id"],
                "languageCode": pack["languageCode"],
                "version": pack["version"],
                "contractVersion": pack["contractVersion"],
                "textDirection": pack["textDirection"],
            }
            connection.executemany(
                "INSERT INTO metadata(key, value) VALUES (?, ?)",
                sorted(metadata.items()),
            )

            localization_rows = [
                (key, value["text"], value["direction"])
                for key, value in document["localization"].items()
            ]
            connection.executemany(
                "INSERT INTO localization(key, text, direction) VALUES (?, ?, ?)",
                localization_rows,
            )

            lexicon_rows = [
                (
                    entry["id"],
                    entry["surface"],
                    entry["partOfSpeech"],
                    entry["direction"],
                    json.dumps(
                        entry["fields"],
                        ensure_ascii=False,
                        sort_keys=True,
                        separators=(",", ":"),
                    ),
                )
                for entry in document["lexicon"]
            ]
            connection.executemany(
                "INSERT INTO lexicon("
                "id, surface, part_of_speech, direction, fields_json"
                ") VALUES (?, ?, ?, ?, ?)",
                lexicon_rows,
            )

            for entry in document["lexicon"]:
                fields = entry["fields"]
                canonical = fields.get("canonical", {})
                sense_id = canonical.get("senseId", entry["id"])
                register = canonical.get("register", "neutral")
                cefr = canonical.get("cefr", fields.get("cefr", "unknown"))
                if cefr not in _CEFR_LEVELS:
                    cefr = "unknown"
                tags = canonical.get("semanticTags", [])
                connection.execute(
                    "INSERT INTO concepts("
                    "concept_id, sense_id, lemma, part_of_speech, register, cefr, "
                    "surface, direction, semantic_tags_json, legacy_fields_json"
                    ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    (
                        entry["id"],
                        sense_id,
                        entry["surface"],
                        entry["partOfSpeech"].lower(),
                        register,
                        cefr,
                        entry["surface"],
                        entry["direction"],
                        json.dumps(tags, ensure_ascii=False, separators=(",", ":")),
                        json.dumps(
                            fields,
                            ensure_ascii=False,
                            sort_keys=True,
                            separators=(",", ":"),
                        ),
                    ),
                )

                noun = canonical.get("noun")
                if noun is not None:
                    forms = noun["caseForms"]
                    connection.execute(
                        "INSERT INTO german_nouns("
                        "concept_id, gender, plural, declension_class, "
                        "nominative_singular, accusative_singular, dative_singular, "
                        "genitive_singular, nominative_plural, accusative_plural, "
                        "dative_plural, genitive_plural"
                        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        (
                            entry["id"],
                            noun["gender"],
                            noun.get("plural"),
                            noun["declensionClass"],
                            forms["nominativeSingular"],
                            forms["accusativeSingular"],
                            forms["dativeSingular"],
                            forms["genitiveSingular"],
                            forms.get("nominativePlural"),
                            forms.get("accusativePlural"),
                            forms.get("dativePlural"),
                            forms.get("genitivePlural"),
                        ),
                    )

                verb = canonical.get("verb")
                if verb is not None:
                    connection.execute(
                        "INSERT INTO german_verbs("
                        "concept_id, infinitive, separable_prefix, inseparable_prefix, "
                        "reflexivity, auxiliary, participle_ii, preterite, imperative"
                        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                        (
                            entry["id"],
                            verb["infinitive"],
                            verb.get("separablePrefix"),
                            verb.get("inseparablePrefix"),
                            verb["reflexivity"],
                            verb["auxiliary"],
                            verb.get("participleII"),
                            verb.get("preterite"),
                            verb.get("imperative"),
                        ),
                    )
                    for frame in verb["valencyFrames"]:
                        connection.execute(
                            "INSERT INTO verb_valency_frames("
                            "concept_id, frame_id, governed_case, preposition, "
                            "preposition_case, semantic_role, object_required"
                            ") VALUES (?, ?, ?, ?, ?, ?, ?)",
                            (
                                entry["id"],
                                frame["id"],
                                frame.get("governedCase"),
                                frame.get("preposition"),
                                frame.get("prepositionCase"),
                                frame["semanticRole"],
                                1 if frame["objectRequired"] else 0,
                            ),
                        )
                    for form in verb["forms"]:
                        connection.execute(
                            "INSERT INTO german_verb_forms("
                            "concept_id, tense, person_key, form"
                            ") VALUES (?, ?, ?, ?)",
                            (
                                entry["id"],
                                form["tense"],
                                form["personKey"],
                                form["form"],
                            ),
                        )

            family_bases: dict[str, str] = {}
            family_members: list[tuple[Any, ...]] = []
            for entry in document["lexicon"]:
                canonical = entry["fields"].get("canonical", {})
                family = canonical.get("wordFamily")
                if not isinstance(family, Mapping):
                    continue
                family_id = family["familyId"]
                base_concept_id = family["baseConceptId"]
                previous_base = family_bases.get(family_id)
                if previous_base is not None and previous_base != base_concept_id:
                    raise ValueError("word family base concept mismatch")
                family_bases[family_id] = base_concept_id
                family_members.append(
                    (
                        family_id,
                        entry["id"],
                        family["relationType"],
                        family.get("prefix"),
                        family.get("suffix"),
                        family["semanticDistance"],
                        family["pedagogicalLevel"],
                        1 if family["interferenceRisk"] else 0,
                    )
                )

            connection.executemany(
                "INSERT INTO german_word_families(family_id, base_concept_id) "
                "VALUES (?, ?)",
                sorted(family_bases.items()),
            )
            connection.executemany(
                "INSERT INTO german_word_family_members("
                "family_id, concept_id, relation_type, prefix, suffix, "
                "semantic_distance, pedagogical_level, interference_risk"
                ") VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                sorted(family_members),
            )

            grammar_rows = [
                (
                    entry["id"],
                    entry["titleKey"],
                    json.dumps(
                        entry["tree"],
                        ensure_ascii=False,
                        sort_keys=True,
                        separators=(",", ":"),
                    ),
                )
                for entry in document["grammar"]
            ]
            connection.executemany(
                "INSERT INTO grammar(id, title_key, tree_json) VALUES (?, ?, ?)",
                grammar_rows,
            )
            connection.execute(f"PRAGMA user_version={sqlite_schema_version}")
            assert_german_sqlite(connection)
            connection.commit()
            connection.execute("VACUUM")
        finally:
            connection.close()
        return path.read_bytes()
