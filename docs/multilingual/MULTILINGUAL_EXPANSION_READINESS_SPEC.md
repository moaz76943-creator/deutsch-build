# DEUTSCH بالعربي — Multilingual Expansion Readiness Specification + Task Factory

**TASK_ID:** `MULTILINGUAL-READINESS-SPEC-001`
**ACTOR_ID / OWNER:** `CHAT-5`
**Status:** **PROPOSAL / HANDOFF — NOT YET AUTHORITATIVE FOR SHARED-CORE MUTATION**
**Scope:** specification and task-factory only; no language activation, no broad content generation, no Shared Core mutation.
**Canonical repository snapshot audited:** `sali97m-cpu/deutsch-bilarabi@6d6f88b8a9481de981d7a15d5595e590420da306`
**Durable CLAIM:** GitHub Issue #32.

---

## 0. Authority and interpretation

This document converts the already-approved multilingual direction into a precise, testable proposal. It does **not** replace the Master Project Source, current GitHub code, verification evidence, checkpoints, approved architecture, or current ownership.

The authoritative interpretation order remains:

1. live canonical GitHub code / PR state;
2. executed tests, CI, builds and verification;
3. verified checkpoints / project record;
4. CURRENT PROJECT RECORD / ENGINEERING_STATE;
5. approved architecture / ADR / Notion contracts;
6. this proposal;
7. conversation text.

Until this proposal is reviewed/approved through the existing architecture/governance path:

- it MUST NOT be used to activate production languages;
- it MUST NOT authorize broad content generation;
- it MUST NOT justify a second Language Registry, Language Factory, Pair system, scheduler, state store or parallel architecture;
- shared runtime/core changes remain separate tasks requiring their own CLAIM, owner, branch and verification.

Core invariant:

> **registered ≠ implemented ≠ tested ≠ verified ≠ production-ready**

The approved scale target (50 production-expansion languages, architecture scalable to 100) is a capacity target, not evidence that those languages exist or are ready.

---

## 1. Current evidence-backed baseline

### 1.1 What exists in current GitHub

The current repository has a real language boundary and a German reference implementation:

- `LanguagePack`
- `GermanLanguagePack`
- `LanguageContentPack`
- `LanguageTextNormalizer`
- `LanguageContentQuality`
- `LanguageContentIntelligence`
- `LanguageExerciseStrategy`
- `LanguagePresentation`
- neutral `LearningContent` projection
- German language namespace under `lib/language/german/`
- German content namespace under `content/german/`
- language-boundary regression history and architecture tests
- composition-root selection of one `GermanLanguagePack`

The architecture has already moved substantial German behavior out of shared learning algorithms. Shared SRS/mastery/persistence/auth/subscription responsibilities must remain language-agnostic.

### 1.2 What is not evidenced as an operational implementation

The current tree does **not** provide evidence of separately implemented operational components named or equivalent to:

- runtime Language Registry;
- executable Capability Matrix;
- Language Factory for arbitrary languages;
- directed Pair Registry / Pair Intelligence runtime;
- executable per-language readiness gate;
- per-language/per-pair Golden Set framework;
- on-demand multi-language runtime loader/cache;
- universal neutral content schema suitable for arbitrary target/source languages.

Approved architecture references these concepts, but documentation approval is not implementation evidence.

### 1.3 Current German implementation is a reference, not proof of multilingual readiness

German is the current composed learning language. It must be treated as the **reference implementation/current single-target runtime**, not as proof that the multilingual contract is complete.

Material current couplings include:

- `GermanLanguagePack.sourceLocale => 'ar'`, which couples the target-language pack to a source/user language;
- `content/content_pack.schema.json` uses explicit `german`, `arabic`, `sentenceAr`, German verb fields and Arabic-specific fields;
- `ContentItem` is a compatibility model with `german` / `arabic` fields;
- `VerbConjugation` remains German/Arabic shaped;
- `SafeTtsController` currently discovers and requires a German voice directly;
- `SpeechService` defaults to `de_DE`;
- `WritingAnalyzer` contains German-specific capitalization, V2 and verb heuristics;
- `content_depth.dart` is a German-specific enrichment dataset.

Therefore German under this proposed universal readiness model is **PARTIAL / REFERENCE IMPLEMENTATION / NOT YET ASSESSED AS UNIVERSAL-CONTRACT READY**. This does not negate the current German application behavior or its existing verification.

---

## 2. Blocking specification gaps before Language Workers

The following are real blockers to safely spawning language implementation workers.

