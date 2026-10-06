# DEUTSCH بالعربي — Production Persistence Authority Map

**Task:** 6A — Persistence Authority Map  
**Baseline:** `main@56be6496b1e19c8a664e6835bf980fcf22f6d795`  
**Specification version:** 1  
**Behavior change:** NONE  
**Status:** Normative persistence ownership specification

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
| **Global XP** | `gamification.sqlite → gamification_profile.total_xp` through `SqliteGamificationRepository` | `v34_state.xp` is **legacy migration seed only**, not a valid authority after gamification initialization | Canonical gamification event transaction first. No independent learner-state XP write is permitted after cutover. | If gamification DB is pristine, legacy `v34_state.xp` may seed it once through `migrateLegacyProfileIfPristine()`. Once any gamification state/event exists, SQLite wins permanently. | `GamificationReviewEvent.reviewId` → `gamification_review_events.event_id` | Gamification DB **v3**; legacy source `v34_state`; pristine migration currently has no explicit migration marker | **DRIFT RISK:** normal review paths still update `LearnerState.xp`; `recordConversationAttempt()` also increments learner XP without a gamification event. Must be reconciled in a later behavior-change task. |
| **Streak** | `gamification.sqlite → gamification_profile.current_streak / longest_streak` | `v34_state.streak` is **legacy migration seed only** | Gamification event and profile update occur atomically in SQLite. No post-cutover learner-state streak writer. | Legacy streak may seed a completely pristine gamification DB once. Otherwise SQLite profile/event history wins. | Same `reviewId/event_id` used by the triggering review | Gamification DB **v3**; legacy `v34_state` seed | **DRIFT RISK:** `LearnerRepository.record()` still computes and writes `state.streak` before recording gamification. Quick-review production reads already use canonical gamification streak. |
| **Learned IDs** | `pair_progress_v2.db → pair_card_progress.learned` | `v34_state.learned` is **pre-bind migration staging only** | Before pair authority exists, placement/legacy code may stage state in learner JSON. During binding: migrate into pair DB → successful pair commit → clear learner `learned/review/reviewCards`. After binding: pair DB only. | If target pair contains any canonical pair/card rows, do not import learner legacy progress over it. Pair DB wins. | Entity key: `(source_language_id, target_language_id, card_id)`. Logical review replay also requires a stable review operation ID in a future implementation. | Pair progress schema **v2**; legacy source `v34_state` | **COMPLIANT authority boundary:** `_withoutLegacyPairProgress()` strips this field from SharedPreferences after pair binding. |
| **Review cards** | `pair_progress_v2.db → pair_card_progress` | `v34_state.reviewCards` is **legacy/pre-bind staging only** | Load canonical pair card → schedule with unified SRS → commit updated card in pair SQLite transaction. Never mirror it back to learner JSON after binding. | Pair DB wins whenever pair authority exists. Legacy review cards may migrate only into an empty target pair. | Canonical entity identity: `(pair, ReviewFacetKey.storageKey)`. Required logical mutation idempotency: stable review/attempt ID; current pair schema does not yet persist one. | Pair progress schema **v2**, including Phase16b SRS columns | **PARTIALLY COMPLIANT:** single card authority exists after bind; replay protection for additive pair mutations is still missing. |
| **Raw attempts** | `SharedPreferences → v34_state.attempts` through `LearnerPersistence` | None. `MemoryAgentSnapshot.tasks[].attempts` is an aggregate in a separate domain and must never replace raw attempts. | Build stable `Attempt` → normalize bounded payload → `prefs.setString(v34_state)` must succeed → update repository cache. | Invalid individual records are discarded without discarding all history. Maximum 2000 records. A failed canonical write must not be represented as a successful attempt. | `Attempt.id` (`a_*`, `f_*`, `c_*`, `w_*`). Retried writes must eventually dedupe by this ID; current list persistence does not enforce dedupe. | Learner JSON **`v34_state`**; no embedded schemaVersion | **GAP:** physical schema version is implicit in the preference key and attempt IDs are not currently deduplicated on persistence. |
| **Favorites (production learner verb favorites)** | `SharedPreferences → v34_state.favoriteVerbs` | `verb_favorites_v1` is **migration source only** | Normal write: mutate canonical set → normalize/save `v34_state` → update cache. Legacy migration: merge legacy values → save canonical successfully → delete legacy key. | Never delete `verb_favorites_v1` before canonical save succeeds. If both survive after interrupted migration, merge bounded values and retry migration. | Entity key: normalized verb infinitive. Retry-safe mutation contract should be `(infinitive, desiredMembership)`; current toggle API itself is not retry-idempotent. | Canonical `v34_state`; legacy `verb_favorites_v1` | **CANONICAL ownership already established**, but toggle semantics need explicit idempotent command semantics in a later task. |
| **Placement history** | `SharedPreferences → v34_state.placementHistory` | None | Produce `PlacementDiagnosticRecord` → replace/dedupe same record ID → prepend bounded history → canonical save → cache update. | Corrupt records are ignored. Keep max 20. Production onboarding reads this canonical history. | `PlacementDiagnosticRecord.id`, currently typically `placement_<microsecondsSinceEpoch>` | Learner JSON `v34_state` | **COMPLIANT.** `recordPlacementDiagnostic()` and `LearnerPlacementProfileRepository` both write the same canonical learner store. |
| **Assessment history** | `SharedPreferences → v34_state.assessmentHistory` | None | Build normalized `AssessmentHistory` → canonical save → cache update. | Corrupt records are ignored; history bounded to 100. No secondary store may override it. | `AssessmentHistory.id` / source `AssessmentResult.id` | Learner JSON `v34_state` | **GAP:** `recordAssessment()` prepends records but currently does not dedupe by ID, so retry may duplicate history. |
| **Pair progress** | `pair_progress_v2.db → pair_progress + pair_card_progress` | None. Learner `learned/review/reviewCards` are migration sources only. Agent task progress is a separate domain. | Pair-level and card-level mutations occur inside a SQLite transaction. Pair row and card row commit atomically. | Existing canonical pair/card data prevents legacy snapshot migration. Never resolve pair DB from learner JSON after canonical pair state exists. | Pair aggregate: `(source_language_id,target_language_id)`. Card identity: `(source_language_id,target_language_id,card_id)`. Additive review mutations still require a future stable operation/event ID. | `PairProgressDatabase.schemaVersion = 2`; file `pair_progress_v2.db` | **CANONICAL**, but additive `achievement_points/correct_count/incorrect_count` currently have no durable operation dedupe key. |
| **SRS facet state** | `pair_progress_v2.db → pair_card_progress.{facet_type,variant_key,repetitions,interval_days,lapses,successes,failures,difficulty,stability_days,due_at_utc,last_reviewed_at_utc}` | `v34_state.reviewCards` only before/while legacy migration | Read current facet card from pair DB → run `unifiedSrsScheduler` → write scheduled state atomically to pair DB. | Pair DB is authoritative. If target pair is non-empty, legacy state cannot overwrite it. Invalid legacy cards are rejected during normalization/migration. | Entity: `pairKey + ReviewFacetKey.storageKey`. Logical review operation must eventually be keyed by stable `Attempt.id/reviewId` to prevent double scheduling on retry. | Pair DB **v2** | **CANONICAL scheduler/store relationship is established.** Durable mutation idempotency is the remaining gap. |
| **Gamification audit/events** | `gamification.sqlite → gamification_review_events` | None | Within one SQLite transaction: reject duplicate `event_id` → read profile/unlocked badges → compute transition → insert immutable event → update profile projection → insert newly unlocked badges → commit. | Duplicate `event_id` is a no-op. Partial event/profile/badge state cannot commit because all writes share one transaction. Future repair should rebuild projections from canonical event history rather than from learner XP/streak. | `event_id = GamificationReviewEvent.reviewId` | Gamification DB **v3** | **COMPLIANT idempotency boundary.** |
| **Gamification profile projection** | `gamification.sqlite → gamification_profile` | Event table is the audit ledger, not a competing writer. `v34_state.xp/streak` are legacy migration seeds only. | Updated only as part of the same transaction that accepts the canonical review event. | If a future integrity repair is required, event history is the reconstruction input. Legacy learner fields may only initialize a pristine DB. | Projection version is implied by accepted `event_id`s | Gamification DB **v3** | **CANONICAL read authority** for XP/streak in production-facing gamification consumers. |

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

