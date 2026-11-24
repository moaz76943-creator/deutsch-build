# Google Play Compliance Status – Deutsch بالعربي (November 25, 2026 – verification)

## Summary
The app meets current Google Play requirements for target API level, Core App Quality, Data safety, permissions, privacy policy content, signing, and security standards. Risk of rejection is low. Privacy policy is publicly live at https://deutsch-bilarabi-privacy.netlify.app/privacy.html. In-app links point to the live URL. All major code-level compliance items are in place.

## Target SDK
- `targetSdk 36` / `compileSdk 36` in `android/app/build.gradle`.
- Meets the August 31, 2026 requirement: new apps and updates must target Android 16 (API 36) or higher.
- Existing apps need at least API 35 to remain available to new users on newer devices.
- Extension window to November 1, 2026 has closed; current setting is compliant.

## Permissions
- Minimal set: only optional `RECORD_AUDIO` (runtime, on-demand, with prominent bilingual in-app disclosure).
- Broad storage, media, INTERNET, network state, MANAGE_EXTERNAL_STORAGE explicitly removed via `tools:node="remove"` to enforce offline-first and accurate Data safety.
- No location, contacts, SMS, or other sensitive permissions.
- Aligns with minimum-scope principles and upcoming 2027 location/contacts policy changes (not applicable here).

## Privacy Policy & Data Safety
- Public privacy policy live at https://deutsch-bilarabi-privacy.netlify.app/privacy.html
- Content is complete, accurate, and matches the offline design + on-device microphone processing.
- In-app link (constant `kPrivacyPolicyUrl` and Profile screen) points to the live Netlify URL.
- Policy explicitly covers on-device microphone processing (not collection/sharing), local storage only, no network, deletion via uninstall.
- Data safety form answers provided in policy: no collection, no sharing. Matches binary (no INTERNET permission).
- Account deletion path documented (uninstall sufficient; no remote data).
- Health-check workflow (`.github/workflows/privacy_policy_health_check.yml`) already monitors the live Netlify URL.
- **Synced (Nov 25, 2026):** Live Netlify privacy.html last-updated date now matches the repository (November 24, 2026) after redeploy. Perfect consistency achieved.

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
- **Predictive back:** Explicitly enabled via `android:enableOnBackInvokedCallback="true"` on the application tag (added Nov 24, 2026). Aligns with Android 16 (API 36) default behavior and Core App Quality expectations. Flutter PopScope handles navigation correctly.

## Remaining Recommendations (future runs / Play Console)
1. Complete Permissions declaration form in Play Console for RECORD_AUDIO with core-functionality justification (pronunciation practice).
2. Ensure Data safety form is filled exactly as documented (no collection/sharing).
3. Run pre-launch report and monitor vitals (crash/ANR thresholds).
4. Test on API 36 devices for behavior changes (edge-to-edge, predictive back).
5. Optionally enable GitHub Pages on deutsch-bilarabi-privacy as a backup URL.

**Status: Ready for production release. All code-level compliance items (target SDK, permissions, privacy policy URL, in-app disclosure, signing, integrity checks, predictive back) are complete. Remaining items are Play Console form completion and final testing. Privacy policy date consistency fixed.**
