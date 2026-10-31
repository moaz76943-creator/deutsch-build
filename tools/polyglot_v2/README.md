# Polyglot SQLite V2 — Phase 1 foundation

Repository: `moaz76943-creator/deutsch-build`.

These files introduce the V2 contract without touching the running Flutter app, signing, user data, Android permissions, or CI workflows.

- `assets/polyglot_v2/pack_v2.sql`: five per-language content tables, indexes, synonym support and entry-specific CEFR.
- `assets/polyglot_v2/progress_v2.sql`: one *separate* user-owned local database table; never delete progress when a pack is removed.
- `tools/polyglot_v2/create_pack_v2.py`: editor-approved JSON -> deterministic SQLite -> gzip + SHA-256, using Python stdlib only.
- `tools/polyglot_v2/source_de_train_v2.json`: one German development fixture; **not** a production pack or a complete A1–B1 course.
- `tools/polyglot_v2/test_polyglot_v2.py`: contract tests, negative checks and reproducibility.

Local gate (does not invoke Flutter engine in Termux):

```sh
python3 -m unittest discover -s tools/polyglot_v2 -p 'test_polyglot_v2.py' -v
python3 -m py_compile tools/polyglot_v2/create_pack_v2.py tools/polyglot_v2/test_polyglot_v2.py
dart analyze lib/ 2>&1 | grep 'error •' || true
```

The last command should print no blocking errors, but check the analyzer process output for tool failures. Flutter/widget tests require a compatible runner.

A SHA-256 file next to a downloaded archive detects corruption but **does not authenticate an attacker-controlled source**. Phase 2 requires trusted HTTPS and a trusted/pinned manifest, with size limits, private paths and atomic installation. Details: `docs/architecture/polyglot_offline_runtime_v2.md`.

No 100-language data is claimed. All language packs require reviewed licensed source data. Existing `assets/content/packs/de` is not replaced here. Do not include downloadable `*.db.gz` under Flutter assets.
