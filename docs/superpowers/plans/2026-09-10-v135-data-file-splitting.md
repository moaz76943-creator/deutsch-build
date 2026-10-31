# V135 Data File Splitting Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the two oversized generated Dart data libraries into small chunk files while preserving the exact aggregate datasets and public symbols.

**Architecture:** Keep `a1` and `verbConjugations` as the stable public constants. Move their literal entries into numbered `part_XX` libraries and compose them with Dart const spreads. Move the verb model into its own model library and export it from the aggregate data library so existing consumers retain the same import path.

**Tech Stack:** Dart/Flutter source, Python pytest/static audits.

**Spec:** `docs/specs/2026-09-09-adaptive-learning-hybrid-design.md`

## Global Constraints

- Preserve all existing public names (`a1`, `verbConjugations`, `VerbConjugation`).
- Do not delete or auto-edit content entries.
- Preserve entry order and aggregate cardinality.
- No Flutter SDK/runtime claims when the SDK is unavailable.

---

### Task 1: Chunk oversized data libraries

**Files:**
- Create: `lib/data/content_a1_part_*.dart`
- Create: `lib/data/verb_conjugations_part_*.dart`
- Create: `lib/models/verb_conjugation.dart`
- Modify: `lib/data/content_a1.dart`
- Modify: `lib/data/verb_conjugations.dart`
- Test: `tests/test_data_chunking.py`

**Interfaces:**
- Consumes: existing literal entries.
- Produces: stable aggregate constants with unchanged public API.

- [x] Write failing test.
- [x] Run it and confirm failure.
- [x] Implement chunking.
- [ ] Run complete regression/audits.