| Gap | Current evidence | Why it blocks language workers | Required closure |
|---|---|---|---|
| G1 — authoritative language expansion contract absent | Control Center explicitly says authoritative 20-language specification is required | workers would invent incompatible language rules | approve one minimum supported-language contract |
| G2 — source/user vs target coupling | `GermanLanguagePack.sourceLocale = ar` | target packs cannot be independently reused with different source/user languages | separate language identity from directed pair configuration |
| G3 — no executable Registry/Capability Matrix evidence | approved concept exists; current tree has no operational implementation found | configuration presence could be mistaken for support | define lifecycle/state/capability contract, then implement once |
| G4 — no Pair runtime contract | approved Pair Intelligence concept; no current executable pair layer found | A→B could silently be treated as B→A | define directed pair identity and readiness |
| G5 — German/Arabic-shaped content schema | current JSON schema and compatibility models | arbitrary languages would require schema forks or Core leakage | neutral canonical authoring/runtime boundary + language-specific extension rules |
| G6 — grammar/morphology contract incomplete | current neutral interfaces cover some behavior but not general morphology/grammar capability | German categories could leak into every new language | capability-based Language Intelligence contract |
| G7 — speech/TTS still German-wired in current runtime services | direct `de-DE` / `de_DE` behavior | new language workers would edit shared services or silently reuse German | language-owned speech/pronunciation profile + capability gate |
| G8 — writing/depth still German-specific shared service files | direct German rules/data | language worker cannot safely add equivalent behavior without duplication | language-owned analyzer/enrichment contracts or explicit unsupported capability |
| G9 — Golden Sets / semantic equivalence not executable | approved concept, no per-language/pair framework evidenced | no objective cross-language quality proof | define golden artifacts and gates |
| G10 — readiness is conceptual, not machine-enforced | approved readiness rule exists | registry/config could accidentally expose incomplete language | fail-closed mandatory readiness gates |
| G11 — provenance/quarantine not bound to language/pair lifecycle | German content tooling exists; universal per-language rules not evidenced | generated/imported content could bypass language-specific review | universal provenance + quarantine contract |
| G12 — on-demand loading/cache/offline language lifecycle not implemented | architecture requires it; current app composes one German pack | scaling by packaging/preloading all languages would violate architecture and unsigned/replayed manifests could bypass reviewed pack state | loader/cache manifest, authenticity/replay-protection and budget contract |
| G13 — language/pair compatibility versioning not formalized | no current universal version matrix found | contract/schema upgrades can break packs independently | compatibility/version model |
| G14 — no standard Language Worker capsule | V4 task protocol exists generally, not a multilingual-specific factory | parallel language work could touch Shared Core or collide | task factory below |

**Admission rule:** no per-language implementation worker becomes READY until G1–G5, G9–G10 and G13 are approved at specification level and the necessary shared implementation prerequisite is VERIFIED.

---

## 3. Minimum Supported-Language Contract

A language is not "supported" from a registry row alone. At minimum, a language record MUST declare the following.

### 3.1 Identity

- stable `language_id` independent of display text;
- canonical language code;
- supported locale set where locale-specific behavior matters;
- native name and display-name localization references;
- script(s);
- text direction per script/context;
- segmentation/tokenization policy or explicit capability absence;
- normalization policy/version;
- language-pack version;
- contract/schema compatibility versions;
- declared role eligibility and references to the corresponding role-readiness records.

Stable language identity and role readiness MUST be separate. Every declared `user_language`, `source_language`, or `target_language` role owns an explicit readiness record keyed by `language_id + role` and bound to the exact version/hash set of every artifact and evidence input consumed by that role assessment. Applicable inputs include the contract/capability snapshot and, as relevant, the language pack, learner-facing localization bundle, language-intelligence implementation, content pack, Golden Set, provider/speech profile, compatibility policy and verification-evidence fingerprint. Updating any consumed artifact or evidence input invalidates the prior readiness record until that exact new set is reassessed. Each role record follows:

`REGISTERED → SPECIFIED → IMPLEMENTED → TESTED → VERIFIED → PRODUCTION_READY`

Exception states:

`BLOCKED / QUARANTINED / DEPRECATED / SUPERSEDED`

A language MAY be ready for one role and unready for another. No aggregate language-wide `PRODUCTION_READY` value may promote or mask an unready role, and no transition may be inferred from presence in configuration.

### 3.2 Role declaration

A language record declares whether it is technically eligible for:

- `user_language`;
- `source_language`;
- `target_language`.

Eligibility is not the same as role readiness or pair readiness. Consumers MUST query the exact declared role record; they MUST NOT infer `source_language` or `target_language` readiness from `user_language` readiness, or vice versa.

### 3.3 Capability declaration

Capabilities MUST be explicit and fail closed. At minimum consider:

- learner-facing localization/product communication when `user_language` is claimed;
- orthography/script;
- normalization;
- tokenization/segmentation;
- vocabulary/content;
- grammar;
- morphology/inflection;
- verb/conjugation behavior where applicable;
- sentence/exercise strategy;
- writing analysis;
- pronunciation representation;
- TTS;
- STT/speech recognition;
- listening;
- speaking;
- conversation;
- search/indexing;
- lexical enrichment;
- assessment;
- CEFR/level mapping where valid;
- offline core pack;
- provider-dependent capabilities.

A capability may be `SUPPORTED`, `LIMITED`, `UNSUPPORTED`, `NOT_APPLICABLE`, `BLOCKED`, or `QUARANTINED`. Unknown/missing declaration MUST NOT degrade silently into supported.

State semantics are distinct and fail closed:

- `SUPPORTED` — an implementation exists for the declared language/version/role scope;
- `LIMITED` — an implementation exists with explicit declared limitations that the consumer must accept deliberately;
- `UNSUPPORTED` — the capability is applicable but this language/version does not support it;
- `NOT_APPLICABLE` — the capability or gate genuinely does not apply to this language/role/task and that non-applicability is explicitly justified; it MUST NOT be used as a synonym for missing implementation or an unresolved product decision;
- `BLOCKED` — the capability is applicable but cannot currently proceed/be exposed because a declared dependency, prerequisite, or unresolved decision blocks it;
- `QUARANTINED` — implementation/artifact evidence exists but quality/risk/provenance state forbids exposure.

Planning/decision state, runtime/provider availability, and release/readiness lifecycle are separate axes. A pending decision must not masquerade as `NOT_APPLICABLE`; provider/device availability must not upgrade an operationally unsupported capability; and operational `SUPPORTED` alone does not imply `TESTED`, `VERIFIED`, or `PRODUCTION_READY`.

---

## 4. USER LANGUAGE, SOURCE LANGUAGE and TARGET LANGUAGE

These concepts MUST not be conflated.

### 4.1 User Language

`user_language` is the language used for learner-facing explanations/instructions/localized product communication where applicable.

Declaring `user_language` eligibility is a support claim and therefore MUST be fail-closed. The language must own or reference versioned learner-facing localization assets for the applicable product surfaces (for example explanations, instructions, validation/error text and other required learning communication), declare coverage explicitly, and provide localization fixtures/Goldens for those surfaces. Missing localization MUST produce an explicit unavailable/unsupported state; it MUST NOT silently fall back to English, German or another bridge language. A language cannot become `PRODUCTION_READY` for the `user_language` role until the mandatory User-Language Localization Gate passes.

### 4.2 Source Language

`source_language` is the reference language used by directed pair intelligence for translations, contrastive explanations, transfer errors, false friends and source-side semantics.

A product may default `source_language = user_language`, but the architecture MUST NOT require them to be identical.

### 4.3 Target Language

`target_language` is the language being learned/practiced.

A target-language implementation MUST NOT contain a hard-coded source language. Therefore a future target pack equivalent to `GermanLanguagePack` MUST not intrinsically own `sourceLocale = ar`.

### 4.4 No bridge rule

For an unsupported `source → target` pair:

- do not route through English;
- do not route through German;
- do not silently substitute another source language;
- do not expose pair-dependent features as supported.

The system must return an explicit unsupported/limited capability result.

---

## 5. Directed Pair Contract

Pair identity is ordered:

`PAIR(source_language, target_language)`

Therefore:

`A→B != B→A`

Every direction independently owns:

- pair ID and version;
- source/target IDs;
- capability declaration;
- translation/semantic-equivalence evidence;
- contrastive grammar rules;
- transfer-error model;
- false-friend data where relevant;
- pair-specific examples/explanations if required;
- directed Golden Set;
- pair-level readiness;
- provenance/review state.

A reverse direction may reuse verified language-level assets, but it cannot inherit pair readiness automatically.

Pair state follows:

`REGISTERED → SPECIFIED → IMPLEMENTED → TESTED → VERIFIED → PRODUCTION_READY`

No `A→B` transition changes `B→A`.

---

## 6. Language Intelligence Contract

Language Intelligence is language-owned logic/data behind a stable Core-facing boundary.

It MUST describe or implement, as applicable:

1. **Orthography & script**
   - scripts;
   - normalization;
   - casing behavior;
   - punctuation;
   - diacritics/combining marks;
   - directionality.

2. **Segmentation/tokenization**
   - word/token boundary policy;
   - script-specific segmentation when required;
   - search normalization.

3. **Phonology/pronunciation**
   - pronunciation representation;
   - stress/tone/length or other contrastive features where applicable;
   - pronunciation-to-content linkage;
   - speech locale candidates.

4. **Morphology**
   - inflectional dimensions that actually exist in the language;
   - lemma/form relationships;
   - derivational information only when product capability requires it.

5. **Grammar**
   - sentence/word-order behavior;
   - grammatical categories relevant to the language;
   - validation/explanation strategy;
   - learner-error rules.

6. **Lexical intelligence**
   - accepted forms;
   - senses;
   - collocations;
   - grammatical markers;
   - search/indexing behavior.

7. **Learning behavior**
   - exercise strategy;
   - answer normalization;
   - writing analysis;
   - language-specific assessment constraints.

The shared Core MUST consume capabilities/contracts, not German categories. A language without articles, grammatical gender, plural morphology, case, verb conjugation, whitespace tokenization or capitalization MUST NOT be forced to provide fake German-shaped data.

---

## 7. Grammar and morphology requirements

### 7.1 Universal rule

Universal schemas represent **capabilities and neutral semantic roles**, not a fixed inventory of German grammar fields.

### 7.2 Language-owned feature space

Each language may define typed/validated language-owned grammatical and morphological attributes. Examples may include case, gender, classifier, aspect, evidentiality, tone sandhi, politeness or script variant, but the universal contract MUST NOT require categories that do not exist.

### 7.3 Shared learning projection

Shared UI/learning algorithms may consume neutral fields such as:

- `grammaticalMarker`;
- `acceptedForms`;
- target/source text;
- language-neutral skill/topic/level tags.

Richer morphology stays behind language-specific capability interfaces or versioned language-owned payloads.

