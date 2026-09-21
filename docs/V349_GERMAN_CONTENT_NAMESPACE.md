# V349 — German Content Namespace Migration

**Baseline:** V348 — German Language Pack at Composition Root

## Change

German language-owned authoring sources remain organized under:

```text
content/german/
content/german/generated/
```

Flutter runtime code must remain inside the Dart package boundary under `lib/`.
Therefore editable/authoring sources outside `lib/` are **not imported directly by
Flutter libraries**. The verified runtime path is materialized before
analysis/build into:

```text
lib/data/generated/
```

The small `lib/data/content_a1.dart` and
`lib/data/verb_conjugations.dart` files are package-local compatibility/runtime
facades over that generated output. They contain no canonical content tables.

Engineering CI makes this boundary explicit with:

```text
python3 tool/content_compiler.py compile --output-dir lib/data/generated
```

before `flutter analyze`, tests, and Android build.

## Integrity

- 14,813 content entries preserved.
- 14,813 unique IDs preserved.
- 14,813 unique German entries preserved.
- No content values or IDs are intentionally changed by the namespace boundary.
- SRS, Mastery, search behavior, and learning behavior are not changed.

## Source / runtime separation

- Editable JSON packs remain under `content/`.
- The German language-owned manifest remains under `content/german/`.
- Legacy German Dart authoring/source material remains outside the Flutter package boundary.
- Flutter runtime generated Dart lives under `lib/data/generated/`.
- Runtime libraries under `lib/` must not import/export `content/german/` directly.

This separation avoids a false compatibility state where Python/source checks
pass while Flutter analyzer cannot resolve imports outside its package runtime
surface.

## Verification

Required verification is:

1. content/schema and ingestion validation;
2. compiler parity against editable JSON packs;
3. Python regression and architecture/security/quality gates;
4. runtime materialization into `lib/data/generated/`;
5. `flutter analyze`;
6. Flutter tests;
7. Android build where the release gate requires it.

## Compatibility

The migration remains staged. `lib/data` facade names are retained for
package consumers, but they are no longer canonical content tables. Their
purpose is to expose verified generated runtime content without duplicating the
editable authoring source.
