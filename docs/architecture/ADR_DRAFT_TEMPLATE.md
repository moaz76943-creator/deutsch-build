# ADR Draft — Issue #{{ISSUE_NUMBER}}: {{TITLE}}

Status: **DRAFT / NOT ACCEPTED**

> This document is generated from trusted repository policy/SRS sources and an
> untrusted feature Issue. It is review material only. It becomes architectural
> policy only after explicit review and adoption in the canonical decision ledger.

## Feature request (untrusted input)

{{FEATURE_REQUEST}}

## Canonical constraints

{{CANONICAL_CONSTRAINTS}}

## SRS / adaptive-learning impact

{{SRS_CONTEXT}}

## Proposed decision

{{PROPOSED_DECISION}}

## Alternatives to evaluate

1. Extend the existing canonical owner with the smallest coherent contract change.
2. Introduce a new boundary only when no existing owner can express the responsibility cleanly.
3. Reject approaches that duplicate SRS, error-bank, speech-hardware, or public page ownership.

## Security, privacy, and cost

- Treat Issue and PR text as untrusted data.
- Never expose secrets or execute PR-head code from privileged/secret-backed automation.
- Never auto-approve source changes.
- Preserve zero-additional-billing unless explicitly superseded by the owner with current evidence.

## Verification plan

{{VERIFICATION_PLAN}}

## Review checklist

- [ ] Canonical owner identified.
- [ ] SRS/error-bank impact classified.
- [ ] Presentation/audio boundaries preserved.
- [ ] No lint suppression introduced or retained in changed files.
- [ ] No duplicate engine/page/model introduced.
- [ ] Security/privacy/cost impact reviewed.
- [ ] Regression and exact-head verification plan defined.
