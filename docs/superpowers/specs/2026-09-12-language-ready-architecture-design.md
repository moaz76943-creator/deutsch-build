# Language-Ready Architecture Design

## Goal

تهيئة `Deutsch بالعربي` بحيث تصبح إضافة لغة تعلم جديدة أو تغيير اللغة عملية محلية ومحدودة قدر الإمكان، من دون نقل خوارزميات التعلم أو خفض جودة المحتوى أو كسر الأمان أو سلوك المتعلم الحالي.

## Scope

هذه المواصفة تخص **لغة التعلم** أولًا، مع إبقاء لغة واجهة التطبيق الحالية (العربية) مفهومًا منفصلًا. لا نضيف Multi-Language Runtime ديناميكيًا في هذه المرحلة؛ اختيار اللغة يتم على مستوى Composition Root / build configuration، ويمكن أن يكون لكل لغة تطبيق/حزمة محتوى مستقلة.

## Recommended Architecture

نستخدم طبقات واضحة:

```text
Core domain
  ↓
Language-agnostic contracts + algorithms
  ↓
Language adapter / LanguagePack
  ↓
Language-specific content + grammar + morphology + examples
  ↓
Composition Root
  ↓
Shared presentation + language-aware presentation
```

المسار الموصى به عند إضافة لغة لاحقة:

```text
language/<lang>/
content/<lang>/
composition selection
focused tests
```

ولا يجوز أن تتطلب اللغة الجديدة تعديل SRS أو Mastery أو learner persistence أو authentication أو subscription.

## Language Boundaries

### LANGUAGE-AGNOSTIC

منطق SRS، الذاكرة، mastery الحسابي، learner state، authentication، subscription، secure storage، backend transport، والاختبارات العامة يجب أن تبقى مستقلة عن الألمانية.

### LANGUAGE-SPECIFIC

القواعد والمورفولوجيا، نظام الأفعال، normalization الخاصة باللغة، article/gender logic، grammar-sensitive validation، TTS locale/config، وواجهات الأسئلة التي تفترض بنية لغة بعينها.

### CONTENT-SPECIFIC

المفردات والأمثلة والترجمات والمواقف والـverb rows وأي dataset خاص باللغة. ملفات البيانات لا تتحول إلى منطق مشترك.

### PRESENTATION-SHARED

الصفحات والعناصر البصرية وسير التنقل التي لا تعتمد على محتوى أو قواعد لغة بعينها.

### LANGUAGE-PRESENTATION

النصوص التي تقول صراحةً "الألمانية" أو تعرض German/Arabic fields، وسيناريوهات اللغة المحددة، وأي شاشة ذات محتوى لغوي ثابت.

### INTEGRATION-SENSITIVE

العقود الحالية التي تحمل افتراضات اللغة ضمن schema أو signatures، وعلى رأسها `ContentItem` و`ConversationTurn` و`VerbConjugation`، إضافة إلى services التي تستخدم هذه النماذج مباشرة.

## Audit Findings — V346

