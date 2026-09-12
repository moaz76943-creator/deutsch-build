# Deutsch بالعربي — V251 / P0-2B Verb Favorites Isolation

## Objective
Close the remaining local-data ownership gap around verb favorites without changing learner-visible behavior, content IDs, dependencies, or premium logic.

## Finding
`VerbConjugationPage` still owned the legacy `verb_favorites_v1` SharedPreferences key directly, while `LearnerRepository` owned the canonical `LearnerState.favoriteVerbs` state.

This recreated the exact split-ownership risk previously identified: deleting canonical learner state could leave verb favorites behind, and UI code could bypass the repository boundary.

## Fix
- `VerbConjugationPage` now receives the existing `LearnerRepository` instead of creating its own persistence path.
- Verb favorite reads use `LearnerRepository.loadAndMigrateFavoriteVerbs()`.
- Verb favorite writes use `LearnerRepository.toggleFavoriteVerb()`.
- The repository migrates legacy `verb_favorites_v1` values into canonical `favoriteVerbs` state before removing the legacy key.
- `clearLocalData()` removes both the canonical learner-state key and the legacy favorites key.
- No content, IDs, dependency versions, billing behavior, or TTS behavior changed.
- The migration is bounded to the existing legacy key; no new persistence architecture was introduced.

## TDD
1. Added `tests/test_v251_verb_favorites_repository_boundary.py` with repository ownership and UI-boundary assertions.
2. Focused test initially failed 2/2 because the repository did not own the legacy key and the UI still referenced `PreferencesService`.
3. Applied the minimal repository/page wiring change.
4. Focused test passed 3/3 after adding the deletion contract.
5. Full suite passed after updating the obsolete V152 test contract to the new repository boundary.

## Verification
- Full Python regression suite: **238 passed**.
- Content validation: **PASS** — 14,813 content rows; 11,718 verb rows.
- Content compiler + parity: **PASS** — 14,813 content rows; 11,718 verb rows.
- Security audit: **PASS**.
- Privacy audit: **PASS**.
- Quality audit: **PASS** — 14,813 entries / 14,813 unique IDs / 14,813 unique German entries.
- Accessibility audit: **PASS** — 0 warnings.
- Architecture audit: **PASS**.
- Weakness gate: **PASS**.
- Build-path compatibility: **PASS**.
- Python compileall: **PASS**.
- Bash syntax: **PASS**.
- Flutter/Android/APK/AAB execution: **not performed** because the required toolchain is unavailable in this environment.

## Safety boundary
No project history was reset, no content was deleted, and no dependency was upgraded. The legacy key is retained only as a migration/deletion compatibility surface and is no longer owned by the UI.

## Next stage
Continue P0-2B with a complete inventory of locally persisted learner fields and their data-minimization/retention requirements before introducing any authenticated account or payment trust boundary.
