#!/usr/bin/env python3
"""Generate a deterministic, review-only German content candidate batch.

The bot never mutates canonical content. It writes the existing V360 authoring
contract plus a transient Phase-17 pack/manifest so repository-native gates can
validate schema, UTF-8, duplicate safety, and canonical/quarantine behavior.
"""
from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONTENT = ROOT / "content" / "content_items.json"
DEFAULT_BATCH_DIR = ROOT / "content" / "german" / "batches" / "auto"


@dataclass(frozen=True)
class Candidate:
    key: str
    kind: str
    german: str
    arabic: str
    sentence: str
    sentence_ar: str
    topic: str
    skill: str
    article: str = ""
    plural: str = ""

    @property
    def content_id(self) -> str:
        return f"auto-{self.kind}-{self.key}-v1"

    @property
    def semantic_id(self) -> str:
        return f"{self.kind}.{self.key}"


CANDIDATES: tuple[Candidate, ...] = (
    Candidate("mehrfachsteckdose", "vocabulary", "Mehrfachsteckdose", "مشترك كهربائي متعدد المقابس", "Die Mehrfachsteckdose liegt unter dem Schreibtisch.", "المشترك الكهربائي موجود تحت المكتب.", "المنزل", "recall", "die", "Mehrfachsteckdosen"),
    Candidate("waeschekorb", "vocabulary", "Wäschekorb", "سلة الغسيل", "Der Wäschekorb steht neben der Waschmaschine.", "سلة الغسيل موجودة بجانب الغسالة.", "المنزل", "recall", "der", "Wäschekörbe"),
    Candidate("dosenoeffner", "vocabulary", "Dosenöffner", "فتّاحة العلب", "Der Dosenöffner liegt in der Küchenschublade.", "فتّاحة العلب موجودة في درج المطبخ.", "المطبخ", "recall", "der", "Dosenöffner"),
    Candidate("schneidebrett", "vocabulary", "Schneidebrett", "لوح التقطيع", "Ich schneide das Gemüse auf dem Schneidebrett.", "أقطّع الخضار على لوح التقطيع.", "المطبخ", "recall", "das", "Schneidebretter"),
    Candidate("fahrradstaender", "vocabulary", "Fahrradständer", "موقف الدراجات", "Der Fahrradständer ist vor dem Eingang.", "موقف الدراجات أمام المدخل.", "المدينة", "recall", "der", "Fahrradständer"),
    Candidate("fussgaengerampel", "vocabulary", "Fußgängerampel", "إشارة مرور المشاة", "Die Fußgängerampel ist noch rot.", "إشارة مرور المشاة ما زالت حمراء.", "المدينة", "recall", "die", "Fußgängerampeln"),
    Candidate("warteschlange", "vocabulary", "Warteschlange", "طابور الانتظار", "Vor der Kasse steht eine lange Warteschlange.", "يوجد طابور انتظار طويل أمام صندوق الدفع.", "التسوق", "recall", "die", "Warteschlangen"),
    Candidate("kassenbon", "vocabulary", "Kassenbon", "إيصال الشراء", "Bitte bewahren Sie den Kassenbon auf.", "يرجى الاحتفاظ بإيصال الشراء.", "التسوق", "recall", "der", "Kassenbons"),
    Candidate("umkleidekabine", "vocabulary", "Umkleidekabine", "غرفة القياس", "Die Umkleidekabine ist links neben den Spiegeln.", "غرفة القياس على اليسار بجانب المرايا.", "التسوق", "recall", "die", "Umkleidekabinen"),
    Candidate("muelltrennung", "vocabulary", "Mülltrennung", "فرز النفايات", "Mülltrennung ist in diesem Haus wichtig.", "فرز النفايات مهم في هذا المنزل.", "الحياة اليومية", "recall", "die", ""),
    Candidate("pfandautomat", "vocabulary", "Pfandautomat", "جهاز إرجاع العبوات", "Der Pfandautomat steht am Eingang des Supermarkts.", "جهاز إرجاع العبوات موجود عند مدخل السوبرماركت.", "التسوق", "recall", "der", "Pfandautomaten"),
    Candidate("briefkastenanlage", "vocabulary", "Briefkastenanlage", "مجموعة صناديق البريد", "Die Briefkastenanlage befindet sich im Erdgeschoss.", "مجموعة صناديق البريد موجودة في الطابق الأرضي.", "السكن", "recall", "die", "Briefkastenanlagen"),
    Candidate("wecker-stellen", "exercise", "Ich stelle den Wecker auf sieben Uhr.", "أضبط المنبّه على الساعة السابعة.", "Ich stelle den Wecker auf sieben Uhr.", "أضبط المنبّه على الساعة السابعة.", "تمارين جمل", "production"),
    Candidate("tasse-neben-teller", "exercise", "Bitte stellen Sie die Tasse neben den Teller.", "ضع الكوب بجانب الطبق من فضلك.", "Bitte stellen Sie die Tasse neben den Teller.", "ضع الكوب بجانب الطبق من فضلك.", "تمارين جمل", "production"),
    Candidate("auf-bus-warten", "exercise", "Wir warten seit zehn Minuten auf den Bus.", "ننتظر الحافلة منذ عشر دقائق.", "Wir warten seit zehn Minuten auf den Bus.", "ننتظر الحافلة منذ عشر دقائق.", "تمارين جمل", "production"),
    Candidate("weg-zum-bahnhof", "exercise", "Kannst du mir den Weg zum Bahnhof erklären?", "هل يمكنك أن تشرح لي الطريق إلى محطة القطار؟", "Kannst du mir den Weg zum Bahnhof erklären?", "هل يمكنك أن تشرح لي الطريق إلى محطة القطار؟", "تمارين جمل", "production"),
    Candidate("termin-verschieben", "exercise", "Ich habe den Termin auf Freitag verschoben.", "نقلت الموعد إلى يوم الجمعة.", "Ich habe den Termin auf Freitag verschoben.", "نقلت الموعد إلى يوم الجمعة.", "تمارين جمل", "production"),
    Candidate("regenschirm-mitnehmen", "exercise", "Wenn es regnet, nehme ich einen Regenschirm mit.", "إذا أمطرت، آخذ مظلة معي.", "Wenn es regnet, nehme ich einen Regenschirm mit.", "إذا أمطرت، آخذ مظلة معي.", "تمارين جمل", "production"),
    Candidate("vor-dem-schlafen", "exercise", "Bevor ich schlafe, stelle ich den Wecker.", "قبل أن أنام، أضبط المنبّه.", "Bevor ich schlafe, stelle ich den Wecker.", "قبل أن أنام، أضبط المنبّه.", "تمارين جمل", "production"),
    Candidate("obwohl-muede", "exercise", "Obwohl ich müde bin, lerne ich noch zehn Minuten.", "رغم أنني متعب، أدرس عشر دقائق إضافية.", "Obwohl ich müde bin, lerne ich noch zehn Minuten.", "رغم أنني متعب، أدرس عشر دقائق إضافية.", "تمارين جمل", "production"),
    Candidate("nachricht-beantworten", "exercise", "Ich beantworte die Nachricht nach der Arbeit.", "أجيب عن الرسالة بعد العمل.", "Ich beantworte die Nachricht nach der Arbeit.", "أجيب عن الرسالة بعد العمل.", "تمارين جمل", "production"),
    Candidate("fenster-offen-lassen", "exercise", "Lass bitte das Fenster ein paar Minuten offen.", "اترك النافذة مفتوحة بضع دقائق من فضلك.", "Lass bitte das Fenster ein paar Minuten offen.", "اترك النافذة مفتوحة بضع دقائق من فضلك.", "تمارين جمل", "production"),
    Candidate("unterlagen-mitbringen", "exercise", "Bitte bringen Sie alle Unterlagen zum Termin mit.", "يرجى إحضار جميع الأوراق إلى الموعد.", "Bitte bringen Sie alle Unterlagen zum Termin mit.", "يرجى إحضار جميع الأوراق إلى الموعد.", "تمارين جمل", "production"),
    Candidate("adresse-aufschreiben", "exercise", "Ich schreibe die Adresse auf, damit ich sie nicht vergesse.", "أكتب العنوان كي لا أنساه.", "Ich schreibe die Adresse auf, damit ich sie nicht vergesse.", "أكتب العنوان كي لا أنساه.", "تمارين جمل", "production"),
)


