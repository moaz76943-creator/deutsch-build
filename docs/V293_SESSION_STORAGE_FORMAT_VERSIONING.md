# V293 — Session Storage Format Versioning

Status: VERIFIED

V293 adds an explicit one-byte storage format version to the Android session-credential payload. The reader validates the version before decryption and rejects unknown versions as corrupted data. The version byte is included in the maximum stored-payload bound.

No legacy fallback, migration, token format, provider credential, or production secret was introduced.

Verification:
- V293 focused tests: 3/3 passed.
- Full project Python tests: 370 passed.
- Security audit: PASS.
- Privacy audit: PASS.
- Architecture checks: covered by project regression suite; no oversized-file regression detected.
- Accessibility audit: PASS, 0 warnings.
- Quality audit: PASS; 14,813 entries, 14,813 unique IDs, 14,813 unique German entries.
- Credential leakage scan: PASS.
- Flutter/Dart/APK: NOT RUN in this environment because the toolchain is unavailable.
