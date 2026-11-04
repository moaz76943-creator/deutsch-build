#!/usr/bin/env python3
"""Deterministic German linguistic QA for canonical source and SQLite packs.

The checks are deliberately rule-bounded: they validate relationships encoded
by the canonical schema and avoid heuristic claims that are not universal
German grammar rules. No network, model, or paid service is used.
"""

from __future__ import annotations

import argparse
import json
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Mapping, Sequence

_WORD_FAMILY_RELATIONS = {
    "base",
    "agent_noun",
    "event_noun",
    "derived_noun",
    "derived_adjective",
    "prefixed_verb",
    "compound",
    "semantic_relative",
    "historical_relative",
    "not_pedagogically_linked",
}
_WORD_FAMILY_DISTANCES = {"low", "medium", "high"}
_WORD_FAMILY_LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}


@dataclass(frozen=True, order=True)
class QaIssue:
    severity: str
    path: str
    code: str
    message: str

    def to_json(self) -> dict[str, str]:
        return {
            "severity": self.severity,
            "path": self.path,
            "code": self.code,
            "message": self.message,
        }


@dataclass(frozen=True)
class QaReport:
    issues: tuple[QaIssue, ...]

    @property
    def errors(self) -> tuple[QaIssue, ...]:
        return tuple(issue for issue in self.issues if issue.severity == "error")

    @property
    def warnings(self) -> tuple[QaIssue, ...]:
        return tuple(issue for issue in self.issues if issue.severity == "warning")

    @property
    def is_valid(self) -> bool:
        return not self.errors

    def to_json(self) -> dict[str, Any]:
        return {
            "status": "valid" if self.is_valid else "invalid",
            "errors": len(self.errors),
            "warnings": len(self.warnings),
            "issues": [issue.to_json() for issue in self.issues],
        }


class GermanLinguisticQaError(ValueError):
    """Raised when canonical German data fails deterministic QA."""


def _report(issues: Iterable[QaIssue]) -> QaReport:
    return QaReport(tuple(sorted(issues)))


def _error(issues: list[QaIssue], code: str, path: str, message: str) -> None:
    issues.append(QaIssue("error", path, code, message))


def _warning(issues: list[QaIssue], code: str, path: str, message: str) -> None:
    issues.append(QaIssue("warning", path, code, message))


