#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
CONTENT = ROOT / "content" / "content_items.json"
QUEUE = ROOT / "tool" / "content_review_queue.json"
CORRECTIONS = ROOT / "content" / "german" / "editorial_corrections.jsonl"
REVIEW_ROOT = ROOT / "tool" / "editorial_review"
MANIFEST = REVIEW_ROOT / "task10_manifest.json"
BATCH_SIZE = 200
ALLOWED_STATUSES = {"APPROVED", "NEEDS_SPECIALIST_REVIEW"}

_DOUBLED_ARTICLE = re.compile(r"\b(der|die|das)\s+\1\b", re.IGNORECASE)
_PREFIX_ARTICLE = re.compile(r"^(der|die|das)\s+", re.IGNORECASE)
_SUSPECT_COMPOUND = re.compile(
    r"^(?:der|die|das)\s+(?:familie|familien|arbeit|arbeits|bahn|badezimmer|"
    r"wetter|wohn|wohnung|schule|fahrrad)[a-zäöüß]+$",
    re.IGNORECASE,
)
_SUSPECT_ARABIC = re.compile(
    r"^(?:العائلة|العمل|عمل|القطار|حمام|الطقس|سكن|الدراجة)\s+\S+"
)
_KNOWN_ARABIC_FORM_RISK = re.compile(
    r"(?:رأىتم|أعطىتم|أعطىت|عاشتم|تنسىون|تلتقيون|تدربتم الألمانية)"
)
_ARABIC_VALENCY_RISK = re.compile(
    r"(?:ألتقي|تلتقي|يلتقي|تلتقيون)\s+صديقي"
)
_BARE_INFINITIVE = re.compile(r"^[a-zäöüß]+(?:en|n)$", re.IGNORECASE)
_SEPARABLE_PARTICLES = frozenset(
    {"an", "auf", "aus", "ein", "mit", "um", "zu", "zurück"}
)
_LITERAL_COMPOUND_ARABIC_GLOSSES = frozenset({
    "القطار الغرفة","العائلة خطة","الرياضة خطة","الحمام خطة",
    "العمل رقم","العمل خطة","العمل مكان","العمل عقد","النوم وقت",
    "المرضى بطاقة","المرضى رقم","الغرفة غرفة","الرياضة بطاقة",
    "حركة المرور بطاقة","حركة المرور جدول","حركة المرور وقت",
    "الأطفال وقت","الأطفال بطاقة","العائلة رقم","العائلة وقت",
    "الحاسوب بيانات","السوبرماركت بطاقة","اللغة اختبار","البيانات بيانات",
    "التقديم للوظيفة مكان","التقديم للوظيفة خطة","الطلب الرسمي جهة",
})


def _read_json(path: Path) -> object:
    return json.loads(path.read_text(encoding="utf-8"))


def _git_blob_sha(path: Path) -> str:
    payload = path.read_bytes()
    header = f"blob {len(payload)}\0".encode("ascii")
    return hashlib.sha1(header + payload).hexdigest()


def _normalize(value: object) -> str:
    return " ".join(str(value or "").strip().lower().split())


def _arabic_tokens(value: object) -> set[str]:
    cleaned = re.sub(r"[^\u0600-\u06ff]+", " ", _normalize(value))
    return {token for token in cleaned.split() if len(token) > 1}


def _arabic_overlap(left: object, right: object) -> float:
    left_tokens = _arabic_tokens(left)
    right_tokens = _arabic_tokens(right)
    if not left_tokens or not right_tokens:
        return 0.0
    return len(left_tokens & right_tokens) / len(left_tokens | right_tokens)


def _prefix_article(value: object) -> str:
    match = _PREFIX_ARTICLE.match(_normalize(value))
    return match.group(1).lower() if match else ""


def _is_conjugation_row(row: dict[str, object]) -> bool:
    topic = str(row.get("topic", ""))
    return row.get("skill") == "production" and (
        "تصريف" in topic or topic.startswith("الأفعال —")
    )


def _separable_particle(value: object) -> str:
    tokens = _normalize(value).split()
    if tokens and tokens[-1] in _SEPARABLE_PARTICLES:
        return tokens[-1]
    return ""


