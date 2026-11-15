# Increment 3 — content-factory absorption decision record (2026-11-15)

Task: "Absorb content-factory unique assets into the application tree with
equivalence proof (packs, standards, legal ledger)"
(POLYGLOT_100_PROGRESS.md, Next queued increments #3).
Branch: `chore/absorb-factory-standards` from `origin/main` @ `2b77cc218`.
Import provenance: `content-factory/` = merge commit `ab207624e` of
`moaz76943-creator/-offline-packs-store@main` HEAD `ca821e59` (877 files,
history-preserving; see `content-factory/IMPORT_PROVENANCE.md`).

## Equivalence proof

Every absorbed file is byte-identical (SHA-256) to its imported
`content-factory/` counterpart; 27/27 target files match the import. No source
file under `content-factory/` was modified or deleted (preservation rule).

| Absorbed target (app tree) | Files | Source of truth |
|---|---:|---|
| `standards/directed_pairs/` | 8 | `content-factory/standards/directed_pairs/` |
| `standards/lexical/` | 7 | `content-factory/standards/lexical/` |
| `standards/morphology/` | 11 | `content-factory/standards/morphology/` |
| `tools/factory_extensions/directed_translation_scale/{__init__.py,graph.py}` | 2 | `content-factory/tools/factory_extensions/directed_translation_scale/` |

Runtime dependency chain verified: `tools/factory_extensions/directed_translation_scale/graph.py`
(stdlib-only) backs `standards/directed_pairs/test_factory_adapter.py`;
`standards/*` README commands run from the repository root unchanged.

## Verification (executed, exit codes recorded)

```
python3 -m unittest discover -s standards/directed_pairs -p 'test_*.py'  -> OK (29 tests)
python3 -m unittest discover -s standards/lexical      -p 'test_*.py'  -> OK (+ SQLite v2 projection)
python3 -m unittest discover -s standards/morphology   -p 'test_*.py'  -> OK
python3 tools/polyglot/registry_sync.py --check                        -> exit 0
                                                    (100 registered languages, Hebrew excluded,
                                                     checksum ef04da5d49a91d69…)
git diff --check                                                        -> exit 0
```

## Dispositions for the other named classes (NOT absorbed, with reasons)

| Class | Finding | Disposition |
|---|---|---|
| `packs/` (204 files + root manifest) | All factory packs are legacy stubs: root `manifest.json` is fail-closed (`intellectual_property_status=UNVERIFIED_RIGHTS`, `islamic_ethics_gate=NOT_VERIFIED_FOR_PRODUCTION`), every language `pack_verified=false`, `content_available=false`, `production_ready=false`, `is_active=false`; factory STATUS.md reports 0 filled language-concept cells. | BLOCKED by the rights/provenance gate (PROJECT_INTENT plan item 6). Absorbing them would inject unverified content into the app tree. No app pack file replaced (`packs/deutsch_deep_master.pack.gz` remains the app's own artifact). |
| `legal/ledger/sources.json` | App copy (724 B, `compliance_status=SOVEREIGN_PURE`, 2 audited sources, he/syc/ber/zgh excluded) strictly supersedes the factory copy (49 B, empty `sources` array). | App copy kept; factory copy not absorbed (target is better). |
| `catalog/` (`language_registry.v1.json` etc.) | Factory registry id set diverges from the canonical 100-language registry (18 ids differ); superseded by increment 1 and the increment-5 regeneration on PR #1183. | Not absorbed; canonical registry stays authoritative. |
| `standards/proficiency/` + `tools/proficiency_mapping/` | Standards are self-consistent and green in the factory tree, but `ProficiencyValidator.__init__` requires per-language proficiency metadata (`proficiency.framework_ids`, `mapping_status`) that the factory's stale `catalog/language_registry.v1.json` carries and the canonical app registry deliberately does not (identity/capabilities only, per TASKS_100 #34–36, #40). | BLOCKED pending an owner decision: either extend the canonical registry with a proficiency section (schema change) or keep the standard factory-side. Not silently absorbed; the stale factory registry must not enter the app tree. |

## Evidence debt

- No Dart/Flutter SDK locally; no Dart files touched by this change.
- GitHub CI for the new branch/PR recorded in the PR itself; SKIPPED checks are
  never claimed as PASS.