def _clean(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    return text or None


def _primary_language(document: Mapping[str, Any]) -> str:
    pack = document.get("pack")
    if not isinstance(pack, Mapping):
        return ""
    language = _clean(pack.get("languageCode")) or ""
    return language.split("-", 1)[0].lower()


def validate_german_source(document: Mapping[str, Any]) -> QaReport:
    if _primary_language(document) != "de":
        return QaReport(())

    issues: list[QaIssue] = []
    lexicon = document.get("lexicon")
    if not isinstance(lexicon, list):
        _error(issues, "source.lexicon_invalid", "lexicon", "lexicon must be a list")
        return _report(issues)

    for index, raw_entry in enumerate(lexicon):
        if not isinstance(raw_entry, Mapping):
            _error(
                issues,
                "source.entry_invalid",
                f"lexicon[{index}]",
                "lexicon entry must be an object",
            )
            continue

        path = f"lexicon[{index}]"
        surface = _clean(raw_entry.get("surface"))
        part_of_speech = (_clean(raw_entry.get("partOfSpeech")) or "").lower()
        fields = raw_entry.get("fields")
        if not isinstance(fields, Mapping):
            continue
        canonical = fields.get("canonical")
        if canonical is None:
            # Phase-2 migration intentionally permits untouched legacy rows.
            continue
        if not isinstance(canonical, Mapping):
            _error(
                issues,
                "canonical.invalid",
                path + ".fields.canonical",
                "canonical data must be an object",
            )
            continue

        cefr = _clean(canonical.get("cefr"))
        if cefr in {None, "unknown"}:
            _warning(
                issues,
                "concept.cefr_unresolved",
                path + ".fields.canonical.cefr",
                "CEFR is not resolved yet",
            )
        register = _clean(canonical.get("register"))
        if register in {None, "unknown"}:
            _warning(
                issues,
                "concept.register_unresolved",
                path + ".fields.canonical.register",
                "register is not resolved yet",
            )

        noun = canonical.get("noun")
        verb = canonical.get("verb")
        if part_of_speech == "noun":
            if not isinstance(noun, Mapping):
                _error(
                    issues,
                    "noun.canonical_missing",
                    path + ".fields.canonical.noun",
                    "canonical noun entry requires noun morphology",
                )
            else:
                _validate_noun(noun, surface, path + ".fields.canonical.noun", issues)
            if verb is not None:
                _error(
                    issues,
                    "noun.verb_branch_present",
                    path + ".fields.canonical.verb",
                    "noun entry cannot carry canonical verb morphology",
                )
        elif part_of_speech == "verb":
            if not isinstance(verb, Mapping):
                _error(
                    issues,
                    "verb.canonical_missing",
                    path + ".fields.canonical.verb",
                    "canonical verb entry requires verb morphology",
                )
            else:
                _validate_verb(verb, surface, path + ".fields.canonical.verb", issues)
            if noun is not None:
                _error(
                    issues,
                    "verb.noun_branch_present",
                    path + ".fields.canonical.noun",
                    "verb entry cannot carry canonical noun morphology",
                )
        elif noun is not None or verb is not None:
            _error(
                issues,
                "canonical.part_of_speech_mismatch",
                path + ".partOfSpeech",
                "German noun/verb morphology does not match partOfSpeech",
            )

    _validate_word_families(lexicon, issues)
    return _report(issues)


def _validate_word_family_entry(
    raw_entry: Any,
    index: int,
    concept_ids: set[str],
    families: dict[str, list[tuple[str, str, str]]],
    issues: list[QaIssue],
) -> None:
    if not isinstance(raw_entry, Mapping):
        return
    concept_id = _clean(raw_entry.get("id"))
    fields = raw_entry.get("fields")
    if concept_id is None or not isinstance(fields, Mapping):
        return
    canonical = fields.get("canonical")
    if not isinstance(canonical, Mapping):
        return
    family = canonical.get("wordFamily")
    if family is None:
        return

    path = f"lexicon[{index}].fields.canonical.wordFamily"
    if not isinstance(family, Mapping):
        _error(
            issues,
            "word_family.invalid",
            path,
            "wordFamily must be an explicit object",
        )
        return
    allowed_family_keys = {
        "familyId",
        "baseConceptId",
        "relationType",
        "prefix",
        "suffix",
        "semanticDistance",
        "pedagogicalLevel",
        "interferenceRisk",
    }
    unknown_family_keys = sorted(set(family) - allowed_family_keys)
    if unknown_family_keys:
        _error(
            issues,
            "word_family.unknown_keys",
            path,
            "wordFamily contains unknown keys: " + ", ".join(unknown_family_keys),
        )

    family_id = _clean(family.get("familyId"))
    base_id = _clean(family.get("baseConceptId"))
    relation = _clean(family.get("relationType"))
    distance = _clean(family.get("semanticDistance"))
    level = _clean(family.get("pedagogicalLevel"))
    interference = family.get("interferenceRisk")

    if family_id is None:
        _error(issues, "word_family.family_id_blank", path + ".familyId", "familyId is required")
    if base_id is None:
        _error(issues, "word_family.base_id_blank", path + ".baseConceptId", "baseConceptId is required")
    elif base_id not in concept_ids:
        _error(
            issues,
            "word_family.base_missing",
            path + ".baseConceptId",
            "baseConceptId must reference a concept in the same pack",
        )
    if relation not in _WORD_FAMILY_RELATIONS:
        _error(
            issues,
            "word_family.relation_invalid",
            path + ".relationType",
            "relationType must be an approved explicit relation",
        )
    if distance not in _WORD_FAMILY_DISTANCES:
        _error(
            issues,
            "word_family.distance_invalid",
            path + ".semanticDistance",
            "semanticDistance must be low, medium, or high",
        )
    if level not in _WORD_FAMILY_LEVELS:
        _error(
            issues,
            "word_family.level_invalid",
            path + ".pedagogicalLevel",
            "pedagogicalLevel must be an explicit CEFR level",
        )
    if not isinstance(interference, bool):
        _error(
            issues,
            "word_family.interference_invalid",
            path + ".interferenceRisk",
            "interferenceRisk must be boolean",
        )
    for key in ("prefix", "suffix"):
        value = family.get(key)
        if value is not None and _clean(value) is None:
            _error(
                issues,
                "word_family.affix_invalid",
                path + "." + key,
                key + " must be a non-empty string when present",
            )

    if family_id is not None and base_id is not None and relation is not None:
        families.setdefault(family_id, []).append(
            (concept_id, base_id, relation)
        )


def _validate_word_family_group(
    family_id: str,
    members: list[tuple[str, str, str]],
    issues: list[QaIssue],
) -> None:
    base_ids = {member[1] for member in members}
    if len(base_ids) != 1:
        _error(
            issues,
            "word_family.base_conflict",
            "wordFamily." + family_id,
            "all members of a family must share one baseConceptId",
        )
        return
    base_id = next(iter(base_ids))
    bases = [
        concept_id
        for concept_id, _, relation in members
        if relation == "base"
    ]
    if bases != [base_id]:
        _error(
            issues,
            "word_family.base_member_invalid",
            "wordFamily." + family_id,
            "family must contain exactly one base relation on baseConceptId",
        )


def _validate_word_families(
    lexicon: list[Any],
    issues: list[QaIssue],
) -> None:
    concept_ids = {
        _clean(entry.get("id"))
        for entry in lexicon
        if isinstance(entry, Mapping) and _clean(entry.get("id")) is not None
    }
    families: dict[str, list[tuple[str, str, str]]] = {}

    for index, raw_entry in enumerate(lexicon):
        if not isinstance(raw_entry, Mapping):
            continue
        concept_id = _clean(raw_entry.get("id"))
        fields = raw_entry.get("fields")
        if concept_id is None or not isinstance(fields, Mapping):
            continue
        canonical = fields.get("canonical")
        if not isinstance(canonical, Mapping):
            continue
        family = canonical.get("wordFamily")
        if family is None:
            continue

        path = f"lexicon[{index}].fields.canonical.wordFamily"
        if not isinstance(family, Mapping):
            _error(
                issues,
                "word_family.invalid",
                path,
                "wordFamily must be an explicit object",
            )
            continue
        allowed_family_keys = {
            "familyId",
            "baseConceptId",
            "relationType",
            "prefix",
            "suffix",
            "semanticDistance",
            "pedagogicalLevel",
            "interferenceRisk",
        }
        unknown_family_keys = sorted(set(family) - allowed_family_keys)
        if unknown_family_keys:
            _error(
                issues,
                "word_family.unknown_keys",
                path,
                "wordFamily contains unknown keys: " + ", ".join(unknown_family_keys),
            )

        family_id = _clean(family.get("familyId"))
        base_id = _clean(family.get("baseConceptId"))
        relation = _clean(family.get("relationType"))
        distance = _clean(family.get("semanticDistance"))
        level = _clean(family.get("pedagogicalLevel"))
        interference = family.get("interferenceRisk")

        if family_id is None:
            _error(
                issues,
                "word_family.family_id_blank",
                path + ".familyId",
                "familyId is required",
            )
        if base_id is None:
            _error(
                issues,
                "word_family.base_id_blank",
                path + ".baseConceptId",
                "baseConceptId is required",
            )
        elif base_id not in concept_ids:
            _error(
                issues,
                "word_family.base_missing",
                path + ".baseConceptId",
                "baseConceptId must reference a concept in the same pack",
            )
        if relation not in _WORD_FAMILY_RELATIONS:
            _error(
                issues,
                "word_family.relation_invalid",
                path + ".relationType",
                "relationType must be an approved explicit relation",
            )
        if distance not in _WORD_FAMILY_DISTANCES:
            _error(
                issues,
                "word_family.distance_invalid",
                path + ".semanticDistance",
                "semanticDistance must be low, medium, or high",
            )
        if level not in _WORD_FAMILY_LEVELS:
            _error(
                issues,
                "word_family.level_invalid",
                path + ".pedagogicalLevel",
                "pedagogicalLevel must be an explicit CEFR level",
            )
        if not isinstance(interference, bool):
            _error(
                issues,
                "word_family.interference_invalid",
                path + ".interferenceRisk",
                "interferenceRisk must be boolean",
            )
        for key in ("prefix", "suffix"):
            value = family.get(key)
            if value is not None and _clean(value) is None:
                _error(
                    issues,
                    "word_family.affix_invalid",
                    path + "." + key,
                    key + " must be a non-empty string when present",
                )

        if family_id is not None and base_id is not None and relation is not None:
            families.setdefault(family_id, []).append((concept_id, base_id, relation))

    for family_id, members in families.items():
        base_ids = {member[1] for member in members}
        if len(base_ids) != 1:
            _error(
                issues,
                "word_family.base_conflict",
                "wordFamily." + family_id,
                "all members of a family must share one baseConceptId",
            )
            continue
        base_id = next(iter(base_ids))
        bases = [
            concept_id for concept_id, _, relation in members if relation == "base"
        ]
        if bases != [base_id]:
            _error(
                issues,
                "word_family.base_member_invalid",
                "wordFamily." + family_id,
                "family must contain exactly one base relation on baseConceptId",
            )


def _validate_noun(
    noun: Mapping[str, Any],
    surface: str | None,
    path: str,
    issues: list[QaIssue],
) -> None:
    gender = _clean(noun.get("gender"))
    if gender not in {"masculine", "feminine", "neuter"}:
        _error(
            issues,
            "noun.gender_unresolved",
            path + ".gender",
            "canonical German noun requires explicit grammatical gender",
        )

    declension = _clean(noun.get("declensionClass"))
    if declension in {None, "unknown"}:
        _error(
            issues,
            "noun.declension_unresolved",
            path + ".declensionClass",
            "canonical German noun requires a declension class",
        )

    forms = noun.get("caseForms")
    if not isinstance(forms, Mapping):
        _error(
            issues,
            "noun.case_forms_invalid",
            path + ".caseForms",
            "caseForms must be an object",
        )
        return

    singular_keys = (
        "nominativeSingular",
        "accusativeSingular",
        "dativeSingular",
        "genitiveSingular",
    )
    for key in singular_keys:
        if _clean(forms.get(key)) is None:
            _error(
                issues,
                "noun.case_form_blank",
                path + ".caseForms." + key,
                "singular case form cannot be blank",
            )

    nominative = _clean(forms.get("nominativeSingular"))
    if surface is not None and nominative is not None and nominative != surface:
        _error(
            issues,
            "noun.lemma_nominative_mismatch",
            path + ".caseForms.nominativeSingular",
            "surface/lemma must equal nominative singular",
        )

    plural = _clean(noun.get("plural"))
    plural_keys = (
        "nominativePlural",
        "accusativePlural",
        "dativePlural",
        "genitivePlural",
    )
    plural_values = {key: _clean(forms.get(key)) for key in plural_keys}
    if plural is None:
        if any(value is not None for value in plural_values.values()):
            _error(
                issues,
                "noun.plural_forms_without_plural",
                path + ".caseForms",
                "plural case forms require canonical plural",
            )
    else:
        if plural_values["nominativePlural"] != plural:
            _error(
                issues,
                "noun.plural_mismatch",
                path + ".caseForms.nominativePlural",
                "canonical plural must equal nominative plural",
            )
        for key, value in plural_values.items():
            if value is None:
                _error(
                    issues,
                    "noun.plural_case_missing",
                    path + ".caseForms." + key,
                    "declared plural requires all plural case forms",
                )


def _validate_verb_prefixes(
    verb: Mapping[str, Any],
    infinitive: str | None,
    path: str,
    issues: list[QaIssue],
) -> None:
    separable = _clean(verb.get("separablePrefix"))
    inseparable = _clean(verb.get("inseparablePrefix"))
    if separable is not None and inseparable is not None:
        _error(
            issues,
            "verb.prefix_conflict",
            path,
            "verb cannot declare both separable and inseparable prefixes",
        )
    if infinitive is not None and separable is not None and not infinitive.startswith(separable):
        _error(
            issues,
            "verb.separable_prefix_mismatch",
            path + ".separablePrefix",
            "separable prefix must be a prefix of infinitive",
        )
    if infinitive is not None and inseparable is not None and not infinitive.startswith(inseparable):
        _error(
            issues,
            "verb.inseparable_prefix_mismatch",
            path + ".inseparablePrefix",
            "inseparable prefix must be a prefix of infinitive",
        )


def _validate_verb_valency_frames(
    verb: Mapping[str, Any],
    path: str,
    issues: list[QaIssue],
) -> None:
    frames = verb.get("valencyFrames", [])
    if not isinstance(frames, list):
        return

    seen_frames: set[str] = set()
    for index, raw_frame in enumerate(frames):
        frame_path = path + f".valencyFrames[{index}]"
        if not isinstance(raw_frame, Mapping):
            _error(
                issues,
                "valency.invalid_frame",
                frame_path,
                "valency frame must be an object",
            )
            continue
        frame_id = _clean(raw_frame.get("id"))
        if frame_id is None:
            _error(
                issues,
                "valency.blank_frame_id",
                frame_path + ".id",
                "frame id cannot be blank",
            )
        elif frame_id in seen_frames:
            _error(
                issues,
                "valency.duplicate_frame_id",
                frame_path + ".id",
                "frame id must be unique per verb",
            )
        else:
            seen_frames.add(frame_id)

        role = _clean(raw_frame.get("semanticRole"))
        if role is None:
            _error(
                issues,
                "valency.blank_semantic_role",
                frame_path + ".semanticRole",
                "semantic role cannot be blank",
            )
        governed = _clean(raw_frame.get("governedCase"))
        preposition = _clean(raw_frame.get("preposition"))
        preposition_case = _clean(raw_frame.get("prepositionCase"))
        if (preposition is None) != (preposition_case is None):
            _error(
                issues,
                "valency.preposition_case_pair",
                frame_path,
                "preposition and prepositionCase must be declared together",
            )
        if governed is None and not (
            preposition is not None and preposition_case is not None
        ):
            _error(
                issues,
                "valency.missing_government",
                frame_path,
                "valency frame requires case or preposition government",
            )


def _validate_verb_forms(
    verb: Mapping[str, Any],
    path: str,
    issues: list[QaIssue],
) -> None:
    forms = verb.get("forms", [])
    if not isinstance(forms, list):
        return

    seen_forms: set[tuple[str, str]] = set()
    for index, raw_form in enumerate(forms):
        form_path = path + f".forms[{index}]"
        if not isinstance(raw_form, Mapping):
            _error(
                issues,
                "verb.invalid_form",
                form_path,
                "verb form must be an object",
            )
            continue
        tense = _clean(raw_form.get("tense"))
        person = _clean(raw_form.get("personKey"))
        form = _clean(raw_form.get("form"))
        if tense is None or person is None or form is None:
            _error(
                issues,
                "verb.form_field_blank",
                form_path,
                "tense, personKey and form are required",
            )
            continue
        key = (tense, person)
        if key in seen_forms:
            _error(
                issues,
                "verb.duplicate_form_key",
                form_path,
                "tense/personKey must be unique",
            )
        seen_forms.add(key)


def _validate_verb(
    verb: Mapping[str, Any],
    surface: str | None,
    path: str,
    issues: list[QaIssue],
) -> None:
    infinitive = _clean(verb.get("infinitive"))
    if infinitive is None:
        _error(
            issues, "verb.infinitive_blank", path + ".infinitive", "infinitive is blank"
        )
    elif surface is not None and infinitive != surface:
        _error(
            issues,
            "verb.lemma_infinitive_mismatch",
            path + ".infinitive",
            "surface/lemma must equal canonical infinitive",
        )

    if _clean(verb.get("auxiliary")) in {None, "unknown"}:
        _error(
            issues,
            "verb.auxiliary_unresolved",
            path + ".auxiliary",
            "canonical verb requires haben/sein classification",
        )
    if _clean(verb.get("reflexivity")) in {None, "unknown"}:
        _error(
            issues,
            "verb.reflexivity_unresolved",
            path + ".reflexivity",
            "canonical verb requires explicit reflexivity metadata",
        )

    separable = _clean(verb.get("separablePrefix"))
    inseparable = _clean(verb.get("inseparablePrefix"))
    if separable is not None and inseparable is not None:
        _error(
            issues,
            "verb.prefix_conflict",
            path,
            "verb cannot declare both separable and inseparable prefixes",
        )
    if (
        infinitive is not None
        and separable is not None
        and not infinitive.startswith(separable)
    ):
        _error(
            issues,
            "verb.separable_prefix_mismatch",
            path + ".separablePrefix",
            "separable prefix must be a prefix of infinitive",
        )
    if (
        infinitive is not None
        and inseparable is not None
        and not infinitive.startswith(inseparable)
    ):
        _error(
            issues,
            "verb.inseparable_prefix_mismatch",
            path + ".inseparablePrefix",
            "inseparable prefix must be a prefix of infinitive",
        )

    frames = verb.get("valencyFrames", [])
    if isinstance(frames, list):
        seen_frames: set[str] = set()
        for index, raw_frame in enumerate(frames):
            frame_path = path + f".valencyFrames[{index}]"
            if not isinstance(raw_frame, Mapping):
                _error(
                    issues,
                    "valency.invalid_frame",
                    frame_path,
                    "valency frame must be an object",
                )
                continue
            frame_id = _clean(raw_frame.get("id"))
            if frame_id is None:
                _error(
                    issues,
                    "valency.blank_frame_id",
                    frame_path + ".id",
                    "frame id cannot be blank",
                )
            elif frame_id in seen_frames:
                _error(
                    issues,
                    "valency.duplicate_frame_id",
                    frame_path + ".id",
                    "frame id must be unique per verb",
                )
            else:
                seen_frames.add(frame_id)

            role = _clean(raw_frame.get("semanticRole"))
            if role is None:
                _error(
                    issues,
                    "valency.blank_semantic_role",
                    frame_path + ".semanticRole",
                    "semantic role cannot be blank",
                )
            governed = _clean(raw_frame.get("governedCase"))
            preposition = _clean(raw_frame.get("preposition"))
            preposition_case = _clean(raw_frame.get("prepositionCase"))
            if (preposition is None) != (preposition_case is None):
                _error(
                    issues,
                    "valency.preposition_case_pair",
                    frame_path,
                    "preposition and prepositionCase must be declared together",
                )
            if governed is None and not (
                preposition is not None and preposition_case is not None
            ):
                _error(
                    issues,
                    "valency.missing_government",
                    frame_path,
                    "valency frame requires case or preposition government",
                )

    forms = verb.get("forms", [])
    if isinstance(forms, list):
        seen_forms: set[tuple[str, str]] = set()
        for index, raw_form in enumerate(forms):
            form_path = path + f".forms[{index}]"
            if not isinstance(raw_form, Mapping):
                _error(
                    issues,
                    "verb.invalid_form",
                    form_path,
                    "verb form must be an object",
                )
                continue
            tense = _clean(raw_form.get("tense"))
            person = _clean(raw_form.get("personKey"))
            form = _clean(raw_form.get("form"))
            if tense is None or person is None or form is None:
                _error(
                    issues,
                    "verb.form_field_blank",
                    form_path,
                    "tense, personKey and form are required",
                )
                continue
            key = (tense, person)
            if key in seen_forms:
                _error(
                    issues,
                    "verb.duplicate_form_key",
                    form_path,
                    "tense/personKey must be unique",
                )
            seen_forms.add(key)


def assert_german_source(document: Mapping[str, Any]) -> QaReport:
    report = validate_german_source(document)
    _raise_if_invalid(report, "source")
    return report


def _audit_sqlite_nouns(connection: sqlite3.Connection, issues: list[QaIssue]) -> None:
    noun_sql = """
        SELECT c.concept_id, c.lemma, c.part_of_speech,
               n.gender, n.plural, n.declension_class,
               n.nominative_singular, n.accusative_singular,
               n.dative_singular, n.genitive_singular,
               n.nominative_plural, n.accusative_plural,
               n.dative_plural, n.genitive_plural
        FROM german_nouns n
        JOIN concepts c ON c.concept_id = n.concept_id
        ORDER BY c.concept_id
    """
    for row in connection.execute(noun_sql):
        (
            concept_id,
            lemma,
            part_of_speech,
            gender,
            plural,
            declension,
            nominative_singular,
            accusative_singular,
            dative_singular,
            genitive_singular,
            nominative_plural,
            accusative_plural,
            dative_plural,
            genitive_plural,
        ) = row
        path = "sqlite.german_nouns." + str(concept_id)
        if str(part_of_speech).lower() != "noun":
            _error(
                issues,
                "concept.part_of_speech_mismatch",
                path,
                "german_nouns row must reference a noun concept",
            )
        if _clean(gender) not in {"masculine", "feminine", "neuter"}:
            _error(
                issues, "noun.gender_unresolved", path + ".gender", "gender unresolved"
            )
        if _clean(declension) in {None, "unknown"}:
            _error(
                issues,
                "noun.declension_unresolved",
                path + ".declension_class",
                "declension unresolved",
            )
        for name, value in (
            ("nominative_singular", nominative_singular),
            ("accusative_singular", accusative_singular),
            ("dative_singular", dative_singular),
            ("genitive_singular", genitive_singular),
        ):
            if _clean(value) is None:
                _error(
                    issues, "noun.case_form_blank", path + "." + name, "case form blank"
                )
        if _clean(lemma) != _clean(nominative_singular):
            _error(
                issues,
                "noun.lemma_nominative_mismatch",
                path + ".nominative_singular",
                "lemma must equal nominative singular",
            )
        clean_plural = _clean(plural)
        plural_values = (
            _clean(nominative_plural),
            _clean(accusative_plural),
            _clean(dative_plural),
            _clean(genitive_plural),
        )
        if clean_plural is None:
            if any(value is not None for value in plural_values):
                _error(
                    issues,
                    "noun.plural_forms_without_plural",
                    path,
                    "plural forms exist without canonical plural",
                )
        else:
            if plural_values[0] != clean_plural:
                _error(
                    issues,
                    "noun.plural_mismatch",
                    path + ".nominative_plural",
                    "canonical plural must equal nominative plural",
                )
            if any(value is None for value in plural_values):
                _error(
                    issues,
                    "noun.plural_case_missing",
                    path,
                    "declared plural requires all plural case forms",
                )


def _audit_sqlite_verbs(connection: sqlite3.Connection, issues: list[QaIssue]) -> None:
    verb_sql = """
        SELECT c.concept_id, c.lemma, c.part_of_speech,
               v.infinitive, v.separable_prefix, v.inseparable_prefix,
               v.reflexivity, v.auxiliary
        FROM german_verbs v
        JOIN concepts c ON c.concept_id = v.concept_id
        ORDER BY c.concept_id
    """
    for row in connection.execute(verb_sql):
        (
            concept_id,
            lemma,
            part_of_speech,
            infinitive,
            separable,
            inseparable,
            reflexivity,
            auxiliary,
        ) = row
        path = "sqlite.german_verbs." + str(concept_id)
        if str(part_of_speech).lower() != "verb":
            _error(
                issues,
                "concept.part_of_speech_mismatch",
                path,
                "german_verbs row must reference a verb concept",
            )
        if _clean(lemma) != _clean(infinitive):
            _error(
                issues,
                "verb.lemma_infinitive_mismatch",
                path + ".infinitive",
                "lemma must equal infinitive",
            )
        if _clean(auxiliary) in {None, "unknown"}:
            _error(
                issues,
                "verb.auxiliary_unresolved",
                path + ".auxiliary",
                "auxiliary unresolved",
            )
        if _clean(reflexivity) in {None, "unknown"}:
            _error(
                issues,
                "verb.reflexivity_unresolved",
                path + ".reflexivity",
                "reflexivity unresolved",
            )
        sep = _clean(separable)
        insep = _clean(inseparable)
        infinitive_text = _clean(infinitive)
        if sep is not None and insep is not None:
            _error(issues, "verb.prefix_conflict", path, "conflicting prefix metadata")
        if (
            sep is not None
            and infinitive_text is not None
            and not infinitive_text.startswith(sep)
        ):
            _error(
                issues,
                "verb.separable_prefix_mismatch",
                path + ".separable_prefix",
                "separable prefix is not a prefix of infinitive",
            )
        if (
            insep is not None
            and infinitive_text is not None
            and not infinitive_text.startswith(insep)
        ):
            _error(
                issues,
                "verb.inseparable_prefix_mismatch",
                path + ".inseparable_prefix",
                "inseparable prefix is not a prefix of infinitive",
            )


def _audit_sqlite_valency(
    connection: sqlite3.Connection, issues: list[QaIssue]
) -> None:
    valency_sql = """
        SELECT concept_id, frame_id, governed_case, preposition,
               preposition_case, semantic_role
        FROM verb_valency_frames
        ORDER BY concept_id, frame_id
    """
    for row in connection.execute(valency_sql):
        concept_id, frame_id, governed, preposition, preposition_case, role = row
        path = "sqlite.valency." + str(concept_id) + "." + str(frame_id)
        if _clean(frame_id) is None:
            _error(issues, "valency.blank_frame_id", path, "frame id blank")
        if _clean(role) is None:
            _error(issues, "valency.blank_semantic_role", path, "semantic role blank")
        prep = _clean(preposition)
        prep_case = _clean(preposition_case)
        if (prep is None) != (prep_case is None):
            _error(
                issues,
                "valency.preposition_case_pair",
                path,
                "preposition and prepositionCase must be declared together",
            )
        if _clean(governed) is None and not (
            prep is not None and prep_case is not None
        ):
            _error(
                issues,
                "valency.missing_government",
                path,
                "valency frame requires case or preposition government",
            )


def _audit_sqlite_word_families(
    connection: sqlite3.Connection, issues: list[QaIssue]
) -> None:
    tables = {
        str(row[0])
        for row in connection.execute(
            "SELECT name FROM sqlite_master WHERE type='table'"
        )
    }
    family_tables = {"german_word_families", "german_word_family_members"}
    present_family_tables = family_tables.intersection(tables)
    if present_family_tables and present_family_tables != family_tables:
        _error(
            issues,
            "word_family.sqlite_partial_schema",
            "sqlite.word_family",
            "word family schema must be complete",
        )
    elif family_tables.issubset(tables):
        family_rows = connection.execute(
            "SELECT f.family_id, f.base_concept_id, m.concept_id, "
            "m.relation_type, m.semantic_distance, m.pedagogical_level, "
            "m.interference_risk "
            "FROM german_word_families f "
            "JOIN german_word_family_members m ON m.family_id=f.family_id "
            "ORDER BY f.family_id, m.concept_id"
        ).fetchall()
        by_family: dict[str, list[tuple[Any, ...]]] = {}
        for row in family_rows:
            family_id, base_id, concept_id, relation, distance, level, risk = row
            path = "sqlite.word_family." + str(family_id) + "." + str(concept_id)
            if _clean(relation) not in _WORD_FAMILY_RELATIONS:
                _error(issues, "word_family.relation_invalid", path, "invalid relation")
            if _clean(distance) not in _WORD_FAMILY_DISTANCES:
                _error(issues, "word_family.distance_invalid", path, "invalid distance")
            if _clean(level) not in _WORD_FAMILY_LEVELS:
                _error(
                    issues,
                    "word_family.level_invalid",
                    path,
                    "invalid pedagogical level",
                )
            if risk not in (0, 1):
                _error(
                    issues,
                    "word_family.interference_invalid",
                    path,
                    "invalid interference flag",
                )
            by_family.setdefault(str(family_id), []).append(row)

        for family_id, rows in by_family.items():
            base_ids = {str(row[1]) for row in rows}
            if len(base_ids) != 1:
                _error(
                    issues,
                    "word_family.base_conflict",
                    "sqlite.word_family." + family_id,
                    "family has conflicting base concepts",
                )
                continue
            base_id = next(iter(base_ids))
            bases = [str(row[2]) for row in rows if str(row[3]) == "base"]
            if bases != [base_id]:
                _error(
                    issues,
                    "word_family.base_member_invalid",
                    "sqlite.word_family." + family_id,
                    "family base relation does not match base concept",
                )


def audit_sqlite_connection(connection: sqlite3.Connection) -> QaReport:
    issues: list[QaIssue] = []
    language_row = connection.execute(
        "SELECT value FROM metadata WHERE key='languageCode'"
    ).fetchone()
    if language_row is None or str(language_row[0]).split("-", 1)[0].lower() != "de":
        return QaReport(())

    try:
        foreign_key_rows = connection.execute("PRAGMA foreign_key_check").fetchall()
    except sqlite3.Error as exc:
        _error(
            issues,
            "sqlite.foreign_key_check_failed",
            "sqlite",
            "foreign_key_check failed: " + str(exc),
        )
        return _report(issues)

    for row in foreign_key_rows:
        _error(
            issues,
            "sqlite.foreign_key_violation",
            "sqlite." + str(row[0]),
            "foreign key violation in canonical pack",
        )

    _audit_sqlite_nouns(connection, issues)
    _audit_sqlite_verbs(connection, issues)
    _audit_sqlite_valency(connection, issues)
    _audit_sqlite_word_families(connection, issues)

    return _report(issues)


def assert_german_sqlite(connection: sqlite3.Connection) -> QaReport:
    report = audit_sqlite_connection(connection)
    _raise_if_invalid(report, "sqlite")
    return report


def _raise_if_invalid(report: QaReport, context: str) -> None:
    if report.is_valid:
        return
    first = report.errors[0]
    raise GermanLinguisticQaError(
        context + " German QA failed: " + first.code + " at " + first.path
    )


def _merge(reports: Iterable[QaReport]) -> QaReport:
    return _report(issue for report in reports for issue in report.issues)


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Run deterministic German linguistic QA"
    )
    parser.add_argument("--source", action="append", default=[])
    parser.add_argument("--sqlite", action="append", default=[])
    parser.add_argument("--report")
    args = parser.parse_args(argv)

    reports: list[QaReport] = []
    try:
        for source_path in args.source:
            payload = json.loads(Path(source_path).read_text(encoding="utf-8"))
            if not isinstance(payload, Mapping):
                raise GermanLinguisticQaError("source root must be an object")
            reports.append(validate_german_source(payload))
        for sqlite_path in args.sqlite:
            connection = sqlite3.connect(sqlite_path)
            try:
                reports.append(audit_sqlite_connection(connection))
            finally:
                connection.close()
    except (
        OSError,
        json.JSONDecodeError,
        sqlite3.Error,
        GermanLinguisticQaError,
    ) as exc:
        report = {
            "status": "error",
            "message": str(exc),
        }
        if args.report:
            Path(args.report).write_text(
                json.dumps(report, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
                encoding="utf-8",
            )
        print(json.dumps(report, ensure_ascii=False, sort_keys=True))
        return 1

    merged = _merge(reports)
    output = merged.to_json()
    if args.report:
        destination = Path(args.report)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_text(
            json.dumps(output, ensure_ascii=False, sort_keys=True, indent=2) + "\n",
            encoding="utf-8",
        )
    print(json.dumps(output, ensure_ascii=False, sort_keys=True))
    return 0 if merged.is_valid else 1


if __name__ == "__main__":
    raise SystemExit(main())
