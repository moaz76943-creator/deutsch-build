#!/usr/bin/env python3
"""Strict ARB localization engineering agent.

The agent never performs machine translation. It synchronizes ARB structure,
requires contextual/idiomatic review metadata, preserves canonical metadata and
ICU arguments, resolves explicit RTL/LTR direction, and applies a deterministic
width budget intended for constrained glass-card UI surfaces.
"""

from __future__ import annotations

import argparse
import json
import re
import unicodedata
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

RTL_LANGUAGES = frozenset({"ar", "fa", "he", "ur", "ps"})
ALLOWED_TRANSLATION_STRATEGIES = frozenset(
    {"contextual", "idiomatic", "cultural_equivalent", "sense_equivalent"}
)
CANONICAL_METADATA_FIELDS = frozenset(
    {"description", "placeholders", "layout"}
)


class LocalizationAgentError(ValueError):
    """Raised when synchronization cannot preserve the localization contract."""


@dataclass(frozen=True)
class AuditIssue:
    code: str
    key: str
    message: str
    severity: str = "error"

    def to_json(self) -> dict[str, str]:
        return {
            "code": self.code,
            "key": self.key,
            "message": self.message,
            "severity": self.severity,
        }


@dataclass(frozen=True)
class LocalizationAuditReport:
    locale_code: str
    direction: str
    errors: tuple[AuditIssue, ...]
    warnings: tuple[AuditIssue, ...]

    @property
    def is_valid(self) -> bool:
        return not self.errors

    def to_json(self) -> dict[str, Any]:
        return {
            "status": "PASS" if self.is_valid else "FAIL",
            "locale": self.locale_code,
            "direction": self.direction,
            "errors": [issue.to_json() for issue in self.errors],
            "warnings": [issue.to_json() for issue in self.warnings],
        }


def _primary_language(locale_code: str) -> str:
    if not isinstance(locale_code, str) or not locale_code.strip():
        raise LocalizationAgentError("locale code must be a non-empty string")
    return re.split(r"[-_]", locale_code.strip().lower(), maxsplit=1)[0]


def text_direction_for(locale_code: str) -> str:
    return "rtl" if _primary_language(locale_code) in RTL_LANGUAGES else "ltr"


def _message_keys(arb: Mapping[str, Any]) -> list[str]:
    return [key for key in arb if not key.startswith("@")]


def _metadata(arb: Mapping[str, Any], key: str) -> Mapping[str, Any]:
    value = arb.get(f"@{key}", {})
    return value if isinstance(value, Mapping) else {}


def _skip_ws(text: str, index: int) -> int:
    while index < len(text) and text[index].isspace():
        index += 1
    return index


def _scan_quoted(text: str, index: int) -> int:
    """Skip one ICU apostrophe-quoted literal, including doubled apostrophes."""
    index += 1
    while index < len(text):
        if text[index] == "'":
            if index + 1 < len(text) and text[index + 1] == "'":
                index += 2
                continue
            return index + 1
        index += 1
    return index


def _find_matching_brace(text: str, start: int) -> int:
    depth = 1
    index = start + 1
    while index < len(text):
        char = text[index]
        if char == "'":
            index = _scan_quoted(text, index)
            continue
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
            if depth == 0:
                return index
        index += 1
    raise LocalizationAgentError("unbalanced ICU message braces")


def _split_argument_header(content: str) -> tuple[str, str | None, str]:
    parts: list[str] = []
    start = 0
    depth = 0
    index = 0
    while index < len(content) and len(parts) < 2:
        char = content[index]
        if char == "'":
            index = _scan_quoted(content, index)
            continue
        if char == "{":
            depth += 1
        elif char == "}":
            depth -= 1
        elif char == "," and depth == 0:
            parts.append(content[start:index].strip())
            start = index + 1
        index += 1
    tail = content[start:].strip()
    if not parts:
        return tail, None, ""
    name = parts[0]
    if len(parts) == 1:
        comma = tail.find(",")
        if comma < 0:
            return name, tail.strip().lower(), ""
        return name, tail[:comma].strip().lower(), tail[comma + 1 :].strip()
    return name, parts[1].strip().lower(), tail


