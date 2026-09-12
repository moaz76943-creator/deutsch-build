# Deutsch بالعربي — V180

## Scope
Learning-content expansion, verb-data repair, and build-wrapper fail-fast hardening.

## Changes
- Added 20 new A2 learning items (`w16130`–`w16149`) with practical Arabic translations and contextual examples.
- Added 27 new conjugation rows across `beeinflussen`, `sich erkundigen`, and `erwähnen` (9 persons each; present + Perfekt).
- Repaired malformed conjugation data in the legacy `erwidern`, `hinausgehen`, and `verteidigen` blocks without changing content IDs.
- Preserved deterministic content IDs and expanded the reviewed corpus from 14,793 to 14,813 entries.
- Added V180 regression tests covering content wiring, new verb person sets, repaired grammar shapes, and corpus baseline integrity.
- Hardened `scripts/build_guard.sh` so a missing `gradle-wrapper.jar` fails fast instead of producing a misleading Gradle invocation failure.

## Validation
- Python regression suite: 165 passed.
- Content quality audit: PASS; 14,813 entries, 14,813 unique IDs, 14,813 unique German entries.
- Security audit: PASS.
- Accessibility audit: PASS; 0 warnings.
- Architecture audit: PASS; 0 oversized files.
- Weakness gate: PASS.
- Shell syntax checks: PASS.
- Flutter/Dart analysis and Flutter tests: not run because Flutter/Dart are not installed in this environment.
- Android APK build: not performed. The extracted project is also missing `android/gradle/wrapper/gradle-wrapper.jar`; V180 makes this condition explicit in the build guard rather than hiding it.
- Project remains private; no public publishing or sharing performed.
