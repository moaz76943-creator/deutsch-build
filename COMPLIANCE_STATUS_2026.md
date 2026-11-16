# Google Play Compliance Status – Deutsch بالعربي (November 16, 2026 – ~10:00 UTC verification)

## Summary
The app meets current Google Play requirements for target API level, Core App Quality, Data safety, permissions, privacy policy content, signing, and security standards. Risk of rejection is low for most areas once the public privacy policy URL is live. **Primary remaining rejection risk (re-verified 2026-11-16 ~10:00 UTC via direct HTTP request): privacy policy URL returns 404 because GitHub Pages is not enabled on the deutsch-bilarabi-privacy repository.** One compliance improvement applied this run: re-verified the live URL status (still 404) and updated this status document with the latest check timestamp. An issue has been created in the privacy repository with exact enablement steps.

## Target SDK
- `targetSdk 36` / `compileSdk 36` in `android/app/build.gradle`.
- Meets the August 31, 2026 requirement: new apps and updates must target Android 16 (API 36) or higher.
- Existing apps need at least API 35 to remain available to new users on newer devices.
- Extension window to November 1, 2026 has closed; current setting is compliant.

## Permissions
- Minimal set: only optional `RECORD_AUDIO` (runtime, on-demand, with prominent in-app disclosure).
- Broad storage, media, INTERNET, network state, MANAGE_EXTERNAL_STORAGE explicitly removed via `tools:node="remove"` to enforce offline-first and accurate Data safety.
- No location, contacts, SMS, or other sensitive permissions.
- Aligns with minimum-scope principles and upcoming 2027 location/contacts policy changes (not applicable here).

## Privacy Policy & Data Safety
- Public privacy policy intended at https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html
- **Current status (re-verified 2026-11-16 ~10:00 UTC via direct HTTP request): 404 — "There isn't a GitHub Pages site here." GitHub Pages not enabled on the deutsch-bilarabi-privacy repository.** This is the primary remaining rejection risk.
- Content is complete, accurate, and matches the offline design + on-device microphone processing.
- In-app link present (Profile screen) pointing to the correct URL.
- Policy explicitly covers on-device microphone processing (not collection/sharing), local storage only, no network, deletion via uninstall.
- Data safety form answers provided in policy: no collection, no sharing. Matches binary (no INTERNET permission).
- Account deletion path documented (uninstall sufficient; no remote data).
- Health-check workflow (`.github/workflows/privacy_policy_health_check.yml`) correctly monitors the URL and will fail until Pages is enabled.

## Signing & Integrity Protection
- Release signing config enforced (`secureRelease` via `release-signing.gradle`).
- Play App Signing expected (upload key separate).
- R8 minify + shrinkResources enabled.
- `allowBackup="false"`, cleartext disabled, networkSecurityConfig strict, FLAG_SECURE in MainActivity.
- No Play Integrity API (consistent with offline design; network permission removed). Integrity via Play signing, sandbox, and minification.
- Native libs use NDK 28.2+ for 16 KB page size support.
- Additional early integrity check in MainActivity (SecurityGuard against rooted/debugged/emulated environments in release builds).

## Core App Quality
- Offline-first, no unnecessary permissions, stable expected (pre-launch report recommended).
- No ads, no tracking, clear value for language learning.
- Prominent bilingual in-app disclosure implemented before any RECORD_AUDIO request (see `lib/core/privacy/microphone_disclosure.dart`).

## Remaining Recommendations (future runs)
1. **Enable GitHub Pages (ACTION REQUIRED NOW)** on the deutsch-bilarabi-privacy repository:
   - Go to the repository → Settings → Pages.
   - Source: Deploy from a branch → Branch: `main` → Folder: `/ (root)`.
   - Click Save. Wait 1–2 minutes, then verify https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html returns 200 and shows the policy HTML.
   - This is the sole major remaining rejection risk. Manual step required (GitHub UI; API attempt returned 403 due to integration token scopes). An issue with these steps has been opened/prepared in the privacy repo.
2. Complete Permissions declaration form in Play Console for RECORD_AUDIO with core-functionality justification (pronunciation practice).
3. Ensure Data safety form is filled exactly as documented (no collection/sharing).
4. Run pre-launch report and monitor vitals (crash/ANR thresholds).
5. Test on API 36 devices for behavior changes (edge-to-edge, predictive back).

**Status: Nearly ready for production release. Enable GitHub Pages for the privacy policy URL before submitting — this is the final blocker.**
