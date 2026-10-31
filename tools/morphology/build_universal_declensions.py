#!/usr/bin/env python3
"""Compile reviewed noun, adjective and pronoun declensions to offline SQLite.

JSON input: {"nominals": [{"id", "lemma", "part_of_speech", "gender",
"number", "declensions": [{"id", "grammatical_case", "number",
"definiteness", "inflected_form"}]}]}. Alternatively provide a top-level
"nominal_declensions" array whose forms include "nominal_id"; never mix
nested and flat forms. A bare list of nominals is also supported.

No declensions are generated or inferred; supplied grammatical labels are
normalized. For mixed-language inputs, namespace identifiers explicitly.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sqlite3
import tempfile
import unicodedata
from pathlib import Path
from typing import Any, Iterable, Iterator

SCHEMA_PATH = Path(__file__).with_name("declension_schema.sql")
BATCH_SIZE = 1000
_PARTS_OF_SPEECH = frozenset({"noun", "adjective", "pronoun"})
_LABEL_RE = re.compile(r"^[a-z][a-z0-9_-]*$")


class ValidationError(ValueError):
    """The input dataset or final database violates the nominal contract."""


def _text(data: dict[str, Any], key: str, at: str) -> str:
    value = data.get(key)
    if not isinstance(value, str) or not value.strip():
        raise ValidationError(f"{at}.{key} must be non-empty text")
    value = unicodedata.normalize("NFC", value.strip())
    if len(value) > 2000 or any(unicodedata.category(c) in ("Cc", "Cf") for c in value):
        raise ValidationError(f"{at}.{key} contains invalid text or controls")
    return value


def _label(data: dict[str, Any], key: str, at: str) -> str:
    value = _text(data, key, at).casefold()
    if not _LABEL_RE.fullmatch(value):
        raise ValidationError(f"{at}.{key} must be an ASCII grammatical label")
    return value


def _dataset(data: object) -> tuple[list[Any], list[Any] | None]:
    if isinstance(data, list):
        data = {"nominals": data}
    if not isinstance(data, dict) or not isinstance(data.get("nominals"), list):
        raise ValidationError("Input must be a nominal list or object with a 'nominals' list")
    if set(data) - {"nominals", "nominal_declensions", "languageCode"}:
        raise ValidationError("Unexpected dataset keys")
    if "languageCode" in data:
        _text(data, "languageCode", "dataset")
    flat = data.get("nominal_declensions")
    if "nominal_declensions" in data and not isinstance(flat, list):
        raise ValidationError("'nominal_declensions' must be a list")
    if not data["nominals"]:
        raise ValidationError("Dataset requires at least one nominal")
    return data["nominals"], flat


def _nominal_rows(nominals: list[Any]) -> Iterator[tuple[str, ...]]:
    for i, item in enumerate(nominals):
        at = f"nominals[{i}]"
        if not isinstance(item, dict):
            raise ValidationError(f"{at} must be an object")
        part_of_speech = _label(item, "part_of_speech", at)
        if part_of_speech not in _PARTS_OF_SPEECH:
            raise ValidationError(f"{at}.part_of_speech must be noun, adjective, or pronoun")
        yield (
            _text(item, "id", at),
            _text(item, "lemma", at),
            part_of_speech,
            _label(item, "gender", at),
            _label(item, "number", at),
        )


def _declension_row(item: object, at: str, parent_id: str | None) -> tuple[str, ...]:
    if not isinstance(item, dict):
        raise ValidationError(f"{at} must be an object")
    if parent_id is None:
        nominal_id = _text(item, "nominal_id", at)
    else:
        nominal_id = _text(item, "nominal_id", at) if "nominal_id" in item else parent_id
        if nominal_id != parent_id:
            raise ValidationError(f"{at}.nominal_id differs from enclosing nominal")
    return (
        _text(item, "id", at),
        nominal_id,
        _label(item, "grammatical_case", at),
        _label(item, "number", at),
        _label(item, "definiteness", at),
        _text(item, "inflected_form", at),
    )


def _declension_rows(nominals: list[Any], flat: list[Any] | None) -> Iterator[tuple[str, ...]]:
    if flat is not None:
        for i, nominal in enumerate(nominals):
            if not isinstance(nominal, dict):
                raise ValidationError(f"nominals[{i}] must be an object")
            if "declensions" in nominal:
                raise ValidationError("Do not mix nested 'declensions' with flat 'nominal_declensions'")
        for i, form in enumerate(flat):
            yield _declension_row(form, f"nominal_declensions[{i}]", None)
    else:
        for i, nominal in enumerate(nominals):
            at = f"nominals[{i}]"
            if not isinstance(nominal, dict):
                raise ValidationError(f"{at} must be an object")
            nominal_id = _text(nominal, "id", at)
            forms = nominal.get("declensions", [])
            if not isinstance(forms, list):
                raise ValidationError(f"{at}.declensions must be a list")
            for j, form in enumerate(forms):
                yield _declension_row(form, f"{at}.declensions[{j}]", nominal_id)


def _insert_batches(db: sqlite3.Connection, sql: str, rows: Iterable[tuple[str, ...]], batch_size: int) -> int:
    count = 0
    batch: list[tuple[str, ...]] = []
    for row in rows:
        batch.append(row)
        if len(batch) == batch_size:
            db.executemany(sql, batch)
            count += len(batch)
            batch.clear()
    if batch:
        db.executemany(sql, batch)
        count += len(batch)
    return count


def verify_orphan_declensions(db: sqlite3.Connection) -> None:
    orphan = db.execute("""
        SELECT d.id FROM nominal_declensions AS d
        LEFT JOIN nominals AS n ON n.id = d.nominal_id
        WHERE n.id IS NULL LIMIT 1
    """).fetchone()
    if orphan or db.execute("PRAGMA foreign_key_check").fetchone():
        raise ValidationError(f"Orphan nominal declension: {orphan[0] if orphan else 'foreign key violation'}")


def verify_declension_index(db: sqlite3.Connection) -> None:
    for row in db.execute("PRAGMA index_list('nominal_declensions')"):
        columns = [part[2] for part in db.execute(
            'PRAGMA index_info("' + row[1].replace('"', '""') + '")'
        )]
        if columns[:3] == ["nominal_id", "grammatical_case", "number"] and not row[4]:
            return
    raise ValidationError("Missing composite index (nominal_id, grammatical_case, number)")


def verify_database(db: sqlite3.Connection) -> None:
    verify_orphan_declensions(db)
    verify_declension_index(db)
    if db.execute("PRAGMA integrity_check").fetchone() != ("ok",):
        raise ValidationError("SQLite integrity_check failed")


def build_database(
    input_path: Path, output_path: Path, *, overwrite: bool = False, batch_size: int = BATCH_SIZE
) -> tuple[int, int]:
    """Batch insert into a private temp database, publish atomically on success."""
    input_path, output_path = Path(input_path), Path(output_path)
    if input_path.resolve() == output_path.resolve():
        raise ValueError("Input and output paths must differ")
    if type(batch_size) is not int or batch_size < 1:
        raise ValueError("batch_size must be a positive integer")
    if output_path.exists() and not overwrite:
        raise FileExistsError(f"Refusing to overwrite {output_path}; use --overwrite")
    with input_path.open("r", encoding="utf-8") as handle:
        nominals, flat = _dataset(json.load(handle))
    schema = SCHEMA_PATH.read_text(encoding="utf-8")
    fd, temp_path = tempfile.mkstemp(
        prefix=f".{output_path.name}.", suffix=".tmp", dir=output_path.parent
    )
    os.close(fd)
    try:
        db = sqlite3.connect(temp_path)
        try:
            db.execute("PRAGMA foreign_keys = ON")
            db.executescript(schema)
            db.execute("BEGIN IMMEDIATE")
            try:
                count_nominals = _insert_batches(
                    db, "INSERT INTO nominals (id, lemma, part_of_speech, gender, number) VALUES (?, ?, ?, ?, ?)",
                    _nominal_rows(nominals), batch_size,
                )
                count_forms = _insert_batches(
                    db, "INSERT INTO nominal_declensions (id, nominal_id, grammatical_case, number, definiteness, inflected_form) VALUES (?, ?, ?, ?, ?, ?)",
                    _declension_rows(nominals, flat), batch_size,
                )
                verify_database(db)
                db.commit()
            except Exception:
                db.rollback()
                raise
        finally:
            db.close()
        if overwrite:
            os.replace(temp_path, output_path)
        else:
            os.link(temp_path, output_path)  # atomic, no-clobber publication
        return count_nominals, count_forms
    finally:
        if os.path.exists(temp_path):
            os.unlink(temp_path)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="UTF-8 nominal JSON input")
    parser.add_argument("--output", required=True, type=Path, help="Destination SQLite file")
    parser.add_argument("--overwrite", action="store_true", help="Explicitly replace existing output")
    parser.add_argument("--batch-size", type=int, default=BATCH_SIZE)
    args = parser.parse_args()
    try:
        nominals, forms = build_database(args.input, args.output, overwrite=args.overwrite, batch_size=args.batch_size)
    except (OSError, ValueError, sqlite3.Error) as exc:
        parser.exit(1, f"Declension build failed: {exc}\n")
    print(f"Created {args.output}: {nominals} nominals, {forms} declensions")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
