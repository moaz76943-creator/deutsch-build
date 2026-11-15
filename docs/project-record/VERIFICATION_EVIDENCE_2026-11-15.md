# Verification evidence & evidence debt — deutsch-build `main` @ 7b44989b1

Recorded: 2026-11-15 (UTC) · Task: T98 (TASKS_100.md §J "Document actual
verification evidence and clearly mark missing checks as evidence debt").
Scope: post-merge verification of `main` after PR #1206 (final consolidation
report, T99). Every command below was executed against the working tree at
`7b44989b1899dfb5595fe8284df92eaf8ab9094e` (clean, `git status` empty).
No SKIPPED or ABSENT check is reported as PASS anywhere in this document.

## 1. What was verified (executed, not asserted)

| # | Check | Command / source | Result |
|---|---|---|---|
| 1 | Tree state | `git status` on `main` | clean; branch up to date with `origin/main` @ `7b44989b1` |
| 2 | CI, unified gate, push of HEAD | `gh run list --branch main --workflow="Polyglot Unified CI & Security Gate" --limit 3` | `completed success` — runs 43738999215 (HEAD), 43737997751, 43734265033 |
| 3 | Registry integrity | `python3 tools/polyglot/registry_sync.py --check` | `OK: 100 registered languages, Hebrew excluded, checksum ef04da5d49a91d69…` · exit 0 |
| 4 | Scoped security audit (tree) | `python3 tools/security/scoped_security_audit.py` | `PASS` — 0 leaks, 0 private keys, 0 tracking SDKs (1513 files scanned) · exit 0 |
| 5 | Fail-closed contract suites | `PYTHONPATH=. /usr/bin/python3 -m pytest tests/test_build_provenance_t94.py tests/test_release_traceability_t96.py tests/test_lkg_rollback_t97.py tests/test_storage_separation_t70.py tests/test_pack_admission_bounds_t67.py tests/test_last_known_good_t68.py tests/test_migration_t69.py tests/test_content_inventory_t71.py -q` | **89 passed** |
| 6 | Quality gate baseline | `PYTHONPATH=. /usr/bin/python3 -m pytest tests/quality_gate -q` | **49 failed / 119 passed / 10 skipped** — identical to the recorded pre-existing baseline (PRs #1199/#1200/#1202/#1204/#1206 all recorded 49F/119P/10S) |
| 7 | Quality-gate failure shape | `pytest tests/quality_gate -q --tb=no` | failures by file: test_security_audit_decision.py 12 · test_task6d_gamification_single_writer 9 · test_task6c_sqlite_learner_state 6 · test_task6b_review_transaction 5 · test_task7_localization_boundary 4 · test_current_topology_security_gate 3 · test_cefr_search_ui_tokens 3 · test_zero_billing_actions_policy 2 · test_task8_search_authority 2 · test_workflow_supply_chain 1 · test_task11_release_hardening 1 · test_android_permission_contract 1 |
| 8 | GitHub `main` push protection | repo `security_and_analysis` (set this session) | secret scanning = enabled · push protection = enabled |

Note on the 49 quality-gate failures (point 7): they are pre-existing on
`main` and are outside any session-verified scope so far; 12 of them
(`test_security_audit_decision.py`) are the fail-closed "Enforce security
decision" gate cases that PR #1187 fixes (T21) and remain red until #1187
merges.
They are recorded here as evidence debt, not as passes, and were not touched.

Note on the runner: the Hermes 3.14 venv has no `pytest`; all pytest commands
used `/usr/bin/python3` (3.12.3, pytest 9.2.0) with `PYTHONPATH=.`.

## 2. Evidence debt (explicitly NOT verified — must not be reported as success)

1. **Flutter/Dart behaviour.** No Flutter/Dart toolchain is available on the
   Termux aarch64 host. All Dart-side assertions in the repo are static
   source contracts executed under pytest. The executable Dart gate is CI
   only; CI signal on `main` for HEAD (run 43738999215, 19 s, docs-only diff
   under T93 change detection) is a **fast-path** run, not the full Flutter
   suite. The last full Flutter gate on the same tree as `565457eff`/#1205
   predates the T99 docs merge; docs-only changes do not alter Dart sources.
2. **PR #1187 (security hardening, T21–30/61–65/91–95).** Offline-First
   Security Audit run 43681022541 = FAIL. Findings are pre-existing `main`
   debt, not introduced by the branch: (a) SECRETS — 305 Gitleaks findings
   over fetched history, already classified: 1 real-format classic GitHub
   PAT in `get-app` line 5 @ `b19dfd490` (2026-10-11, ancestor of main, all
   branches, 21 tags; revocation is owner-only — issue #1198), 2 test-only
   ED25519 fixture pairs @ `a040e5b08`, 302 false positives; (b) POLICY —
   `http`, `cached_network_image`, `dart:io HttpClient`, runtime HTTP(S)
   URL capability present in Dart sources (capability-removal backlog).
   #1187 is NOT mergeable-green and must not be merged until the owner
   revokes the PAT and decides on history purge + the network-capability
   policy. Merging it now would paint `main`'s audit red permanently.
3. **History secrets exposure.** Working tree is clean and push protection
   is on, but the PAT remains in public Git history; no history rewrite was
   performed (incident record docs/project-record/SECRETS_INCIDENT_2026-11-15.md).
   Until owner revocation + purge decision, publication of the repository
   must remain blocked.
4. **Quality gate.** 49 pre-existing failures / 10 skips listed in §1.7 —
   content/CEFR/task6b–8 contracts outside verified scope on this host.
5. **Offline content completeness.** 73 of 100 languages measure ZERO
   provenance-backed bundled content (T71 inventory; `productionReady` = 2:
   `de`, `ar`; `sourceApproved` = 0; `contentComplete` = not-derivable).
   No language pack is release-ready from bundled assets.
6. **iOS / macOS / desktop / web builds.** Never built or verified in any
   session on this host; nothing claimed.
7. **Skipped CI checks.** AI-collaboration-bridge, path-filtered guards, and
   deployment workflows report SKIPPED on docs-only commits; SKIPPED ≠ PASS.
   The Offline-First Security Audit issue-template workflow appears only on
   PRs until #1187 lands.
8. **Signed release.** No APK/AAB has ever been built on this host; the T94/
   T96/T97 provenance/traceability/LKG chain is verified by 54 fail-closed
   contracts locally and is wired into `build_apk.yml` / `build_aab.yml`,
   which have not yet executed end-to-end for a real signed release.
9. **Branch protection on `main`.** Not enabled (issue #1198 action 5, owner).
   Direct pushes to `main` are not blocked by the server.
10. **Excluded languages.** `he`, `iw`, `syc`, `ber`, `zgh` and citizenship
    exams remain excluded; the `syc` heritage-framed German bitext corpus
    (L067) is retained by design and flagged for owner awareness in the
    2026-11-15 session log. No excluded-language product content was added.

## 3. Blocked items (with the real blocker)

- **T100 (public promotion)** — blocked on: owner PAT revocation (issue
  #1198), owner history-purge decision, owner network-capability decision,
  branch protection enablement, and #1187 landing green.
- **PR #1187 merge** — see §2.2.
- **#1182-class consolidation anchor work** — closed as superseded; nothing
  actionable.
- **73 zero-content languages** — factory-automation throughput problem
  (harvest pipeline live at ~698/518,200 concept cells); cannot be finished
  in-session honestly; no words invented.

## 4. Exact SHAs pinned by this record

- `main` @ `7b44989b1899dfb5595fe8284df92eaf8ab9094e` (T99 report, PR #1206)
- Parent `f654a14fd` (PR #1205), `565457eff` (PR #1172)
- Registry checksum prefix `ef04da5d49a91d69…` (100 languages, `he` excluded)
- CI: run 43738999215 (`Polyglot Unified CI & Security Gate`, success, HEAD)
- Failing audit run: 43681022541 (`Offline-First Security Audit`, 305
  findings, classified in SECRETS_INCIDENT_2026-11-15.md)

This document adds no code and changes no behaviour; it records what was and
was not verified, so later sessions cannot mistake debt for debt-free state.
