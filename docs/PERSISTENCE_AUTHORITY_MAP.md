# DEUTSCH بالعربي — Production Persistence Authority Map

**Task:** 6A — Persistence Authority Map
**Baseline:** `main@56be6496b1e19c8a664e6835bf980fcf22f6d795`
**Specification version:** 4
**Behavior change:** TASK 6B/6C/6D convergence implemented
**Status:** Normative persistence ownership specification, reconciled through TASK 6D

---

## 1. Purpose

This document defines exactly one authoritative durable source for every
production learner-state domain.

A store may be one of:

- **CANONICAL** — the only source allowed to win reads/conflicts.
- **MIRROR** — derived from the canonical value; never authoritative.
- **MIGRATION SOURCE** — read only during a bounded one-way migration.
- **DERIVED CACHE** — rebuildable from another canonical source.
- **SEPARATE DOMAIN** — durable data that resembles another entity but has
  different semantics and must never be used as its authority.

No two durable stores may independently mutate the same logical entity.

---

## 2. Global authority rules

A canonical store wins every conflict.

A mirror must never overwrite canonical state based only on timestamp,
non-zero value, record count, or apparent freshness.

A migration source becomes non-authoritative immediately after successful
migration. Migration is one-way unless a separately versioned reverse
migration is explicitly designed.

Every cross-store logical review operation must eventually use one stable
operation identifier across all participating stores. Retrying the same
logical operation must not award XP twice, advance SRS twice, increment
counters twice, or create duplicate history.

Derived caches may be deleted and regenerated without learner-data loss.

Content persistence and learner-state persistence are separate authority
domains.

---

## 3. Durable learner-state authority matrix