| Area | Classification | Current reality | Safe direction |
|---|---|---|---|
| `lib/core/srs.dart` | LANGUAGE-AGNOSTIC | pure scheduling math | keep in Core |
| `lib/core/memory.dart` | LANGUAGE-AGNOSTIC | learner review queue | keep in Core |
| `lib/core/mastery.dart` | LANGUAGE-AGNOSTIC | mastery evidence math | keep in Core |
| `lib/core/learning_core.dart` | INTEGRATION-SENSITIVE | generic decisions but directly typed to `ContentItem` and `ContentQuality` | first introduce generic content contract/adapter before moving |
| `lib/core/text_normalizer.dart` | LANGUAGE-SPECIFIC | text normalization currently supports German characters | split generic normalization from language adapter |
| `lib/core/content_quality.dart` | LANGUAGE-SPECIFIC + INTEGRATION-SENSITIVE | validates German sentence format and German-specific quality rules | move German rules behind language-specific quality contract |
| `lib/models/content.dart` | INTEGRATION-SENSITIVE | schema uses `german`, `arabic`, `sentenceAr`, `article`, `plural` | redesign only in a dedicated high-risk migration stage; preserve stable IDs |
| `lib/models/verb_conjugation.dart` | INTEGRATION-SENSITIVE | model includes German/Arabic conjugation semantics | retain stable model initially; later language-specific verb DTO/adapter |
| `lib/models/conversation.dart` | INTEGRATION-SENSITIVE | `promptGerman` / `promptArabic` fields | migrate toward language-neutral turns plus localized content |
| `lib/services/content_engine.dart` | CONTENT-SPECIFIC + INTEGRATION-SENSITIVE | loads German corpus and generated German corpus | replace with a language content source selected by Composition Root |
| `lib/services/verb_index.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | indexes German conjugation datasets | move behind language-specific adapter; generic search sees a verb lookup contract |
| `lib/services/search_index.dart` | LANGUAGE-AGNOSTIC ALGORITHM + INTEGRATION-SENSITIVE | algorithm indexes hard-coded `german` and `arabic` fields | preserve algorithm; make searchable fields/contracts language-neutral |
| `lib/services/content_depth.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | German/Arabic lexical depth enrichment | move to language pack/content layer |
| `lib/services/assessment_engine.dart` | LANGUAGE-PRESENTATION + INTEGRATION-SENSITIVE | question prompts explicitly say German and use German/Arabic fields | move copy/role logic behind language exercise strategy |
| `lib/services/production_engine.dart` | LANGUAGE-SPECIFIC + PRESENTATION | production prompts assume German target | language exercise strategy |
| `lib/services/repair_engine.dart` | LANGUAGE-SPECIFIC + PRESENTATION | repair prompts and expected answers assume German | language exercise strategy |
| `lib/services/reading_practice.dart` | LANGUAGE-SPECIFIC | reads `item.german` | language content projection |
| `lib/services/vocabulary_coach.dart` | INTEGRATION-SENSITIVE | vocabulary logic uses German field names | consume language-neutral content view |
| `lib/services/word_profile_service.dart` | INTEGRATION-SENSITIVE | profile generation depends on current content model | language-neutral profile contract + language adapter |
| `lib/services/content_intelligence.dart` | LANGUAGE-SPECIFIC + CONTENT-SPECIFIC | duplicate/difficulty analysis uses German text and articles/plurals | split generic analytics from German lexical heuristics |
| `lib/services/writing_analyzer.dart` | LANGUAGE-SPECIFIC | German orthographic/linguistic heuristics | language-specific analyzer |
| `lib/services/conversation_engine.dart` | LANGUAGE-PRESENTATION + CONTENT-SPECIFIC | embedded German/Arabic scenarios | language content pack |
| `lib/services/tts_service.dart` | LANGUAGE-SPECIFIC | German locale/assumptions | language TTS configuration |
| `lib/data/content_*` | CONTENT-SPECIFIC | German A1 corpus/expansions | move under `content/german/` eventually without data mutation |
| `lib/data/verb_conjugations*` | CONTENT-SPECIFIC | German conjugation corpus | move under `content/german/` eventually |
| `lib/data/generated/*` | CONTENT-SPECIFIC | generated German corpora | generated output follows language-specific input path |
| `lib/ui_v35/*` | MIXED | shared UI + many German/Arabic assumptions | split shared widgets from language-aware presentation incrementally |
| `lib/ui_v35/pages/core_pages.dart` | LANGUAGE-PRESENTATION + CONTENT-SPECIFIC | fixed German reality scenarios and placement questions | language pack/config + reusable page shell |
| `lib/main.dart` | COMPOSITION ROOT | currently composes German content/indexes | select one language pack here; no language logic elsewhere |

## Critical Discovery

`ContentItem` is the largest architectural coupling point. Renaming/migrating its fields is a high-risk schema/interface change because persistence, content generation, search, quality, assessment, and UI all consume it. Therefore V346 does **not** change it.

The same rule applies to `VerbConjugation` and `ConversationTurn`.

## Migration Rules

1. No blind file moving.
2. No content rewriting as a side effect of architecture work.
3. Stable content IDs remain unchanged.
4. Existing German output must remain byte-for-byte equivalent where practical.
5. Every migration step has a focused architecture test, then full pytest regression.
6. Flutter/analyze/build are reported only when the toolchain is available.
7. Core algorithms stay behaviorally unchanged unless a test proves an interface boundary requires an equivalent refactor.
8. No Multi-Language Runtime is introduced in this phase.
9. German remains the canonical first language implementation; a new language is added through a separate language boundary, not by parameterizing every German file.

## Staged Roadmap

- **V346** — audit and freeze language boundaries. No production behavior change.
- **V347** — introduce language-neutral content projection/contract while keeping `ContentItem` as a compatibility model.
- **V348** — introduce `GermanLanguagePack` / language contracts at Composition Root.
- **V349** — move German corpus and verb data under language-specific content namespace without changing IDs.
- **V350** — isolate language-specific exercise/assessment/conversation rules.
- **V351+** — progressively split language-aware presentation and UI copy; remove compatibility coupling only after full regression.

## Acceptance Criteria for V346

- A complete classification of current language coupling exists.
- High-risk models are explicitly marked and not changed.
- A staged migration path exists.
- Architecture tests prevent accidental placement of German-specific logic in Core.
- No production learning/content semantics change in the audit stage.