def _branch_messages(style: str) -> list[str]:
    branches: list[str] = []
    index = 0
    while index < len(style):
        index = _skip_ws(style, index)
        if index >= len(style):
            break
        selector_start = index
        while (
            index < len(style)
            and not style[index].isspace()
            and style[index] != "{"
        ):
            index += 1
        selector = style[selector_start:index].strip()
        index = _skip_ws(style, index)
        if not selector:
            break
        if index >= len(style) or style[index] != "{":
            while index < len(style) and not style[index].isspace():
                index += 1
            continue
        end = _find_matching_brace(style, index)
        branches.append(style[index + 1 : end])
        index = end + 1
    return branches


def icu_argument_names(text: str) -> frozenset[str]:
    """Extract ICU argument names without treating plural/select branch bodies as args."""
    names: set[str] = set()
    index = 0
    while index < len(text):
        char = text[index]
        if char == "'":
            index = _scan_quoted(text, index)
            continue
        if char != "{":
            index += 1
            continue
        end = _find_matching_brace(text, index)
        content = text[index + 1 : end]
        name, kind, style = _split_argument_header(content)
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            raise LocalizationAgentError(
                f"invalid ICU argument name: {name!r}"
            )
        names.add(name)
        if kind in {"plural", "selectordinal", "select"}:
            for branch in _branch_messages(style):
                names.update(icu_argument_names(branch))
        index = end + 1
    return frozenset(names)


def _visible_text(text: str) -> str:
    result: list[str] = []
    index = 0
    while index < len(text):
        if text[index] != "{":
            result.append(text[index])
            index += 1
            continue
        end = _find_matching_brace(text, index)
        result.append("X")
        index = end + 1
    return "".join(result)


def estimate_width_units(text: str) -> float:
    """Estimate width in em-like units without depending on Flutter/font APIs."""
    units = 0.0
    for char in _visible_text(text):
        if char.isspace():
            units += 0.35
            continue
        category = unicodedata.category(char)
        if category.startswith("P"):
            units += 0.45
            continue
        width = unicodedata.east_asian_width(char)
        if width in {"W", "F"}:
            units += 1.0
        elif "ARABIC" in unicodedata.name(char, ""):
            units += 0.72
        else:
            units += 0.62
    return round(units, 3)


def _layout_budget(
    base_meta: Mapping[str, Any],
    target_meta: Mapping[str, Any],
) -> float:
    layout = base_meta.get("layout")
    if isinstance(layout, Mapping):
        raw = layout.get("maxWidthEm")
        if (
            isinstance(raw, (int, float))
            and not isinstance(raw, bool)
            and raw > 0
        ):
            return float(raw)
    layout = target_meta.get("layout")
    if isinstance(layout, Mapping):
        raw = layout.get("maxWidthEm")
        if (
            isinstance(raw, (int, float))
            and not isinstance(raw, bool)
            and raw > 0
        ):
            return float(raw)
    return 48.0


def _assert_target_locale(
    target_arb: Mapping[str, Any],
    locale_code: str,
) -> str:
    locale = _primary_language(locale_code)
    declared = target_arb.get("@@locale")
    if declared is not None:
        if not isinstance(declared, str) or not declared.strip():
            raise LocalizationAgentError(
                "target @@locale must be a non-empty string"
            )
        if _primary_language(declared) != locale:
            raise LocalizationAgentError(
                f"target locale mismatch: declared {declared!r}, "
                f"requested {locale!r}"
            )
    return locale


def build_translation_template(
    base_arb: Mapping[str, Any],
    *,
    locale_code: str,
) -> dict[str, Any]:
    """Build a reviewer template without copying source-language message text."""
    locale = _primary_language(locale_code)
    result: dict[str, Any] = {"@@locale": locale}
    for key in _message_keys(base_arb):
        result[key] = ""
        base_meta = dict(_metadata(base_arb, key))
        meta: dict[str, Any] = {
            "description": base_meta.get("description", ""),
            "translationStrategy": "contextual",
            "reviewStatus": "candidate",
        }
        if "placeholders" in base_meta:
            meta["placeholders"] = base_meta["placeholders"]
        if "layout" in base_meta:
            meta["layout"] = base_meta["layout"]
        result[f"@{key}"] = meta
    return result


