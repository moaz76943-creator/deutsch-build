# Deutsch بالعربي — Language Boundary Audit V346

**Status:** VERIFIED AUDIT BASELINE
**Purpose:** map all current language coupling before production migration.

## Classification legend

- **LANGUAGE-AGNOSTIC** — must not depend on German/Arabic language rules or content.
- **LANGUAGE-SPECIFIC** — implementation depends on linguistic rules, morphology, normalization, locale, or grammar.
- **CONTENT-SPECIFIC** — data/examples/scenarios belonging to one learning language.
- **PRESENTATION-SHARED** — reusable visual/page structure without language assumptions.
- **LANGUAGE-PRESENTATION** — presentation or copy that assumes a specific learning-language/source-language pair.
- **INTEGRATION-SENSITIVE** — an existing contract/model used by many consumers; migration requires a dedicated compatibility stage.

## Executive finding

The application already has a strong separation for SRS, memory, mastery, authentication, subscription, transport, and learner persistence. The main obstacle to language modularity is not the learning algorithms; it is that the current **content schema and several services encode German/Arabic directly**.

The single highest-risk boundary is `ContentItem` because the current fields are explicitly named `german`, `arabic`, `sentence`, `sentenceAr`, `article`, `plural`, and `accepted`. This model is consumed by Core, persistence, search, assessment, content intelligence, UI, and content generation. A direct rename would create a large synchronized migration, so it is explicitly deferred.

## Current inventory

