# Production Reachability Map — TASK 5

## Scope and baseline

- Repository: `sali97m-cpu/deutsch-bilarabi`
- Audited baseline: `main@73f78bc4d370df5437a10f2f0ce0170f2032e654`
- Production root under audit: `lib/main.dart`
- This document is analysis-only. It does not authorize deletion or migration.
- TASK 5 changes no code or tests. The only repository change is this file.

## Method

This map was built with bounded static analysis:

1. Read the exact production entrypoint and bootstrap files at the baseline SHA.
2. Follow direct Dart imports and concrete constructor/reference edges from:
   `lib/main.dart` → `lib/bootstrap/production_bootstrap.dart` → `Phase3ProductionShell`.
3. Inspect only the direct Phase3 presentation/runtime dependencies needed to establish the root closure.
4. Run targeted repository code searches for the audited historical shells/facades and for test, generated-code, documentation, and compatibility references.
5. Treat a runtime route as reachable only when a production-reachable file imports the target and registers/constructs it explicitly. No reflection-by-name or string-only route is treated as an import edge.
6. No unbounded recursive whole-repository graph traversal was used.

### Classification semantics

- **ACTIVE** — directly reachable from the production root and part of production composition/behavior.
- **ACTIVE_SHARED_COMPONENT** — production-root reachable through an ACTIVE node, but used as a subordinate/shared component rather than a top-level composition root.
- **LEGACY_COMPATIBILITY** — not reachable from the production root, but intentionally retained because legacy source surfaces or compatibility callers still consume it, or historical source-contract tests still depend on the retained surface.
- **DEAD** — no production-root reachability and no current `lib/` compatibility consumer was found. Test/document references may still exist, so DEAD is not deletion authorization.

## Canonical production graph

```text
lib/main.dart
└── import bootstrap/production_bootstrap.dart
    └── bootstrapDeutschApp()
        ├── runApp(_RenderFirstBootstrapApp)
        ├── ProductionRuntimeCoordinator
        │   └── lib/bootstrap/production_runtime.dart
        │       ├── ActivePackRuntimeProvider
        │       ├── GermanLanguagePack
        │       ├── PackManagerService
        │       ├── SqlCipherPackDatabaseSecurity
        │       ├── AndroidKeystorePackDatabaseKeyStore
        │       └── SystemAgentRuntime
        ├── placement path
        │   └── PlacementTestScreen
        └── activated learning path
            └── _ActivatedPhase3App
                └── LocalLearningRecoveryRuntimeHost
                    └── Phase3ProductionShell
                        ├── LifeTaskRouteRegistry
                        │   └── explicit builders for the 50 life-task feature screens
                        ├── Phase3FlashcardDeckPage
                        ├── Phase6L10nController
                        ├── Phase10PresentationBridge
                        ├── Phase10TasksTrackView
                        ├── SrsReviewHubScreen
                        └── shared design-system components
                            ├── AppGlassCard
                            ├── AppTypography / AppDirectionalText
                            ├── AppColors
                            └── AppAudioButton
```

There is no production import edge from this root chain to either
`lib/ui/app.dart` or `lib/ui_v35/app.dart`.

## Audited candidates

