# TASK 8 — Search Authority Consolidation

**Baseline:** `main@11ece8cecd0dd7b4f085de8339849e567e8d3bfc`
**Task:** TASK 8 — Search Authority Consolidation
**Status:** Production search authority frozen; runtime behavior preserved
**Persistence/data migration:** None

## 1. Purpose

This record establishes one search authority for the shipped architecture and
prevents the historical resident-corpus search graph from becoming a second
production search engine.

The task is a topology consolidation, not a feature expansion. At the audited
baseline the Phase3 production closure does not wire a search screen. Therefore
there is no production legacy-search caller to migrate in this task and no
justification for introducing new UI wiring merely to perform a migration.

Future production search wiring must enter through the canonical bounded
repository declared below.

## 2. CANONICAL PRODUCTION SEARCH AUTHORITY

The only approved content-search authority for production wiring is:

`IndexedSrsCorpusRepository.searchContent`
→ `OfflineLexiconSearchRepository`
→ feature/application consumer.

Physical/query authority:

`lib/features/srs/corpus_sqlite_repository.dart`

Production adapter:

`lib/features/lexicon_search/data/offline_lexicon_search_repository.dart`

The adapter delegates query execution to the admitted indexed SQLite corpus. It
does not own a full corpus list, token map, trigram map, or a second CEFR source.

The indexed corpus is a rebuildable content projection as defined by the
persistence authority map. Search must not write learner progress, SRS, XP,
streak, attempts, favorites, or canonical pack content.

## 3. Bounded-query contract

The SQLite search boundary is intentionally finite:

- result limit is clamped to **1..200**;
- at most **6** normalized search terms are admitted per query;
- each admitted term is at most **200** characters;
- CEFR filtering accepts only the runtime-supported **A1, A2, B1, B2** set;
- article filtering accepts only **der, die, das**;
- SQL applies an explicit parameterized `LIMIT ?`;
- only selected rows are hydrated.

Unknown or unsupported filter values do not widen the query. The feature
adapter returns no results for unsupported CEFR requests instead of fabricating
a level or silently broadening the search.

## 4. Language and pair semantics

The current `lexicon_search` adapter is the German-learning feature boundary;
its German/Arabic projection is not a generic Shared Core language contract.

This distinction is mandatory:

- a pair/language-owned adapter may apply German-specific normalization and
  German-learning presentation semantics;
- generic production search infrastructure must not encode match classes such
  as `exactGerman`, `exactArabic`, `containsGerman`,
  `containsArabic`, `tokenGerman`, or `tokenArabic`;
- no missing language capability may silently pivot through German or English;
- source, target, and UI language identities remain distinct;
- any future multilingual search authority must be supplied through an explicit
  language/pair capability boundary rather than by generalizing legacy labels.

## 5. Historical resident SearchIndex

`lib/services/search_index.dart` is classified **LEGACY_COMPATIBILITY** and
**NOT PRODUCTION AUTHORITY**.

It retains historical compatibility consumers under the detached V35/service
graph. It is not reachable from the current production root.

The implementation owns resident corpus structures including exact/token/group
maps and a whole-corpus trigram index. Those structures must not be wired into
the Phase3 production closure.

This task does not delete or rewrite that file because:

1. current compatibility modules still consume its API;
2. an old divergent branch also owns edits to that path;
3. deletion is not required to establish production authority; and
4. the project cleanup law forbids deleting compatibility code without a
   separate reachability and consumer-migration proof.

A later compatibility-retirement task may delete it only after its remaining
callers are migrated or formally retired.

## 6. Historical features/search adapter

`lib/features/search/data/lexicon_search_repository.dart` is also
**LEGACY_COMPATIBILITY** and **NOT PRODUCTION AUTHORITY**.

It wraps `SearchIndex<T>` and maintains a resident ID map over an iterable
corpus. No current Phase3 production-root import reaches this adapter.

Its retained bookmark/note infrastructure is a separate concern and does not
grant the old search adapter production authority.

## 7. Production reachability decision

Audited production roots:

- `lib/main.dart`
- `lib/bootstrap/production_bootstrap.dart`
- `lib/bootstrap/production_runtime.dart`
- `lib/ui/phase3/phase3_production_shell.dart`

At the TASK 8 baseline none imports or constructs:

- `SearchIndex`;
- `lib/services/search_index.dart`;
- `lib/features/search/data/lexicon_search_repository.dart`;
- `OfflineLexiconSearchRepository`;
- `QuickSearchModal`.

Therefore the shipped application currently has no production search entry
point to cut over. The consolidation action is to freeze the correct authority
and make any reintroduction of the resident legacy graph fail the canonical
quality gate.

## 8. Regression gate

`tests/quality_gate/test_task8_search_authority_contract.py` is the executable
boundary for this decision.

It verifies that:

- the production import closure cannot reach `SearchIndex` or its legacy
  adapter;
- the canonical adapter delegates to `IndexedSrsCorpusRepository`;
- the canonical adapter does not mirror a full `LearningContent` corpus;
- SQLite query/resource bounds remain present;
- language-specific legacy match labels do not enter production reachability;
- the audited search surfaces remain below the 1000-line ceiling.

Because this contract lives in `tests/quality_gate/`, the canonical local
quality gate executes it without adding a hosted workflow or CI cost.

## 9. Scope exclusions

TASK 8 makes no change to:

- SQLite schema or migrations;
- SRS scheduling or review transactions;
- learner progress, XP, streak, attempts, or favorites;
- pack admission/provenance;
- Phase3 navigation or UI composition;
- CI/CD workflows;
- dependencies or lockfiles;
- legacy compatibility behavior.

No data is copied, re-keyed, synthesized, or deleted.

## 10. Exit condition

TASK 8 is complete when all of the following hold:

1. `IndexedSrsCorpusRepository.searchContent` plus
   `OfflineLexiconSearchRepository` is the sole permitted production search
   authority.
2. The current production closure does not reach the resident legacy
   `SearchIndex` graph.
3. Search queries remain bounded and fail closed at the SQLite boundary.
4. Generic production search contains no German/Arabic-labelled legacy match
   semantics.
5. Compatibility search code is explicitly non-authoritative rather than
   silently treated as a second runtime.
6. The canonical local quality gate passes on the exact TASK 8 branch head.

This closes search-authority ambiguity without inventing a migration where no
production legacy consumer exists.