`SecureLocalGamificationRepository` implements the gamification interface but
has no production construction path at the audited baseline. It is therefore
not a concurrent production authority. If it is activated in the future, it
requires an explicit one-way authority migration; it must never run beside
`SqliteGamificationRepository` for the same profile.

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

## 9. Known authority violations to resolve after TASK 6A

| ISSUE | CURRENT STATE | REQUIRED FUTURE STATE |
|---|---|---|
| Global XP dual writing | `LearnerState.xp` and `gamification_profile.total_xp` both mutate | Only gamification SQLite writes global XP |
| Streak dual writing | `LearnerState.streak` and gamification profile both mutate | Only gamification SQLite writes streak |
| Conversation XP | `recordConversationAttempt()` modifies learner XP without gamification event | Route award through canonical gamification event |
| Pair review replay | pair achievement/correct/incorrect counters are additive with no review-event dedupe | Persist stable applied-operation/review ID |
| Raw attempt replay | `Attempt.id` exists but JSON list does not dedupe | Enforce exactly-once append by ID |
| Assessment retry | `AssessmentHistory.id` exists but `recordAssessment()` does not remove same-ID record before prepend | Dedupe/upsert by result ID |
| Favorite toggle retry | toggle operation is not idempotent | Persist desired membership or command/event ID |
| Learner JSON schema | `v34_state` encodes version only in key name | Future migration should use explicit payload schema version before next structural change |

These are implementation findings, not authorization to change behavior in
TASK 6A.

---

## 10. Final Single Source of Truth declaration

The authoritative production ownership model is:

| DOMAIN | AUTHORITY |
|---|---|
| XP / streak / gamification badges and profile | `SqliteGamificationRepository` / `gamification.sqlite` |
| Gamification event audit | `gamification_review_events` |
| Pair-scoped concept progress | `PairProgressDatabase` / `pair_progress_v2.db` |
| SRS facet/card state | `PairProgressDatabase` / `pair_card_progress` |
| Raw attempts | `LearnerPersistence` / `v34_state.attempts` |
| Assessment history | `LearnerPersistence` / `v34_state.assessmentHistory` |
| Placement history | `LearnerPersistence` / `v34_state.placementHistory` |
| Verb favorites | `LearnerPersistence` / `v34_state.favoriteVerbs` |
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