| Candidate | Classification | Production import reachable? | Referenced by test only? | Generated-code reference? | Reflective/runtime route reference? | Documentation only? | Compatibility API still consumed? | Evidence / conclusion |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `lib/main.dart` | **ACTIVE** | **Yes** — process entrypoint → `bootstrap/production_bootstrap.dart` | No | No checked-in generated reference found | No reflection; direct Dart call to `bootstrapDeutschApp()` | No | N/A | The file contains only the bootstrap import and `Future<void> main() => bootstrapDeutschApp();`. |
| `lib/bootstrap/production_bootstrap.dart` | **ACTIVE** | **Yes** — directly imported by `lib/main.dart` | No | No checked-in generated reference found | Uses explicit widget construction/navigation, not reflective loading | No | N/A | Owns render-first startup, placement routing, learner/gamification composition and creation of `Phase3ProductionShell`. |
| `lib/bootstrap/production_runtime.dart` | **ACTIVE** | **Yes** — imported by `production_bootstrap.dart` | No | No checked-in generated reference found | No reflective route | No | N/A | `ProductionRuntimeCoordinator` owns bounded corpus activation, pack admission/security and system-agent lifecycle. |
| `lib/ui/phase3/phase3_production_shell.dart` | **ACTIVE** | **Yes** — `production_bootstrap.dart → _ActivatedPhase3App → LocalLearningRecoveryRuntimeHost → Phase3ProductionShell` | No | No generated reference found | Explicit `MaterialPageRoute` and explicit route-registry builders; no reflection | No | N/A | This is the live production application shell at the audited HEAD. |
| `lib/ui/phase3/life_task_route_registry.dart` | **ACTIVE_SHARED_COMPONENT** | **Yes** — imported by `Phase3ProductionShell` | No | No generated reference found | **Yes, explicit runtime registry**: 50 compile-time-imported builders keyed by feature key | No | N/A | Runtime routing is explicit; feature-key strings select already-imported builders. |
| `lib/ui/phase3/phase3_flashcards.dart` | **ACTIVE_SHARED_COMPONENT** | **Yes** — imported by `Phase3ProductionShell` | No | No generated reference found | Direct `MaterialPageRoute`, not reflection | No | N/A | Owns production Phase3 flashcard projection/deck presentation. |
| `lib/ui/phase3/phase6_l10n_controller.dart` | **ACTIVE_SHARED_COMPONENT** | **Yes** — imported by `Phase3ProductionShell` and its Phase3 children | No | No generated reference found | Runtime language selection is controller/event based, not reflective route loading | No | N/A | Owns active Phase3 localization/directed-language-pair state. |
| `lib/design_system/app_glass_card.dart` | **ACTIVE_SHARED_COMPONENT** | **Yes** — imported by `Phase3ProductionShell` / active Phase3 and life-task UI | No | No generated reference found | No | No | N/A | Shared visual primitive used from production-reachable presentation code. |
| `lib/design_system/app_typography.dart` | **ACTIVE_SHARED_COMPONENT** | **Yes** — imported by `Phase3ProductionShell`, Phase3 track UI and production-reachable life-task screens | No | No generated reference found | No | No | N/A | `AppDirectionalText` is an active shared production component. |
| `lib/ui/app.dart` | **LEGACY_COMPATIBILITY** | **No** — no `lib/` importer; canonical bootstrap explicitly excludes the old shell | **Yes for external reachability** — historical tests inspect the file | No generated reference found | Internal `MaterialPageRoute` calls exist, but the shell is unreachable from production | No | No production consumer; retained for historical source-contract compatibility | Defines `DeutschApp`, but current startup never constructs it. `docs/LEGACY_UI_AUDIT.md` explicitly retains it pending historical-test migration. |
| `lib/ui_v35/app.dart` | **LEGACY_COMPATIBILITY** | **No** — no `lib/` importer; `DeutschAppV35` is not constructed by production | **Yes for external reachability** — many historical V35 tests inspect the source | No generated reference found | Contains its own named-route table, but that table is unreachable because `DeutschAppV35` is unreachable | No | No production consumer; retained as a historical V35 shell | Do not equate the V35 directory with this top-level shell. The shell is quarantined; directory children are classified separately. |
| `lib/ui_v35/safe_ui.dart` | **LEGACY_COMPATIBILITY** | **No** from the production root | No — it is imported by legacy code as well as tests | No generated reference found | No | No | **Yes** — consumed by `lib/ui/app.dart`, `ui_v35/learning_pages.dart`, `verb_pages.dart`, `progress_pages.dart`, `pages/core_pages.dart`, `conversation_pages.dart`, etc. | Shared compatibility shim over `services/tts_service.dart`; not production-reachable from Phase3 at this HEAD. |
| `lib/ui_v35/shared/text/bidi_text.dart` | **LEGACY_COMPATIBILITY** | **No** from the production root | No — consumed by V35 modules as well as tested | No generated reference found | No | No | **Yes** — used by V35 commute, grammar, pronunciation, placement, gamification and word-family modules | A shared V35 presentation component, but no import edge from the current Phase3 production closure was found. |
| `lib/services/app_dependencies.dart` | **LEGACY_COMPATIBILITY** | **No** — neither production bootstrap nor production runtime imports `AppDependencies` | No — consumed by historical UI modules | No generated reference found | No | No | **Yes** — consumed by `lib/ui/app.dart` and multiple V35 pages | Historical application-wide dependency facade. Current production composes explicit Phase3/runtime dependencies instead. |
| `lib/services/auth_session_controller.dart` | **LEGACY_COMPATIBILITY** | **No** from the current production root | No — consumed by V35 account/UI code | No generated reference found | No | No | **Yes** — `ui_v35/app.dart` and `ui_v35/account_auth_page.dart` | Account controller is outside the current Phase3 production closure. |
| `lib/services/search_index_legacy.dart` | **RETIRED (was DEAD)** | **No** at the TASK 5 baseline | Historical lexical assertions migrated/retired in TASK 5B | No generated reference found | No | Historical plans remain historical records | **No** | Removed in TASK 5B after reconfirming zero `lib/` consumers. `SearchIndex` behavior guards now assert the dependency-explicit engine directly. |

## Critical target findings

### 1. `lib/ui/app.dart` vs `lib/ui_v35/app.dart`

Both top-level application shells are outside the production import closure.

- `DeutschApp` exists only in `lib/ui/app.dart`; no production file constructs it.
- `DeutschAppV35` exists only in `lib/ui_v35/app.dart`; no production file constructs it.
- The canonical quality contract already asserts that neither historical shell is reintroduced into `production_bootstrap.dart` / `production_runtime.dart`.
- Their internal navigation graphs therefore do not become production-reachable merely because the source files compile.

