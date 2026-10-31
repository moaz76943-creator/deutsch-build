# V367 — Language Content Quality Contract

V367 introduces a language-neutral `LanguageContentQuality` contract over the
existing `LearningContent` projection. German-specific content validation now
has an explicit home in `GermanContentQuality` so the quality policy can move
with a future learning language rather than becoming part of the core.

This stage intentionally does not migrate all consumers away from the legacy
`ContentQuality` facade. That migration is reserved for the next architecture
stage so learner behavior remains unchanged during the boundary introduction.
