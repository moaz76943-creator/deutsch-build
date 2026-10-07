# TASK 10 — Editorial Content QA

Baseline: `main@a0d698f192a26f51be73a6a53c27541a31381669`.

The automated pipeline processes all 1,180 candidates in
`tool/content_review_queue.json` and fails closed on linguistic uncertainty.

- APPROVED: 690
- NEEDS_SPECIALIST_REVIEW: 490
- Mechanically proven canonical corrections: 68

The only automatic mutation is removal of a duplicated German article in an
example sentence (`der der`, `die die`, `das das`). The corrections are
tracked in `content/german/editorial_corrections.jsonl`, applied to the bounded
Dart authoring sources, and consumed by `tool/content_compiler.py` so
regeneration cannot restore the defect.

The correction ledger and all review batches are checksum-pinned in
`tool/editorial_review/task10_manifest.json`.

No learner state, SQLite progress, SRS, XP/streak, localization, UI, dependency,
or CI workflow is changed.

Verification:

```bash
python3 tool/editorial_content_review.py check
./scripts/local_quality_gate.sh
```
