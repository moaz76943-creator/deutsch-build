# V128 — Crash Hardening + Content Quality

- Hardened app boot when SharedPreferences initialization fails.
- Hardened async UI lifecycle boundaries after storage/TTS/speech awaits.
- Made the local write queue non-throwing to UI callers and protected storage reads.
- Corrected the Perfekt forms and examples for `vermeiden`.
- Added 20 A2 content items (`w16030`–`w16049`) and 9 conjugation rows for `besprechen`.
- Preserved existing IDs and kept the project offline/private by default.

## Verification
Run the Python test suite, content/security/quality audits, compileall, and archive integrity checks before delivery. Flutter/Android build remains unverified when the SDK is unavailable.