def _same_conjugation_family(
    left: dict[str, object],
    right: dict[str, object],
) -> bool:
    if not (
        _is_conjugation_row(left)
        and _is_conjugation_row(right)
        and _normalize(left.get("topic")) == _normalize(right.get("topic"))
    ):
        return False
    left_german = _normalize(left.get("german"))
    right_german = _normalize(right.get("german"))
    if (
        _BARE_INFINITIVE.fullmatch(left_german)
        and _BARE_INFINITIVE.fullmatch(right_german)
    ):
        return False
    left_particle = _separable_particle(left_german)
    right_particle = _separable_particle(right_german)
    if left_particle or right_particle:
        return left_particle == right_particle
    return True


def _row_risks(row: dict[str, object]) -> list[str]:
    risks: set[str] = set()
    german = str(row.get("german", ""))
    arabic = str(row.get("arabic", ""))
    sentence = str(row.get("sentence", ""))
    sentence_ar = str(row.get("sentenceAr", ""))
    prefix_article = _prefix_article(german)
    field_article = _normalize(row.get("article"))
    if _DOUBLED_ARTICLE.search(sentence):
        risks.add("DUPLICATED_GERMAN_ARTICLE")
    if prefix_article and not field_article:
        risks.add("MISSING_ARTICLE_METADATA")
    if prefix_article and field_article and prefix_article != field_article:
        risks.add("ARTICLE_MISMATCH")
    if (
        not _is_conjugation_row(row)
        and _normalize(arabic)
        and _normalize(arabic) == _normalize(sentence_ar)
    ):
        risks.add("GLOSS_EQUALS_EXAMPLE_TRANSLATION")
    if _SUSPECT_COMPOUND.match(german) and _SUSPECT_ARABIC.match(arabic):
        risks.add("SUSPECT_COMPOUND_TRANSLATION")
    if (
        _KNOWN_ARABIC_FORM_RISK.search(arabic)
        or _KNOWN_ARABIC_FORM_RISK.search(sentence_ar)
    ):
        risks.add("KNOWN_ARABIC_FORM_RISK")
    normalized_german = _normalize(german)
    headword = _PREFIX_ARTICLE.sub("", normalized_german)
    if normalized_german in {"waschst", "wascht"}:
        risks.add("INVALID_GERMAN_CONJUGATION")
    if sentence in {"Ich nehme heute mit.", "Wir nehmen heute mit."}:
        risks.add("EXAMPLE_TRANSLATION_MISMATCH")
    if sentence in {
        "Ich nehme das Gewicht ab.",
        "Ich nehme die Lautstärke zu.",
    }:
        risks.add("INVALID_GERMAN_EXAMPLE_SEMANTICS")
    if sentence.startswith("Das riert "):
        risks.add("MALFORMED_GERMAN_EXAMPLE")
    if headword in {"verkehrkarte", "verkehrplan", "verkehrzeit"}:
        risks.add("NONSTANDARD_GERMAN_COMPOUND")
    if (
        normalized_german in {"ziehe um", "ziehen um"}
        and "يغيّر ملابسه" in arabic
    ):
        risks.add("SEMANTIC_GLOSS_SCOPE_RISK")
    if (
        _ARABIC_VALENCY_RISK.search(arabic)
        or _ARABIC_VALENCY_RISK.search(sentence_ar)
    ):
        risks.add("ARABIC_VALENCY_RISK")
    if arabic.strip() in _LITERAL_COMPOUND_ARABIC_GLOSSES:
        risks.add("LITERAL_COMPOUND_TRANSLATION")
    return sorted(risks)


def _base_disposition(
    left: dict[str, object],
    right: dict[str, object],
) -> tuple[str, list[str]]:
    risk_codes = sorted(set(_row_risks(left) + _row_risks(right)))
    if _same_conjugation_family(left, right) and not risk_codes:
        return "APPROVED", risk_codes
    left_german = _normalize(left.get("german"))
    right_german = _normalize(right.get("german"))
    same_gloss = _normalize(left.get("arabic")) == _normalize(right.get("arabic"))
    same_sentence = _normalize(left.get("sentence")) == _normalize(
        right.get("sentence")
    )
    contains_relation = (
        right_german in left_german or left_german in right_german
    )
    gloss_overlap = _arabic_overlap(left.get("arabic"), right.get("arabic"))
    if (
        not risk_codes
        and not same_gloss
        and not same_sentence
        and not contains_relation
        and gloss_overlap < 0.34
    ):
        return "FALSE_POSITIVE", risk_codes
    return "NEEDS_SPECIALIST_REVIEW", risk_codes


