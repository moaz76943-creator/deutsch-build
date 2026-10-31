# TASK 9 — Generated Content Degraph

**Baseline:** `main@a609c5b791dc79ce6301873ab9530e24c483eb99`
**Task:** TASK 9 — GENERATED CONTENT DEGRAPH
**Behavioral data migration:** None
**Canonical learner/content data mutation:** None

## 1. Goal

Remove the large generated Dart content corpora from the production import and
compilation graph after the runtime has converged on the admitted bounded SQLite
corpus.

This task does **not** delete canonical authoring data, generated parity
artifacts, compiler support, or compatibility facades. It removes the remaining
production import edge that caused generated verb rows to be pulled into the
application graph transitively.

## 2. Baseline measurement

At the TASK 9 baseline, `lib/data/generated/` contains:

- **70 Dart files**
- **10,869,990 bytes** total generated Dart source
- **39 content files / 5,087,022 bytes**
- **31 verb files / 5,782,968 bytes**

The production vocabulary path was already SQLite-backed and
`lib/data/content_a1.dart` had no production caller.

The remaining leak was:

`GermanLanguagePack`
→ `GermanContentPack`
→ `VerbIndex`
→ `lib/data/verb_conjugations.dart`
→ `lib/data/generated/verb_conjugations_generated.dart`
→ generated verb chunks.

Although `GermanContentPack` constructed `VerbIndex.fromRows` with an empty
row list, the import inside `VerbIndex` still made the embedded generated verb
corpus part of the Dart compilation graph.

## 3. Root fix

`lib/services/verb_index.dart` is now an explicit-row engine only.

It:

- imports the neutral `VerbConjugation` model directly;
- exposes `VerbIndex.fromRows(...)`;
- has no default embedded-data constructor;
- has no `verbConjugations`, expansion-list, or generated-corpus fallback;
- contains no import of `lib/data/verb_conjugations.dart`.

A caller that needs verb rows must now supply them explicitly. This is
fail-closed: a missing data source cannot silently fall back to a compiled
German corpus.

The existing production German metadata adapter already supplies an explicit
empty row set while production verb/content data is resolved from the admitted
indexed SQLite corpus.

## 4. Canonical runtime authority

Production content remains:

authoring JSON/CSV
→ validation/admission
→ pack
→ indexed SQLite
→ bounded runtime repositories.

The production bootstrap continues to consume the resolved indexed corpus and
does not re-materialize the full generated Dart vocabulary corpus.

No SRS, learner progress, XP, streak, attempt, favorites, or pair-progress
authority changes in this task.

## 5. Generated artifacts intentionally retained

The following compatibility/parity artifacts remain tracked and available:

- `lib/data/generated/content_items_generated.dart`
- `lib/data/generated/verb_conjugations_generated.dart`
- their generated chunk files;
- `lib/data/content_a1.dart`;
- `lib/data/verb_conjugations.dart`.

They are retained because historical compatibility/tooling surfaces still refer
to them and because deletion is not required for production degraphing.

Their presence in the repository does not grant them production authority.

## 6. Compiler and parity tooling intentionally retained

`tool/content_compiler.py` remains unchanged.

The canonical quality path still verifies:

- deterministic compile into a temporary directory;
- row-for-row parity against canonical JSON;
- generated artifact integrity.

TASK 9 does not alter `scripts/local_quality_gate.sh`, release scripts, or CI
workflows. This keeps verification behavior stable while removing only the
production import edge.

## 7. Collision discipline

Open PR #454 was inspected before mutation. It overlaps SQLite/runtime/content
composition files such as the SRS corpus repository, German content pack and
legacy production-root files.

TASK 9 therefore does not modify any PR #454 path.

Mutable source scope is limited to:

- `lib/services/verb_index.dart`;
- TASK 9 semantic contract;
- this degraph record.

## 8. Executable acceptance contract

`tests/quality_gate/test_task9_generated_content_degraph_contract.py` verifies
that:

1. the production Dart import closure contains no file under
   `lib/data/generated/`;
2. the production closure contains neither compatibility data facade;
3. `VerbIndex` requires explicit rows and owns no embedded corpus import;
4. `GermanContentPack` remains metadata-only/fail-closed;
5. canonical content compiler/parity tooling remains intact;
6. audited source files remain below the 1000-line ceiling.

The closure walker follows import/export/part directives, including conditional
Dart URI branches, and fails if an internal dependency is missing.

## 9. Integrity guarantees

TASK 9 does not:

- change content IDs or row values;
- alter JSON/CSV authoring sources;
- alter SQLite schemas or migrations;
- synthesize fallback content;
- change localization or directed-pair semantics;
- modify UI;
- modify build/CI scripts;
- change dependencies or lockfiles;
- delete generated compatibility artifacts.

The runtime either receives explicitly sourced rows or has no rows. There is no
silent embedded-corpus fallback.

## 10. Exit condition

TASK 9 is ready for integration when:

- the semantic contract proves zero generated/facade files in production
  reachability;
- Dart analyzer reports zero blocking errors in `lib/`;
- the canonical local quality gate passes on the exact branch HEAD;
- no unrelated file is changed.

The 10,869,990 bytes of generated Dart source remain available for parity and
compatibility evidence, but are no longer reachable from the shipped production
Dart graph.