### 7.4 Required verification

For a language claiming morphology/grammar support:

- deterministic fixtures;
- valid/invalid form cases;
- Unicode normalization cases;
- ambiguity cases;
- regression set for known learner errors;
- language-expert or authoritative-source review where automated validation is insufficient.

---

## 8. Pronunciation, TTS and speech contract

Speech-related support is optional by capability, never assumed from language registration.

A language speech profile MUST declare:

- TTS locale candidates in priority order;
- STT locale candidates in priority order;
- script/locale mapping;
- pronunciation representation format(s);
- whether phonemic/phonetic/romanized guidance is supported;
- provider/device prerequisites;
- offline availability if any;
- fallback policy;
- quality limitations;
- verification evidence.

Rules:

- no German locale in a universal speech service;
- unsupported TTS/STT returns explicit capability-unavailable state;
- no silent use of another language voice;
- provider independence remains preserved;
- speech capability must be separately verified for device/platform profiles;
- pronunciation content requires provenance and language validation;
- TTS availability alone does not prove pronunciation-learning quality.

The current `SafeTtsController` German voice logic and default `SpeechService(localeId='de_DE')` are shared-surface gaps to be handled by a separately owned implementation task after this spec is approved.

---

## 9. Content and schema contract

### 9.1 Neutral canonical semantic shape

A future universal authoring/runtime boundary SHOULD support at least:

- stable `content_id`;
- target-language text;
- source-language text only when the artifact is pair-owned;
- target example;
- source example only when pair-owned;
- topic/skill;
- level/difficulty metadata;
- accepted target forms;
- neutral grammatical marker(s);
- language-owned linguistic payload;
- pronunciation/audio references;
- provenance;
- review/quarantine status;
- schema version;
- language/pair ownership;
- content-pack version.

### 9.2 Do not mutate compatibility models blindly

Current `ContentItem`, `VerbConjugation` and `content_pack.schema.json` are German/Arabic-shaped compatibility surfaces. They MUST NOT be renamed/rebuilt as a side effect of this proposal.

Migration requires a separate high-risk task that:

- introduces a neutral boundary/adapter;
- preserves stable IDs;
- proves German runtime parity;
- migrates generators/validators before generated artifacts;
- keeps canonical German ownership under `content/german/`;
- prevents `lib/data/generated/` compatibility exports from becoming a competing source of truth.

### 9.3 Language-specific extensions

Language-specific data belongs to the language pack, not Shared Core. A universal schema may reference a versioned language-owned extension but MUST validate its declared language/version.

---

## 10. Golden Sets and Semantic Equivalence

### 10.1 Language Golden Set

Each language claiming a capability needs a versioned Golden Set appropriate to that capability. Coverage should include:

- script/Unicode;
- normalization;
- tokenization;
- representative lexical forms;
- morphology/grammar;
- accepted answers;
- search behavior;
- writing-analysis cases;
- pronunciation/speech fixtures when claimed;
- known ambiguity/edge cases;
- learner-facing localization/product-communication fixtures for every language claiming the `user_language` role, including required-surface coverage and no-silent-fallback cases.

### 10.2 Directed Pair Golden Set

Every production-ready directed pair requires pair-owned fixtures for:

- meaning preservation;
- non-equivalence traps;
- context-sensitive translation;
- contrastive grammar;
- false friends/transfer errors where relevant;
- semantic ambiguity;
- register/politeness where material;
- pair-specific learner errors.

### 10.3 Semantic Equivalence Gate

The gate MUST test meaning preservation for the declared task. Literal surface similarity is insufficient.

Failures that change material meaning, grammatical role, polarity, quantity, tense/aspect, participant, register where required, or instructional intent are release blockers for the affected capability/pair.

No pair can inherit a passing semantic-equivalence gate from another pair.

---

## 11. Role, Pair and Deployment Readiness / Quality Gates

A language role or directed pair may be called `PRODUCTION_READY` only when **every mandatory applicable gate for that exact role or pair passes**. No aggregate language state or score may hide a failed mandatory gate.

Mandatory gates:

1. **Contract Gate** — identity, scripts, declared roles, versions and role-specific lifecycle/readiness records valid.
2. **Capability Gate** — every exposed feature has explicit support state.
3. **User-Language Localization Gate** — mandatory when `user_language` is claimed; required learner-facing localization assets/coverage and no-silent-fallback fixtures pass.
4. **Language Intelligence Gate** — declared normalization/tokenization/grammar/morphology behavior implemented and tested.
5. **Content Gate** — schema, duplicates, Unicode, required linguistic fields, examples, levels and internal consistency pass.
6. **Provenance/IP Gate** — provenance present and licensing/originality review requirements satisfied.
7. **Quarantine Gate** — no quarantined item is published as canonical.
8. **Golden Set Gate** — mandatory language fixtures pass.
9. **Endpoint Role Readiness Gate** — every directed pair requires the source language's `source_language` role and target language's `target_language` role to have independently passed every capability consumed by that direction; pair evidence cannot substitute for an unready endpoint role.
10. **Directed Pair Gate** — pair-dependent features pass pair fixtures.
11. **Semantic Equivalence Gate** — mandatory directed-pair semantic cases pass.
12. **Speech Gate** — required only for capabilities claimed; TTS/STT/pronunciation verified on applicable profiles.
13. **Offline/Loading Gate** — pack load, cache, failure and partial-offline behavior verified, including trusted manifest authenticity and replay/downgrade protection.
14. **Performance Gate** — startup/load/memory/storage/battery/network budgets for language assets pass.
15. **Compatibility Gate** — contract/schema/app compatibility matrix is valid.
16. **Regression Gate** — current German/reference behavior and shared Core remain green.
17. **Release Gate** — current CI/build/checkpoint and applicable independent verification pass.

