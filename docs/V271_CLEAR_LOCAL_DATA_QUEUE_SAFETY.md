# V271 — Clear Local Data Queue Safety

## Purpose
Ensure local-data clearing remains ordered behind repository writes and that the in-memory learner-state cache is invalidated when the canonical persisted state is successfully removed, even if legacy cleanup fails afterward.

## Change
`LearnerRepository.clearLocalData()` now:

1. Runs inside the existing `_writeQueue`.
2. Records whether the canonical `v34_state` removal succeeded.
3. Attempts legacy `verb_favorites_v1` removal afterward.
4. Invalidates `_cachedState` in `finally` only when the canonical state was successfully removed.

This prevents a stale in-memory snapshot from surviving a successful primary deletion while still preserving the cache if the canonical deletion itself did not succeed.

## Verification
- V271 focused test: PASS
- Full regression: 268 passed
- Privacy audit: PASS
- Security audit: PASS
- Quality audit: PASS (14,813 content entries)
- Accessibility audit: PASS (0 warnings)
- Architecture audit: PASS
- Weakness gate: PASS
- Build path compatibility: PASS
- Content compiler: PASS (14,813 content rows; 11,718 verb rows; parity PASS)
- CI secret hygiene: PASS
- Python compileall: PASS
- Bash syntax: PASS

Flutter/Android/APK/AAB runtime/build verification remains unavailable in this environment because the required Flutter and Android SDK toolchain is not installed.
