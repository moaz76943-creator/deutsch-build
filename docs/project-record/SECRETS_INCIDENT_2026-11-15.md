# Secrets incident record — deutsch-build public repository

- Recorded: 2026-11-15 (UTC)
- Status: OPEN — OWNER ACTION REQUIRED (credential revocation); tree verified clean; no history rewrite performed (see rationale)
- Trigger: PR #1187 "Offline-First Security Audit" run 43681022541 returned FAIL with
  SECRETS_OUTCOME=failure (305 Gitleaks findings over full fetched history) and
  POLICY_OUTCOME=failure (pre-existing offline-policy violations, tracked separately).

## What was done (this session)

1. Reproduced the CI secrets scan classification locally against the 305 findings
   (rule, file, line, commit) without printing any matched value.
2. Classified every finding. Result:
   - 1 confirmed real-format GitHub personal access token (classic `ghp_` format)
     in history — see "Confirmed exposure".
   - 2 embedded test-only ED25519 private keys in history — see "Test-key findings".
   - 302 false positives: content `canonical_key` fixtures, SHA-256 hashes
     (`token_sha256` in semantic-vector manifests, file digests in
     `engineering_checkpoint.json`), RFC test vectors in
     `test/security/phase7_security_integrity_test.dart`, placeholder constants
     (`deutsch_crash_count_v1`, `vocabulary_items_v3`, `key-prod-ed25519-v1`,
     `ed25519_pub_key`), and prose in the 2026-09-11 plan document (also inside
     `deutsch_bilarabi_v383_codex_handoff.tar.gz`).
3. Verified the current tree is clean:
   - `python3 tools/security/scoped_security_audit.py` -> PASS (0 leaks, 0 private keys, 0 tracking SDKs).
   - No `ghp_` string and no PEM private-key block anywhere in the working tree
     (only the detectors' own regex patterns and fake test strings).
   - `get-app` (current) reads `~/deutsch-bilarabi/token.env` (untracked path); no token literal.
4. Confirmed the active gh CLI session token is a different credential
   (`gho_` OAuth token, not the leaked `ghp_` value); no session compromise.
5. Enabled repository hardening (was off): GitHub secret scanning = enabled,
   secret scanning push protection = enabled. New secrets can no longer be pushed.

## Confirmed exposure

- File: `get-app`, line 5
- Introduced by commit `b19dfd490` ("update: 2026-10-11 00:09:16"), an ancestor of
  `main`, of every local branch, and of tags `latest`, `v3.0.0`,
  `v420.0.0-release-build-verified` (21 tags total).
- Value: a classic GitHub PAT, `ghp_` + 36 chars (prefix `ghp_Yw`, suffix `cU50`
  recorded for identification only; the full value is intentionally NOT recorded
  anywhere in this repository and must not be pasted into any issue, doc, or log).
- The working-tree copy was scrubbed later (the line now reads `token = ""`), but
  the value remains reachable in public Git history and in any clone/fork made
  while public. Fork count is 0 today; that does not undo prior cloning.

## Test-key findings (low severity)

- `tests/test_language_pack_factory.py:20` and `tests/test_phase6_signed_manifest.py:11`
  (commit `a040e5b08`) embed an ED25519 private/public key pair used only as a
  `tmp_path` test fixture. `tools/pack_manifest_signing.py` takes `key_path` as a
  parameter and ships no embedded default key; no production reference exists.
- Action: confirm the pair was never reused outside tests; if reused anywhere,
  rotate. Evidence says test-only.

## Why no history rewrite was performed

- Every branch, tag, and open-PR head contains the exposing commit; a
  `filter-repo --replace-text` rewrite changes all SHAs after 2026-10-11,
  dangling the content-factory lineage anchor (`ab207624e`), every recorded
  merge receipt in `POLYGLOT_100_PROGRESS.md`, and all 100 open PRs.
- The exposure is public since 2026-10-11; revocation is the only effective
  remediation and it is owner-only. A rewrite without revocation changes nothing.
- Per the operating contract: unknown critical state => STOP / RECONCILE; no
  destructive force-push without explicit owner authorization.

## Required owner actions

1. REVOKE the leaked PAT immediately at github.com/settings/tokens (identify by
   prefix `ghp_Yw` / suffix `cU50` or by last-used date around 2026-10-11).
2. Confirm the two test ED25519 pairs were never used outside tests; rotate if unsure.
3. Decide on a coordinated history purge (rewrite + force-push + tag recreation +
   PR rebases) or accept revocation as sufficient. The exact recipe is ready:
   `git filter-repo --replace-text` on the token string, then recreate tags.
4. Keep secret scanning + push protection enabled (done this session).
5. Enable branch protection with required checks on `main` (currently unprotected).

## Red lines respected

- No secret value recorded in this report or any commit.
- No force-push, no history rewrite, no test weakening, no gate bypass.
- Excluded languages (`he`, `iw`, `syc`, `ber`, `zgh`) and citizenship exams untouched.

## Evidence

- CI run 43681022541 (Offline-First Security Audit, FAIL, 305 findings) — https://github.com/moaz76943-creator/deutsch-build/actions/runs/43681022541
- Local classification: parsed from the run log; per-file counts in this report.
- `tools/security/scoped_security_audit.py` on current tree: PASS.
- `gh api repos/.../branches/main/protection` -> 404 (unprotected); `forkCount: 0`.
- Hardening: `gh api PATCH repos/.../security_and_analysis` -> secret_scanning=enabled, push_protection=enabled.
