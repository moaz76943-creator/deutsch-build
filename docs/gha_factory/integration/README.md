# GHA-07 Private Flutter SQLite v2 integration — independent checkpoint

**TASK_ID:** GHA-07-PRIVATE-FLUTTER-PACK-INTEGRATION  
**OWNER:** Private integration worker  
**BASE:** moaz76943-creator/deutsch-build / staging/v2-full-platform  
**MUTABLE SCOPE:** test/gha_factory/integration/** and docs/gha_factory/integration/** only  
**STATE:** DELTA (independent tests) + BLOCKED_DEPENDENCY (real pack/runtime integration)  
**Private base snapshot 2026-10-13:** staging HEAD 7a47673045ae9308fef60fece7070a07ebe18394. **Public latest observed:** main 8c872804a132ae514ac7efe0c01ded3981293564 (recheck on resume).

## Live evidence and ownership

1. Public store manifest schemaVersion is 2.0.0 and packs is an **empty array**. Its languages list comprises registered legacy/metadata entries, not verified production SQLite v2 packs. Public version.json has latest_verified_version null and release_status BLOCKED_DEPENDENCY. There is no approved GHA-06 production-pack SHA. Do not use legacy files to claim production availability.
2. [Private Route 14 PR #55](https://github.com/moaz76943-creator/deutsch-build/pull/55) is open/draft and owns lib/services/pack_downloader_service.dart and test/jules/WS14/**. Its improved downloader is **not merged into the target base**. It adds approved-host and redirect checks, packs-only source gates, archive/content digest checks, bounded gzip/SQLite validation, and backup rollback. Its author did not run Dart/Flutter tests, so those behaviors are unverified.
3. [Private Route 04 PR #54](https://github.com/moaz76943-creator/deutsch-build/pull/54) is open/draft and owns canonical language identity/readiness files. Do not replace or modify these files.
4. Route 15 DatabaseService.verifyUniversalSchema currently requires SQLite PRAGMA user_version=2; mapping_version=2.0.0; contract_version=1.0.0; requested language_code; required tables, lexemes view, lexicon_fts and a nonempty same-language lexicon. Its searchDictionary filters by requested language and clamps its limit. Runtime availability and source provenance are separate from schema acceptance.
5. **Important fixture contract defect found and corrected:** metadata/pack.json in the initial synthetic envelope omitted contractVersion=1.0.0, required by Route 14 PR #55. New test prevents recurrence; the fix does not alter or validate the private installer.
5a. **Oracle/runtime parity caveat:** the Python-only oracle now rejects duplicate JSON keys and requires a bounded-search index. The inspected Dart Route 14/15 source does not establish equivalent rejection of duplicate JSON keys or that named index. These are **open parity checks**, not passing Flutter/security claims.
5b. SHA-256 evidence does **not** demonstrate cryptographic signature verification. The inspected base/PR #55 downloader did not establish a trusted public-key signature/key-rotation policy. **BLOCKED_SIGNATURE_CONTRACT:** do not report signature acceptance as verified.
6. No claimant to either initial test/docs scope was found among inspected open PRs. No Route 04/14/15/16/17/18/19 or Jules source paths were modified.

## Delivered independent tests

| File | Coverage | Evidence limitation |
| --- | --- | --- |
| test/gha_factory/integration/test_sqlite_v2_fixture_contract.py | Temporary SQLite v2 schema; five language IDs de/ar/en/es/fr; no cross-language SQL fallback; Arabic/Latin/CJK Unicode; foreign keys; user_version; empty/corrupt DB; deterministic gzip envelope; SHA-256 tampering; mandatory files, duplicate JSON metadata, identity/version and expanded-size bounds; corrupted/truncated gzip; content SHA-256; missing FTS, view and index; fixture sentinel content/progress immutability | Python test oracle only; synthetic tokens, no real source/rights and no actual Dart rollback |
| test/gha_factory/integration/flutter_pack_contract_test.dart | Direct Route 15 verifyUniversalSchema with isolated temporary SQLite v2 databases; incorrect version/language, missing FTS, missing lexemes and incompatible mapping version rejected; CJK Unicode round-trip; language-tagged translation preserved; RTL/LTR script metadata; existing downloader rejects HTTP; gzip expansion cap | Flutter SDK required; **NOT RUN** in present environment |

All fixture lexical text is deliberately artificial. This test suite does **not** fabricate or distribute an approved production pack. It never reads/writes a real encrypted learner vault, private user progress or public repository files.

## Verification log

- Local Python command: python3 -m unittest discover -s test/gha_factory/integration -p 'test_*.py' -v
- Result: **PASS: 19 tests**, executed on the locally authored identical fixture suite. This validates the Python-only oracle, not installation. New negative tests first exposed missing strict JSON/version/hash checks in the test oracle and a missing Route 14 fixture metadata field; they were repaired locally before the PASS result.
- Flutter/Dart SDK: unavailable in the present container, with DNS to the official Dart archive unavailable. Focused Flutter tests (12 declared) and Dart compilation error gate **NOT RUN**.
- Android build, emulator/device cold startup, navigation, real audio fallback, production SQLite performance/memory bounds, real cancellation/rollback, SRS history preservation: **NOT RUN**.
- No private GitHub Actions runners were started; no paid CI resources were used.
- All commits use [skip ci]; no workflows, release manifests, Android permissions or app source files changed.

## Known integration gaps to resolve with the respective owners

- Route 14's proposed installer currently lives only in draft PR #55; the staging branch still contains legacy manifest handling. No source paths are claimed by GHA-07.
- Dart JSON parsing in reviewed Route 14 uses `jsonDecode` and has no explicit duplicate-key rejection; unlike the stricter fixture oracle this behavior has not been proven fail-closed.
- An externally trusted manifest-signature verification contract remains undefined/unverified. A raw digest in an unsigned manifest does not authenticate its publisher.
- Real five-language content, update rollback, mounted SQLite reads, progress-vault integrity and Android startup have no executed evidence.

## Required acceptance gates before merging

1. GHA-01/GHA-06 approve immutable licensed source snapshots and real non-empty production SQLite v2 candidate(s); pin the actual pack and manifest SHA.
2. Reconcile Route 04 and Route 14/15 contracts without colliding with Jules owners. Execute Route 14's installer fixture tests and this scope's Flutter tests using the final code.
3. Verify archive/content SHA-256, trusted HTTPS origins/redirects, source language, package version, three envelope members, record counts, PRAGMA integrity_check, foreign_key_check, mandatory tables/indexes/FTS5; resolve the signature contract separately.
4. Test actual interrupted/retried installation, update rollback with prior valid pack retained, offline cold start, no German fallback, optional-media absence, five-language isolation and CJK/RTL behavior.
5. Verify real progress-vault before/after hashes or isolated safe snapshot evidence, persistent learner IDs, SRS repetition counts and due dates. No real personal data/logs may leave private trust boundary.
6. Run focused Flutter tests and the approved compilation-only command: dart analyze lib/ 2>&1 | grep "error •" (the error output must be empty). Avoid broad static lint/fix loops. Use existing build scripts for a real Android startup when a free runner is available. Do not imply Android PASS without execution.
7. Obtain independent review, record reproducible test/build results and only then merge the scoped PR. Current status must remain **BLOCKED_DEPENDENCY**; the scoped PR is a draft.

## Handoff

**STATE:** DELTA + BLOCKED_DEPENDENCY / BLOCKED_SIGNATURE_CONTRACT  
**NEXT_ACTION:** Recheck live public GHA-06 pack admission and Route 14/04 PRs; execute this suite with a real Flutter/Dart SDK in an approved free environment. Open PR #57 remains a draft until the full merge gate succeeds; no private CI should be started solely to make the status appear green. Resume the focused runtime integration when those durable prerequisites exist. No additional source-file ownership claimed.
