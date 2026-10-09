# Deutsch بالعربي — Phase 2 Offline Runtime v2 (approved architecture contract)

**Status:** Approved specification, not yet a production implementation.
**Authority:** User decision of 2026-10-09. Stage 1 introduces SQLite schemas and offline pack compiler only.

## Network permission and precise boundary

- `android.permission.INTERNET` is approved solely for **explicit on-demand language-pack downloads and updates**.
- Source URLs MUST match a configured HTTPS allowlist (such as an exact GitHub Releases repository or owned HTTPS CDN). Reject HTTP, unexpected redirects, cross-host redirects, query-based host spoofing and arbitrary user-provided network URLs.
- No requests during lessons, exercises, pronunciation practice, grammar, testing, SRS, persistence or progress restoration. No telemetry, analytics beacons, remote AI, remote TTS, crash-report uploads or tracking.
- `INTERNET` is an app-level Android permission: the OS cannot limit it to one feature. Enforce the restriction in the code architecture and integration tests by exposing network access **only** to `PackDownloadTransport`.
- Maintain a manual fallback: import a local `*.db.gz` and its trusted metadata using Android's document picker/SAF. Do not request broad storage permissions.

## Install pipeline — fail closed

1. User explicitly selects a language; UI shows source, size and whether it is already installed.
2. Download metadata from pinned trusted HTTPS endpoint. Metadata includes language code, immutable pack version, exact SHA-256 digest of the **compressed** artifact, compressed and uncompressed size caps, schema version and stable content IDs.
3. Verify metadata trust. HTTPS with a configured allowlist prevents accidental off-origin access, but if the server is compromised an attacker can replace both archive and checksum. A *pinned digest/catalog shipped in the app*, or an authenticated manifest signed by a trusted key, is required for strong authenticity; Phase 2 does **not** silently reinstate the retired Ed25519/Keystore runtime.
4. Download to a temporary file under app-private storage; use stream limits and reject excessive compressed bytes. Do not load unbounded archives into Flutter UI memory.
5. Verify SHA-256 of the complete compressed file **before decompression** using the trusted manifest digest. Reject mismatch and delete only the temporary staging files.
6. Decompress off the UI isolate in bounded chunks; reject decompression bombs / oversized uncompressed content, bad gzip, path traversal and extra archive entries. `gzip` represents one SQLite database, not a zip directory.
7. Open staged SQLite read-only; validate `PRAGMA integrity_check`, `foreign_key_check`, `user_version`, content-language-code, entry count, stable IDs and application schema contract.
8. Atomically promote the verified database and catalog pointer, preserving the previous working version on any failure. If the device restarts mid-install, recover the last committed version.
9. Only after installation, expose language content to feature repositories. All subsequent reads, search, sound maps, exercises and review queries are **offline only**.
10. Manual imports perform the **same** SHA-256, schema and atomic-activation checks. Do not permit unsigned/untrusted arbitrary SQLite as production content.

## Storage separation and consistency

- A single language pack is a versioned read-only SQLite file in app-private storage. The built-in German+Arabic core is bundled separately, subject to an actual compressed-size budget (target <=25 MB, measure release artifact rather than claiming success).
- The other language packs are hosted externally and never listed as Flutter assets. The 100-language **registry** is not the same as 100 validated, publishable course packs.
- `srs_progress` resides in an independent writable `learner_progress.sqlite`. Never use cascading FK to removable content; never delete on uninstall/update.
- Stable `lexeme_id`, `concept_id`, `source_language_code`, `target_language_code`, `skill`, `facet_key`, `learner_id` identify review records. A changed lexeme ID requires an explicit migration map.
- Allow multiple entries per language and concept (distinct `sense_id`/lemma); lexeme CEFR is independent from concept CEFR.
- UI language direction comes from `language_profiles.direction` and per-span `Directionality`, not by reversing German/IPA text along with the Arabic interface.
- Reject disallowed language codes/aliases according to project policy (including `he` and `iw` and regional variants).

## Quality and billing gates

- Phase 2 acceptance: install a reviewed pack, reopen with airplane mode, search its lexemes, answer an exercise, persist SRS, update pack, delete pack, reinstall pack and confirm unchanged SRS.
- Negative cases: incorrect SHA-256, tampered manifest, wrong language, invalid SQLite, decompression bomb, interrupted download, malicious redirect, no network, insufficient storage and corrupt current catalog.
- Automated checks should use stdlib SQL/Python tests and Flutter widget/integration tests on a compatible runner; physical Android smoke verifies lifecycle. Termux Dart compile-error gate runs before committing.
- GitHub Actions matrices are **manual-only** with explicit per-job caps, limited concurrency and auditable outputs. Do not describe placeholder echo commands as real generation. The existing `polyglot_parallel_engine.yml` must be reviewed before any merge triggering its path-based push event.
- No new automatic runs, payment services, or network endpoints are authorized by this specification alone.

## Delivery sequencing

Stage 1: V2 data contracts and deterministic offline generator -> review.
Stage 2A: approved pack catalog and trusted source metadata.
Stage 2B: bounded/verified downloader + SAF import + atomic installer; add `INTERNET` if not already present.
Stage 2C: SQLite repository adapters and progress migration, no mock data.
Stage 2D: mobile smoke and offline/upgrade regression gates; only then release-candidate evaluation.

Never revert or overwrite user data or earlier UI features to force an apparently successful startup.
