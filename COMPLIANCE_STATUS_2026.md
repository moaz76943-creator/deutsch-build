# Google Play Compliance Status – Deutsch بالعربي (November 10, 2026)

## Summary
The app meets current Google Play requirements for target API level, Core App Quality, Data safety, permissions, privacy policy content, signing, and security standards. Risk of rejection is low for most areas once the public privacy policy URL is live. One compliance improvement applied this run: corrected the privacy policy health-check workflow URL so CI accurately monitors the required public policy location.

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
- **Current status (verified 2026-11-10): 404 — GitHub Pages not enabled on the deutsch-bilarabi-privacy repository.** This is the primary remaining rejection risk.
- Content is complete, accurate, and matches the offline design + on-device microphone processing.
- In-app link present (Profile screen) pointing to the correct URL.
- Policy explicitly covers on-device microphone processing (not collection/sharing), local storage only, no network, deletion via uninstall.
- Data safety form answers provided in policy: no collection, no sharing. Matches binary (no INTERNET permission).
- Account deletion path documented (uninstall sufficient; no remote data).

## Signing & Integrity Protection
- Release signing config enforced (`secureRelease` via `release-signing.gradle`).
- Play App Signing expected (upload key separate).
- R8 minify + shrinkResources enabled.
- `allowBackup="false"`, cleartext disabled, networkSecurityConfig strict, FLAG_SECURE in MainActivity.
- No Play Integrity API (consistent with offline design; network permission removed). Integrity via Play signing, sandbox, and minification.
- Native libs use NDK 28.2+ for 16 KB page size support.

## Core App Quality
- Offline-first, no unnecessary permissions, stable expected (pre-launch report recommended).
- No ads, no tracking, clear value for language learning.

## Remaining Recommendations (future runs)
1. **Enable GitHub Pages** on the deutsch-bilarabi-privacy repository (Settings → Pages → Deploy from branch `main` / root). Verify the URL returns 200. This clears the main rejection risk.
2. Complete Permissions declaration form in Play Console for RECORD_AUDIO with core-functionality justification (pronunciation practice).
3. Ensure Data safety form is filled exactly as documented (no collection/sharing).
4. Run pre-launch report and monitor vitals (crash/ANR thresholds).
5. Test on API 36 devices for behavior changes (edge-to-edge, predictive back).

**Status: Nearly ready for production release. Enable GitHub Pages for the privacy policy URL before submitting.**
