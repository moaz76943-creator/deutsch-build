# V305 — Repository Hygiene

## Scope
Remove obsolete root-level migration helper scripts that are no longer referenced by runtime code, build scripts, tests, or documentation.

## Decision
Historical migration helpers remain represented by their versioned documentation and tests where relevant; executable migration copies are not retained at repository root once their changes are canonical.

## Removed
- V219_LOCAL_STATE_LOAD_HARDENING.py
- V236_CI_CACHE_ISOLATION.py
- V237_CONTENT_DATA_ARCHITECTURE.py
- V239_CONTENT_ENGINE_ADAPTER.py
- V240_JSON_RUNTIME_SOURCE.py
- V241_JSON_CONTENT_BUILD_SWITCH.py
- V242_SEARCH_INDEX_CONTENT_ENGINE.py
- V243_MASTERY_DASHBOARD_CONTENT_ENGINE.py
- V245_LEARNING_PAGES_CONTENT_ENGINE.py

## Safety
No runtime references were found before removal. TDD guard `tests/test_v305_repository_hygiene.py` failed before removal and passes after removal.

## Verification
- Focused test: PASS
- Full Python regression: 390 passed
- Flutter/Android build: not run; required toolchain is unavailable in the current environment.