def _build_corrections(queue: dict[str, object]) -> list[dict[str, str]]:
    found: dict[str, dict[str, str]] = {}
    items = queue.get("items")
    if not isinstance(items, list):
        raise ValueError("review queue items must be a list")
    for item in items:
        for side in ("a", "b"):
            sentence = str(item[f"sentence_{side}"])
            fixed = _DOUBLED_ARTICLE.sub(r"\1", sentence)
            if fixed == sentence:
                continue
            row = {
                "id": str(item[f"id_{side}"]),
                "field": "sentence",
                "from": sentence,
                "to": fixed,
                "rule": "REMOVE_DUPLICATED_GERMAN_ARTICLE",
            }
            previous = found.get(row["id"])
            if previous is not None and previous != row:
                raise ValueError(f"conflicting correction for {row['id']}")
            found[row["id"]] = row
    return sorted(found.values(), key=lambda row: row["id"])


def _classify(
    queue: dict[str, object],
    content: list[dict[str, object]],
) -> list[dict[str, str]]:
    by_id = {str(row["id"]): row for row in content}
    decisions: list[dict[str, str]] = []
    for item in queue["items"]:
        left_id, right_id = str(item["id_a"]), str(item["id_b"])
        left, right = by_id[left_id], by_id[right_id]
        base_status, base_risks = _base_disposition(left, right)
        residual = [
            risk for risk in base_risks if risk != "DUPLICATED_GERMAN_ARTICLE"
        ]
        status = "NEEDS_SPECIALIST_REVIEW"
        reason = "CONSERVATIVE_EDITORIAL_REVIEW"
        if not residual:
            if base_status in {"APPROVED", "FALSE_POSITIVE"}:
                status = "APPROVED"
                reason = (
                    "STABLE_REVIEWED_ENTRY"
                    if base_status == "APPROVED"
                    else "DISTINCT_STABLE_ENTRIES"
                )
            elif base_status == "NEEDS_SPECIALIST_REVIEW" and base_risks:
                left_german = _normalize(left["german"])
                right_german = _normalize(right["german"])
                relation = (
                    right_german in left_german or left_german in right_german
                )
                if (
                    not relation
                    and _arabic_overlap(left["arabic"], right["arabic"]) < 0.34
                ):
                    status = "APPROVED"
                    reason = "MECHANICAL_CORRECTION_REMOVED_ONLY_RISK"
        decisions.append({
            "id_a": left_id,
            "id_b": right_id,
            "status": status,
            "reason": reason,
        })
    return decisions


def _patch_authoring_sources(corrections: list[dict[str, str]]) -> None:
    pending = {row["id"]: row for row in corrections}
    for path in sorted((ROOT / "content" / "german").glob("content_*.dart")):
        text = path.read_text(encoding="utf-8")
        original = text
        for content_id, correction in list(pending.items()):
            marker = f"id: '{content_id}'"
            position = text.find(marker)
            if position < 0:
                continue
            start = text.rfind("ContentItem(", 0, position)
            end = text.find("\n  ),", position)
            if start < 0 or end < 0:
                raise ValueError(f"cannot bound ContentItem {content_id}")
            block = text[start:end]
            if correction["from"] in block:
                block = block.replace(correction["from"], correction["to"], 1)
                text = text[:start] + block + text[end:]
            elif correction["to"] not in block:
                raise ValueError(f"authoring correction drift: {content_id}")
            pending.pop(content_id)
        if text != original:
            path.write_text(text, encoding="utf-8")
    if pending:
        raise ValueError(f"missing authoring correction IDs: {sorted(pending)}")


def _write_corrections(corrections: list[dict[str, str]]) -> None:
    CORRECTIONS.write_text(
        "\n".join(
            json.dumps(row, ensure_ascii=False, separators=(",", ":"))
            for row in corrections
        )
        + "\n",
        encoding="utf-8",
    )


def _write_batches(decisions: list[dict[str, str]]) -> list[str]:
    names: list[str] = []
    REVIEW_ROOT.mkdir(parents=True, exist_ok=True)
    for index in range(0, len(decisions), BATCH_SIZE):
        name = f"task10_batch_{index // BATCH_SIZE + 1:03d}.jsonl"
        names.append(name)
        rows = decisions[index:index + BATCH_SIZE]
        (REVIEW_ROOT / name).write_text(
            "\n".join(
                json.dumps(row, ensure_ascii=False, separators=(",", ":"))
                for row in rows
            )
            + "\n",
            encoding="utf-8",
        )
    return names


