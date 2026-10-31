# V135 Weakness Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Reduce the project's weakest risks by strengthening accessibility, architecture visibility, content review, and release gates without changing learning behavior.

**Architecture:** Add deterministic static audits under `tool/`, strengthen a small set of UI semantics, and combine the audits through a weakness gate. Content similarity remains review-only and never mutates source content.

**Tech Stack:** Flutter/Dart source, Python 3 static audits, pytest, ZIP release artifacts.

**Spec:** Project development instructions for Deutsch بالعربي, with weakness-first prioritization.

## Global Constraints

- No automatic deletion of content.
- No unverified claims of Android runtime stability.
- Tests precede production changes.
- Preserve existing learning behavior.
- Prefer local/offline-safe behavior.

---

### Task 1: Add weakness-focused audits

**Files:**
- Create: `tool/accessibility_audit.py`
- Create: `tool/architecture_audit.py`
- Create: `tool/content_review_queue.py`
- Create: `tool/weakness_gate.py`
- Test: `test/v135_weakness_focus_test.py`

**Steps:**
- [x] Write failing tests.
- [x] Run focused tests and confirm failure.
- [ ] Implement audits.
- [ ] Run focused tests.
- [ ] Run full suite.

### Task 2: Strengthen UI accessibility

**Files:**
- Modify: `lib/ui_v35/app.dart`

**Steps:**
- [x] Add semantic grouping to key home statistics.
- [ ] Audit icon-only controls and text inputs.
- [ ] Preserve RTL/LTR intent.
- [ ] Run static accessibility audit.

### Task 3: Release and documentation hardening

**Files:**
- Modify: `pubspec.yaml`
- Modify: `android/app/build.gradle`
- Create: `docs/V135_WEAKNESS_HARDENING.md`

**Steps:**
- [ ] Bump release metadata.
- [ ] Document remaining runtime evidence gaps.
- [ ] Run release checks.

### Task 4: Verification

**Steps:**
- [ ] Run V135 tests.
- [ ] Run full Python suite.
- [ ] Run quality audit.
- [ ] Run security audit.
- [ ] Run content intelligence audit.
- [ ] Run accessibility audit.
- [ ] Run architecture audit.
- [ ] Run weakness gate.
- [ ] Run compileall.
- [ ] Validate release ZIP.