A readiness report must identify its exact subject (`language_id + role`, directed `pair_id`, or deployment tuple) and show each gate independently.

Production activation is a separate deployment decision keyed by `DEPLOYMENT(user_language, source_language, target_language)`. Its **final** durable assessment MUST occur only after integration, post-merge regression, and checkpoint evidence exist, and MUST bind the exact role-readiness record/evidence fingerprint for all three selected roles, the exact directed-pair readiness record, the compatibility/release policy versions used, the exact **integrated** app/core commit and immutable release-artifact digest, and one deployment-level evidence fingerprint covering the applicable post-merge Compatibility, Regression and Release Gate CI/build/checkpoint results. A pre-integration assessment may establish an integration candidate and handoff only; it MUST NOT be recorded or treated as final `DEPLOYMENT-READINESS`. It MUST require: (a) the selected user's `user_language` role is independently `PRODUCTION_READY` with the User-Language Localization Gate passed; (b) the source endpoint's `source_language` role is independently ready; (c) the target endpoint's `target_language` role is independently ready; and (d) the exact directed pair is independently ready. This user-role gate applies even when the selected user language differs from both pair endpoints. Any change to a bound role, pair, localization/artifact, evidence fingerprint, applicable compatibility/release policy, app/core commit, or release artifact invalidates the deployment assessment. If any tuple member is unavailable, blocked, quarantined, incompatible, stale or unready, activation fails closed without fallback.

---

## 12. Provenance, review and quarantine

Every canonical content artifact must be traceable.

Minimum provenance metadata where applicable:

- artifact/content ID;
- language ID;
- pair ID if pair-owned;
- source type;
- source/reference identifier;
- license/permission classification where applicable;
- authoring/import/generation method;
- generator/model/tool version when generated;
- schema/content-pack version;
- reviewer/review method;
- validation evidence;
- creation/update timestamp;
- quarantine/release state.

Pipeline:

`AUTHOR/IMPORT/GENERATE → PROVENANCE/IP SCREEN → LANGUAGE VALIDATION → SEMANTIC/PAIR VALIDATION → SAFETY → HUMAN REVIEW WHEN REQUIRED → CANONICAL GATES → RELEASE`

Unknown, materially uncertain or conflicting content goes to **QUARANTINE**. It is not guessed into production.

AI-generated content is not automatically original, accurate, licensed, semantically equivalent or publishable.

---

## 13. On-demand loading, caching and offline behavior

The approved scaling model forbids preloading or bundling every language into the base runtime.

A language pack loader must eventually support:

- manifest lookup by language/pair;
- version/hash verification;
- manifest authenticity verification anchored in a trusted release/distribution root (for example a protected signing key or equivalently trusted channel) so a replaced payload and replaced hash cannot authenticate each other;
- replay/downgrade protection: bind authenticated manifest identity to language/pair, pack version, compatibility version and payload hash; enforce a trusted freshness boundary both **before** and **after** any local acceptance. On first install/new device/local-state loss, the loader must have an authenticated bootstrap minimum/epoch, trusted release checkpoint, revocation/freshness proof, or equivalent trusted policy source and must reject an otherwise-valid signed manifest older than that trusted bootstrap boundary. After first acceptance, the effective minimum is the stricter of the trusted bootstrap/current policy boundary and the locally accepted boundary. An explicitly authorized rollback must identify an exact known-good artifact/policy exception rather than permit arbitrary downgrade;
- compatibility check before load;
- bounded memory/storage cache;
- explicit eviction policy;
- atomic pack publication/update;
- interrupted-download recovery;
- stale/corrupt pack rejection;
- rollback only to an exact known-good pack explicitly permitted by the authenticated rollback policy/freshness boundary; ordinary cache history or compatibility alone MUST NOT authorize downgrade;
- partial offline core content where declared;
- explicit unavailable state when required assets are absent.

A language worker owns only its language/pair artifacts. It MUST NOT implement a separate loader/cache subsystem.

Manifest trust roots, signing-key creation/rotation and production distribution credentials are protected release/security concerns and remain human-gated. Language workers consume the verified authenticity contract; they do not mint or rotate production trust material.

Cache availability MUST NOT bypass readiness or compatibility gates.

---

## 14. Compatibility and versioning

At minimum track:

- `universal_language_contract_version`;
- `language_pack_version`;
- `language_intelligence_version`;
- `content_schema_version`;
- `content_pack_version`;
- `learner_localization_bundle_version` when `user_language` is claimed;
- role-readiness artifact/evidence fingerprint;
- `pair_contract_version`;
- `pair_intelligence_version`;
- Golden Set version;
- minimum/maximum compatible app/core version where necessary;
- for every directed-pair pack, the exact or explicitly compatible **source endpoint** language-pack / language-intelligence / content-pack versions it was verified against;
- for every directed-pair pack, the exact or explicitly compatible **target endpoint** language-pack / language-intelligence / content-pack versions it was verified against.

Compatibility must be explicit, not inferred.

A directed-pair artifact MUST NOT activate merely because the pair pack and both endpoint packs are each independently app/core-compatible. The active combination must satisfy the pair pack's verified endpoint-version constraints (or be an explicitly verified atomic bundle). Any material endpoint normalization/content/intelligence version change invalidates stale pair evidence until the new combination is verified.

A pack with unknown/incompatible versions is not loaded as supported. Migration must be deterministic and separately verified.

Backward compatibility must preserve current German IDs, learner state and learning behavior unless a separately approved migration explicitly changes them.

---

## 15. Ready Task Factory

Every multilingual task produced from this spec MUST use this capsule.

### Required fields

```text
TASK_ID:
ACTOR_ID:
OWNER:
SOURCE:                       # durable origin: issue/chat/automation/agent
LANGUAGE_ID:
LANGUAGE_ROLE:                # user_language / source_language / target_language when role-specific
USER_LANGUAGE_ID:             # required for deployment-specific assessment
SOURCE_LANGUAGE_ID:           # if pair-specific
TARGET_LANGUAGE_ID:           # if pair-specific
PAIR_ID:                      # directed, if applicable
DEPLOYMENT_ID:                # USER + directed SOURCE→TARGET tuple, if applicable
USER_ROLE_READINESS_REF:      # exact record ID + artifact/evidence fingerprint for deployment
SOURCE_ROLE_READINESS_REF:    # exact record ID + artifact/evidence fingerprint for deployment
TARGET_ROLE_READINESS_REF:    # exact record ID + artifact/evidence fingerprint for deployment
PAIR_READINESS_REF:           # exact directed-pair record ID + artifact/evidence fingerprint
COMPATIBILITY_POLICY_VERSION: # exact assessed version for deployment
RELEASE_POLICY_VERSION:       # exact assessed version for deployment
APP_CORE_RELEASE_REF:          # exact integrated app/core commit/version + immutable release-artifact digest
DEPLOYMENT_GATE_EVIDENCE_FINGERPRINT: # exact post-merge compatibility/regression/release CI-build-checkpoint evidence
TASK_TYPE:
BRANCH:
PR:                           # PR number/URL when one exists
BASE_REF:
MUTABLE_SCOPE:
PROTECTED_SCOPE:
DEPENDENCIES:
CURRENT_STATE:
OBJECTIVE:
ACCEPTANCE_CRITERIA:
VERIFICATION:
STOP_CONDITIONS:
RECOVERY_PATH:
CHECKPOINT:                   # latest durable checkpoint or NONE
BLOCKER:                      # exact blocker or NONE
LAST_EVIDENCE:
LAST_SEEN:                    # latest durable observation timestamp/evidence
NEXT_ACTION:
```

### Task types

- `LANG-SPEC` — language identity/capabilities only;
- `LANG-INTEL` — language intelligence;
- `LANG-CONTENT` — language-owned content pack;
- `LANG-LOCALIZATION` — learner-facing localization assets/coverage for a claimed `user_language` role;
- `LANG-GOLDEN` — language Golden Set;
- `LANG-SPEECH` — pronunciation/TTS/STT capability;
- `PAIR-SPEC` — directed pair definition;
- `PAIR-INTEL` — contrastive/semantic pair intelligence;
- `PAIR-GOLDEN` — directed pair Golden Set;
- `PAIR-READINESS` — evidence-only final readiness assessment for exactly one directed `SOURCE→TARGET` pair; it does not imply reverse-pair readiness or language-level readiness;
- `LANG-READINESS` — evidence-only final readiness assessment for exactly one declared `LANGUAGE_ID + LANGUAGE_ROLE` and its exact artifact/evidence versions; it does not promote either other roles of the same language or any directed pair;
- `DEPLOYMENT-READINESS` — **final**, evidence-only protected-gate assessment for exactly one `USER_LANGUAGE_ID + SOURCE_LANGUAGE_ID + TARGET_LANGUAGE_ID` tuple. It runs only after integration, post-merge regression, and checkpoint evidence exist. It MUST populate `USER_ROLE_READINESS_REF`, `SOURCE_ROLE_READINESS_REF`, `TARGET_ROLE_READINESS_REF`, `PAIR_READINESS_REF`, `COMPATIBILITY_POLICY_VERSION`, `RELEASE_POLICY_VERSION`, `APP_CORE_RELEASE_REF`, and `DEPLOYMENT_GATE_EVIDENCE_FINGERPRINT` with the exact assessed records/fingerprints/versions, the **integrated** app/core release commit/version plus immutable release-artifact digest, and the exact post-merge Compatibility/Regression/Release CI-build-checkpoint evidence. It never performs production activation itself;
- shared prerequisite tasks such as `ML-CONTRACT`, `ML-SCHEMA`, `ML-LOADER` remain serialized Shared-Core work and are **not language-worker tasks**.

