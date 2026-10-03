#!/usr/bin/env python3
"""Generate an RFC/ADR draft from a feature Issue without mutating source control."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Mapping, Sequence


class RfcDraftError(ValueError):
    """Raised when a feature Issue cannot be converted into a safe RFC draft."""


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
        raise RfcDraftError(
            f"canonical policy is missing required constraints: {', '.join(missing)}"
        )


def render_rfc(issue: Mapping[str, Any], policy: str) -> tuple[str, str]:
    _require_policy(policy)

    number = issue.get("number")
    if not isinstance(number, int) or number <= 0:
        raise RfcDraftError("feature issue requires a positive numeric issue number")
    title = _text(issue.get("title")).strip()
    if not title:
        raise RfcDraftError("feature issue requires a title")
    body = _text(issue.get("body")).strip() or "(No issue body supplied.)"

    path = f"docs/architecture/RFC-DRAFT-issue-{number}.md"
    document = f"""# RFC / ADR Draft — Issue #{number}: {title}

Status: **DRAFT / NOT ACCEPTED**
Source: GitHub Issue #{number}
Proposed repository path: `{path}`

> Generated from untrusted feature-request text plus the canonical architecture policy.
> This is review material only; it is not an accepted architectural decision.

## Feature request (untrusted input)

{_blockquote(body)}

## Canonical constraints

- Preserve `Shared Core + Language Intelligence + Directed Pair Intelligence`.
- Keep `USER_LANGUAGE`, `SOURCE_LANGUAGE`, and `TARGET_LANGUAGE` distinct.
- Keep authored files within the repository's 1000-line boundary.
- Presentation must not import `flutter_tts`, `speech_to_text`, or equivalent device-facing packages directly.
- Reuse canonical services/models rather than creating parallel engines, pages, or compatibility patches.
- Preserve the root-cause repair sequence and `scripts/local_quality_gate.sh` as the canonical gate.

## SRS / adaptive-learning impact

If the feature records learner answers, mistakes must feed the existing error/mistake bank and
successful or failed retrievals must update the canonical SRS state. Persistent mastery, error
history, and XP ownership must not be duplicated. If no learner answer is recorded, state that
explicitly during architecture review.

## Proposed decision

**TBD by architecture review.** Identify the existing canonical owner that should absorb the feature
before introducing a new service, controller, model, route, or persistence boundary.

## Alternatives to evaluate

1. Extend the existing canonical owner with the smallest coherent contract change.
2. Introduce a new boundary only when no existing owner can express the responsibility cleanly.
3. Reject approaches that duplicate SRS, the error bank, speech hardware ownership, or public page identity.

## Security, privacy, and cost

- Treat Issue and PR text as untrusted data.
- Never expose secrets or execute PR-head code from privileged/secret-backed automation.
- Never auto-approve source changes.
- Preserve zero-additional-billing unless explicitly superseded by the owner with current evidence.

## Verification plan

- Add focused regression tests before behavioral implementation.
- Run affected regression coverage and `scripts/local_quality_gate.sh`.
- Require exact-head CI evidence before integration claims.
- Record any accepted decision or supersession in `docs/architecture/DECISION_LOG.md`.

## Review checklist

- [ ] Canonical owner identified.
- [ ] SRS/error-bank impact classified.
- [ ] Presentation/audio boundaries preserved.
- [ ] No duplicate engine/page/model introduced.
- [ ] Security/privacy/cost impact reviewed.
- [ ] Regression and exact-head verification plan defined.
"""
    return path, document


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Generate a deterministic feature RFC draft")
    parser.add_argument("--event", required=True, type=Path)
    parser.add_argument("--policy", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = _build_parser().parse_args(argv)
    try:
        event = json.loads(args.event.read_text(encoding="utf-8"))
        if not isinstance(event, dict):
            raise RfcDraftError("event payload must be an object")
        issue = event.get("issue")
        if not isinstance(issue, Mapping):
            raise RfcDraftError("event payload does not contain an issue object")
        policy = args.policy.read_text(encoding="utf-8")
        expected_path, document = render_rfc(issue, policy)
        normalized = args.output.as_posix()
        if not normalized.endswith(expected_path):
            raise RfcDraftError(
                f"output path must end with canonical RFC draft path {expected_path!r}"
            )
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(document, encoding="utf-8")
    except (OSError, json.JSONDecodeError, RfcDraftError) as exc:
        print(f"RFC draft generation failed: {exc}")
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
