#!/usr/bin/env python3
"""Build a language-neutral, offline SQLite verb pack from a JSON dataset.

This is a data normalizer; it does not infer or synthesize conjugations.
Python standard library only.
"""

import argparse
import json
import os
import sqlite3
import tempfile
from pathlib import Path
from typing import Iterable

SCHEMA_PATH = Path(__file__).with_name("morphology_schema.sql")
BATCH_SIZE = 1000


class ValidationError(ValueError):
    """The input or generated database violates the morphology contract."""


def _required_text(item: dict, key: str, location: str) -> str:
    value = item.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValidationError(f"{location}.{key} must be a non-empty string")
    return value


def _dataset(data: object) -> tuple[list, list | None]:
    if isinstance(data, list):
        data = {"verbs": data}
    if not isinstance(data, dict) or not isinstance(data.get("verbs"), list):
        raise ValidationError("Input must be a verb list or an object with a 'verbs' list")
    flat = data.get("verb_conjugations")
    if flat is not None and not isinstance(flat, list):
        raise ValidationError("'verb_conjugations' must be a list")
    return data["verbs"], flat


def _verb_rows(verbs: list) -> Iterable[tuple]:
    for i, verb in enumerate(verbs):
        location = f"verbs[{i}]"
        if not isinstance(verb, dict):
            raise ValidationError(f"{location} must be an object")
        verb_id = _required_text(verb, "verb_id", location)
        infinitive = _required_text(verb, "infinitive", location)
        translation = verb.get("translation_ar")
        if translation is not None and not isinstance(translation, str):
            raise ValidationError(f"{location}.translation_ar must be a string or null")
        rank = verb.get("frequency_rank")
        if rank is not None and (type(rank) is not int or rank < 1):
            raise ValidationError(f"{location}.frequency_rank must be a positive integer or null")
        yield verb_id, infinitive, translation, rank


def _form_row(form: object, location: str, parent_id: str | None) -> tuple:
    if not isinstance(form, dict):
        raise ValidationError(f"{location} must be an object")
    if parent_id is None:
        verb_id = _required_text(form, "verb_id", location)
    else:
        supplied_id = form.get("verb_id", parent_id)
        if supplied_id != parent_id:
            raise ValidationError(f"{location}.verb_id conflicts with its parent verb")
        verb_id = parent_id
    return (
        _required_text(form, "conjugation_id", location),
        verb_id,
        _required_text(form, "tense", location),
        _required_text(form, "person", location),
        _required_text(form, "conjugated_form", location),
    )


def _form_rows(verbs: list, flat: list | None) -> Iterable[tuple]:
    if flat is not None:
        for i, verb in enumerate(verbs):
            if not isinstance(verb, dict):
                raise ValidationError(f"verbs[{i}] must be an object")
            if verb.get("conjugations"):
                raise ValidationError("Use either nested 'conjugations' or flat 'verb_conjugations', not both")
        for i, form in enumerate(flat):
            yield _form_row(form, f"verb_conjugations[{i}]", None)
    else:
        for i, verb in enumerate(verbs):
            verb_id = _required_text(verb, "verb_id", f"verbs[{i}]")
            forms = verb.get("conjugations", [])
            if not isinstance(forms, list):
                raise ValidationError(f"verbs[{i}].conjugations must be a list")
            for j, form in enumerate(forms):
                yield _form_row(form, f"verbs[{i}].conjugations[{j}]", verb_id)


def _insert_batches(db: sqlite3.Connection, statement: str, rows: Iterable[tuple]) -> int:
    batch = []
    count = 0
    for row in rows:
        batch.append(row)
        if len(batch) == BATCH_SIZE:
            db.executemany(statement, batch)
            count += len(batch)
            batch.clear()
    if batch:
        db.executemany(statement, batch)
        count += len(batch)
    return count


def verify_orphan_forms(db: sqlite3.Connection) -> None:
    """Detect orphan conjugations independently of the connection's FK setting."""
    orphan = db.execute("""
        SELECT c.conjugation_id
        FROM verb_conjugations AS c
        LEFT JOIN verbs AS v ON v.verb_id = c.verb_id
        WHERE v.verb_id IS NULL
        LIMIT 1
    """).fetchone()
    if orphan is not None or db.execute("PRAGMA foreign_key_check").fetchone() is not None:
        raise ValidationError(f"Orphan conjugation detected: {orphan[0] if orphan else 'foreign key violation'}")


def verify_conjugation_index(db: sqlite3.Connection) -> None:
    """Verify there is a concrete composite index in (verb_id, tense) order."""
    for index in db.execute("PRAGMA index_list('verb_conjugations')"):
        index_name = index[1]
        columns = [column[2] for column in db.execute(
            'PRAGMA index_info("' + index_name.replace('"', '""') + '")'
        )]
        if columns[:2] == ["verb_id", "tense"] and not index[4]:
            return
    raise ValidationError("Missing non-partial index on verb_conjugations(verb_id, tense)")


def verify_database(db: sqlite3.Connection) -> None:
    verify_orphan_forms(db)
    verify_conjugation_index(db)


def build_database(input_path: Path, output_path: Path, overwrite: bool = False) -> tuple[int, int]:
    """Generate and validate a database, publishing it only on full success.

    Existing outputs are protected by default. --overwrite uses atomic replacement.
    """
    input_path = Path(input_path)
    output_path = Path(output_path)
    if input_path.resolve() == output_path.resolve():
        raise ValueError("Input and output paths must differ")
    if output_path.exists() and not overwrite:
        raise FileExistsError(f"Refusing to overwrite {output_path}; pass --overwrite explicitly")
    with input_path.open("r", encoding="utf-8") as source:
        verbs, flat = _dataset(json.load(source))
    schema = SCHEMA_PATH.read_text(encoding="utf-8")
    fd, tmp_name = tempfile.mkstemp(prefix=f".{output_path.name}.", suffix=".tmp", dir=output_path.parent)
    os.close(fd)
    try:
        db = sqlite3.connect(tmp_name)
        try:
            db.execute("PRAGMA foreign_keys = ON")
            db.executescript(schema)
            verb_count = _insert_batches(
                db, "INSERT INTO verbs (verb_id, infinitive, translation_ar, frequency_rank) VALUES (?, ?, ?, ?)",
                _verb_rows(verbs),
            )
            form_count = _insert_batches(
                db, "INSERT INTO verb_conjugations (conjugation_id, verb_id, tense, person, conjugated_form) VALUES (?, ?, ?, ?, ?)",
                _form_rows(verbs, flat),
            )
            verify_database(db)
            db.commit()
        finally:
            db.close()
        if overwrite:
            os.replace(tmp_name, output_path)
        else:
            os.link(tmp_name, output_path)  # atomic no-clobber publication
        return verb_count, form_count
    finally:
        if os.path.exists(tmp_name):
            os.unlink(tmp_name)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="UTF-8 JSON verb dataset")
    parser.add_argument("--output", required=True, type=Path, help="Destination SQLite database")
    parser.add_argument("--overwrite", action="store_true", help="Explicitly replace an existing output atomically")
    args = parser.parse_args()
    try:
        verbs, forms = build_database(args.input, args.output, overwrite=args.overwrite)
    except (OSError, ValueError, sqlite3.Error) as exc:
        parser.exit(1, f"Morphology build failed: {exc}\n")
    print(f"Created {args.output}: {verbs} verbs, {forms} conjugations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
