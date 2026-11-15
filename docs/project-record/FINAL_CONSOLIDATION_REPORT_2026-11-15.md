# FINAL CONSOLIDATION REPORT — deutsch-build (2026-11-15)

Task: TASKS_100.md J §99 — "Produce a final consolidation report listing merged paths,
preserved history, PR dispositions, unresolved blockers, and exact SHAs."

Status vocabulary: **MERGED** · **OPEN** · **BLOCKED** · **EVIDENCE DEBT**.
Every SHA below was verified against the live repository on 2026-11-15 (UTC); nothing in
this report is inferred from chat history alone.

## 1. Scope and method

- Private app repository: `moaz76943-creator/deutsch-build` — integration target `main`.
- Public content factory: `moaz76943-creator/-offline-packs-store` — retained on `main`;
  retirement/unification not authorized while blockers in §6 remain open.
- Method: `git log`/`git merge-base`/`git rev-parse` on `deutsch-build@main`;
  `gh pr list` (state=open/merged) against both repositories;
  `python3 tools/polyglot/registry_sync.py --check` (exit 0);
  cross-checked against `docs/project-record/POLYGLOT_100_PROGRESS.md` (increments 1–21)
  and `state/PR_TRIAGE_2026-11-15.md`.

## 2. Exact SHAs at record time

- `deutsch-build@main` HEAD: `f654a14fd78c159880f1cdb05c1cbb48237e6488`
  (subject: `fix(search): fail-closed contract pinning single Trie bounds declarations (#1205)`).
  `origin/main` matches; working tree clean.