Classification for both top-level shells: **LEGACY_COMPATIBILITY**.

### 2. `lib/ui_v35/` is not classified wholesale

No direct/import-export edge from the current production root into `lib/ui_v35/` was found at this HEAD.

That does **not** justify a blanket `DEAD` label for the directory:

- `lib/ui_v35/safe_ui.dart` is still a shared compatibility shim consumed by multiple retained legacy UI modules.
- `lib/ui_v35/shared/text/bidi_text.dart` is shared by multiple retained V35 modules.
- V35 grammar, commute, pronunciation, placement, gamification, learning and account modules still have internal compatibility/reference relationships and historical regression coverage.

Accordingly, this audit classifies individual V35 files. At the audited HEAD, the production-active shared presentation layer is instead under `lib/design_system/` and `lib/ui/phase3/`. No V35 child was promoted to **ACTIVE_SHARED_COMPONENT** without a proven production import edge.

### 3. `lib/services/search_index_legacy.dart`

The file advertises itself as a temporary compatibility facade, but current code search shows:

- no `lib/` import of `search_index_legacy.dart`;
- no application use of `LegacySearchIndex` outside its own definition;
- V35 architecture tests explicitly forbid V35 from constructing/importing the legacy facade;
- historical tests still inspect the file and documentation still describes its prior migration role.

At the TASK 5 baseline the runtime node was classified **DEAD**, not **LEGACY_COMPATIBILITY**, because no current compatibility caller remained. TASK 5B retired the file after migrating meaningful `SearchIndex` assertions away from the facade. Historical versioned architecture documents remain historical records.

### 4. Historical composition facade

`lib/services/app_dependencies.dart` is not part of the current production composition root.

Its consumers found under `lib/` are the historical `lib/ui/app.dart` and V35 modules such as grammar, commute, pronunciation and Zen surfaces. Current production instead passes explicit dependencies through `production_bootstrap.dart`, `production_runtime.dart`, `Phase3ProductionShell`, `LearnerRepository`, `GamificationRepository`, `QuickReviewService`, `ExplainerService` and the Phase3 runtime/controller boundaries.

Classification: **LEGACY_COMPATIBILITY**.

## Generated-code and reflection check

Targeted searches under the checked-in generated corpus path `lib/data/generated/` found no references to:

- `DeutschApp`
- `DeutschAppV35`
- `LegacySearchIndex`
- `AppDependencies`
- `Phase3ProductionShell`
- `LifeTaskRouteRegistry`
- `Phase3FlashcardDeckPage`
- `Phase6L10nController`
- `AppGlassCard`
- `AppDirectionalText`
- `SafeTtsController`
- `BidiText`

The production route model observed here is compile-time explicit. `LifeTaskRouteRegistry` maps feature keys to imported `WidgetBuilder` instances; it is not a reflective class-name loader. No string-only route reference was treated as proof of reachability.

## Deletion boundary for later tasks

TASK 5 performs **zero deletions**.

A **DEAD** classification in this document means only:

1. no path from the audited production root was found, and
2. no current `lib/` compatibility consumer was found.

It does not mean a file can be deleted without migrating historical tests/docs and rerunning the repository acceptance gates. In particular, the legacy top-level UI shells are intentionally classified **LEGACY_COMPATIBILITY**, not DEAD, because the repository still preserves source-contract coverage around those surfaces.

## Final reachability conclusion

The authoritative production topology at
`73f78bc4d370df5437a10f2f0ce0170f2032e654` is:

`lib/main.dart → lib/bootstrap/production_bootstrap.dart → Phase3ProductionShell`

with `lib/bootstrap/production_runtime.dart` providing the production runtime/corpus/pack composition and Phase3-specific presentation/runtime modules providing the active UI graph.

Neither historical top-level shell participates in production startup. The V35 directory must be handled file-by-file rather than by directory name, and the old search singleton facade currently has no application consumer.


## TASK 5B retirement record

Starting from `main@30081e1fc73f53e1e4da124d06c8659d08a75a79`, TASK 5B used the DEAD classification above as its deletion allowlist.

- Retired: `lib/services/search_index_legacy.dart`.
- Preserved: `lib/ui/app.dart`, `lib/ui_v35/app.dart`, `lib/ui_v35/safe_ui.dart`, `lib/ui_v35/shared/text/bidi_text.dart`, `lib/services/app_dependencies.dart`, and `lib/services/auth_session_controller.dart` because they are classified `LEGACY_COMPATIBILITY`, not `DEAD`.
- Meaningful search-index assertions were moved to the dependency-explicit `SearchIndex` implementation.
- Lexical assertions whose only purpose was to inspect the deleted facade were retired.
- The V345 guard that forbids reintroducing `LegacySearchIndex` into V35 remains in place.