def _read_json(path: Path) -> object:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        raise ValueError(f"invalid JSON source {path}: {exc}") from exc


def _normalize(value: str) -> str:
    return " ".join(unicodedata.normalize("NFC", value).casefold().split())


def _safe_run_key(value: str) -> str:
    normalized = value.strip()
    if not re.fullmatch(r"[A-Za-z0-9._-]{1,80}", normalized):
        raise ValueError("run key must contain only letters, numbers, dot, underscore, or hyphen")
    return normalized


def _default_run_key() -> str:
    now = datetime.now(timezone.utc)
    iso = now.isocalendar()
    return f"{iso.year}-W{iso.week:02d}"


def _canonical_state(content_path: Path) -> tuple[set[str], set[str]]:
    data = _read_json(content_path)
    if not isinstance(data, list):
        raise ValueError("canonical content root must be an array")
    ids: set[str] = set()
    german: set[str] = set()
    for row in data:
        if not isinstance(row, dict):
            continue
        content_id = row.get("id")
        headword = row.get("german")
        if isinstance(content_id, str) and content_id:
            ids.add(content_id)
        if isinstance(headword, str) and headword.strip():
            german.add(_normalize(headword))
    return ids, german


def _reviewed_candidate_state(batch_dir: Path) -> tuple[set[str], set[str]]:
    ids: set[str] = set()
    german: set[str] = set()
    if not batch_dir.exists():
        return ids, german
    for path in sorted(batch_dir.glob("*.json")):
        try:
            data = _read_json(path)
        except ValueError:
            continue
        if not isinstance(data, dict):
            continue
        entries = data.get("entries")
        if isinstance(entries, list):
            for row in entries:
                if not isinstance(row, dict):
                    continue
                content_id = row.get("id")
                word = row.get("word")
                if isinstance(content_id, str) and content_id:
                    ids.add(content_id)
                if isinstance(word, str) and word.strip():
                    german.add(_normalize(word))
        items = data.get("contentItems")
        if isinstance(items, list):
            for row in items:
                if not isinstance(row, dict):
                    continue
                content_id = row.get("id")
                word = row.get("german")
                if isinstance(content_id, str) and content_id:
                    ids.add(content_id)
                if isinstance(word, str) and word.strip():
                    german.add(_normalize(word))
    return ids, german