| Path / area | Classification | Evidence / current responsibility | Migration direction |
|---|---|---|---|
| `lib/core/srs.dart` | LANGUAGE-AGNOSTIC | scheduling math only | keep unchanged |
| `lib/core/memory.dart` | LANGUAGE-AGNOSTIC | review queue over learner state | keep unchanged |
| `lib/core/mastery.dart` | LANGUAGE-AGNOSTIC | mastery evidence/calculation | keep unchanged |
| `lib/core/safe_runtime.dart` | LANGUAGE-AGNOSTIC | runtime safety helpers | keep unchanged |
| `lib/core/text_normalizer.dart` | LANGUAGE-SPECIFIC | German character awareness is present | split generic normalization from language rules later |
| `lib/core/text/directional_text.dart` | LANGUAGE-PRESENTATION + INTEGRATION-SENSITIVE | generic language-direction wrapper with explicit German/Arabic convenience constructors | keep `forLanguage` shared; move pair-specific shortcuts behind language presentation adapters when compatibility permits |
| `lib/core/content_quality.dart` | LANGUAGE-SPECIFIC + INTEGRATION-SENSITIVE | German sentence regex/quality messages and `ContentItem` fields | German quality adapter behind a generic contract |
| `lib/core/learning_core.dart` | INTEGRATION-SENSITIVE | algorithm is generic but typed to German-shaped `ContentItem` and `ContentQuality` | introduce content projection first; do not rewrite algorithms |
| `lib/models/content.dart` | INTEGRATION-SENSITIVE | German/Arabic field names plus article/plural | dedicated schema migration with compatibility layer |
| `lib/models/verb_conjugation.dart` | INTEGRATION-SENSITIVE | conjugation rows contain Arabic translation and German-specific structure | language-specific verb model/adapter later |
| `lib/models/conversation.dart` | INTEGRATION-SENSITIVE | `promptGerman` + `promptArabic` are pair-specific fields | language-neutral conversation turn + localized content later |
| `lib/models/word_profile.dart` | INTEGRATION-SENSITIVE | profile model is consumed with German field semantics | project through language-neutral interface where needed |
| `lib/services/content_engine.dart` | CONTENT-SPECIFIC + INTEGRATION-SENSITIVE | imports German A1 and generated content | become selected language content source at composition root |
| `lib/services/verb_index.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | builds indexes from German conjugation datasets | language-specific verb index behind generic lookup contract |
| `lib/services/search_index.dart` | LANGUAGE-AGNOSTIC ALGORITHM + INTEGRATION-SENSITIVE | ranking/index algorithm is reusable, but field names and labels are German/Arabic-bound | preserve ranking; feed it language-neutral searchable projections |
| `lib/services/content_depth.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | German/Arabic lexical depth enrichment | move to German language layer |
| `lib/services/assessment_engine.dart` | LANGUAGE-PRESENTATION + INTEGRATION-SENSITIVE | prompts explicitly say German and consume German/Arabic fields | exercise strategy per language |
| `lib/services/production_engine.dart` | LANGUAGE-PRESENTATION | German production prompts and expected language | language-specific exercise strategy |
| `lib/services/repair_engine.dart` | LANGUAGE-PRESENTATION | German repair instructions and expected answers | language-specific repair strategy |
| `lib/services/reading_practice.dart` | LANGUAGE-SPECIFIC | reads `item.german` as target-language text | use target-language projection |
| `lib/services/vocabulary_coach.dart` | INTEGRATION-SENSITIVE | vocabulary flow consumes German-shaped content | language-neutral content view |
| `lib/services/word_profile_service.dart` | INTEGRATION-SENSITIVE | profile generation consumes German field | language-neutral content view + language analyzer |
| `lib/services/content_intelligence.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | duplicate/difficulty analysis uses German tokens, article/plural, German syntax markers | split generic metrics from German lexical heuristics |
| `lib/services/writing_analyzer.dart` | LANGUAGE-SPECIFIC | German linguistic/orthographic heuristics | `language/german` analyzer |
| `lib/services/conversation_engine.dart` | CONTENT-SPECIFIC + LANGUAGE-PRESENTATION | hardcoded German/Arabic scenarios | language-specific scenario content |
| `lib/services/tts_service.dart` | LANGUAGE-SPECIFIC | German-oriented TTS assumptions/labels | locale/config owned by language pack |
| `lib/data/content_a1*` | CONTENT-SPECIFIC | German A1 vocabulary corpus | move under `content/german/` without changing IDs |
| `lib/data/content_expansion_*` | CONTENT-SPECIFIC | German vocabulary expansions | same |
| `lib/data/generated/content_items_*` | CONTENT-SPECIFIC | generated German corpus | generated output follows language-specific namespace |
| `lib/data/verb_conjugations*` | CONTENT-SPECIFIC | German conjugation corpus | move under `content/german/` |
| `lib/data/generated/verb_conjugations_*` | CONTENT-SPECIFIC | generated German verb corpus | same |
| `lib/ui_v35/app.dart` | MIXED / LANGUAGE-PRESENTATION | app title and German-specific entry points | keep shell shared; inject language config/copy |
| `lib/ui_v35/learning_pages.dart` | MIXED / LANGUAGE-PRESENTATION | learning page structure reusable, prompts use German/Arabic fields | extract language exercise content |
| `lib/ui_v35/progress_pages.dart` | MIXED | shared metrics + German text examples | retain shared layout; move examples to language layer |
| `lib/ui_v35/verb_pages.dart` | LANGUAGE-PRESENTATION | UI renders German verb conjugation concepts | shared shell + language-specific verb renderer/data |
| `lib/ui_v35/conversation_pages.dart` | MIXED / CONTENT-SPECIFIC | conversation UI plus hardcoded German/Arabic scenarios | shared UI + language scenarios |
| `lib/ui_v35/account_pages.dart` | PRESENTATION-SHARED with brand copy | account/subscription UI has product-name copy | keep security/subscription logic agnostic; brand copy can be build config |
| `lib/ui_v35/pages/core_pages.dart` | LANGUAGE-PRESENTATION + CONTENT-SPECIFIC | German reality scenarios and German placement questions | generic page shell + German scenario/question provider |
| `lib/ui/app.dart` | MIXED legacy | legacy UI still contains German/Arabic content assumptions | migrate only after canonical path is stable |
| `lib/main.dart` | COMPOSITION ROOT | composes current German corpus and indexes | future language selection belongs here |

## Direct German/Arabic coupling hotspots

### Data schema

`ContentItem` is the central coupling point. Do not rename `german` → `sourceText` or `arabic` → `translation` yet. The safe migration is to introduce a compatibility projection and migrate consumers in stages.

`VerbConjugation` and `ConversationTurn` have the same issue at smaller scale.

### Core

`Srs`, `Memory`, and `Mastery` are clean candidates for permanent language-agnostic status. `LearningCore` is algorithmically generic but currently accepts a German-shaped model, so it should be decoupled by projection rather than rewritten.

`TextNormalizer` and `ContentQuality` are not fully language agnostic today. They must be split before claiming the Core layer is language independent.

### Services

The most important service categories are:

1. reusable algorithms (`search`, learning decisions, statistics),
2. language rules (`verb_index`, `writing_analyzer`, German quality/depth),
3. content providers (`content_engine`, conversation scenarios),
4. presentation-oriented exercise wording (`assessment`, production, repair).

The first category should remain shared; the latter three should be isolated.

### Presentation

The UI is deliberately mixed today. This is acceptable for the current product but not for a future language replacement. We should extract data/configuration first, then extract reusable page shells. Do not duplicate whole screens per language.

## Data ownership target

```text
content/
  german/
    vocabulary/
    verbs/
    conversations/
    generated/

language/
  german/
    config/
    normalization/
    grammar/
    morphology/
    quality/
    exercises/
    tts/

core/
  learning algorithms
  learner state logic
  SRS
  memory
  mastery

presentation/
  shared shells/widgets
  language-aware adapters
```

There is intentionally **no `language/runtime` multi-language switcher** in this phase.

## Future-language change budget

The desired outcome is that adding Spanish, French, Turkish, etc. primarily creates/changes:

```text
language/<new-language>/
content/<new-language>/
composition selection
focused tests
```

and does **not** require edits to:

```text
core/srs
core/memory
core/mastery
authentication
subscription
secure storage
backend transport
learner persistence
```

Changes to shared algorithms should be treated as an architecture regression, not as the normal cost of adding a language.

## V346 safety decision

No production content, IDs, learning semantics, persistence schema, authentication, subscription, scoring, SRS, mastery, or search ranking behavior is changed in V346. The stage only records the boundary and establishes the migration order.

## Roadmap after audit

- **V347:** content-neutral projection/contract while retaining `ContentItem` compatibility.
- **V348:** `GermanLanguagePack` selected at Composition Root.
- **V349:** German content namespace migration with corpus/ID identity tests.
- **V350:** assessment/production/repair/conversation language strategies.
- **V351+:** presentation split and retirement of compatibility coupling only after regression.

lib/core/language/app_text_direction.dart
