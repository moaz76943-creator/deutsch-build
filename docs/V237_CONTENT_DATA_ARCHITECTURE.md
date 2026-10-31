# V237 — Content Data Architecture

## Decision

Keep Flutter/Dart as the application language. Introduce editable JSON content packs as a safe, versioned representation while preserving the existing Dart runtime tables during the migration.

## Current packs

- `content/content_items.json`: 14,813 content items.
- `content/verb_conjugations.json`: 11,718 verb conjugation rows represented by the current application source.
- `content/content_pack.schema.json`: machine-readable schema definitions.

## Safety boundary

The app does not read JSON directly in V237. The current Dart catalogue remains the runtime source. JSON is generated from the existing catalogue and validated independently. This prevents a data-format migration from changing learning behavior in the same release.

## CI boundary

Both `build-apk.yml` and `quality.yml` validate the editable packs before later build/test work. A malformed pack therefore fails CI before it can become a runtime change.

## Next migration step

A later stage can add a deterministic JSON-to-Dart compiler and a parity gate, then migrate one bounded content slice at a time. No destructive bulk replacement is part of V237.
