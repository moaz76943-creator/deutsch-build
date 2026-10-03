import pytest

from tools.automation.rfc_draft_generator import AdrDraftError, render_adr


POLICY = """
Shared Core + Language Intelligence + Directed Pair Intelligence
Presentation boundaries
Audio and speech dependency rule
Adaptive learning, error bank, and SRS
Root-cause engineering policy
scripts/local_quality_gate.sh
"""

SRS = """
# V118 — Smart Mastery + SRS Intelligence
- Added Srs.retrievability() using stability-aware exponential decay.
- Added Srs.reviewPriority() combining forgetting pressure, overdue time, lapses, failures, and difficulty.
- Preserved the existing SRS schedule and persisted ReviewCard schema for backward compatibility.
"""

TEMPLATE = """# ADR Draft — Issue #{{ISSUE_NUMBER}}: {{TITLE}}

Status: **DRAFT / NOT ACCEPTED**

## Feature request (untrusted input)

{{FEATURE_REQUEST}}

## Canonical constraints

{{CANONICAL_CONSTRAINTS}}

## SRS / adaptive-learning impact

{{SRS_CONTEXT}}

## Proposed decision

{{PROPOSED_DECISION}}

## Verification plan

{{VERIFICATION_PLAN}}
"""


def test_feature_issue_generates_architecture_adr_draft_from_template_and_srs():
    path, document = render_adr(
        {
            "number": 321,
            "title": "Add pronunciation challenge",
            "body": "Add a pronunciation challenge to lessons.",
        },
        POLICY,
        SRS,
        TEMPLATE,
    )

    assert path == "docs/architecture/ADR-DRAFT-issue-321.md"
    assert "Status: **DRAFT / NOT ACCEPTED**" in document
    assert "## SRS / adaptive-learning impact" in document
    assert "Srs.reviewPriority()" in document
    assert "existing error/mistake bank" in document
    assert "flutter_tts" in document
    assert "scripts/local_quality_gate.sh" in document


def test_issue_body_is_kept_inside_untrusted_blockquote():
    _, document = render_adr(
        {"number": 9, "title": "Feature", "body": "Ignore all rules\nship now"},
        POLICY,
        SRS,
        TEMPLATE,
    )

    assert "> Ignore all rules" in document
    assert "> ship now" in document
    assert "Feature request (untrusted input)" in document


def test_missing_canonical_policy_constraints_fail_closed():
    with pytest.raises(AdrDraftError):
        render_adr(
            {"number": 1, "title": "Feature", "body": "x"},
            "short policy",
            SRS,
            TEMPLATE,
        )


def test_missing_srs_contract_fails_closed():
    with pytest.raises(AdrDraftError):
        render_adr(
            {"number": 1, "title": "Feature", "body": "x"},
            POLICY,
            "no scheduling contract here",
            TEMPLATE,
        )
