# V374 — Development Acceleration

## Purpose

V374 adds a change-aware verification layer. It does not remove tests or weaken release gates.

## Daily fast path

```bash
./scripts/check-fast.sh --changed content/content_items.json --report docs/V374_FAST_REPORT.json
```

The analyzer classifies changes as LOW, MEDIUM, HIGH, or CRITICAL. Unknown impact fails closed and escalates to broader verification.

## Explicit skipped checks

Fast reports distinguish selected checks from checks that were not run. Unaffected checks are reported as `SKIPPED — unaffected`; they are never represented as PASS.

## Cache

`.verification_cache/cache.json` stores only PASS results keyed by hashes of relevant files, configuration, and tool version. Corrupt or stale cache entries are treated as misses. The cache directory is ignored by source control.

## Content compilation

`tool/content_compiler.py compile --cache <path>` can reuse generated output when canonical JSON inputs and the compiler contract are unchanged. Generated Dart remains derived output; parity is still required.

## Release path

```bash
./scripts/check-release.sh
```

Release mode remains full and includes regression tests, content quality, security, privacy, accessibility, architecture, weakness, canonical content validation, compiler parity, and Flutter/Android checks when the toolchain is available. If Flutter is unavailable, the build gate exits non-zero rather than fabricating a PASS.

## Machine-readable report

`tool/verify.py` reports `changed`, `risk`, `selected`, `skipped`, `passed`, `failed`, `security`, `content`, `compiler`, and `warnings` fields.
