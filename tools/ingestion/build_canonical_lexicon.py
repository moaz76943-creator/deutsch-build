#!/usr/bin/env python3
"""Build factory-compatible CEFR A1/A2 canonical sources, fully offline.

With no --input, emits a small ORIGINAL EDITORIAL STARTER, not an official
CEFR inventory. For production, supply reviewed, properly licensed JSON/JSONL
records via --input. Neither schema validation nor CEFR tagging constitutes a
linguistic certification.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sys
import tempfile
import unicodedata
from pathlib import Path
from typing import Any

LANGUAGES = {
    "en": ("English", "ltr", "ar"),
    "fr": ("Français", "ltr", "ar"),
    "es": ("Español", "ltr", "ar"),
    "tr": ("Türkçe", "ltr", "ar"),
    "ar": ("العربية", "rtl", "en"),
}
REQUIRED = {"id", "surface", "partOfSpeech", "languageCode", "textDirection",
            "definitions", "translations", "examples", "cefr"}
ALLOWED = REQUIRED | {"sourceRef", "license"}
BIDI_CONTROLS = set(chr(n) for n in (*range(0x202A, 0x202F), *range(0x2066, 0x206A)))
FALLBACK = re.compile(r"__TEMPLATE_TEXT__|<untranslated>|TRANSLATE_ME|\bTODO\b|\bTBD\b", re.I)
ID_PATTERN = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$")

# surface, part of speech, native definition, native example,
# explicit direct translation, example translation (Arabic except ar -> English)
STARTER: dict[str, list[tuple[str, str, str, str, str, str]]] = {
    "en": [
        ("hello", "interjection", "A greeting when meeting someone", "Hello, everyone!", "مرحبًا", "مرحبًا بالجميع!"),
        ("water", "noun", "A liquid people drink", "The water is cold.", "ماء", "الماء بارد."),
        ("book", "noun", "A set of pages to read", "I have a book.", "كتاب", "لدي كتاب."),
        ("house", "noun", "A building where people live", "This house is small.", "بيت", "هذا البيت صغير."),
        ("eat", "verb", "To consume food", "We eat breakfast.", "يأكل", "نأكل الفطور."),
        ("drink", "verb", "To swallow a liquid", "I drink water.", "يشرب", "أشرب الماء."),
        ("school", "noun", "A place where pupils learn", "The school is near.", "مدرسة", "المدرسة قريبة."),
        ("today", "adverb", "On the present day", "Today is Monday.", "اليوم", "اليوم هو الاثنين."),
        ("appointment", "noun", "An arranged meeting at a specific time", "I have an appointment tomorrow.", "موعد", "لدي موعد غدًا."),
        ("directions", "noun", "Instructions for finding a route", "Can you give me directions?", "إرشادات الطريق", "هل يمكنك إرشادي إلى الطريق؟"),
        ("improve", "verb", "To make something better", "I want to improve my writing.", "يحسن", "أريد تحسين كتابتي."),
        ("decide", "verb", "To choose after considering options", "We need to decide today.", "يقرر", "علينا أن نقرر اليوم."),
    ],
    "fr": [
        ("bonjour", "interjection", "Formule de salutation", "Bonjour à tous !", "مرحبًا", "مرحبًا بالجميع!"),
        ("eau", "noun", "Liquide que l'on boit", "L'eau est froide.", "ماء", "الماء بارد."),
        ("livre", "noun", "Ensemble de pages à lire", "J'ai un livre.", "كتاب", "لدي كتاب."),
        ("maison", "noun", "Bâtiment où l'on habite", "Cette maison est petite.", "بيت", "هذا البيت صغير."),
        ("manger", "verb", "Consommer de la nourriture", "Nous mangeons ensemble.", "يأكل", "نأكل معًا."),
        ("boire", "verb", "Avaler un liquide", "Je bois de l'eau.", "يشرب", "أشرب الماء."),
        ("école", "noun", "Lieu où les élèves apprennent", "L'école est proche.", "مدرسة", "المدرسة قريبة."),
        ("aujourd'hui", "adverb", "Le jour présent", "Aujourd'hui, il fait beau.", "اليوم", "الجو جميل اليوم."),
        ("rendez-vous", "noun", "Rencontre prévue à une heure donnée", "J'ai un rendez-vous demain.", "موعد", "لدي موعد غدًا."),
        ("itinéraire", "noun", "Chemin à suivre pour arriver quelque part", "Pouvez-vous m'indiquer l'itinéraire ?", "مسار", "هل يمكنك إرشادي إلى الطريق؟"),
        ("améliorer", "verb", "Rendre quelque chose meilleur", "Je veux améliorer mon français.", "يحسن", "أريد تحسين لغتي الفرنسية."),
        ("décider", "verb", "Faire un choix", "Nous devons décider aujourd'hui.", "يقرر", "علينا أن نقرر اليوم."),
    ],
    "es": [
        ("hola", "interjection", "Saludo al encontrarse con alguien", "¡Hola a todos!", "مرحبًا", "مرحبًا بالجميع!"),
        ("agua", "noun", "Líquido que bebemos", "El agua está fría.", "ماء", "الماء بارد."),
        ("libro", "noun", "Conjunto de páginas para leer", "Tengo un libro.", "كتاب", "لدي كتاب."),
        ("casa", "noun", "Edificio donde vive una persona", "Esta casa es pequeña.", "بيت", "هذا البيت صغير."),
        ("comer", "verb", "Tomar alimentos", "Comemos juntos.", "يأكل", "نأكل معًا."),
        ("beber", "verb", "Tomar un líquido", "Bebo agua.", "يشرب", "أشرب الماء."),
        ("escuela", "noun", "Lugar donde estudian los alumnos", "La escuela está cerca.", "مدرسة", "المدرسة قريبة."),
        ("hoy", "adverb", "En el día presente", "Hoy es lunes.", "اليوم", "اليوم هو الاثنين."),
        ("cita", "noun", "Encuentro acordado para una hora", "Tengo una cita mañana.", "موعد", "لدي موعد غدًا."),
        ("indicaciones", "noun", "Instrucciones para encontrar un lugar", "¿Me puedes dar indicaciones?", "إرشادات", "هل يمكنك إرشادي إلى الطريق؟"),
        ("mejorar", "verb", "Hacer que algo sea mejor", "Quiero mejorar mi español.", "يحسن", "أريد تحسين لغتي الإسبانية."),
        ("decidir", "verb", "Elegir entre opciones", "Tenemos que decidir hoy.", "يقرر", "علينا أن نقرر اليوم."),
    ],
    "tr": [
        ("merhaba", "interjection", "Karşılaşırken kullanılan selam", "Herkese merhaba!", "مرحبًا", "مرحبًا بالجميع!"),
        ("su", "noun", "İçilen sıvı", "Su soğuk.", "ماء", "الماء بارد."),
        ("kitap", "noun", "Okunan sayfalardan oluşan eser", "Bir kitabım var.", "كتاب", "لدي كتاب."),
        ("ev", "noun", "İnsanların yaşadığı yer", "Bu ev küçük.", "بيت", "هذا البيت صغير."),
        ("yemek", "verb", "Yiyecek tüketmek", "Birlikte yemek yiyoruz.", "يأكل", "نأكل معًا."),
        ("içmek", "verb", "Sıvı tüketmek", "Su içiyorum.", "يشرب", "أشرب الماء."),
        ("okul", "noun", "Öğrencilerin eğitim aldığı yer", "Okul yakın.", "مدرسة", "المدرسة قريبة."),
        ("bugün", "adverb", "İçinde bulunulan gün", "Bugün pazartesi.", "اليوم", "اليوم هو الاثنين."),
        ("randevu", "noun", "Belirli saat için ayarlanan görüşme", "Yarın randevum var.", "موعد", "لدي موعد غدًا."),
        ("yol tarifi", "noun", "Bir yere giden yolu anlatan bilgi", "Bana yol tarifi verebilir misin?", "إرشادات الطريق", "هل يمكنك إرشادي إلى الطريق؟"),
        ("geliştirmek", "verb", "Bir şeyi daha iyi hâle getirmek", "Türkçemi geliştirmek istiyorum.", "يحسن", "أريد تحسين لغتي التركية."),
        ("karar vermek", "verb", "Seçenekler arasında seçim yapmak", "Bugün karar vermeliyiz.", "يقرر", "علينا أن نقرر اليوم."),
    ],
    "ar": [
        ("مرحبا", "interjection", "تحية تقال عند اللقاء", "مرحبًا بالجميع!", "hello", "Hello, everyone!"),
        ("ماء", "noun", "سائل ضروري للحياة", "الماء بارد.", "water", "The water is cold."),
        ("كتاب", "noun", "صفحات مكتوبة أو مطبوعة للقراءة", "لدي كتاب.", "book", "I have a book."),
        ("بيت", "noun", "مكان يعيش فيه الإنسان", "هذا البيت صغير.", "house", "This house is small."),
        ("يأكل", "verb", "يتناول الطعام", "هو يأكل الفطور.", "eat", "He eats breakfast."),
        ("يشرب", "verb", "يتناول سائلًا", "هي تشرب الماء.", "drink", "She drinks water."),
        ("مدرسة", "noun", "مكان يتعلم فيه الطلاب", "المدرسة قريبة.", "school", "The school is near."),
        ("اليوم", "adverb", "اليوم الحالي", "اليوم يوم الاثنين.", "today", "Today is Monday."),
        ("موعد", "noun", "وقت محدد للقاء", "لدي موعد غدًا.", "appointment", "I have an appointment tomorrow."),
        ("إرشادات", "noun", "تعليمات تساعد على الوصول إلى مكان", "هل يمكنك إعطائي إرشادات الطريق؟", "directions", "Can you give me directions?"),
        ("يحسن", "verb", "يجعل الشيء أفضل", "يريد أن يحسن لغته.", "improve", "He wants to improve his language skills."),
        ("يقرر", "verb", "يختار بعد التفكير", "علينا أن نقرر اليوم.", "decide", "We need to decide today."),
    ],
}


def _text(value: Any, where: str) -> str:
    if not isinstance(value, str) or not value.strip() or len(value) > 2000:
        raise ValueError(f"{where} must be nonempty text (up to 2000 characters)")
    value = unicodedata.normalize("NFC", value.strip())
    if any(c in BIDI_CONTROLS or unicodedata.category(c) == "Cc" for c in value):
        raise ValueError(f"{where} contains control characters")
    if FALLBACK.search(value):
        raise ValueError(f"{where} contains template/fallback content")
    return value


def _direction(value: str, declared: str, where: str) -> None:
    for c in value:
        kind = unicodedata.bidirectional(c)
        if kind in ("L", "R", "AL"):
            actual = "ltr" if kind == "L" else "rtl"
            if actual != declared:
                raise ValueError(f"{where} has {actual} text, expected {declared}")
            return


def _record(entry: Any, language: str) -> dict[str, Any]:
    if not isinstance(entry, dict) or set(entry) - ALLOWED or REQUIRED - set(entry):
        raise ValueError(f"{language}: record must have {sorted(REQUIRED)}; optional sourceRef/license")
    if entry["languageCode"] != language:
        raise ValueError(f"{language}: languageCode mismatch")
    display, direction, _ = LANGUAGES[language]
    if entry["textDirection"] != direction:
        raise ValueError(f"{language}: textDirection must be {direction}")
    entry_id = _text(entry["id"], "id")
    if not ID_PATTERN.fullmatch(entry_id):
        raise ValueError(f"{language}: invalid id {entry_id}")
    surface = _text(entry["surface"], "surface")
    _direction(surface, direction, "surface")
    pos = _text(entry["partOfSpeech"], "partOfSpeech")
    if len(pos) > 64:
        raise ValueError(f"{language}: partOfSpeech too long")
    cefr = entry["cefr"]
    if cefr not in ("A1", "A2"):
        raise ValueError(f"{language}: cefr must be A1 or A2")

    fields: dict[str, Any] = {
        "canonical": {"cefr": cefr, "register": "neutral", "semanticTags": []},
    }
    for key in ("definitions", "translations", "examples"):
        items = entry[key]
        if not isinstance(items, list) or not items:
            raise ValueError(f"{language}: {key} must contain at least one object")
        checked = []
        for item in items:
            if not isinstance(item, dict):
                raise ValueError(f"{language}: {key} items must be objects")
            permitted = ({"text", "languageCode"} if key != "examples"
                         else {"text", "translation", "translationLanguageCode"})
            if set(item) != permitted:
                raise ValueError(f"{language}: {key} must have exactly {sorted(permitted)}")
            for k, val in item.items():
                _text(val, f"{key}.{k}")
            target = item.get("languageCode", language)
            if target not in LANGUAGES:
                raise ValueError(f"{language}: unsupported nested language {target}")
            if key == "definitions" and target != language:
                raise ValueError(f"{language}: definitions must be in the source language")
            if key == "translations" and target == language:
                raise ValueError(f"{language}: translations require a different language")
            if key == "examples":
                target = item["translationLanguageCode"]
                if target not in LANGUAGES or target == language:
                    raise ValueError(f"{language}: invalid example translation language")
                _direction(item["text"], direction, "example")
                _direction(item["translation"], LANGUAGES[target][1], "example translation")
            else:
                _direction(item["text"], LANGUAGES[target][1], key)
            checked.append(item)
        fields[key] = checked
    fields["provenance"] = {
        "sourceRef": _text(entry.get("sourceRef", "original-editorial-starter"), "sourceRef"),
        "license": _text(entry.get("license", "original-editorial"), "license"),
        "cefrStatus": "editorial-unverified" if entry.get("sourceRef") == "original-editorial-starter" else "source-asserted",
    }
    return {"id": entry_id, "surface": surface, "partOfSpeech": pos,
            "direction": direction, "fields": fields}


def starter_records(language: str) -> list[dict[str, Any]]:
    _, direction, target = LANGUAGES[language]
    records = []
    for index, (surface, pos, definition, example, translation, translated_example) in enumerate(STARTER[language]):
        stable = hashlib.sha256(f"{language}\0{surface}\0{pos}".encode("utf-8")).hexdigest()[:16]
        records.append({
            "id": f"{language}-{stable}", "surface": surface, "partOfSpeech": pos,
            "languageCode": language, "textDirection": direction,
            "definitions": [{"languageCode": language, "text": definition}],
            "translations": [{"languageCode": target, "text": translation}],
            "examples": [{"text": example, "translationLanguageCode": target,
                          "translation": translated_example}],
            "cefr": "A1" if index < 8 else "A2",
            "sourceRef": "original-editorial-starter", "license": "original-editorial",
        })
    return records


def read_records(path: Path) -> list[dict[str, Any]]:
    if not path.is_file():
        raise ValueError(f"missing input: {path}")
    if path.suffix.lower() == ".jsonl":
        entries = [json.loads(line) for line in path.read_text(encoding="utf-8-sig").splitlines() if line.strip()]
    elif path.suffix.lower() == ".json":
        payload = json.loads(path.read_text(encoding="utf-8-sig"))
        entries = payload.get("entries") if isinstance(payload, dict) else payload
    else:
        raise ValueError(f"{path}: expected .json or .jsonl")
    if not isinstance(entries, list):
        raise ValueError(f"{path}: input must be a list or an object with entries[]")
    return entries


def make_document(language: str, records: list[dict[str, Any]]) -> dict[str, Any]:
    display, direction, _ = LANGUAGES[language]
    if not records:
        raise ValueError(f"{language}: refusing to emit an empty lexicon")
    lexicon = [_record(record, language) for record in records]
    ids = [item["id"] for item in lexicon]
    if len(ids) != len(set(ids)):
        raise ValueError(f"{language}: duplicate lexical ids")
    return {
        "schemaVersion": 1,
        "pack": {"id": language, "languageCode": language,
                 "displayName": display, "version": "1.0.0",
                 "contractVersion": "1.0.0", "textDirection": direction},
        "requiredLocalizationKeys": ["pack.title"],
        "localization": {"pack.title": {"text": display, "direction": direction}},
        "lexicon": sorted(lexicon, key=lambda e: e["id"]),
        "grammar": [],
    }


def factory_validator():
    root = Path(__file__).resolve().parents[2]
    if str(root) not in sys.path:
        sys.path.insert(0, str(root))
    try:
        from tools.language_pack_factory import validate_source_document
    except ImportError as exc:
        raise RuntimeError("The real tools.language_pack_factory validator is required") from exc
    return validate_source_document


def build(languages: list[str], input_paths: list[Path], root: Path,
          *, check: bool = False, force: bool = False, validator=None) -> list[tuple[Path, int, str]]:
    for lang in languages:
        if lang not in LANGUAGES:
            raise ValueError(f"unsupported language: {lang}")
    if len(set(languages)) != len(languages):
        raise ValueError("duplicate --languages values")
    records = {lang: [] for lang in languages}
    if input_paths:
        for path in input_paths:
            for entry in read_records(path):
                if not isinstance(entry, dict) or entry.get("languageCode") not in records:
                    raise ValueError(f"{path}: record languageCode must be one of {languages}")
                records[entry["languageCode"]].append(entry)
    else:
        records = {lang: starter_records(lang) for lang in languages}
    validate = factory_validator() if validator is None else validator
    prepared: list[tuple[Path, bytes, int, str]] = []
    for lang in languages:
        document = make_document(lang, records[lang])
        accepted = validate(document)
        if accepted["pack"]["languageCode"] != lang or len(accepted["lexicon"]) != len(records[lang]):
            raise ValueError(f"{lang}: factory changed language or entry count")
        data = (json.dumps(accepted, ensure_ascii=False, sort_keys=True, indent=2) + "\n").encode("utf-8")
        validate(json.loads(data))  # JSON round-trip through the real factory, before any write
        dest = root / "assets" / "content" / "packs" / lang / "canonical" / f"{lang}-1.0.0.json"
        digest = hashlib.sha256(data).hexdigest()
        if dest.exists() and dest.read_bytes() != data and not force and not check:
            raise FileExistsError(f"{dest} differs: use --force to explicitly replace")
        prepared.append((dest, data, len(records[lang]), digest))
    if not check:
        for dest, data, _, _ in prepared:
            if dest.exists() and dest.read_bytes() == data:
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            fd, tmp = tempfile.mkstemp(prefix=".canonical-", suffix=".tmp", dir=dest.parent)
            try:
                with os.fdopen(fd, "wb") as handle:
                    handle.write(data)
                    handle.flush()
                    os.fsync(handle.fileno())
                os.replace(tmp, dest)
            finally:
                if os.path.exists(tmp):
                    os.unlink(tmp)
    return [(dest, count, digest) for dest, _, count, digest in prepared]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--languages", nargs="+", choices=sorted(LANGUAGES), default=list(LANGUAGES))
    parser.add_argument("--input", action="append", type=Path, default=[],
                        help="Reviewed, licensed JSON/JSONL record collection (repeatable)")
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[2])
    parser.add_argument("--check", action="store_true", help="Validate and report; do not write")
    parser.add_argument("--force", action="store_true", help="Replace different existing canonical outputs")
    args = parser.parse_args(argv)
    try:
        result = build(args.languages, args.input, args.repo_root, check=args.check, force=args.force)
    except (ValueError, OSError, RuntimeError, KeyError, TypeError) as exc:
        parser.exit(1, f"ingestion rejected: {exc}\n")
    for path, count, digest in result:
        print(f"{'VALID' if args.check else 'WROTE'} {path} entries={count} sha256={digest}")
    if not args.input:
        print("NOTICE: small editorial starter, not an official CEFR inventory")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
