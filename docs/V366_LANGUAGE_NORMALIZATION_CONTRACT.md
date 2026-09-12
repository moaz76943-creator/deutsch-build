# V366 — Language Normalization Contract

## Purpose

Move answer-text normalization behind a language-facing contract so the
learning core does not own German-specific normalization rules.

## Boundary

`LanguageTextNormalizer` is a language-agnostic contract. The selected
`LanguagePack` exposes it through `textNormalizer`.

`GermanTextNormalizer` owns the current German behavior, including German
umlaut/eszett folding and the existing punctuation/whitespace cleanup.

The legacy `lib/core/text_normalizer.dart` remains temporarily available for
existing non-core consumers during the staged migration. It is intentionally
not imported by `LearningCore`. Its eventual removal belongs to the next
migration stage and must preserve observable normalization behavior.

## Compatibility

No learner state, SRS cards, mastery records, content IDs, or canonical
content data are changed by this stage.

No dynamic language selection is introduced. The Composition Root continues
to select the language pack.

## Verification

The V366 contract tests verify the abstraction, German implementation, and
that `LearningCore` no longer imports or references the legacy normalizer.
