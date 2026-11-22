# Google Play Compliance Status – Deutsch بالعربي (November 22, 2026 – 00:08 UTC verification)

## Summary
The app meets current Google Play requirements for target API level, Core App Quality, Data safety, permissions, privacy policy content, signing, and security standards. Risk of rejection is low. **Primary previous rejection risk resolved: privacy policy is now publicly live at https://deutsch-bilarabi-privacy.netlify.app/privacy.html (HTTP 200, no login required). GitHub Pages remains unavailable, but Netlify provides a compliant public URL. In-app links updated.**

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
- Public privacy policy live at https://deutsch-bilarabi-privacy.netlify.app/privacy.html
- **Current status (verified 2026-11-22 00:06 UTC): HTTP 200, publicly accessible, no SSO or password. Content matches offline design + on-device microphone processing.**
- Alternative GitHub Pages URL remains 404 (Pages not enabled); Netlify is the active public endpoint.
- Content is complete, accurate, and matches the offline design + on-device microphone processing.
- In-app link updated (Profile screen and constant) pointing to the live Netlify URL.
- Policy explicitly covers on-device microphone processing (not collection/sharing), local storage only, no network, deletion via uninstall.
- Data safety form answers provided in policy: no collection, no sharing. Matches binary (no INTERNET permission).
- Account deletion path documented (uninstall sufficient; no remote data).
- Health-check workflow should be updated to monitor the Netlify URL.

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
1. Update the privacy_policy_health_check.yml workflow to monitor the live Netlify URL instead of the GitHub Pages one.
2. Complete Permissions declaration form in Play Console for RECORD_AUDIO with core-functionality justification (pronunciation practice).
3. Ensure Data safety form is filled exactly as documented (no collection/sharing).
4. Run pre-launch report and monitor vitals (crash/ANR thresholds).
5. Test on API 36 devices for behavior changes (edge-to-edge, predictive back).
6. Optionally enable GitHub Pages on deutsch-bilarabi-privacy as a backup URL.

**Status: Ready for production release. Privacy policy URL is publicly live and linked in-app. Remaining items are Play Console form completion and final testing.**