| ENTITY | CANONICAL STORE | MIRROR STORE | WRITE ORDER | RECOVERY RULE | IDEMPOTENCY KEY | MIGRATION VERSION | CURRENT IMPLEMENTATION STATUS |
|---|---|---|---|---|---|---|---|
| **Global XP** | `gamification.sqlite → gamification_profile.total_xp` through `SqliteGamificationRepository` | `v34_state.xp` is an immutable **legacy seed/rollback buffer only** and is not exposed by normal `LearnerPersistence.load()` reads | New reward operations are accepted as idempotent gamification events; profile mutation and revision increment occur in the same SQLite transaction. Learner attempts never award XP. | Legacy XP may seed only while `gamification_store_meta.revision == 0` and profile/events/badges are pristine. Successful seed or any accepted event advances revision and permanently blocks reseeding. | `GamificationReviewEvent.reviewId` → `gamification_review_events.event_id` | Gamification DB **v4**; durable `gamification_store_meta.revision`; legacy source `v34_state` | **COMPLIANT after TASK 6D:** `SqliteGamificationRepository` is the sole production XP writer; conversation rewards use the same event ledger. |
| **Streak** | `gamification.sqlite → gamification_profile.current_streak / longest_streak` | `v34_state.streak` is an immutable **legacy seed/rollback buffer only** and is not exposed by normal learner-state reads | Streak transition is computed only by the gamification engine and committed with the accepted event/profile/revision transaction. | Legacy streak may seed only at revision 0 on a pristine gamification store. After revision advances, SQLite profile wins and stale legacy fallback/reseed is forbidden. | Same stable `reviewId/event_id` used by the triggering review | Gamification DB **v4**; durable revision contract | **COMPLIANT after TASK 6D:** no learner-state streak writer remains in the production review/conversation paths. |
| **Learned IDs** | `pair_progress_v2.db → pair_card_progress.learned` | `v34_state.learned` is **pre-bind migration staging only** | Before pair authority exists, placement/legacy code may stage state in learner JSON. During binding: migrate into pair DB → successful pair commit → clear learner `learned/review/reviewCards`. After binding: pair DB only. | If target pair contains any canonical pair/card rows, do not import learner legacy progress over it. Pair DB wins. | Entity key: `(source_language_id, target_language_id, card_id)`. Logical review replay also requires a stable review operation ID in a future implementation. | Pair progress schema **v2**; legacy source `v34_state` | **COMPLIANT authority boundary:** `_withoutLegacyPairProgress()` strips this field from SharedPreferences after pair binding. |
| **Review cards** | `pair_progress_v2.db → pair_card_progress` | `v34_state.reviewCards` is **legacy/pre-bind staging only** | Load canonical pair card → schedule with unified SRS → commit updated card in pair SQLite transaction. Never mirror it back to learner JSON after binding. | Pair DB wins whenever pair authority exists. Legacy review cards may migrate only into an empty target pair. | Canonical entity identity: `(pair, ReviewFacetKey.storageKey)`. Required logical mutation idempotency: stable review/attempt ID; current pair schema does not yet persist one. | Pair progress schema **v2**, including Phase16b SRS columns | **PARTIALLY COMPLIANT:** single card authority exists after bind; replay protection for additive pair mutations is still missing. |
| **Raw attempts** | `learner_state.sqlite → learner_attempts` through `LearnerStateDatabase` | `v34_state.attempts` is retained as legacy rollback material only | Stable `Attempt.id` → exactly-once SQLite append/upsert contract → hydrated synchronous cache. Attempt persistence is XP/streak-neutral. | Verified TASK 6C cutover uses transactional migration + SHA-256 read-back. After cutover revision advances, stale legacy fallback is forbidden. | `Attempt.id`, including review/conversation stable event IDs | Learner DB **v1**; legacy source `v34_state` | **COMPLIANT after TASK 6C/6D.** |
| **Favorites (production learner verb favorites)** | `learner_state.sqlite → learner_favorite_verbs` | `v34_state.favoriteVerbs` and `verb_favorites_v1` are preserved legacy rollback/migration inputs | Persist explicit desired membership with a discrete SQLite operation; hydrate synchronous learner cache after success. | TASK 6C migration is all-or-nothing and keeps both legacy sources untouched. Post-cutover SQLite revision prevents stale legacy fallback. | `(normalized verb, desiredMembership)` | Learner DB **v1** | **COMPLIANT after TASK 6C.** |
| **Placement history** | `learner_state.sqlite → learner_placement_history` and bounded child tables | `v34_state.placementHistory` is legacy rollback material only | Strict validated record → idempotent SQLite insert by ID → bounded retention → cache hydration. | TASK 6C transactional migration/read-back verification prevents partial authority. | `PlacementDiagnosticRecord.id` | Learner DB **v1** | **COMPLIANT after TASK 6C.** |
| **Assessment history** | `learner_state.sqlite → learner_assessment_history` and weak-skill child rows | `v34_state.assessmentHistory` is legacy rollback material only | Strict validated record → idempotent SQLite insert by ID → bounded retention → cache hydration. | TASK 6C transactional migration/read-back verification prevents partial authority. | `AssessmentHistory.id` | Learner DB **v1** | **COMPLIANT after TASK 6C.** |
| **Pair progress** | `pair_progress_v2.db → pair_progress + pair_card_progress + review_transaction_journal` | None. Learner `learned/review/reviewCards` are migration sources only. Agent task progress is a separate domain. | Pair/SRS mutation and stable review outbox acceptance occur atomically; journal-only deliveries support non-SRS review rewards such as conversation. | Existing canonical pair/card data prevents legacy snapshot overwrite; pending journal rows reconcile boundedly after restart. | Stable `review_event_id` plus payload SHA-256; entity keys remain directed pair/card keys | `PairProgressDatabase.schemaVersion = 3`; file remains `pair_progress_v2.db` | **COMPLIANT after TASK 6B/6D.** |
| **SRS facet state** | `pair_progress_v2.db → pair_card_progress.{facet_type,variant_key,repetitions,interval_days,lapses,successes,failures,difficulty,stability_days,due_at_utc,last_reviewed_at_utc}` | `v34_state.reviewCards` only before/while legacy migration | Read canonical card → schedule → atomically persist SRS mutation and stable review journal acceptance. | Pair DB wins; replay with the same event ID/payload is benign, while ID/payload mismatch fails closed. | `review_event_id` + payload SHA-256, scoped card identity via `ReviewFacetKey.storageKey` | Pair DB **v3** | **COMPLIANT after TASK 6B.** |
| **Gamification audit/events** | `gamification.sqlite → gamification_review_events` | None | Within one SQLite transaction: validate duplicate payload → insert immutable event → update profile/badges → increment durable revision. | Exact duplicate `event_id` is a no-op; mismatched duplicate payload fails closed. Crash replay is safe through the TASK 6B journal reconciler. | `event_id = GamificationReviewEvent.reviewId` | Gamification DB **v4** | **COMPLIANT.** |
| **Gamification profile projection** | `gamification.sqlite → gamification_profile` | Event table is the audit ledger; `v34_state.xp/streak` are immutable seed/rollback inputs only | Updated only in `SqliteGamificationRepository` as part of accepted event/seed transactions. | `gamification_store_meta.revision` blocks reseeding once any canonical mutation has occurred. Production readers use the gamification profile, never learner XP/streak. | Projection is advanced by accepted event IDs and durable revision | Gamification DB **v4** | **SOLE XP/STREAK AUTHORITY after TASK 6D.** |

