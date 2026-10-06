# Legacy UI Audit

## Runtime status

Canonical production startup is now:

`lib/main.dart → lib/bootstrap/production_bootstrap.dart → Phase3ProductionShell`

`lib/main.dart` is intentionally a thin entrypoint. Render-first bootstrap,
placement routing, runtime failure containment, and Phase3 composition live in
`lib/bootstrap/production_bootstrap.dart`. Bounded corpus activation, memory
seeding, pack admission, and SystemAgentRuntime lifecycle live in
`lib/bootstrap/production_runtime.dart`.

Neither `lib/ui/app.dart` nor `lib/ui_v35/app.dart` is a production
entrypoint.

## `lib/ui/app.dart`

This file is retained only as a historical compatibility surface because older
non-canonical regression contracts still inspect it. Repository-wide code
search finds no production import of this top-level shell.

It must not be imported by the production bootstrap. Removal is permitted only
after its historical tests are migrated to current semantic boundaries and the
full regression/analyzer/build gates are available.

## `lib/ui_v35/app.dart`

The top-level `DeutschAppV35` shell is also not launched by production.
Individual files under `lib/ui_v35/` may still be active shared presentation
components and must not be deleted by directory-name heuristics.

The shell itself remains quarantined compatibility code until its historical
source-contract tests are retired or rewritten against current Phase3
behavior.

## Safety rules

1. Production roots must never import either historical top-level shell.
2. A versioned directory name is not evidence that all children are dead.
3. Deletion requires import/reference proof plus preservation of meaningful
   behavioral coverage.
4. Current production behavior is defined by the Phase3 bootstrap topology,
   not by historical V35 documentation.
5. Live GitHub main is authoritative when older reports conflict with this
   topology.
