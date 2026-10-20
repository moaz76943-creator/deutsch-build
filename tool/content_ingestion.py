#!/usr/bin/env python3
"""Validate language-owned editable content manifests.

The manifest is a build-time contract: it identifies the editable vocabulary,
verb and audio sources belonging to one learning language. It does not make
those files runtime-canonical and never rewrites them during validation.
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path
import sys
import shutil
import tempfile

ROOT = Path(__file__).resolve().parents[1]
GERMAN_DIR = ROOT / "content" / "german"
MANIFEST = GERMAN_DIR / "content_manifest.json"
AUDIO_MANIFEST = GERMAN_DIR / "audio_manifest.json"


def _read_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid JSON source {path}: {exc}") from exc


def _relative_source(base: Path, value: object, field: str) -> Path:
    if not isinstance(value, str) or not value:
        raise ValueError(f"manifest field {field} must be a non-empty string")
    path = Path(value)
    if path.is_absolute():
        raise ValueError(f"manifest field {field} must use a relative path")
    resolved = (base / path).resolve()
    try:
        resolved.relative_to(ROOT.resolve())
    except ValueError as exc:
        raise ValueError(f"manifest field {field} escapes the repository") from exc
    return resolved


def _validate_audio(audio_path: Path) -> int:
    audio = _read_json(audio_path)
    if not isinstance(audio, dict) or set(audio) != {"version", "entries"}:
        raise ValueError("audio manifest must contain exactly version and entries")
    if audio["version"] != 1 or not isinstance(audio["entries"], list):
        raise ValueError("audio manifest version/entries shape mismatch")
    allowed = {"contentId", "word", "sentence", "pronunciation"}
    seen: set[str] = set()
    for entry in audio["entries"]:
        if not isinstance(entry, dict) or "contentId" not in entry:
            raise ValueError("audio entry must contain contentId")
        if set(entry) - allowed:
            raise ValueError("audio entry contains an unsupported field")
        content_id = entry["contentId"]
        if not isinstance(content_id, str) or not content_id:
            raise ValueError("audio contentId must be a non-empty string")
        if content_id in seen:
            raise ValueError(f"duplicate audio contentId: {content_id}")
        seen.add(content_id)
        for key, value in entry.items():
            if not isinstance(value, str) or not value:
                raise ValueError(f"audio field {key} must be a non-empty string")
            if key != "contentId":
                path = Path(value)
                if path.is_absolute() or ".." in path.parts:
                    raise ValueError(f"audio field {key} must use a safe relative path")
    return len(audio["entries"])


CONTENT_FIELDS = ("id", "german", "arabic", "sentence", "sentenceAr", "topic", "skill", "article", "plural", "accepted")
VERB_FIELDS = ("infinitive", "arabic", "group", "person", "personAr", "form", "past", "pastArabic", "example", "exampleAr", "pastExample", "pastExampleAr")


def _validate_content_row(row: object) -> None:
    if not isinstance(row, dict) or set(row) != set(CONTENT_FIELDS):
        raise ValueError("batch content item schema mismatch")
    if not isinstance(row["id"], str) or not row["id"]:
        raise ValueError("batch content id must be a non-empty string")
    if not isinstance(row["accepted"], list) or not all(isinstance(v, str) and v for v in row["accepted"]):
        raise ValueError("batch accepted must be a list of non-empty strings")
    for key in CONTENT_FIELDS:
        if key not in {"accepted"} and not isinstance(row[key], str):
            raise ValueError(f"batch content field {key} must be a string")


def _validate_verb_row(row: object) -> None:
    if not isinstance(row, dict) or set(row) != set(VERB_FIELDS):
        raise ValueError("batch verb row schema mismatch")
    for key in VERB_FIELDS:
        if not isinstance(row[key], str):
            raise ValueError(f"batch verb field {key} must be a string")


def _validate_batch(batch: object, content_path: Path, verb_path: Path) -> tuple[list[dict[str, object]], list[dict[str, object]], list[dict[str, str]]]:
    if not isinstance(batch, dict) or set(batch) != {"version", "languageCode", "contentItems", "verbConjugations", "audio"}:
        raise ValueError("bulk batch schema mismatch")
    if batch["version"] != 1 or not isinstance(batch["languageCode"], str) or not batch["languageCode"]:
        raise ValueError("bulk batch version/languageCode mismatch")
    if not isinstance(batch["contentItems"], list) or not isinstance(batch["verbConjugations"], list) or not isinstance(batch["audio"], list):
        raise ValueError("bulk batch arrays are required")

    existing_content = _read_json(content_path)
    if not isinstance(existing_content, list):
        raise ValueError("existing content source must be an array")
    existing_ids = {row.get("id") for row in existing_content if isinstance(row, dict)}
    batch_ids: set[str] = set()
    content_rows: list[dict[str, object]] = []
    for row in batch["contentItems"]:
        _validate_content_row(row)
        content_id = row["id"]
        if content_id in existing_ids:
            raise ValueError(f"duplicate existing content id: {content_id}")
        if content_id in batch_ids:
            raise ValueError(f"duplicate batch content id: {content_id}")
        batch_ids.add(content_id)
        content_rows.append(row)

    existing_verbs = _read_json(verb_path)
    if not isinstance(existing_verbs, list):
        raise ValueError("existing verb source must be an array")
    existing_verb_keys = {(row.get("infinitive"), row.get("person"), row.get("form")) for row in existing_verbs if isinstance(row, dict)}
    batch_verb_keys: set[tuple[object, object, object]] = set()
    verb_rows: list[dict[str, object]] = []
    for row in batch["verbConjugations"]:
        _validate_verb_row(row)
        key = (row["infinitive"], row["person"], row["form"])
        if key in existing_verb_keys:
            raise ValueError(f"duplicate existing verb row: {key[0]} / {key[1]} / {key[2]}")
        if key in batch_verb_keys:
            raise ValueError(f"duplicate batch verb row: {key[0]} / {key[1]} / {key[2]}")
        batch_verb_keys.add(key)
        verb_rows.append(row)

    audio_rows: list[dict[str, str]] = []
    audio_seen: set[str] = set()
    for entry in batch["audio"]:
        if not isinstance(entry, dict) or set(entry) - {"contentId", "word", "sentence", "pronunciation"} or "contentId" not in entry:
            raise ValueError("bulk audio entry schema mismatch")
        content_id = entry["contentId"]
        if content_id not in batch_ids:
            raise ValueError(f"audio contentId is not in batch: {content_id}")
        if content_id in audio_seen:
            raise ValueError(f"duplicate batch audio contentId: {content_id}")
        audio_seen.add(content_id)
        for key, value in entry.items():
            if not isinstance(value, str) or not value:
                raise ValueError(f"bulk audio field {key} must be a non-empty string")
            if key != "contentId":
                path = Path(value)
                if path.is_absolute() or ".." in path.parts:
                    raise ValueError(f"bulk audio field {key} must use a safe relative path")
        audio_rows.append(entry)
    return content_rows, verb_rows, audio_rows


def validate_audio_assets(audio_manifest_path: Path, audio_root: Path, content_path: Path) -> tuple[int, int]:
    """Validate manifest references against real audio assets without mutating files."""
    audio = _read_json(audio_manifest_path)
    content = _read_json(content_path)
    if not isinstance(content, list):
        raise ValueError("content source must be an array")
    content_ids = {row.get("id") for row in content if isinstance(row, dict)}
    if not isinstance(audio, dict) or audio.get("version") != 1 or not isinstance(audio.get("entries"), list):
        raise ValueError("audio manifest schema mismatch")

    referenced: set[Path] = set()
    for entry in audio["entries"]:
        if not isinstance(entry, dict) or "contentId" not in entry:
            raise ValueError("audio entry must contain contentId")
        content_id = entry["contentId"]
        if content_id not in content_ids:
            raise ValueError(f"audio contentId is not in content: {content_id}")
        for key, value in entry.items():
            if key == "contentId":
                continue
            if not isinstance(value, str) or not value:
                raise ValueError(f"audio field {key} must be a non-empty string")
            relative = Path(value)
            if relative.is_absolute() or ".." in relative.parts:
                raise ValueError(f"audio field {key} must use a safe relative path")
            asset = (audio_root / relative).resolve()
            try:
                asset.relative_to(audio_root.resolve())
            except ValueError as exc:
                raise ValueError(f"audio field {key} escapes the audio root") from exc
            if not asset.is_file():
                raise ValueError(f"missing audio asset: {relative}")
            referenced.add(asset)

    audio_extensions = {".aac", ".flac", ".m4a", ".mp3", ".ogg", ".wav"}
    actual = {path.resolve() for path in audio_root.rglob("*") if path.is_file() and path.suffix.lower() in audio_extensions} if audio_root.exists() else set()
    orphaned = sorted(path.relative_to(audio_root.resolve()).as_posix() for path in actual - referenced)
    if orphaned:
        raise ValueError("orphan audio assets: " + ", ".join(orphaned))
    return len(audio["entries"]), len(referenced)


def prepare_batch(source: Path, output: Path) -> tuple[int, int, int]:
    batch = _read_json(source)
    content_rows, verb_rows, audio_rows = _validate_batch(
        batch, MANIFEST.parent / "../content_items.json", MANIFEST.parent / "../verb_conjugations.json"
    )
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(batch, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
    return len(content_rows), len(verb_rows), len(audio_rows)


def apply_batch(source: Path, content_path: Path, verb_path: Path, generated_dir: Path, audio_path: Path | None = None) -> tuple[int, int, int]:
    batch = _read_json(source)
    content_rows, verb_rows, audio_rows = _validate_batch(batch, content_path, verb_path)
    existing_content = _read_json(content_path)
    existing_verbs = _read_json(verb_path)
    if not isinstance(existing_content, list) or not isinstance(existing_verbs, list):
        raise ValueError("existing sources must be arrays")
    merged_content = existing_content + content_rows
    merged_verbs = existing_verbs + verb_rows
    target_audio = audio_path or (GERMAN_DIR / "audio_manifest.json")
    existing_audio = _read_json(target_audio) if target_audio.exists() else {"version": 1, "entries": []}
    if not isinstance(existing_audio, dict) or existing_audio.get("version") != 1 or not isinstance(existing_audio.get("entries"), list):
        raise ValueError("existing audio manifest schema mismatch")
    existing_audio_ids = {entry.get("contentId") for entry in existing_audio["entries"] if isinstance(entry, dict)}
    for entry in audio_rows:
        if entry["contentId"] in existing_audio_ids:
            raise ValueError(f"duplicate existing audio contentId: {entry['contentId']}")
    merged_audio = {"version": 1, "entries": existing_audio["entries"] + audio_rows}

    generated_dir.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="content_apply_", dir=str(generated_dir.parent)) as tmp:
        tmp_path = Path(tmp)
        temp_content = tmp_path / "content_items.json"
        temp_verbs = tmp_path / "verb_conjugations.json"
        temp_audio = tmp_path / "audio_manifest.json"
        temp_generated = tmp_path / "generated"
        temp_content.write_text(json.dumps(merged_content, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        temp_verbs.write_text(json.dumps(merged_verbs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        temp_audio.write_text(json.dumps(merged_audio, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        from content_compiler import compile_to, parity
        compile_to(temp_generated, temp_content, temp_verbs)
        parity(temp_generated, temp_content, temp_verbs)
        backup_dir = tmp_path / "backup"
        backup_dir.mkdir()
        shutil.copy2(content_path, backup_dir / content_path.name)
        shutil.copy2(verb_path, backup_dir / verb_path.name)
        if target_audio.exists():
            shutil.copy2(target_audio, backup_dir / target_audio.name)
        try:
            content_path.write_bytes(temp_content.read_bytes())
            verb_path.write_bytes(temp_verbs.read_bytes())
            target_audio.parent.mkdir(parents=True, exist_ok=True)
            target_audio.write_bytes(temp_audio.read_bytes())
            if generated_dir.exists():
                shutil.rmtree(generated_dir)
            shutil.copytree(temp_generated, generated_dir)
        except Exception:
            content_path.write_bytes((backup_dir / content_path.name).read_bytes())
            verb_path.write_bytes((backup_dir / verb_path.name).read_bytes())
            if (backup_dir / target_audio.name).exists():
                target_audio.write_bytes((backup_dir / target_audio.name).read_bytes())
            raise
    return len(merged_content), len(merged_verbs), len(merged_audio["entries"])



def _source_audio_asset(source_root: Path, relative: str) -> Path:
    path = Path(relative)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"source audio path must be safe and relative: {relative}")
    asset = (source_root / path).resolve()
    try:
        asset.relative_to(source_root.resolve())
    except ValueError as exc:
        raise ValueError(f"source audio path escapes batch directory: {relative}") from exc
    if not asset.is_file():
        raise ValueError(f"missing source audio asset: {relative}")
    if asset.suffix.lower() not in {".aac", ".flac", ".m4a", ".mp3", ".ogg", ".wav"}:
        raise ValueError(f"unsupported source audio asset: {relative}")
    return asset


def _prepare_source_assets(audio_rows: list[dict[str, str]], source_dir: Path, audio_root: Path) -> list[tuple[dict[str, str], Path, Path]]:
    source_assets: list[tuple[dict[str, str], Path, Path]] = []
    seen_destinations: set[Path] = set()
    for entry in audio_rows:
        fields = [value for key, value in entry.items() if key != "contentId"]
        for value in fields:
            src = _source_audio_asset(source_dir, value)
            destination = (audio_root / Path(value)).resolve()
            try:
                destination.relative_to(audio_root.resolve())
            except ValueError as exc:
                raise ValueError(f"audio destination escapes audio root: {value}") from exc
            if destination in seen_destinations:
                raise ValueError(f"duplicate source audio destination: {value}")
            seen_destinations.add(destination)
            if destination.exists():
                raise ValueError(f"existing target audio asset: {value}")
            source_assets.append((entry, src, destination))
    return source_assets


def _merge_content_data(
    batch_path: Path,
    content_path: Path,
    verb_path: Path,
    audio_manifest_path: Path,
    content_rows: list[dict[str, object]],
    verb_rows: list[dict[str, object]],
    audio_rows: list[dict[str, str]],
) -> tuple[list[object], list[object], dict[str, object]]:
    from content_quality_gate import review_batch
    quality = review_batch(batch_path, existing_content_path=content_path)
    if quality["status"] != "PASS":
        detail = "; ".join(quality["errors"])
        raise ValueError(f"content quality gate failed: {detail}")

    existing_content = _read_json(content_path)
    existing_verbs = _read_json(verb_path)
    if not isinstance(existing_content, list) or not isinstance(existing_verbs, list):
        raise ValueError("existing sources must be arrays")
    merged_content = existing_content + content_rows
    merged_verbs = existing_verbs + verb_rows
    existing_audio = _read_json(audio_manifest_path) if audio_manifest_path.exists() else {"version": 1, "entries": []}
    if not isinstance(existing_audio, dict) or existing_audio.get("version") != 1 or not isinstance(existing_audio.get("entries"), list):
        raise ValueError("existing audio manifest schema mismatch")
    existing_audio_ids = {entry.get("contentId") for entry in existing_audio["entries"] if isinstance(entry, dict)}
    for entry in audio_rows:
        if entry["contentId"] in existing_audio_ids:
            raise ValueError(f"duplicate existing audio contentId: {entry['contentId']}")
    merged_audio = {"version": 1, "entries": existing_audio["entries"] + audio_rows}
    return merged_content, merged_verbs, merged_audio


def _execute_publish_transaction(
    merged_content: list[object],
    merged_verbs: list[object],
    merged_audio: dict[str, object],
    source_assets: list[tuple[dict[str, str], Path, Path]],
    content_path: Path,
    verb_path: Path,
    audio_manifest_path: Path,
    generated_dir: Path,
    audio_root: Path,
) -> None:
    generated_dir.parent.mkdir(parents=True, exist_ok=True)
    audio_root.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="content_publish_", dir=str(generated_dir.parent)) as tmp:
        tmp_path = Path(tmp)
        temp_content = tmp_path / "content_items.json"
        temp_verbs = tmp_path / "verb_conjugations.json"
        temp_audio_manifest = tmp_path / "audio_manifest.json"
        temp_generated = tmp_path / "generated"
        temp_audio = tmp_path / "audio"
        temp_content.write_text(json.dumps(merged_content, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        temp_verbs.write_text(json.dumps(merged_verbs, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        temp_audio_manifest.write_text(json.dumps(merged_audio, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")
        from content_compiler import compile_to, parity
        compile_to(temp_generated, temp_content, temp_verbs)
        parity(temp_generated, temp_content, temp_verbs)
        for _, src, destination in source_assets:
            staged = temp_audio / destination.relative_to(audio_root.resolve())
            staged.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(src, staged)

        backup = tmp_path / "backup"
        backup.mkdir()
        shutil.copy2(content_path, backup / "content_items.json")
        shutil.copy2(verb_path, backup / "verb_conjugations.json")
        if audio_manifest_path.exists():
            shutil.copy2(audio_manifest_path, backup / "audio_manifest.json")
        if generated_dir.exists():
            shutil.copytree(generated_dir, backup / "generated")
        if audio_root.exists():
            shutil.copytree(audio_root, backup / "audio")
        try:
            content_path.write_bytes(temp_content.read_bytes())
            verb_path.write_bytes(temp_verbs.read_bytes())
            audio_manifest_path.parent.mkdir(parents=True, exist_ok=True)
            audio_manifest_path.write_bytes(temp_audio_manifest.read_bytes())
            if generated_dir.exists():
                shutil.rmtree(generated_dir)
            shutil.copytree(temp_generated, generated_dir)
            for _, _, destination in source_assets:
                staged = temp_audio / destination.relative_to(audio_root.resolve())
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(staged, destination)
        except Exception:
            content_path.write_bytes((backup / "content_items.json").read_bytes())
            verb_path.write_bytes((backup / "verb_conjugations.json").read_bytes())
            if (backup / "audio_manifest.json").exists():
                audio_manifest_path.write_bytes((backup / "audio_manifest.json").read_bytes())
            if (backup / "generated").exists():
                if generated_dir.exists():
                    shutil.rmtree(generated_dir)
                shutil.copytree(backup / "generated", generated_dir)
            if (backup / "audio").exists():
                if audio_root.exists():
                    shutil.rmtree(audio_root)
                shutil.copytree(backup / "audio", audio_root)
            raise


def publish_batch(
    source_dir: Path,
    content_path: Path,
    verb_path: Path,
    generated_dir: Path,
    audio_manifest_path: Path,
    audio_root: Path,
) -> tuple[int, int, int]:
    """atomically publish a reviewed content batch and its audio assets."""
    source_dir = source_dir.resolve()
    batch_path = source_dir / "batch.json"
    if not batch_path.is_file():
        raise ValueError("publish-batch requires batch.json inside the source directory")
    batch = _read_json(batch_path)
    content_rows, verb_rows, audio_rows = _validate_batch(batch, content_path, verb_path)
    source_assets = _prepare_source_assets(audio_rows, source_dir, audio_root)
    merged_content, merged_verbs, merged_audio = _merge_content_data(
        batch_path, content_path, verb_path, audio_manifest_path, content_rows, verb_rows, audio_rows
    )

    _execute_publish_transaction(
        merged_content, merged_verbs, merged_audio, source_assets,
        content_path, verb_path, audio_manifest_path, generated_dir, audio_root
    )

    return len(merged_content), len(merged_verbs), len(merged_audio["entries"])

def validate() -> tuple[int, int, int]:
    manifest = _read_json(MANIFEST)
    if not isinstance(manifest, dict) or set(manifest) != {"version", "languageCode", "contentItems", "verbConjugations", "audioManifest"}:
        raise ValueError("language content manifest schema mismatch")
    if manifest["version"] != 1:
        raise ValueError("unsupported language content manifest version")
    if not isinstance(manifest["languageCode"], str) or not manifest["languageCode"]:
        raise ValueError("languageCode must be a non-empty string")

    content_path = _relative_source(MANIFEST.parent, manifest["contentItems"], "contentItems")
    verb_path = _relative_source(MANIFEST.parent, manifest["verbConjugations"], "verbConjugations")
    audio_path = _relative_source(MANIFEST.parent, manifest["audioManifest"], "audioManifest")
    for path in (content_path, verb_path, audio_path):
        if not path.is_file():
            raise ValueError(f"manifest source is missing: {path.relative_to(ROOT)}")

    content = _read_json(content_path)
    verbs = _read_json(verb_path)
    if not isinstance(content, list) or not isinstance(verbs, list):
        raise ValueError("content and verb sources must be arrays")
    if not content:
        raise ValueError("content source must contain at least one row")

    content_ids: set[str] = set()
    for index, row in enumerate(content):
        if not isinstance(row, dict) or set(row) != set(CONTENT_FIELDS):
            raise ValueError(f"content row schema mismatch at index {index}")
        content_id = row.get("id")
        if not isinstance(content_id, str) or not content_id:
            raise ValueError(f"content id must be non-empty at index {index}")
        if content_id in content_ids:
            raise ValueError(f"duplicate content id: {content_id}")
        content_ids.add(content_id)
        if not all(
            isinstance(row[key], str)
            for key in CONTENT_FIELDS
            if key != "accepted"
        ):
            raise ValueError(f"content string field type mismatch: {content_id}")
        if not isinstance(row["accepted"], list) or not all(
            isinstance(value, str) for value in row["accepted"]
        ):
            raise ValueError(f"accepted field type mismatch: {content_id}")

    for row in verbs:
        _validate_verb_row(row)

    audio_count = _validate_audio(audio_path)
    return len(content), len(verbs), audio_count


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("validate", "validate-audio", "prepare-batch", "apply-batch", "publish-batch"))
    parser.add_argument("--source", type=Path)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    try:
        if args.command == "validate":
            content, verbs, audio = validate()
            print(f"content_items={content} verb_conjugations={verbs} audio_entries={audio} validation=PASS")
        elif args.command == "validate-audio":
            entries, assets = validate_audio_assets(AUDIO_MANIFEST, GERMAN_DIR / "audio", GERMAN_DIR / "../content_items.json")
            print(f"audio_entries={entries} audio_assets={assets} audio_validation=PASS")
        elif args.command == "prepare-batch":
            if args.source is None or args.output is None:
                raise ValueError("prepare-batch requires --source and --output")
            content, verbs, audio = prepare_batch(args.source, args.output)
            print(f"batch_content_items={content} batch_verb_conjugations={verbs} batch_audio_entries={audio} preparation=PASS")
        elif args.command == "apply-batch":
            if args.source is None:
                raise ValueError("apply-batch requires --source")
            content, verbs, audio = apply_batch(
                args.source, GERMAN_DIR / "../content_items.json", GERMAN_DIR / "../verb_conjugations.json",
                GERMAN_DIR / "generated", AUDIO_MANIFEST
            )
            print(f"content_items={content} verb_conjugations={verbs} audio_entries={audio} application=PASS")
        else:
            if args.source is None:
                raise ValueError("publish-batch requires --source directory")
            content, verbs, audio = publish_batch(
                args.source, GERMAN_DIR / "../content_items.json", GERMAN_DIR / "../verb_conjugations.json",
                GERMAN_DIR / "generated", AUDIO_MANIFEST, GERMAN_DIR / "audio"
            )
            print(f"content_items={content} verb_conjugations={verbs} audio_entries={audio} publication=PASS")
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