---

## 4. Cross-store review transaction contract

A single learner review currently touches multiple persistence domains.

The normative authority sequence for a future implementation is:

| STEP | AUTHORITY | REQUIRED PROPERTY |
|---|---|---|
| 1 | Logical review operation | Generate one stable review/attempt ID once. Retrying the operation must reuse it. |
| 2 | Pair/SRS authority | Apply scheduler result to `PairProgressDatabase` using replay protection tied to that operation ID. |
| 3 | Attempt history | Persist raw `Attempt` exactly once using the same logical ID. |
| 4 | Gamification | Record `GamificationReviewEvent(reviewId: sameId)`; duplicate event is a no-op. |
| 5 | Derived diagnostics/agents | Update non-authoritative projections only after canonical learning state is durable, or make the projection independently replayable. |

The current implementation does **not** yet satisfy the complete replay contract:
pair/SRS additive counters do not persist a review-operation ID, learner attempt
history does not deduplicate by `Attempt.id`, and learner XP/streak remain
independent writers.

Those are implementation tasks after 6A; this document itself changes no
runtime behavior.

---

## 5. Additional production-reachable durable state

The production root contains another persistence mechanism not present in the
original four-store inventory.

### System-agent local state

Physical storage:

`SharedPreferences → sys_memory_agent_v1`

Container:

`RuntimeLocalStateContainer.schemaVersion = 1`

Namespaces include at least:

- `memory`
- `progress`
- validation cache

### Agent task progress authority

| FIELD | VALUE |
|---|---|
| **CANONICAL STORE** | `sys_memory_agent_v1 → RuntimeLocalStateContainer["progress"] → OfflineProgressSnapshot` |
| **MIRROR STORE** | `memory` namespace contains related task aggregates, but is a separate agent-memory projection rather than pair/SRS authority |
| **WRITE ORDER** | mutate in-memory `OfflineProgressSnapshot` → serialize namespace → write complete namespaced container to SharedPreferences → emit change |
| **RECOVERY RULE** | invalid/unknown payload decodes to empty safe state; schema v1 progress is migrated to v2; failed migration leaves original physical payload for retry |
| **IDEMPOTENCY KEY** | task record key = directed pair + `taskId`; additive `pointsDelta` is not operation-idempotent and therefore must not be replayed blindly |
| **MIGRATION VERSION** | `OfflineProgressSnapshot.schemaVersion = 2`, legacy = 1; outer container schema = 1 |

This domain owns **curriculum task execution summary only**:
`points`, `bestScore`, `completed`, task mastery and timestamps.

It MUST NOT become authoritative for:

- global XP;
- streak;
- raw learner attempts;
- learned concept IDs;
- review cards;
- SRS due dates/facets;
- `PairProgressDatabase` card mastery.

Likewise, `MemoryAgentSnapshot.tasks[].attempts` is an aggregate count, not
the canonical raw `Attempt` history.

---

## 6. Indexed corpus authority

The indexed corpus is durable, but it is **content persistence**, not learner
progress.

| FIELD | VALUE |
|---|---|
| **CANONICAL STORE** | Authenticated installed pack `content.sqlite`, encrypted with SQLCipher and opened read-only after admission/provenance checks |
| **MIRROR STORE** | Derived indexed SRS SQLCipher database `srs-corpus-v1-<contentSha256>.sqlite`; this is a rebuildable projection/cache |
| **WRITE ORDER** | verify installed-pack provenance/encryption/metadata/cardinality → open canonical source read-only → build `<derived>.building` → migrate bounded data → close → atomic rename → reopen and verify |
| **RECOVERY RULE** | Any unverifiable derived corpus is deleted and rebuilt from the admitted signed source. If the source pack itself fails admission, use the explicit embedded fallback path; never repair learner state from corpus data. |
| **IDEMPOTENCY KEY** | source `contentSha256` + `SrsCorpusContract.schemaVersion` |
| **MIGRATION VERSION** | `SrsCorpusContract.schemaVersion = 2`; derived filename prefix currently `srs-corpus-v1-` |

