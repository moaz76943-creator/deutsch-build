#!/usr/bin/env python3
"""Strict semantic lexicon auditor for canonical multilingual language packs."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

COMMON_USAGE_BANDS = frozenset({"alltag", "common", "standard"})
POSITIVE_USAGE_CLASSIFICATIONS = frozenset(
    {
        "alltag",
        "common",
        "standard",
        "frequent",
        "high_frequency",
        "grundwortschatz",
        "a1",
        "a2",
        "a1-a2",
        "a1/a2",
    }
)
FORBIDDEN_REGISTERS = frozenset(
    {"archaic", "obsolete", "historical", "rare", "dialect_only"}
)
ALLOWED_TRANSLATION_STRATEGIES = frozenset(
    {"contextual", "idiomatic", "cultural_equivalent", "sense_equivalent"}
)
IDIOM_STRATEGIES = frozenset(
    {"idiomatic", "cultural_equivalent", "sense_equivalent"}
)
TRUSTED_GERMAN_USAGE_SOURCES = frozenset(
    {"duden", "goethe", "goethe-institut", "dwds"}
)
SENSITIVE_CONNOTATIONS = frozenset(
    {
        "vulgar",
        "slur",
        "offensive",
        "sexual",
        "violent",
        "politically_sensitive",
        "religiously_sensitive",
    }
)
GERMAN_ARTICLE_GENDER = {
    "der": "masculine",
    "die": "feminine",
    "das": "neuter",
}
GERMAN_GENDER_ARTICLE = {
    value: key for key, value in GERMAN_ARTICLE_GENDER.items()
}
GERMAN_ARTICLE_COLOR_TOKENS = {
    "der": "germanArticle.der",
    "die": "germanArticle.die",
    "das": "germanArticle.das",
}
KNOWN_DE_EN_FALSE_FRIENDS = {
    "bekommen": frozenset({"become"}),
    "aktuell": frozenset({"actual"}),
    "eventuell": frozenset({"eventually"}),
    "chef": frozenset({"chef"}),
    "gift": frozenset({"gift"}),
    "brav": frozenset({"brave"}),
    "sensibel": frozenset({"sensible"}),
    "gymnasium": frozenset({"gymnasium"}),
}


@dataclass(frozen=True)
class LexiconIssue:
    code: str
    message: str
    field: str = ""
    severity: str = "error"

    def to_json(self) -> dict[str, str]:
        return {
            "code": self.code,
            "field": self.field,
            "message": self.message,
            "severity": self.severity,
        }


@dataclass(frozen=True)
class LexiconAuditReport:
    lemma: str
    errors: tuple[LexiconIssue, ...]
    warnings: tuple[LexiconIssue, ...]

    @property
    def is_valid(self) -> bool:
        return not self.errors

    def to_json(self) -> dict[str, Any]:
        return {
            "lemma": self.lemma,
            "status": "PASS" if self.is_valid else "FAIL",
            "errors": [issue.to_json() for issue in self.errors],
            "warnings": [issue.to_json() for issue in self.warnings],
        }


def _primary_language(value: Any) -> str:
    if not isinstance(value, str) or not value.strip():
        return ""
    return re.split(r"[-_]", value.strip().lower(), maxsplit=1)[0]


def _text(value: Any) -> str:
    return value.strip() if isinstance(value, str) else ""


def _mapping(value: Any) -> Mapping[str, Any]:
    return value if isinstance(value, Mapping) else {}


def _error(
    errors: list[LexiconIssue],
    code: str,
    message: str,
    field: str = "",
) -> None:
    errors.append(
        LexiconIssue(code=code, message=message, field=field)
    )


def _canonical_shape(entry: Mapping[str, Any]) -> bool:
    return (
        "surface" in entry
        and "fields" in entry
        and "lemma" not in entry
    )


def adapt_canonical_entry(
    entry: Mapping[str, Any],
    *,
    language_code: str,
) -> dict[str, Any]:
    """Adapt Shared Core lexicon shape into the strict audit view."""
    language = _primary_language(language_code)
    if not language:
        raise ValueError(
            "canonical lexicon audit requires pack languageCode"
        )
    fields = _mapping(entry.get("fields"))
    canonical = _mapping(fields.get("canonical"))
    audit = _mapping(fields.get("lexiconAudit"))
    noun = _mapping(canonical.get("noun"))
    verb = _mapping(canonical.get("verb"))

    adapted: dict[str, Any] = {
        "lemma": entry.get("surface"),
        "language": language,
        "partOfSpeech": entry.get("partOfSpeech"),
        "usageBand": audit.get("usageBand"),
        "usageEvidence": audit.get("usageEvidence"),
        "register": canonical.get(
            "register",
            audit.get("register"),
        ),
        "translation": audit.get("translation"),
        "connotations": audit.get("connotations", []),
        "idioms": audit.get("idioms", []),
        "reviewStatus": audit.get("reviewStatus"),
        "usageNote": audit.get("usageNote"),
    }

    if (
        language == "de"
        and _text(entry.get("partOfSpeech")).lower() == "noun"
    ):
        gender = _text(noun.get("gender")).lower()
        article = GERMAN_GENDER_ARTICLE.get(gender, "")
        adapted.update(
            {
                "gender": gender,
                "article": article,
                "articleColorToken": GERMAN_ARTICLE_COLOR_TOKENS.get(
                    article,
                    "",
                ),
            }
        )

    if (
        language == "de"
        and _text(entry.get("partOfSpeech")).lower() == "verb"
    ):
        infinitive = (
            _text(verb.get("infinitive"))
            or _text(entry.get("surface"))
        )
        prefix = _text(verb.get("separablePrefix"))
        adapted["separable"] = bool(prefix)
        adapted["separablePrefix"] = prefix
        adapted["stem"] = (
            infinitive[len(prefix):]
            if prefix
            and infinitive.lower().startswith(prefix.lower())
            else ""
        )
    return adapted


def _normalized_entry(
    entry: Mapping[str, Any],
    language_code: str | None,
) -> dict[str, Any]:
    if _canonical_shape(entry):
        return adapt_canonical_entry(
            entry,
            language_code=language_code or "",
        )
    return dict(entry)


def _audit_base_fields(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
) -> tuple[str, str, str]:
    lemma = _text(entry.get("lemma"))
    language = _primary_language(entry.get("language"))
    part_of_speech = _text(entry.get("partOfSpeech")).lower()

    if not lemma:
        _error(
            errors,
            "lexicon.lemma_required",
            "lemma must be a non-empty string",
            "lemma",
        )
    if not language:
        _error(
            errors,
            "lexicon.language_required",
            "language must be explicit",
            "language",
        )
    if not part_of_speech:
        _error(
            errors,
            "lexicon.part_of_speech_required",
            "partOfSpeech must be explicit",
            "partOfSpeech",
        )
    return lemma, language, part_of_speech


def _audit_usage_and_register(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
    language: str,
) -> None:
    usage_band = _text(entry.get("usageBand")).lower()
    if usage_band not in COMMON_USAGE_BANDS:
        _error(
            errors,
            "usage.not_alltag",
            "entry is not certified as Alltag/common/standard usage",
            "usageBand",
        )

    register = _text(entry.get("register")).lower()
    if register in FORBIDDEN_REGISTERS:
        _error(
            errors,
            "register.forbidden",
            f"forbidden low-frequency register: {register}",
            "register",
        )

    if language == "de":
        evidence = entry.get("usageEvidence")
        trusted_positive = False
        if isinstance(evidence, list):
            for item in evidence:
                if not isinstance(item, Mapping):
                    continue
                source = _text(item.get("source")).lower()
                classification = _text(
                    item.get("classification")
                ).lower()
                if (
                    source in TRUSTED_GERMAN_USAGE_SOURCES
                    and classification
                    in POSITIVE_USAGE_CLASSIFICATIONS
                ):
                    trusted_positive = True
                    break
        if not trusted_positive:
            _error(
                errors,
                "usage.authority_required",
                "German commonness requires trusted evidence explicitly "
                "classified as common/frequent/core-level usage",
                "usageEvidence",
            )


def _audit_translation(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
    language: str,
) -> tuple[str, str]:
    translation = entry.get("translation")
    if not isinstance(translation, Mapping):
        _error(
            errors,
            "translation.required",
            "translation audit object is required",
            "translation",
        )
        translation = {}

    target_language = _primary_language(
        translation.get("targetLanguage")
    )
    translated_text = _text(translation.get("text"))
    strategy = _text(translation.get("strategy")).lower()
    sense_id = _text(translation.get("senseId"))

    if not target_language:
        _error(
            errors,
            "translation.target_required",
            "targetLanguage must be explicit",
            "translation.targetLanguage",
        )
    if not translated_text:
        _error(
            errors,
            "translation.text_required",
            "translation text is required",
            "translation.text",
        )
    if language and target_language and language != target_language:
        if strategy == "literal":
            _error(
                errors,
                "translation.literal_forbidden",
                "literal translation is forbidden; "
                "use contextual semantic equivalence",
                "translation.strategy",
            )
        elif strategy not in ALLOWED_TRANSLATION_STRATEGIES:
            _error(
                errors,
                "translation.strategy_required",
                "translation strategy must be contextual/idiomatic/"
                "cultural/sense equivalent",
                "translation.strategy",
            )
    if not sense_id:
        _error(
            errors,
            "translation.sense_required",
            "senseId is required to prevent semantic drift",
            "translation.senseId",
        )
    return target_language, translated_text


def _audit_article(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
    language: str,
    part_of_speech: str,
) -> None:
    article = _text(entry.get("article")).lower()
    gender = _text(entry.get("gender")).lower()
    color_token = _text(entry.get("articleColorToken"))

    if language != "de" and (article or gender or color_token):
        _error(
            errors,
            "article.non_german",
            "German der/die/das metadata must not be attached "
            "to non-German entries",
            "article",
        )

    if language == "de" and part_of_speech == "noun":
        if article not in GERMAN_ARTICLE_GENDER:
            _error(
                errors,
                "article.required",
                "German nouns require der/die/das",
                "article",
            )
        else:
            expected_gender = GERMAN_ARTICLE_GENDER[article]
            if gender != expected_gender:
                _error(
                    errors,
                    "article.gender_mismatch",
                    f"{article} requires gender {expected_gender}",
                    "gender",
                )
            expected_token = GERMAN_ARTICLE_COLOR_TOKENS[article]
            if color_token != expected_token:
                _error(
                    errors,
                    "article.color_token_mismatch",
                    f"{article} requires fixed token {expected_token}",
                    "articleColorToken",
                )
    elif (
        language == "de"
        and part_of_speech != "noun"
        and (article or gender or color_token)
    ):
        _error(
            errors,
            "article.non_noun",
            "German article metadata is valid only for nouns",
            "article",
        )


def _audit_false_friends(
    errors: list[LexiconIssue],
    language: str,
    target_language: str,
    lemma: str,
    translated_text: str,
) -> None:
    if language == "de" and target_language == "en" and lemma:
        traps = KNOWN_DE_EN_FALSE_FRIENDS.get(
            lemma.lower(),
            frozenset(),
        )
        if translated_text.lower() in traps:
            _error(
                errors,
                "false_friend.detected",
                f"{lemma!r} -> {translated_text!r} matches a known "
                "German-English false friend",
                "translation.text",
            )


def _audit_verb_structure(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
    part_of_speech: str,
    lemma: str,
) -> None:
    separable = entry.get("separable")
    prefix = _text(entry.get("separablePrefix"))
    stem = _text(entry.get("stem"))
    if part_of_speech == "verb":
        if separable is True:
            if not prefix or not stem:
                _error(
                    errors,
                    "verb.separable_structure_required",
                    "separable verbs require explicit "
                    "separablePrefix and stem",
                    "separablePrefix",
                )
            elif lemma and lemma.lower() != (prefix + stem).lower():
                _error(
                    errors,
                    "verb.separable_mismatch",
                    "lemma must equal separablePrefix + stem",
                    "lemma",
                )
        elif separable is False and prefix:
            _error(
                errors,
                "verb.separable_prefix_unexpected",
                "non-separable verb must not define separablePrefix",
                "separablePrefix",
            )


def _audit_idioms(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
) -> None:
    idioms = entry.get("idioms", [])
    if not isinstance(idioms, list):
        _error(
            errors,
            "idiom.list_required",
            "idioms must be a list",
            "idioms",
        )
    else:
        for index, idiom in enumerate(idioms):
            if not isinstance(idiom, Mapping):
                _error(
                    errors,
                    "idiom.object_required",
                    "idiom must be an object",
                    f"idioms[{index}]",
                )
                continue
            idiom_strategy = _text(
                idiom.get("strategy")
            ).lower()
            if idiom_strategy == "literal":
                _error(
                    errors,
                    "idiom.literal_forbidden",
                    "idioms must use idiomatic/cultural equivalence, "
                    "never literal translation",
                    f"idioms[{index}].strategy",
                )
            elif idiom_strategy not in IDIOM_STRATEGIES:
                _error(
                    errors,
                    "idiom.strategy_required",
                    "idiom strategy must document semantic equivalence",
                    f"idioms[{index}].strategy",
                )
            if (
                not _text(idiom.get("expression"))
                or not _text(idiom.get("translation"))
            ):
                _error(
                    errors,
                    "idiom.text_required",
                    "idiom expression and translation are required",
                    f"idioms[{index}]",
                )


def _audit_connotations(
    entry: Mapping[str, Any],
    errors: list[LexiconIssue],
) -> None:
    connotations_raw = entry.get("connotations", [])
    connotations = (
        {
            _text(item).lower()
            for item in connotations_raw
            if _text(item)
        }
        if isinstance(connotations_raw, list)
        else set()
    )
    sensitive = connotations.intersection(SENSITIVE_CONNOTATIONS)
    if sensitive and (
        entry.get("reviewStatus") != "reviewed"
        or not _text(entry.get("usageNote"))
    ):
        _error(
            errors,
            "connotation.review_required",
            "sensitive connotations require reviewed status "
            "and an explicit usageNote",
            "connotations",
        )


def audit_entry(
    entry: Mapping[str, Any],
    *,
    language_code: str | None = None,
) -> LexiconAuditReport:
    entry = _normalized_entry(entry, language_code)
    errors: list[LexiconIssue] = []
    warnings: list[LexiconIssue] = []

    lemma, language, part_of_speech = _audit_base_fields(entry, errors)
    _audit_usage_and_register(entry, errors, language)
    target_language, translated_text = _audit_translation(
        entry, errors, language
    )
    _audit_article(entry, errors, language, part_of_speech)
    _audit_false_friends(
        errors, language, target_language, lemma, translated_text
    )
    _audit_verb_structure(entry, errors, part_of_speech, lemma)
    _audit_idioms(entry, errors)
    _audit_connotations(entry, errors)

    return LexiconAuditReport(
        lemma=lemma,
        errors=tuple(errors),
        warnings=tuple(warnings),
    )


def audit_entries(
    entries: Sequence[Mapping[str, Any]],
    *,
    language_code: str | None = None,
) -> dict[str, Any]:
    reports = [
        audit_entry(entry, language_code=language_code)
        for entry in entries
    ]
    return {
        "status": (
            "PASS"
            if all(report.is_valid for report in reports)
            else "FAIL"
        ),
        "entries": [report.to_json() for report in reports],
        "errorCount": sum(len(report.errors) for report in reports),
        "warningCount": sum(len(report.warnings) for report in reports),
    }


def _load_document(
    path: Path,
) -> tuple[list[Mapping[str, Any]], str | None]:
    payload = json.loads(path.read_text(encoding="utf-8"))

    if isinstance(payload, list):
        entries = payload
        language_code = None
    elif (
        isinstance(payload, dict)
        and isinstance(payload.get("entries"), list)
    ):
        entries = payload["entries"]
        language_code = _text(payload.get("languageCode")) or None
    elif (
        isinstance(payload, dict)
        and isinstance(payload.get("lexicon"), list)
    ):
        entries = payload["lexicon"]
        language_code = (
            _text(
                _mapping(payload.get("pack")).get("languageCode")
            )
            or None
        )
    else:
        raise ValueError(
            "input must be entries[] or "
            "a canonical language-pack document"
        )

    if not all(isinstance(entry, Mapping) for entry in entries):
        raise ValueError(
            "all lexicon entries must be JSON objects"
        )
    return entries, language_code


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Strict multilingual lexicon auditor"
    )
    parser.add_argument("audit", nargs="?")
    parser.add_argument("--input", type=Path, required=True)
    parser.add_argument(
        "--language",
        help="required for bare canonical lexicon lists",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    entries, document_language = _load_document(args.input)
    result = audit_entries(
        entries,
        language_code=args.language or document_language,
    )
    print(
        json.dumps(
            result,
            ensure_ascii=False,
            sort_keys=True,
        )
    )
    return 0 if result["status"] == "PASS" else 1


if __name__ == "__main__":
    raise SystemExit(main())