def synchronize_arb(
    base_arb: Mapping[str, Any],
    target_arb: Mapping[str, Any],
    *,
    locale_code: str,
) -> dict[str, Any]:
    """Synchronize key order/metadata while refusing to invent translations."""
    locale = _assert_target_locale(target_arb, locale_code)
    base_keys = _message_keys(base_arb)
    target_keys = set(_message_keys(target_arb))
    missing = [key for key in base_keys if key not in target_keys]
    if missing:
        raise LocalizationAgentError(
            "missing localization keys: " + ", ".join(sorted(missing))
        )

    result: dict[str, Any] = {"@@locale": locale}
    for key in base_keys:
        value = target_arb[key]
        if not isinstance(value, str) or not value.strip():
            raise LocalizationAgentError(
                f"empty translation for key: {key}"
            )
        result[key] = value

        base_meta = dict(_metadata(base_arb, key))
        target_meta = dict(_metadata(target_arb, key))
        merged = {
            field: base_meta[field]
            for field in CANONICAL_METADATA_FIELDS
            if field in base_meta
        }
        for field, field_value in target_meta.items():
            if field not in CANONICAL_METADATA_FIELDS:
                merged[field] = field_value
        result[f"@{key}"] = merged
    return result


def audit_arb(
    base_arb: Mapping[str, Any],
    target_arb: Mapping[str, Any],
    *,
    locale_code: str | None = None,
) -> LocalizationAuditReport:
    errors: list[AuditIssue] = []
    warnings: list[AuditIssue] = []
    target_locale_raw = locale_code or target_arb.get("@@locale")
    if (
        not isinstance(target_locale_raw, str)
        or not target_locale_raw.strip()
    ):
        raise LocalizationAgentError(
            "target ARB requires @@locale or locale_code"
        )
    locale = _primary_language(target_locale_raw)
    direction = text_direction_for(locale)

    declared = target_arb.get("@@locale")
    if (
        isinstance(declared, str)
        and _primary_language(declared) != locale
    ):
        errors.append(
            AuditIssue(
                "locale.mismatch",
                "@@locale",
                f"declared locale {declared!r} does not match "
                f"requested {locale!r}",
            )
        )

    base_locale_raw = base_arb.get("@@locale", "")
    base_locale = (
        _primary_language(base_locale_raw)
        if isinstance(base_locale_raw, str) and base_locale_raw.strip()
        else ""
    )
    base_keys = _message_keys(base_arb)
    target_keys = set(_message_keys(target_arb))

    for key in base_keys:
        if key not in target_keys:
            errors.append(
                AuditIssue(
                    "arb.missing_key",
                    key,
                    "required ARB message is missing",
                )
            )
            continue
        base_text = base_arb[key]
        target_text = target_arb[key]
        if not isinstance(base_text, str) or not isinstance(target_text, str):
            errors.append(
                AuditIssue(
                    "arb.non_string_message",
                    key,
                    "ARB messages must be strings",
                )
            )
            continue
        if not target_text.strip():
            errors.append(
                AuditIssue(
                    "arb.empty_translation",
                    key,
                    "translation must not be empty",
                )
            )
            continue

        base_meta = _metadata(base_arb, key)
        target_meta = _metadata(target_arb, key)
        try:
            base_args = icu_argument_names(base_text)
            target_args = icu_argument_names(target_text)
        except LocalizationAgentError as exc:
            errors.append(AuditIssue("icu.invalid", key, str(exc)))
            continue
        if base_args != target_args:
            errors.append(
                AuditIssue(
                    "placeholder.mismatch",
                    key,
                    f"ICU argument set changed: {sorted(base_args)} -> "
                    f"{sorted(target_args)}",
                )
            )

        for field in ("placeholders", "layout"):
            if (
                field in target_meta
                and target_meta.get(field) != base_meta.get(field)
            ):
                errors.append(
                    AuditIssue(
                        "metadata.canonical_mismatch",
                        key,
                        f"target metadata cannot replace canonical {field}",
                    )
                )

        if locale != base_locale:
            strategy = target_meta.get("translationStrategy")
            if strategy == "literal":
                errors.append(
                    AuditIssue(
                        "translation.literal_forbidden",
                        key,
                        "literal translation strategy is forbidden; "
                        "use contextual equivalence",
                    )
                )
            elif strategy not in ALLOWED_TRANSLATION_STRATEGIES:
                errors.append(
                    AuditIssue(
                        "translation.strategy_required",
                        key,
                        "translationStrategy must document "
                        "contextual/idiomatic equivalence",
                    )
                )
            if target_meta.get("reviewStatus") != "reviewed":
                errors.append(
                    AuditIssue(
                        "translation.review_required",
                        key,
                        "localized message must be semantically reviewed "
                        "before production use",
                    )
                )

        budget = _layout_budget(base_meta, target_meta)
        width = estimate_width_units(target_text)
        if width > budget:
            errors.append(
                AuditIssue(
                    "layout.overflow_risk",
                    key,
                    f"estimated width {width:.2f}em exceeds "
                    f"{budget:.2f}em budget",
                )
            )
        base_width = max(estimate_width_units(base_text), 1.0)
        expansion = width / base_width
        if base_width >= 7.0 and expansion > 2.35:
            warnings.append(
                AuditIssue(
                    "layout.high_expansion",
                    key,
                    f"localized text expands to "
                    f"{expansion:.2f}x source width",
                    severity="warning",
                )
            )

    extra = sorted(target_keys.difference(base_keys))
    for key in extra:
        warnings.append(
            AuditIssue(
                "arb.extra_key",
                key,
                "target contains a key not present in the canonical base ARB",
                severity="warning",
            )
        )

    return LocalizationAuditReport(
        locale_code=locale,
        direction=direction,
        errors=tuple(errors),
        warnings=tuple(warnings),
    )


