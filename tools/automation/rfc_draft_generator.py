#!/usr/bin/env python3
"""Generate an ADR draft from a feature Issue using canonical policy and SRS docs."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Mapping, Sequence

_REQUIRED_TEMPLATE_TOKENS = (
    "{{ISSUE_NUMBER}}",
    "{{TITLE}}",
    "{{FEATURE_REQUEST}}",
    "{{CANONICAL_CONSTRAINTS}}",
    "{{SRS_CONTEXT}}",
    "{{PROPOSED_DECISION}}",
    "{{VERIFICATION_PLAN}}",
)


class AdrDraftError(ValueError):
    """Raised when a feature Issue cannot be converted into a safe ADR draft."""


RfcDraftError = AdrDraftError


def _text(value: Any) -> str:
    return value if isinstance(value, str) else ""


def _blockquote(value: str) -> str:
    lines = value.strip().splitlines() or [""]
    return "\n".join(f"> {line}" for line in lines)


def _require_policy(policy: str) -> None:
    required = (
        "Shared Core + Language Intelligence + Directed Pair Intelligence",
        "Presentation boundaries",
        "Audio and speech dependency rule",
        "Adaptive learning, error bank, and SRS",
        "Root-cause engineering policy",
        "scripts/local_quality_gate.sh",
    )
    missing = [needle for needle in required if needle not in policy]
    if missing:
        raise AdrDraftError(
            f"canonical policy is missing required constraints: {', '.join(missing)}"
        )


def _require_srs(srs_document: str) -> None:
    required = ("Srs.retrievability()", "Srs.reviewPriority()", "ReviewCard")
    missing = [needle for needle in required if needle not in srs_document]
    if missing:
        raise AdrDraftError(
            f"SRS document is missing required contract markers: {', '.join(missing)}"
        )


def _require_template(template: str) -> None:
    missing = [token for token in _REQUIRED_TEMPLATE_TOKENS if token not in template]
    if missing:
        raise AdrDraftError(
            f"ADR template is missing required placeholders: {', '.join(missing)}"
        )


def _srs_context(srs_document: str) -> str:
    bullets = [
        line.strip()
        for line in srs_document.splitlines()
        if line.strip().startswith("- ")
    ]
    if not bullets:
        raise AdrDraftError("SRS document does not contain actionable constraints")
    return "\n".join(bullets)


def render_adr(
    issue: Mapping[str, Any],
    policy: str,
    srs_document: str,
    template: str,
) -> tuple[str, str]:
    _require_policy(policy)
    _require_srs(srs_document)
    _require_template(template)

    number = issue.get("number")
    if not isinstance(number, int) or number <= 0:
        raise AdrDraftError("feature issue requires a positive numeric issue number")
    title = _text(issue.get("title")).strip()
    if not title:
        raise AdrDraftError("feature issue requires a title")
    body = _text(issue.get("body")).strip() or "(No issue body supplied.)"

    canonical_constraints = """- Preserve `Shared Core + Language Intelligence + Directed Pair Intelligence`.
- Keep `USER_LANGUAGE`, `SOURCE_LANGUAGE`, and `TARGET_LANGUAGE` distinct.
- Keep authored files within the repository's 1000-line boundary.
- Presentation must not import `flutter_tts`, `speech_to_text`, or equivalent device-facing packages directly.
- Analyzer/lint ignore directives are forbidden; fix warnings at their root cause.
- Reuse canonical services/models rather than creating parallel engines, pages, or compatibility patches.
- Preserve `scripts/local_quality_gate.sh` as the canonical acceptance gate."""

    srs_context = f"""{_srs_context(srs_document)}

Any answer-recording feature must continue through the canonical adaptive-learning persistence path.
Mistakes feed the existing error/mistake bank; successful and failed retrievals update canonical
SRS state; persisted mastery/error/XP ownership must not be duplicated."""

    proposed_decision = """**TBD by architecture review.** Identify the existing canonical owner that should
absorb the feature before introducing a new service, controller, model, route, or persistence boundary."""

    verification_plan = """- Add focused regression tests before behavioral implementation.
- Run affected regression coverage and `scripts/local_quality_gate.sh`.
- Require exact-head CI evidence before integration claims.
- Record any accepted decision or supersession in `docs/architecture/DECISION_LOG.md`."""

    replacements = {
        "{{ISSUE_NUMBER}}": str(number),
        "{{TITLE}}": title,
        "{{FEATURE_REQUEST}}": _blockquote(body),
        "{{CANONICAL_CONSTRAINTS}}": canonical_constraints,
        "{{SRS_CONTEXT}}": srs_context,
        "{{PROPOSED_DECISION}}": proposed_decision,
        "{{VERIFICATION_PLAN}}": verification_plan,
    }

    document = template
    for token, value in replacements.items():
        document = document.replace(token, value)

    path = f"docs/architecture/ADR-DRAFT-issue-{number}.md"
    return path, document.rstrip() + "\n"


def render_rfc(
    issue: Mapping[str, Any],
    policy: str,
    srs_document: str,
    template: str,
) -> tuple[str, str]:
    """Compatibility alias: the canonical generated document is now an ADR draft."""
    return render_adr(issue, policy, srs_document, template)


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate a deterministic feature ADR draft")
    parser.add_argument("--event", required=True, type=Path)
    parser.add_argument("--policy", required=True, type=Path)
    parser.add_argument("--srs-doc", required=True, type=Path)
    parser.add_argument("--template", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        event = json.loads(args.event.read_text(encoding="utf-8"))
        if not isinstance(event, dict):
            raise AdrDraftError("event payload must be an object")
        issue = event.get("issue")
        if not isinstance(issue, Mapping):
            raise AdrDraftError("event payload does not contain an issue object")

        policy = args.policy.read_text(encoding="utf-8")
        srs_document = args.srs_doc.read_text(encoding="utf-8")
        template = args.template.read_text(encoding="utf-8")
        expected_path, document = render_adr(
            issue,
            policy,
            srs_document,
            template,
        )

        if not args.output.as_posix().endswith(expected_path):
            raise AdrDraftError(
                f"output path must end with canonical ADR draft path {expected_path!r}"
            )

        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(document, encoding="utf-8")
    except (OSError, json.JSONDecodeError, AdrDraftError) as exc:
        print(f"ADR draft generation failed: {exc}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
