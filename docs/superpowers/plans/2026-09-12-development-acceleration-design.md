# Development Acceleration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a change-aware development verification layer that speeds daily feedback without weakening release verification.

**Architecture:** A Python orchestrator analyzes changed files, classifies risk, maps changes to affected checks, and uses a dependency-aware cache. Fast mode runs only the required targeted checks and reports skipped checks explicitly; release mode remains full verification. Content compilation is cache-aware and never treats generated Dart as canonical.

**Tech Stack:** Python 3, pytest, Bash, existing project audit/compiler tools, JSON metadata.

**Spec:** User-provided “DEUTSCH بالعربي — خطة تسريع التطوير مع الحفاظ على الجودة”.

## Global Constraints

- Do not delete existing tests; targeted mode only selects a subset and reports skipped tests.
- Release verification remains full and mandatory.
- Security-sensitive changes escalate to security checks automatically.
- Unknown impact escalates rather than guessing.
- Canonical content remains editable JSON; generated Dart is never canonical.
- IDs, SRS keys, and learner progress keys remain immutable.
- Validation must complete before mutation.
- Flutter/Android checks run only when the toolchain is available; absence is reported, never fabricated as PASS.

---

### Task 1: Change-aware dependency and risk engine

**Files:**
- Create: `tool/change_impact.py`
- Test: `tests/test_v374_change_impact.py`

**Interfaces:**
- `class RiskLevel(Enum): LOW, MEDIUM, HIGH, CRITICAL`
- `class ImpactReport`: serializable report containing changed files, risk, affected domains, selected checks, skipped checks, and uncertainty.
- `analyze_changes(root: Path, changed_files: list[str]) -> ImpactReport`
- `detect_changed_files(root: Path) -> list[str]`

- [ ] **Step 1: Write failing tests** for content changes selecting content/compiler checks, UI changes selecting accessibility, security changes selecting security, and unknown paths escalating.
- [ ] **Step 2: Run `pytest tests/test_v374_change_impact.py -q` and verify the expected missing-module failure.**
- [ ] **Step 3: Implement the minimal rule engine with explicit path rules and fail-closed unknown handling.**
- [ ] **Step 4: Re-run focused tests and verify PASS.**
- [ ] **Step 5: Run the existing V373 regression tests and verify no behavior change.**

### Task 2: Dependency-aware verification cache

**Files:**
- Create: `tool/verification_cache.py`
- Create: `.verification_cache/.gitkeep`
- Test: `tests/test_v374_verification_cache.py`

**Interfaces:**
- `fingerprint(paths: Iterable[Path], *, config: dict, tool_version: str) -> str`
- `load(cache_path: Path) -> dict`
- `is_valid(entry: dict, current_fingerprint: str) -> bool`
- `store(cache_path: Path, key: str, fingerprint_value: str, result: dict) -> None`

- [ ] **Step 1: Write failing tests** proving identical inputs reuse cache, source changes invalidate it, config changes invalidate it, and tool-version changes invalidate it.
- [ ] **Step 2: Run the focused tests and verify the expected missing-module failure.**
- [ ] **Step 3: Implement deterministic SHA-256 fingerprints over file paths/content plus configuration and tool version.**
- [ ] **Step 4: Re-run focused tests and verify PASS.**
- [ ] **Step 5: Verify cache corruption is treated as a miss, not as PASS.**

### Task 3: Fast verification orchestrator and machine-readable report

**Files:**
- Create: `tool/verify.py`
- Create: `scripts/check-fast.sh`
- Modify: `scripts/common.sh`
- Test: `tests/test_v374_verify.py`

**Interfaces:**
- `build_plan(report: ImpactReport) -> list[CheckSpec]`
- `run_plan(root: Path, plan: list[CheckSpec], *, cache_path: Path) -> VerificationReport`
- CLI: `python tool/verify.py fast [--changed FILE ...] [--report PATH]`

- [ ] **Step 1: Write failing tests** for targeted content verification, explicit SKIPPED reporting, cache hits, and escalation when impact is uncertain.
- [ ] **Step 2: Run the focused tests and verify the expected failure.**
- [ ] **Step 3: Implement the smallest subprocess-based orchestrator using existing project tools; no replacement audits.**
- [ ] **Step 4: Implement JSON report fields: `changed`, `risk`, `selected`, `skipped`, `passed`, `failed`, `security`, `content`, `compiler`, `warnings`.**
- [ ] **Step 5: Re-run focused tests and verify PASS.**

### Task 4: Release verification wrapper

**Files:**
- Create: `scripts/check-release.sh`
- Test: `tests/test_v374_release_verification_contract.py`

**Interfaces:**
- `scripts/check-release.sh` executes the full existing verification sequence and invokes `tool/verify.py release` as the final report wrapper.

- [ ] **Step 1: Write a failing contract test requiring the release script to contain full-test, security, content, architecture, privacy, accessibility, parity, and build/toolchain gates.**
- [ ] **Step 2: Run the contract test and verify failure.**
- [ ] **Step 3: Implement the release wrapper by delegating to existing scripts rather than duplicating audit logic.**
- [ ] **Step 4: Re-run the contract test and verify PASS.**

### Task 5: Cache-aware content compilation

**Files:**
- Modify: `tool/content_compiler.py`
- Test: `tests/test_v374_content_compile_cache.py`

**Interfaces:**
- `compile_to(..., cache_path: Path | None = None)` retains existing callers and skips regeneration only when the canonical inputs, compiler version, and output contract fingerprint match.

- [ ] **Step 1: Write failing tests** for unchanged-source cache reuse and invalidation after content/verb changes.
- [ ] **Step 2: Run focused tests and verify failure.**
- [ ] **Step 3: Add cache metadata without changing generated output format.**
- [ ] **Step 4: Re-run focused tests and then compiler parity tests.**

### Task 6: Verification report and documentation

**Files:**
- Create: `docs/V374_DEVELOPMENT_ACCELERATION.md`
- Modify: `README.md` only if an existing developer tooling section is present.
- Test: `tests/test_v374_release_contract.py`

- [ ] **Step 1: Write failing documentation contract assertions for fast/release commands and explicit skipped semantics.**
- [ ] **Step 2: Implement concise operator documentation and examples.**
- [ ] **Step 3: Run focused contract tests.**
- [ ] **Step 4: Run full `pytest` and all applicable project audits.**
- [ ] **Step 5: Produce a final machine-readable verification report and archive the verified tree.**