def _select(content_path: Path, batch_dir: Path, limit: int) -> list[Candidate]:
    if limit < 1 or limit > 8:
        raise ValueError("limit must be between 1 and 8")
    canonical_ids, canonical_german = _canonical_state(content_path)
    reviewed_ids, reviewed_german = _reviewed_candidate_state(batch_dir)
    blocked_ids = canonical_ids | reviewed_ids
    blocked_german = canonical_german | reviewed_german

    available: dict[str, list[Candidate]] = {"vocabulary": [], "exercise": []}
    for candidate in CANDIDATES:
        if candidate.content_id in blocked_ids:
            continue
        if _normalize(candidate.german) in blocked_german:
            continue
        available[candidate.kind].append(candidate)

    selected: list[Candidate] = []
    kind_order = ("vocabulary", "exercise")
    while len(selected) < limit and any(available.values()):
        made_progress = False
        for kind in kind_order:
            if len(selected) >= limit:
                break
            candidates = available[kind]
            if not candidates:
                continue
            candidate = candidates.pop(0)
            normalized = _normalize(candidate.german)
            if candidate.content_id in blocked_ids or normalized in blocked_german:
                continue
            selected.append(candidate)
            blocked_ids.add(candidate.content_id)
            blocked_german.add(normalized)
            made_progress = True
        if not made_progress:
            break
    return selected


def _authoring(selected: list[Candidate]) -> dict[str, object]:
    return {
        "version": 1,
        "languageCode": "de",
        "entries": [
            {
                "id": item.content_id,
                "word": item.german,
                "translation": item.arabic,
                "sentence": item.sentence,
                "sentenceTranslation": item.sentence_ar,
                "topic": item.topic,
                "skill": item.skill,
                "article": item.article,
                "plural": item.plural,
                "accepted": [item.german],
            }
            for item in selected
        ],
        "verbs": [],
    }


