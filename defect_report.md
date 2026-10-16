# Performance Review — Unverified Findings and Reproduction Plan

## Status and provenance

This document replaces an earlier report that described an AST audit, exact widget nesting depths, and performance/battery impacts without providing the underlying audit script, trace, or captured results. Those earlier statements are **unverified**. This document does **not** claim that production performance is degraded or that the application was profiled.

**Target for verification:** canonical `staging/v2-full-platform` at its exact SHA when the audit is performed. Record that SHA and the toolchain version alongside the results; line numbers change as the branch evolves.

## 1. `setState` lifecycle safety — hypothesis

Search for `setState(` occurrences under `lib/`, particularly calls reachable after asynchronous gaps or during `build`, `initState`, or `dispose`. A text search is only a candidate locator: it cannot establish whether each call executes inside a safe callback or whether its owner is still mounted.

To turn a suspected defect into a verified finding:

1. Run `dart analyze lib/` and `flutter test` on the candidate tree; preserve complete output and exit codes.
2. Inspect the actual control flow for every candidate call; check `mounted`, request-generation cancellation, and `dispose` interactions where relevant.
3. Add a minimal regression test that reproduces a real lifecycle violation before changing application behavior.

No `setState` violation is proven by this report.

## 2. Vocabulary journal rebuild cost — hypothesis

`lib/screens/vocabulary_journal_screen.dart` is a **candidate for profiling**, not an established hotspot. Earlier line-specific nesting counts (24–29 levels) were not backed by reproducible AST output, and widget nesting by itself does not prove excessive rebuilds, UI-thread blocking, or battery drain.

Verification steps:

1. Pin the branch SHA and open the journal with representative offline content on a target Android device.
2. Capture a baseline Flutter DevTools performance trace (frame timings and rebuild activity) with repeatable scrolling, filtering, and text-scale scenarios.
3. Record the test device, release/profile mode, app and pack versions, dataset size, frame metrics, and trace artifact.
4. Only after observing unnecessary rebuilds, compare a narrowly scoped widget extraction or state-boundary change against the same baseline.
5. Check RTL/LTR mixed text, font scaling, scroll position, and route restoration in widget/device regression tests.

Do not introduce new state-management dependencies or perform a broad UI rewrite without demonstrated benefit and ownership review.

## Acceptance gate

A future *verified* performance defect entry must contain: `SOURCE_SHA`, `TOOLCHAIN`, `REPRO_STEPS`, `EXPECTED`, `ACTUAL`, `EVIDENCE_ARTIFACT`, `REGRESSION_TEST`, and `STATUS`. Without them, use `UNVERIFIED` or `NOT_RUN`, never `PASS` or `FIXED`.

This PR changes documentation only. It does not certify `dart analyze`, `flutter test`, the local quality gate, or Android behavior.
