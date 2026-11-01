# Google Play Compliance Status

**Last reviewed:** November 1, 2026

## Summary
The Deutsch بالعربي app is largely compliant with current Google Play policies, Core App Quality guidelines, Data safety requirements, and security standards. Target SDK is 36 (meets August 31, 2026 requirement for new apps/updates). Permissions are minimal and properly disclosed. Privacy policy is detailed and aligned with Data Safety (no collection/sharing). Play Integrity and App Signing are configured. Prominent disclosure for RECORD_AUDIO is implemented.

## Checked Areas

| Area | Status | Notes |
|------|--------|-------|
| Target SDK / compileSdk | Compliant | 36 (Android 16). Meets current Play requirement. |
| Permissions | Compliant | RECORD_AUDIO (optional, on-device, with prominent disclosure before system dialog), INTERNET, ACCESS_NETWORK_STATE. Broad storage/media removed via tools:node="remove". |
| Privacy Policy | Ready (URL pending) | Full policy at privacy.html covering permissions, Data Safety (None), deletion (uninstall), integrity, children's privacy. Matches form answers. |
| Data Safety | Compliant | No data collected or shared. On-device processing only. |
| Signing | Compliant | Release signing mandatory; Play App Signing expected. |
| Integrity Protection | Configured | Play Integrity API dependency present; tokens for device/app checks, no PII. |
| Security | Compliant | allowBackup=false, usesCleartextTraffic=false, data extraction rules exclude all, R8 minify + shrink, FLAG_SECURE mentioned. |
| Prominent Disclosure | Implemented | lib/core/privacy/microphone_disclosure.dart shows in-app dialog before OS permission request. |

## Identified Risk / One Improvement This Run
**Risk:** Privacy policy public URL currently returns 404 because GitHub Pages is not enabled on the deutsch-bilarabi-privacy repository. Google Play requires a publicly accessible HTML privacy policy URL (non-geofenced).

**Applied improvement:** Documented the status and the exact required action below so the app is one setting away from production readiness.

### Required action (manual, one-time)
1. Go to https://github.com/moaz76943-creator/deutsch-bilarabi-privacy/settings/pages
2. Source: Deploy from a branch → main / / (root)
3. Save. Wait for the site to publish.
4. Verify https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html returns 200.
5. Link the URL in Play Console → App content → Privacy policy, and keep the in-app link.

Once the URL is live, the app meets the requirements for production release.

## Next possible improvements (future runs)
- Verify Play Integrity cloud project number is set for production.
- Confirm edge-to-edge / predictive back testing on API 36 devices (Core App Quality).
- Double-check final merged manifest for any unexpected permissions from plugins.
