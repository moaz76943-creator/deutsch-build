# Release Evidence — Room 3 QA

## Base
- Branch: agent/qa-verification
- Base SHA: ab207624e (origin/main)
- Polyglot Unified CI on a8dfd7788: success (narrow slice only)

## Verified
- Registry: 100 languages, Hebrew excluded (validator exit 0).
- Manifest: 100 packs, SHA-256 100/100, size 100/100, 0 missing.
- Pack payloads: 204 gzip+JSON parse OK.
- Orphan packs: 100 with false terms_count=150 (FAIL — QAD-004).
- Full Python suite: 1175 pass / 209 fail / 12 skip (exit 1).
- Security audit workflow: FAIL-OPEN (QAD-005).

## Blockers for release
1. QAD-005 (security audit fail-open) — P0.
2. QAD-004 (false terms_count on 100 orphan packs) — P1.
3. QAD-002 (CI not exercising full suite) — P0-equivalent process gap.
4. QAD-001 (collection errors) — P1.
5. QAD-003 (fake security tests) — P1.
6. Content depth: 0 vocabulary items in manifest packs (W; release_status already BLOCKED_DEPENDENCY).

## Not verified (environment limits)
- Flutter/Dart tests (no SDK), Android emulator (no emulator), audio/search/images/memory, runtime permission flows.

## Recommendation
Do NOT claim release-ready. Resolve QAD-005 and QAD-001 before any merge; replace fake tests (QAD-003) before release sign-off.
EOF
echo done