### Definition of Ready for a Language Worker

A language worker is READY only when:

- authoritative multilingual contract version is approved;
- shared prerequisites it depends on are VERIFIED;
- language ID is in the approved expansion plan;
- exact capability scope is declared;
- user/source/target roles are explicit;
- mutable directories/files are language-owned and non-overlapping;
- required authoritative linguistic/content sources are identified;
- acceptance criteria and verification are executable;
- no existing owner/PR holds the same scope.

### Definition of Done

- implementation exists only in the claimed language/pair scope;
- focused tests pass;
- verification required by the task's declared acceptance criteria passes;
- the applicable Golden Set passes when the current task owns, produces, consumes, or explicitly depends on that Golden artifact (including `LANG-GOLDEN`, `PAIR-GOLDEN`, `LANG-READINESS`, `PAIR-READINESS`, and `DEPLOYMENT-READINESS`); predecessor specification/intelligence/content tasks are not blocked by a downstream `LANG-GOLDEN` or `PAIR-GOLDEN` task that has not yet been produced;
- relevant content/provenance gates pass;
- full applicable regression/CI passes;
- no Shared Core pollution is introduced;
- evidence/checkpoint is durable;
- HANDOFF to integration/readiness verifier is recorded;
- directed pair work uses a separate `PAIR-READINESS` assessment for each direction before that pair can advance to `VERIFIED` / `PRODUCTION_READY`;
- a directed pair can advance only after the source endpoint's `source_language` role and target endpoint's `target_language` role independently pass every capability consumed by that direction, in addition to the pair-specific readiness report; `PAIR-READINESS` cannot compensate for an unready endpoint role;
- readiness for one language role never promotes another role of the same language and never implicitly promotes any directed pair;
- when `user_language` eligibility is claimed, localization assets/coverage and localization Goldens are mandatory before that exact `user_language` role can become ready;
- `DEPLOYMENT-READINESS` records the exact selected user/source/target IDs plus the exact role, pair, artifact/evidence and policy versions assessed, and it can complete only after `APP_CORE_RELEASE_REF` identifies the integrated immutable app/core release artifact and `DEPLOYMENT_GATE_EVIDENCE_FINGERPRINT` covers the corresponding post-merge regression and checkpoint evidence;
- deployment activation requires an independently ready selected `user_language` role **and** independently ready source/target endpoint roles **and** the exact directed-pair readiness report; readiness of the pair endpoints does not substitute for a third user language;
- no production-ready claim is made outside the exact role, pair, or deployment tuple proven by its applicable gates.

---

## 16. Safe parallel language workstreams

### 16.1 Contract freeze first

Parallel language implementation begins only after the shared contracts required by those workers are frozen/versioned and verified.

### 16.2 Ownership shape

Preferred ownership:

```text
lib/language/<language>/...
content/<language>/...
tests/language/<language>/...
goldens/language/<language>/...

pairs/<source>__<target>/...
goldens/pairs/<source>__<target>/...
```

The exact paths must follow the repository's approved implementation when created; these examples do not authorize a competing folder architecture.

### 16.3 Shared surfaces are serialized

Language workers do NOT edit:

- shared Core;
- Language Registry implementation;
- Language Factory implementation;
- shared Capability Matrix code/schema;
- global loader/cache;
- project-record/workflows;
- common compatibility migrations;
- global UI contracts.

If a language exposes a missing universal capability, the worker files a bounded shared-gap handoff. It does not patch the Core from its language branch.

### 16.4 Parallel dependency model

Safe sequence:

```text
AUTHORITATIVE CONTRACT
  ↓
SHARED PREREQUISITES VERIFIED
  ↓
LANG-SPEC tasks in parallel
  ↓
LANG-INTEL / LANG-CONTENT / LANG-GOLDEN in parallel per language
  ↓
PAIR-SPEC / PAIR-INTEL / PAIR-GOLDEN per directed pair
  ↓
LANGUAGE-ROLE / PAIR READINESS
  ↓
PRE-INTEGRATION READINESS ASSESSMENT / INTEGRATION HANDOFF
  ↓
INTEGRATION LANE
  ↓
POST-MERGE REGRESSION
  ↓
CHECKPOINT
  ↓
FINAL `DEPLOYMENT-READINESS` (USER + SOURCE→TARGET; integrated artifact-bound)
  ↓
PRODUCTION ACTIVATION (separate protected gate)
```

No worker may skip from registration directly to production activation, and no deployment may activate from endpoint/pair readiness without independently gating the selected `user_language` role.

---

## 17. Queue state after this audit

### 17.1 Language Worker READY queue

**EMPTY — intentionally.**

Reason: the current authoritative project state says an authoritative 20-language specification is required before expansion, and the current repository still has shared blockers G2–G13 above. This proposal itself is not yet authority to spawn production language workers.

This is a safety result, not a lack of progress.

### 17.2 Shared prerequisite handoff queue

These are the next real multilingual-readiness tasks after this proposal is reviewed. They are **PROPOSED / NOT CLAIMED BY CHAT-5 FOR CODE MUTATION**:

| TASK_ID | Type | Mutable scope | Dependency | Acceptance | Verification |
|---|---|---|---|---|---|
| `ML-CONTRACT-001` | shared contract | existing language-contract/shared model surfaces | approval of this spec | source/user/target separation + directed-pair identifiers + capability/lifecycle model | focused contract tests + full architecture/regression |
| `ML-REGISTRY-CAPABILITY-001` | shared foundation | one existing approved registry/capability implementation path | ML-CONTRACT-001 | one registry, fail-closed lifecycle/capabilities, no language activation from registration | unit/property tests + architecture drift gate |
| `ML-SCHEMA-NEUTRAL-001` | shared data boundary | content schema/adapter/generator sources | ML-CONTRACT-001 | neutral schema boundary preserving German IDs/parity; no direct destructive model rewrite | compiler parity + content gates + German regression |
| `ML-PAIR-CONTRACT-001` | shared pair foundation | approved pair boundary only | ML-CONTRACT-001 | directed A→B identity, no implicit reverse, no bridge fallback | pair contract tests + negative cases |
| `ML-SPEECH-BOUNDARY-001` | shared speech | TTS/STT language config boundary | ML-CONTRACT-001 | remove hard-coded German from universal service path without behavior regression | speech/TTS focused tests + German parity |
| `ML-GOLDEN-READINESS-001` | verification foundation | tests/golden/readiness tooling | contract + capability model | per-language/per-pair mandatory gates, no aggregate masking | synthetic fixtures proving pass/fail/quarantine |
| `ML-LOADER-CACHE-001` | shared runtime | approved loader/cache boundary | registry + compatibility/versioning | on-demand load, bounded cache, trusted manifest authenticity, replay/downgrade protection, corrupt/incompatible rejection, partial-offline rules | fault/security tests + performance/resource budgets |
| `ML-COMPAT-VERSION-001` | shared compatibility | version/compatibility boundary | contract/schema definitions | explicit version matrix and fail-closed incompatible packs | migration/compatibility tests |

Each task requires independent ownership reconciliation before mutation.

### 17.3 First-language candidate queue

**No named new language is marked READY in this proposal.**

The planned set recorded in the Master Project Source is a planning set, not an implementation priority order. Selecting the first expansion wave needs evidence for:

- product/market priority;
- availability of authoritative linguistic/content sources;
- reviewer/quality capacity;
- speech/provider feasibility;
- script/architecture coverage value;
- pair demand;
- cost/performance constraints.

Once the shared prerequisites are VERIFIED and a first wave is explicitly approved, the task factory above can instantiate independent language tasks without changing Shared Core.

---

## 18. Current German reference-readiness audit

German is useful as the conformance reference.

### Already evidenced

- dedicated language pack;
- dedicated content pack;
- language-specific normalizer;
- language-specific content quality/intelligence;
- language-specific exercise strategy/presentation;
- canonical German content namespace;
- neutral LearningContent projection;
- current composition-root language selection;
- extensive historical/current regression infrastructure.

### Must be reconciled before using German as universal-contract certification

- source locale must no longer be owned by target-language identity;
- German/Arabic-specific authoring/schema compatibility surface must gain a neutral boundary;
- TTS/STT hard-coded German behavior must be behind language-owned speech capability;
- German writing analysis/enrichment must be clearly language-owned or capability-scoped;
- German language Golden Set must be explicit under the new contract;
- Arabic→German pair Golden Set/readiness must be explicit and directed;
- German→Arabic cannot be inferred from Arabic→German;
- compatibility/readiness versions must be explicit.

German should be used to prove backward compatibility of the universalization work, not rewritten to fit a theoretical model.

---

## 19. Architecture drift prevention

After shared implementation is approved, high-value automated invariants should include:

- no target LanguagePack hard-codes a source/user language;
- no Shared Core imports a concrete language implementation;
- no universal TTS/STT service hard-codes German/English locale;
- no registry entry or aggregate language state alone exposes any language role as production-ready;
- no readiness transition for one language role promotes another role;
- no deployment activates unless a fresh `DEPLOYMENT-READINESS` record binds the selected user role, source role, target role, exact directed pair and exact consumed artifact/evidence/policy versions;
- no `A→B` pair auto-creates or marks `B→A` ready;
- no silent English/German bridge;
- no canonical content outside its declared language owner;
- no generated compatibility output becomes canonical source;
- no mandatory readiness gate is hidden by an aggregate score;
- no language worker modifies serialized shared surfaces without handoff.

Only stable approved invariants should become tests; do not encode temporary historical wording.

---

## 20. Handoff decision

This audit finds that multilingual expansion is **architecturally intended and partially prepared, but not yet worker-ready**.

The correct next step is:

1. review/approve or amend this proposal as the authoritative multilingual expansion contract;
2. route the shared prerequisite tasks to one-owner serialized scopes;
3. verify those foundations against the existing German runtime;
4. only then instantiate the first approved language wave through the task factory;
5. maintain independent directed-pair readiness and never infer reverse support;
6. keep production activation behind its own readiness/release gate.

**No new production language was activated by CHAT-5. No Shared Core or German canonical content was modified.**