def _manifest(
    queue: dict[str, object],
    decisions: list[dict[str, str]],
    batches: list[str],
) -> dict[str, object]:
    counts = {
        status: sum(row["status"] == status for row in decisions)
        for status in sorted(ALLOWED_STATUSES)
    }
    return {
        "schema_version": 2,
        "task": "TASK 10 — Editorial Content QA",
        "baseline": "a0d698f192a26f51be73a6a53c27541a31381669",
        "review_only_queue": True,
        "queue_count": int(queue["count"]),
        "canonical_corrections": 68,
        "allowed_statuses": sorted(ALLOWED_STATUSES),
        "status_counts": counts,
        "queue_git_blob_sha": _git_blob_sha(QUEUE),
        "corrections_git_blob_sha": _git_blob_sha(CORRECTIONS),
        "batches": batches,
        "batch_git_blob_shas": {
            name: _git_blob_sha(REVIEW_ROOT / name) for name in batches
        },
    }


def _compile_generated() -> None:
    compiler = ROOT / "tool" / "content_compiler.py"
    for output in (
        ROOT / "content" / "german" / "generated",
        ROOT / "lib" / "data" / "generated",
    ):
        result = subprocess.run(
            [sys.executable, str(compiler), "compile", "--output-dir", str(output)],
            cwd=ROOT,
            text=True,
            capture_output=True,
            check=False,
        )
        if result.returncode != 0:
            raise ValueError(result.stderr or result.stdout)


def apply() -> None:
    queue = _read_json(QUEUE)
    content = _read_json(CONTENT)
    if not isinstance(queue, dict) or not isinstance(content, list):
        raise ValueError("invalid TASK 10 inputs")
    corrections = _build_corrections(queue)
    if len(corrections) != 68:
        raise ValueError(f"expected 68 mechanical corrections, got {len(corrections)}")
    decisions = _classify(queue, content)
    counts = {
        status: sum(row["status"] == status for row in decisions)
        for status in ALLOWED_STATUSES
    }
    if counts != {"APPROVED": 690, "NEEDS_SPECIALIST_REVIEW": 490}:
        raise ValueError(f"unexpected classification counts: {counts}")
    _write_corrections(corrections)
    _patch_authoring_sources(corrections)
    batches = _write_batches(decisions)
    _compile_generated()
    MANIFEST.write_text(
        json.dumps(_manifest(queue, decisions, batches), ensure_ascii=False, indent=2)
        + "\n",
        encoding="utf-8",
    )


def check() -> None:
    queue = _read_json(QUEUE)
    content = _read_json(CONTENT)
    manifest = _read_json(MANIFEST)
    if not isinstance(queue, dict) or not isinstance(content, list):
        raise ValueError("invalid TASK 10 inputs")
    if not isinstance(manifest, dict):
        raise ValueError("invalid TASK 10 manifest")
    corrections = _build_corrections(queue)
    actual_corrections = [
        json.loads(line)
        for line in CORRECTIONS.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    if actual_corrections != corrections:
        raise ValueError("editorial correction ledger drift")
    expected = _classify(queue, content)
    actual: list[dict[str, str]] = []
    for name in manifest["batches"]:
        lines = [
            line
            for line in (REVIEW_ROOT / name).read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        if not 1 <= len(lines) <= BATCH_SIZE:
            raise ValueError(f"batch size violation: {name}")
        actual.extend(json.loads(line) for line in lines)
    if actual != expected:
        raise ValueError("editorial decision drift")
    if manifest != _manifest(queue, actual, list(manifest["batches"])):
        raise ValueError("editorial manifest/checksum drift")
    for correction in corrections:
        found = False
        for path in sorted((ROOT / "content" / "german").glob("content_*.dart")):
            text = path.read_text(encoding="utf-8")
            if f"id: '{correction['id']}'" not in text:
                continue
            found = True
            if correction["from"] in text or correction["to"] not in text:
                raise ValueError(f"authoring correction drift: {correction['id']}")
            break
        if not found:
            raise ValueError(f"missing corrected authoring row: {correction['id']}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("apply", "check"))
    args = parser.parse_args()
    try:
        apply() if args.command == "apply" else check()
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as exc:
        print(f"TASK 10 EDITORIAL PIPELINE: FAIL — {exc}")
        return 1
    manifest = _read_json(MANIFEST)
    counts = manifest["status_counts"]
    print("TASK 10 EDITORIAL PIPELINE: PASS")
    print(f"APPROVED: {counts['APPROVED']}")
    print(f"NEEDS_SPECIALIST_REVIEW: {counts['NEEDS_SPECIALIST_REVIEW']}")
    print(f"CORRECTIONS: {manifest['canonical_corrections']}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
