# Legacy UI Audit

## Runtime status

- `lib/main.dart` launches `lib/ui_v35/app.dart`; `lib/ui/app.dart` is not the runtime entrypoint.
- `lib/ui_v35` is the current UI tree despite its historical `v35` name. It is still actively imported by the application and must be treated as current code, not deleted as legacy.

## `lib/ui/app.dart`

`lib/ui/app.dart` is retained for now because historical regression tests still inspect its repository and caching contracts. A repository-wide import scan found no production entrypoint importing it.

It is therefore **documented and retained**, not deleted blindly. Removal requires first migrating or replacing the historical regression coverage and then re-running the full analyzer/test/build gates.

## Safety rule

No old UI directory or file is removed solely because its name contains a version number. Removal requires an import/reference audit, preservation of covered behavior, and a green regression suite.
