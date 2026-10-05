# Changelog

All notable release changes for DEUTSCH بالعربي are documented here.

## V1.1 — 3.3.10+133 — 2026-10-05

V1.1 is the feature-freeze release for the current Offline-First application scope. The store/package version remains monotonic from 3.3.9+132 to 3.3.10+133.

### Dynamic Corpus Integrity

- Replaced fixed corpus-cardinality assumptions as admission criteria with dynamic integrity checks.
- Content admission is governed by schema validity, identifier uniqueness, signed content SHA-256 metadata, SQLite metadata, and relational integrity.
- Runtime learning reads use the admitted indexed SQLite corpus instead of creating an additional in-memory content authority.
- Bounded indexed access is preserved for review and explanation flows so large language packs do not require full-corpus materialization in the UI path.

### Hybrid Audio

- Added the V1.1 hybrid pronunciation entry point on top of the existing offline audio runtime.
- Verified local recorded audio is preferred when present.
- Native offline TTS remains the fallback when a suitable local recording is unavailable.
- No online TTS fallback or new network dependency is introduced by the hybrid pronunciation path.
- Quick Review uses the same hybrid audio ownership rather than creating a parallel playback implementation.

### Explain Why v2

- Consolidated explanation requests around the shared `ExplainerRequest` contract.
- Added deterministic reason-code explanations backed by the central localization catalog.
- Bound lexical explanations to bounded evidence from the admitted indexed SQLite corpus.
- Added corpus-backed explanation of meaning, grammatical markers, plural forms, usage examples, verb agreement, and past forms where verified evidence exists.
- Grammar feedback and Quick Review now expose learner-facing "لماذا؟" explanation surfaces without duplicating rule logic in the UI.
- Explanation remains offline, deterministic, bounded, and does not depend on a remote AI service.

### Streak Protection

- Preserves streak state with UTC review time, local-day identity, timezone-offset evidence, and Android monotonic elapsed-time / boot anchors.
- Detects backward-clock movement, local-day regression, malformed offsets, and same-boot wall-clock drift including forward clock jumps.
- Clock anomalies fail closed inside the protected gamification transition: accepted streak anchors are preserved and the streak does not advance.
- Production Quick Review reads the protected streak from the local SQLite gamification repository instead of the legacy raw-clock streak field.
- Existing local XP/streak values are migrated once only when the protected gamification database is pristine, preventing upgrade-time progress loss without fabricating monotonic history.
- The Android integrity probe uses permissionless local platform clocks only; no network time source or additional Android permission is required.
- Monotonic boot anchoring is used where the Android boot counter is available; otherwise the existing backward-clock/local-day fail-closed checks remain active.
- Existing one-day streak-freeze behavior remains separate from clock-anomaly handling.

### Production UI Wiring

- Added the production Quick Review route to the active Phase 3 production shell.
- Quick Review builds a due-only bounded working set from canonical SRS state and the admitted indexed SQLite corpus.
- Hybrid Audio is available directly from review cards.
- Explain Why v2 is available on demand from review cards.
- Recall results continue through `UniversalSessionOrchestrator` and `LearnerRepository`; no second SRS, XP, mastery, or streak authority was introduced.
- Source and translation text directions remain explicit in the multilingual review surface.

### Architecture and Privacy

- Maintains the project architecture: Shared Core + Language Intelligence + Directed Pair Intelligence.
- Maintains Offline-First operation for the V1.1 learning, review, audio, and explanation paths.
- Keeps heavy/local data authority in indexed local storage and bounded runtime working sets.
- Does not add a new cloud backend, remote AI dependency, paid service, or additional billing requirement for the V1.1 feature set.

### Release Packaging

- Package version: `3.3.10+133`.
- Android version name: `3.3.10`.
- Android version code: `133`.
- Release builds require explicit release-signing properties.
- Android release builds keep code minification and resource shrinking enabled.
- V1.1 enters Feature Freeze; subsequent changes should be limited to release-blocking defects, verification, signing, packaging, and store preparation.
