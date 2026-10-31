# V167 — Repository Persisted-State Consistency Hardening

## Root cause
`LearnerRepository.save` and `_saveNow` serialized bounded collections/attempts but then cached the original unbounded `LearnerState`. A later `load()` could therefore return records that were not actually persisted.

## Fix
- Added one `_normalizeForPersistence` path shared by `save` and `_saveNow`.
- Added `_toJson` serialization from the normalized state.
- Cache is updated only after `SharedPreferences.setString` succeeds.
- The cached object is now the same bounded state represented by the persisted payload.
- Existing 4 MiB storage guard and write-queue error propagation remain intact.

## Verification
- V167 focused regression: PASS.
- V162–V166 focused regression: PASS.
- `compileall`: PASS.
- Security audit: PASS.
- Quality audit: PASS (14,793 entries; unique IDs and German entries).
- Architecture audit: PASS (0 oversized files).
- Accessibility audit: PASS (0 warnings).
- Weakness Gate: PASS (review queue 1,180; mutation NONE).

Flutter/Android runtime compilation remains unverified in this environment because the Flutter/Android SDK toolchain and external package network are unavailable.
