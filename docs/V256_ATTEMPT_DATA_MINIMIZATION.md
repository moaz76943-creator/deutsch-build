# V256 — Attempt Data Minimization

## Goal

Strengthen the local learner-state boundary so persisted practice attempts are normalized both when loaded from untrusted local storage and immediately before persistence.

## Scope

- Bound attempt identifiers and item/skill fields to 160 characters.
- Bound stored user answer text to 1000 characters.
- Bound recorded duration to 0–3600 seconds.
- Clamp future timestamps to the local current time plus the existing one-day trust window.
- Apply the same normalization on load and before persistence.
- Preserve the existing 4 MB aggregate learner-state limit and 2000-attempt retention limit.

## Safety

No content corpus, content IDs, learner-state fields, or user-facing learning rules were deleted or migrated. Valid values within existing limits remain unchanged.

## Verification

- Focused V256 test: 2 passed.
- Full regression: 246 passed.
- Privacy audit: PASS.
- Security audit: PASS.
- Quality audit: PASS (14,813 content entries).
- Accessibility audit: PASS (0 warnings).
- Architecture audit: PASS.
- Weakness gate: PASS.
- Python compileall: PASS.
- Bash syntax checks: PASS.

Flutter/Android/APK/AAB execution remains unverified because the required Flutter/Android toolchain is unavailable in this environment.