No learner-owned mutable state may be written into either the signed source
pack or the derived indexed corpus.

---

## 7. Stores explicitly denied authority

`SecureLocalGamificationRepository` was removed in TASK 6D because it had no
production consumer and retained a competing XP/streak write implementation.
No alternate local gamification writer may coexist with
`SqliteGamificationRepository`.

`ProgressTrackerService` contains historical SQLite tables such as
`daily_streaks`, `review_scores`, and `spaced_repetition`, but no production
consumer was found in the current root graph. It is not an authority for
streak or SRS.

The historical vocabulary `FavoritesRepository` is not the canonical
production learner verb-favorites authority. `LearnerState.favoriteVerbs`
under `v34_state` remains authoritative for the mapped entity.

Legacy UI/application shells are not persistence authorities merely because
they can read retained compatibility repositories.

---

## 8. Migration precedence

### Learner pair progress

`v34_state.learned/review/reviewCards`
→ `PairProgressDatabase v2`
→ clear legacy pair-progress fields from learner persistence.

Migration is allowed only when the target pair is empty.

### Verb favorites

`verb_favorites_v1`
→ merge into `v34_state.favoriteVerbs`
→ persist canonical learner state successfully
→ remove `verb_favorites_v1`.

### Gamification

`v34_state.xp/streak`
→ `gamification.sqlite v3`

only when gamification profile/events/badges are pristine.

After this cutover, learner XP/streak must never win a conflict.

### Agent task progress

`OfflineProgressSnapshot v1`
→ `OfflineProgressSnapshot v2`

inside `sys_memory_agent_v1`, preserving the physical source if migration
write fails.

### Indexed corpus

signed/encrypted pack content
→ derived SRS corpus schema v2.

The derived database is disposable and rebuildable.

---

## 9. Persistence convergence status after TASK 6D

| ISSUE | RESOLUTION |
|---|---|
| Global XP dual writing | **RESOLVED 6D** — only `SqliteGamificationRepository` mutates XP. |
| Streak dual writing | **RESOLVED 6D** — only the gamification event/profile transaction mutates streak. |
| Conversation XP | **RESOLVED 6D** — conversation uses stable journal delivery + canonical gamification event. |
| Pair review replay | **RESOLVED 6B** — stable review event journal with SHA-256 replay validation. |
| Raw attempt replay | **RESOLVED 6B/6C** — stable Attempt ID and SQLite exactly-once sink. |
| Assessment retry | **RESOLVED 6C** — SQLite ID/payload idempotency. |
| Favorite retry | **RESOLVED 6C** — explicit desired membership SQLite operation. |
| Learner JSON structural authority | **RESOLVED 6C** for attempts/assessment/placement/favorites; JSON remains bounded legacy rollback material. |

---

## 10. Final Single Source of Truth declaration

The authoritative production ownership model is:

| DOMAIN | AUTHORITY |
|---|---|
| XP / streak / gamification badges and profile | `SqliteGamificationRepository` / `gamification.sqlite` v4 |
| Gamification event audit | `gamification_review_events` |
| Pair-scoped concept progress | `PairProgressDatabase` / `pair_progress_v2.db` |
| SRS facet/card state | `PairProgressDatabase` / `pair_card_progress` |
| Raw attempts | `LearnerStateDatabase` / `learner_state.sqlite → learner_attempts` |
| Assessment history | `LearnerStateDatabase` / `learner_state.sqlite → learner_assessment_history` |
| Placement history | `LearnerStateDatabase` / `learner_state.sqlite → learner_placement_history` |
| Verb favorites | `LearnerStateDatabase` / `learner_state.sqlite → learner_favorite_verbs` |
| Curriculum task/agent progress | `OfflineProgressService` under `sys_memory_agent_v1` |
| Signed content | admitted encrypted pack `content.sqlite` |
| Runtime indexed corpus | rebuildable derived SQLCipher SRS corpus; never learner authority |

Any store not listed as canonical above is forbidden from winning a conflict
for that entity.

---

## 11. TASK 6A exit status

The persistence authority map now documents every identified
production-reachable durable state domain and explicitly separates:

- canonical learner state;
- legacy migration state;
- mirrors/projections;
- agent/task progress;
- immutable content;
- rebuildable corpus indexes.

No runtime behavior is changed by this specification.

Remaining dual writers are explicitly recorded as implementation debt for the
next persistence-convergence task rather than silently treated as legitimate
authorities.
