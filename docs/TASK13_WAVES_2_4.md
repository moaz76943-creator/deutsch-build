# TASK 13 — Waves 2–4 and Directed Pair Derivation

Baseline: `main@cb1ac3c8a8324bcbfc26ec666a72efb5888fb61d`.

## Roadmap scope

TASK 13 executes Waves 2–4 using one-wave-ahead preparation and explicit
directed-pair derivation. A candidate is never treated as canonical.

Approved wave assignments:

- Wave 2: Spanish `es`, French `fr`, Italian `it`, Portuguese `pt`,
  Dutch `nl`.
- Wave 3: Turkish `tr`, Polish `pl`, Swedish `sv`, Greek `el`,
  Indonesian `id`.
- Wave 4: Japanese `ja`, Korean `ko`, Persian `fa`, Urdu `ur`.

Wave 2 already existed as 80 quarantined candidate cards. TASK 13 preserves it
without promotion. Waves 3 and 4 add 144 additional candidate cards using the
same fail-closed quarantine shape. These are preparation/evidence assets only;
they are not production-ready language claims.

## One-wave-ahead rule

- Wave 2 prepares the Wave 3 identity/script/role envelope.
- Wave 3 prepares the Wave 4 identity/script/role envelope.
- Wave 4 is the terminal approved wave in the current 20-language roadmap, so
  no unapproved Wave 5 is invented.

All TASK 13 candidate validation manifests use `maxParallel = 1`, preserving
the TASK 12 serial-mutation baseline until real per-pack safe-capacity evidence
exists.

## Directed pairs

For every Wave 2–4 language, TASK 13 derives two explicit candidate directions:

`ar -> language` and `language -> ar`.

That produces 28 directed pair candidates. Reverse readiness is never inherited,
silent pivoting is forbidden, and every pair remains `UNASSESSED`.

## Candidate != Canonical

Every new Wave 3–4 card is marked:

- `reviewStatus = pending`
- `culturalReview = pending`
- `provenanceStatus = pending-qualified-review`
- SQLite `admissionState = CANDIDATE_ONLY`
- canonical row count = 0
- quarantine reason = `cultural.review_required`

Canonical promotion remains blocked until all evidence named in
`tool/task13_wave_contract.json` is present, including qualified linguistic
review, provenance/license review, Pack Self-Test, Semantic Benchmark, directed
pair Golden evidence, pair readiness, runtime compatibility, and the canonical
quality gate.

## Verification

```bash
python3 tool/task13_wave_execution.py check
./scripts/local_quality_gate.sh
```

The verifier executes every candidate SQLite script in an in-memory SQLite
database and cross-checks it against the source JSON. It also validates the
roadmap assignments, prep chain, 28 directed pair candidates, zero canonical
promotions, and the 1000-line ceiling through the active quality-gate contract.
