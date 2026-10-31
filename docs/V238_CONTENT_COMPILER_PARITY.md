# V238 — Editable Content Compiler + Parity Gate

## Goal
Introduce a deterministic JSON-to-Dart compiler without switching runtime content away from the existing Dart catalogue.

## Runtime safety
- V238 does not modify runtime data imports.
- Generated Dart is written to a caller-provided temporary/output directory.
- JSON remains the editable representation; existing Dart remains the runtime source until a later migration proves parity.

## Commands
```bash
python3 tool/content_compiler.py compile --output-dir <dir>
python3 tool/content_compiler.py parity --output-dir <dir>
```

## Parity contract
The compiler emits deterministic constructor rows for `ContentItem` and `VerbConjugation`. The parity command parses the generated Dart and compares rows and field values against the editable JSON packs.

Current verified counts:
- Content items: 14,813
- Verb conjugation rows: 11,718

## CI integration
The build and quality workflows compile into an ephemeral `mktemp -d` directory and run parity before continuing. No recursive forced deletion is used.

## Migration rule
Do not make JSON runtime-canonical until parity has been demonstrated in a real Flutter build and a staged migration test proves unchanged learning behaviour.