- `-offline-packs-store@main` HEAD: `ca821e59ac39a75db37a094e0cb6af112566006f`.
- Content-factory lineage anchor merged into `main`: `c978329df`
  (`chore(consolidation): anchor content-factory import lineage to main`); lineage source
  `ab207624e` (squashed `content-factory/` import, PR #1181) and `070b88776` are ancestors of
  `main` (verified with `git merge-base --is-ancestor`).
- Tags: 21 tags present on the local clone (incl. `latest` and dated `recovery/*` tags);
  no tag was deleted or recreated by this work.
- Canonical registry: `registry_sync.py --check` → exit 0, 100 registered languages,
  Hebrew (`he`/`iw`) excluded, checksum `ef04da5d49a91d69…`.

## 3. Merged paths (all on `main` unless noted)

| Area | What landed | PR | Merge commit (SHA) |
|---|---|---|---|
| Registry | Canonical 100-language registry, he/iw permanently excluded (J §31–33) | #1178 | `56d3d097f` |
| CI | Dead guarded auto-merge workflow repaired; Flutter SDK wired into Unified CI | #1179 | `6bf297fab` |
| Tests | Dart suite made compilable (`package:test` → `package:flutter_test`) | #1180 | `a8dfd7788` |
| Consolidation | Content factory imported under `content-factory/` (877 files, two-parent merge) | #1181 | `ab207624e` |
| Catalogs | Secondary catalogs regenerated from canonical registry | #1183 | `7d0de7dd0` |
| Standards | Factory `standards/` + `directed_translation_scale/` absorbed byte-identical (SHA-256 27/27) | #1184 | `aefd1b989` |
| Registry | T40 machine-readable readiness report (registration vs content-complete/production-ready) | #1185 | `588bb7dd6` |
| Storage | T66/T67 pack admission bounds (256 MiB file-size, per-table/total row-count ceilings) | #1186 | `cf719c23b` |
| Storage | T68 last-known-good pack preservation (`.lastknowngood` backup + boot-time restore) | #1188 | `dd44b2466` |
| Storage | T69 transactional, idempotent, recoverable migrations | #1189 | `09630f748` |
| CI | Language Registry Guard now enforces `content-inventory --check` | #1195 | `825a366b2` |
| Content | T71 measured content inventory (708 files, 5,002 units; 27 languages with content; 73 zero) | #1193 | `e87f0f90c` |
| Red line | Excluded-language pack stub `assets/packs/he.json` removed | #1191 | `d5dc8cef9` |
| Red line | Fail-closed guard against excluded-language pack assets | #1192 | `ac048707f` |
| Storage | T70 shared packs separated from private learner state | #1197 | `830838fbe` |
| CI | T93 fast vs expensive check separation (fail-closed change detection) | #1199 | `c7913abea` |
| Provenance | T94 build artifact provenance (pinned SHA-256/bytes/version/sourceCommit) | #1200, #1201 | `57fdc6dfd`, `46d5eac73` |
| Release | T96 release artifacts bound to exact source commits | #1202, #1203 | `c4b2367cd`, `b6af1bb0c` |
| Rollback | T97 last-known-good application rollback (`--promote`/`--check`/`--plan`) | #1204 | `5c3afd886` |
| App blocker | `TrieSearchEngine` duplicate field declarations (hard compile error) fixed | #1172 | `565457eff` (byte-identical blob `f76a1c463`) |
| Search | Fail-closed contract pinning single Trie bounds declarations; carries the executable Flutter gate over the same tree | #1205 | `f654a14fd` |
| Merge-flow | #1182 (consolidation anchor, DIRTY) closed as superseded by merged `c978329df`; duplicate #1094 closed as byte-identical duplicate of #1172 | — | — |

History preservation: no force-push, no history rewrite, no branch/tag deletion was performed
at any point. The factory import landed as a two-parent merge and was re-anchored afterwards
with `-s ours` so both source histories remain ancestors of `main` without rewriting anyone's
commits. The 21 tags point at their original SHAs.

## 4. PR dispositions

- **MERGED (2026-11-14/15, this consolidation line):** #1178, #1179, #1180, #1181, #1183,
  #1184, #1185, #1186, #1188, #1189, #1191, #1192, #1193, #1195, #1197, #1199, #1200,
  #1201, #1202, #1203, #1204, #1205, and the anchor PR #1182's content via `c978329df`.
  Each SHA is listed in §3. `#1205` rides a non-skipping CI run so the merged tree receives
  an executable Flutter-gate check (AGENTS.md `[skip ci]` policy: a skipped check is never
  reported as PASS).
- **CLOSED (superseded/duplicate):** #1182 (DIRTY; content absorbed as `c978329df`),
  #1094 (byte-identical duplicate of #1172).
- **OPEN — app queue:** 456 open PRs in `deutsch-build` (455 draft at triage time; all
  authored by `moaz76943-creator`). Triage (T11/T12) is complete and machine-readable
  (`state/pr_unique_content.json`, `state/PR_TRIAGE_2026-11-15.md`); per-PR absorption
  decisions are **not** taken — nothing is closed on count alone, and no draft is merged
  without review + CI. Ready-but-DIRTY readiness is metadata only, not merge eligibility.
- **OPEN — factory queue:** 330 open draft PRs in `-offline-packs-store`; 198 are simply
  BEHIND (fast-forwardable), 10 CONFLICTING, remainder BLOCKED. No merges into the app
  repository from the factory queue are authorized; only validated, versioned artifacts
  cross via the documented content-pack contract.
- **BLOCKED:** PR #1187 (`agent/security-hardening`, T21–T30 + T61–T70 lineage). Merge
  conflict in `lib/core/storage/atomic_database_installer.dart` and its truthful Security
  Audit fails on pre-existing main debt. See §6.

## 5. What "unified" means here — and what it does not

- The canonical language registry (100 ids, he/iw excluded), the content-factory import,
  the readiness/inventory reports, the storage/rollback/provenance chain, and the CI gate
  all live on one `main`. That is the maximum consolidation safely available today.
- The repositories remain **two** on purpose: promoting to a single public repository is
  T100 and is gated (§6). No `gh repo edit --visibility public` has been executed, and no
  secret or key material exists in the current tree (verified; §6) — but history still
  contains the leaked token, so the exposure is remediated only by owner revocation.

## 6. Unresolved blockers (owner actions required)

1. **Secrets incident — OPEN.** One real-format GitHub PAT (classic format) exists in
   public git history (commit `b19dfd490`, 2026-10-11); every branch and all 21 tags
   contain it. Current tree verified clean (`scoped_security_audit.py` PASS; no token
   literal in tree); GitHub secret scanning + push protection are enabled. No history
   rewrite was performed (would dangle lineage, receipts and the open-PR queue; revocation
   is the only effective remediation and is owner-only). Tracked in
   `docs/project-record/SECRETS_INCIDENT_2026-11-15.md` and issue #1198.
2. **PR #1187 — BLOCKED.** Needs (a) owner revocation of the leaked PAT, (b) an owner
   decision on the offline-policy conflict (`http`, `cached_network_image` as direct deps
   vs the strict offline-only policy), and (c) conflict resolution in
   `atomic_database_installer.dart`. It must not be merged while it puts `main` red.
3. **T100 — BLOCKED.** Promotion to public `main` requires all required gates green and
   explicit owner authorization; the secrets incident and #1187 are the open gates.
4. **Content reality.** Measured: 27 of 100 registered languages have any bundled content
   (de 4,220; en 255; fr 254; tr 250; plus single-entry corridors); 73 languages measure
   zero pending factory harvest. Registration ≠ readiness; `readiness_report.json` reports
   productionReady = {de, ar}, sourceApproved = 0, content-complete = not-derivable. No
   readiness overclaim is made anywhere in this report.
5. **Factory absorption decisions pending.** `packs/` BLOCKED by the rights/provenance
   gate (fail-closed UNVERIFIED_RIGHTS); proficiency standard BLOCKED on an owner decision
   regarding canonical-registry proficiency metadata; factory's stale catalog registry
   must not enter the app tree.

## 7. Verification evidence and evidence debt

Evidence (this session + recorded increments):
- `registry_sync.py --check` exit 0 (100 languages, Hebrew excluded; checksum ef04da5d…).
- T97: 26/26 contracts; T96: 18/18; T94: 10/10; T93: 6/6; T71: 5 contracts; storage
  separation: 7 contracts — all run and passing at merge time.
- quality_gate failure set stash-verified identical to the clean-tree baseline
  (49 failed / 119 passed / 10 skipped at increments 18–20); zero regressions introduced.
- YAML validity of release workflows verified with pyyaml; detection logic simulated on
  scratch git repos; Dart/Flutter toolchain absent locally.

Evidence debt (must not be reported as success):
- No local Dart/Flutter SDK: `flutter analyze` / `flutter test` have never been executed
  locally; all executable Flutter evidence comes from GitHub Actions.
- Pre-existing quality_gate failures (content/CEFR contracts) remain and are untouched.
- SKIPPED checks on PRs are not PASS; where CI gates were path-filtered, the workflow run
  is recorded as SKIPPED, not success.
- Local Gitleaks cannot run on Termux aarch64 (glibc binary); history scan is CI-verified
  only; local fallback is pattern matching on the current tree.
- GitHub mergeStateStatus/mergeable for the draft queue is metadata-only; no draft PR in
  the queue has been build-verified.

## 8. Exact next steps

1. Owner: revoke the leaked PAT (issue #1198), decide the offline-policy conflict for
   PR #1187, decide the `content-factory/` retention/retirement, decide the packs/ and
   proficiency-standard absorption policy.
2. Owner: authorize (or decline) T100 (public `main` promotion) after gates are green.
3. Agent (after (1)): resolve #1187, close/absorb remaining drafts per T13–T20 with
   per-PR evidence, then produce the final T100 promotion checklist.

---
Report author: consolidation agent session 2026-11-15. Data gathered read-only from the
live repositories; no PR was merged, closed, rebased, or deleted in the course of
producing this report. Red lines respected: no secrets/PII in tree or in this document,
`he`/`iw` exclusion intact, excluded languages and citizenship-exam content untouched.