def _pipeline_pack(selected: list[Candidate], run_key: str) -> dict[str, object]:
    pack_id = f"auto-content-{run_key}".lower()
    return {
        "schemaVersion": 1,
        "pack": {"id": pack_id, "languageCode": "de"},
        "cards": [
            {
                "id": item.content_id,
                "semanticId": item.semantic_id,
                "languageCode": "de",
                "text": item.german,
                "register": "neutral",
                "translation": item.arabic,
                "example": item.sentence,
                "metadata": {
                    "category": item.kind,
                    "kind": item.kind,
                    "origin": "scheduled-content-expansion-bot",
                    "reviewStatus": "pending",
                    "culturalReview": "pending",
                    "semanticConfidence": 1.0,
                },
            }
            for item in selected
        ],
    }


def _write_json(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8", newline="\n")


def _write_summary(path: Path, run_key: str, output: Path, selected: list[Candidate]) -> None:
    vocab = sum(item.kind == "vocabulary" for item in selected)
    exercises = sum(item.kind == "exercise" for item in selected)
    lines = [
        "## Automated content candidate",
        "",
        f"- Run key: `{run_key}`",
        f"- Candidate source: `{output.as_posix()}`",
        f"- Items: **{len(selected)}** ({vocab} vocabulary, {exercises} exercises)",
        "- Promotion state: **review-only**; canonical content is not mutated by this bot.",
        "- Phase-17/18 posture: generated cards are marked `reviewStatus=pending` and `culturalReview=pending`, so the canonical gate must quarantine them until human review.",
        "",
        "### Items",
        "",
        "| ID | Type | German | Arabic |",
        "|---|---|---|---|",
    ]
    for item in selected:
        german = item.german.replace("|", "\\|")
        arabic = item.arabic.replace("|", "\\|")
        lines.append(f"| `{item.content_id}` | {item.kind} | {german} | {arabic} |")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")


def generate(
    *,
    repo_root: Path,
    output: Path,
    pipeline_pack: Path,
    pipeline_manifest: Path,
    report_json: Path,
    summary: Path,
    run_key: str,
    limit: int,
) -> dict[str, object]:
    content_path = repo_root / "content" / "content_items.json"
    batch_dir = repo_root / "content" / "german" / "batches" / "auto"
    selected = _select(content_path, batch_dir, limit)
    report: dict[str, object] = {
        "created": bool(selected),
        "runKey": run_key,
        "selectedCount": len(selected),
        "vocabularyCount": sum(item.kind == "vocabulary" for item in selected),
        "exerciseCount": sum(item.kind == "exercise" for item in selected),
        "output": str(output),
        "pipelinePack": str(pipeline_pack),
        "pipelineManifest": str(pipeline_manifest),
        "ids": [item.content_id for item in selected],
    }
    _write_json(report_json, report)
    if not selected:
        return report

    _write_json(output, _authoring(selected))
    pack = _pipeline_pack(selected, run_key)
    _write_json(pipeline_pack, pack)
    manifest = {
        "maxParallel": 1,
        "cachePath": ".agent-pulse-cache/content_expansion_bot.json",
        "packs": [
            {
                "id": pack["pack"]["id"],
                "languageCode": "de",
                "path": str(pipeline_pack),
            }
        ],
    }
    _write_json(pipeline_manifest, manifest)
    _write_summary(summary, run_key, output, selected)
    return report


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo-root", type=Path, default=ROOT)
    parser.add_argument("--run-key", default=_default_run_key())
    parser.add_argument("--limit", type=int, default=4)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--pipeline-pack", required=True, type=Path)
    parser.add_argument("--pipeline-manifest", required=True, type=Path)
    parser.add_argument("--report-json", required=True, type=Path)
    parser.add_argument("--summary", required=True, type=Path)
    args = parser.parse_args()
    try:
        repo_root = args.repo_root.resolve()
        run_key = _safe_run_key(args.run_key)
        output = args.output or (repo_root / "content" / "german" / "batches" / "auto" / f"auto-{run_key}.json")
        report = generate(
            repo_root=repo_root,
            output=output,
            pipeline_pack=args.pipeline_pack,
            pipeline_manifest=args.pipeline_manifest,
            report_json=args.report_json,
            summary=args.summary,
            run_key=run_key,
            limit=args.limit,
        )
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
        return 0
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