def _load_json(path: Path) -> dict[str, Any]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise LocalizationAgentError(
            f"ARB document must be a JSON object: {path}"
        )
    return value


def _write_json(path: Path, payload: Mapping[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Strict contextual ARB localization agent"
    )
    sub = parser.add_subparsers(dest="command", required=True)

    template = sub.add_parser(
        "template",
        help="create a reviewer ARB template",
    )
    template.add_argument("--base", type=Path, required=True)
    template.add_argument("--locale", required=True)
    template.add_argument("--output", type=Path, required=True)

    audit = sub.add_parser("audit", help="audit one localized ARB")
    audit.add_argument("--base", type=Path, required=True)
    audit.add_argument("--target", type=Path, required=True)
    audit.add_argument("--locale")

    sync = sub.add_parser(
        "sync",
        help="synchronize an already translated ARB",
    )
    sync.add_argument("--base", type=Path, required=True)
    sync.add_argument("--target", type=Path, required=True)
    sync.add_argument("--locale", required=True)
    sync.add_argument("--output", type=Path, required=True)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _parser().parse_args(argv)
    if args.command == "template":
        _write_json(
            args.output,
            build_translation_template(
                _load_json(args.base),
                locale_code=args.locale,
            ),
        )
        return 0
    if args.command == "audit":
        report = audit_arb(
            _load_json(args.base),
            _load_json(args.target),
            locale_code=args.locale,
        )
        print(
            json.dumps(
                report.to_json(),
                ensure_ascii=False,
                sort_keys=True,
            )
        )
        return 0 if report.is_valid else 1
    if args.command == "sync":
        base = _load_json(args.base)
        target = _load_json(args.target)
        result = synchronize_arb(
            base,
            target,
            locale_code=args.locale,
        )
        report = audit_arb(base, result, locale_code=args.locale)
        if not report.is_valid:
            raise LocalizationAgentError(
                "refusing to write invalid synchronized ARB: "
                + "; ".join(issue.message for issue in report.errors)
            )
        _write_json(args.output, result)
        return 0
    raise LocalizationAgentError(f"unsupported command: {args.command}")


if __name__ == "__main__":
    raise SystemExit(main())
