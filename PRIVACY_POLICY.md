# Privacy Policy for Deutsch بالعربي

**Last updated:** November 25, 2026

**Developer / Entity:** moaz76943-creator (matches Google Play developer account listing)

**Public URL:** https://deutsch-bilarabi-privacy.netlify.app/privacy.html

**Contact for privacy inquiries:** Open a GitHub issue on the deutsch-bilarabi-privacy repository or use the in-app feedback / privacy dialog. We respond to legitimate privacy requests.

## Introduction

Deutsch بالعربي is an offline-first German language learning application designed for Arabic speakers. We prioritize user privacy. This policy explains how the app accesses, processes, and handles data in compliance with Google Play User Data policy, Data safety requirements, Core App Quality guidelines, and security standards.

The app is designed to function entirely without an internet connection. Learning content, progress, and features operate on your device only. No network permissions are declared.

## Data We Access and Process

### Microphone / Audio (RECORD_AUDIO)

- **Purpose:** The optional pronunciation trainer feature may request microphone access to record your voice for on-device speech analysis or practice (e.g., comparing pronunciation). Permission is requested at the time of use (not at app launch), immediately after a prominent in-app disclosure explaining the purpose, and the feature degrades gracefully if denied.
- **Collection:** Audio is processed **locally on your device only**. We do not transmit, store on servers, or share audio recordings. Per Google Play Data safety guidelines, pure on-device processing that never leaves the device is not considered "collection" or "sharing".
- **Data Safety:** No voice data is collected or shared off the device. Declare "No" for Audio files / Voice or sound recordings in the Play Console Data safety form.
- You can deny the permission; text-based practice remains available.
- **Required prominent disclosure (must be shown in-app, clearly visible, before the system permission dialog):** "Deutsch بالعربي needs access to your microphone to analyze your pronunciation on-device for practice. Audio never leaves your device and is not stored or shared." This disclosure is mandatory under Google Play User Data policy for sensitive permissions. The system dialog is only shown after the user acknowledges the in-app disclosure. Bilingual (AR/EN) version is implemented in the app.

### Network Access

- **No network permissions declared.** The app does not request or use `INTERNET`, `ACCESS_NETWORK_STATE`, or related permissions. This is enforced in the manifests and quality-gate tests to keep the app fully offline.
- No data can leave the device via the network. Core functionality does not depend on connectivity.

### Local Storage

- Learning progress, preferences, and vocabulary data are stored locally on your device (using SharedPreferences or similar, with encryption where sensitive).
- We do not upload this data to any servers. Uninstalling the app deletes all local data.

### No Other Sensitive Data

The app does **not** collect or access:
- Location data
- Contacts, calendar, or SMS
- Photos or videos (storage and media permissions are explicitly removed via tools:node="remove")
- Advertising IDs or tracking data
- Account information (no user accounts required for core use)
- Any personal identifiable information (PII)
- Device identifiers for tracking or advertising

## Data Safety Declaration (for Google Play)

Exact answers for the Play Console Data safety form (must match this policy):

- **Does your app collect or share any of the required user data types?** No
- **Data collected:** None. On-device processing of optional microphone input does not leave the device and is not declared as collected data. No network access exists, so no off-device transmission is possible.
- **Data shared:** None.
- **Is all of the user data collected by your app encrypted in transit?** N/A (no data collected; no network traffic from the app).
- **Do you provide a way for users to request that their data is deleted?** Yes — see the dedicated section below. Uninstalling the app removes all local data. No server-side data exists.
- **Security practices:** Local data protected by Android sandbox and encryption where used. App uses Google Play App Signing. Release builds enforce minification, resource shrinking, and signing. Native libraries (including SQLite via sqlite3_flutter_libs) are built with NDK r28+ for 16 KB page size alignment, meeting Google Play's page size compatibility requirements for apps targeting API 35+.

## Your Rights and Data Deletion

Because the app stores data only locally on your device and does not create user accounts or store personal data on servers:

- **Access / Review:** All data is under your control on the device. No remote access is possible.
- **Deletion:** Uninstall the app to permanently delete all local learning progress, preferences, and any temporary audio buffers. There is no server-side data to delete. This is the complete and only deletion path required. No additional in-app deletion UI is needed because no persistent remote data exists.
- **Request confirmation:** You may contact us via the methods listed above if you need confirmation that no residual data exists.
- This satisfies Google Play requirements for a clear deletion path (in-app via uninstall, and documented publicly).

## Permissions Summary

| Permission              | Required? | Purpose                              | Off-device transmission? |
|-------------------------|-----------|--------------------------------------|--------------------------|
| RECORD_AUDIO            | Optional (runtime, on-demand, after in-app disclosure)  | Pronunciation practice (on-device)  | No                       |
| INTERNET / network      | Not declared | Not used (offline-first)         | No                       |
| Storage / media permissions     | Removed   | Not used                            | N/A                      |
| POST_NOTIFICATIONS      | Removed (release) | Not used                       | N/A                      |

## App Integrity, Signing, Target SDK, and Security

- Distributed via Google Play App Signing (upload key separate from the signing key managed by Google).
- Targets Android 16 (API level 36), meeting the August 31, 2026 requirement for new apps and updates. Existing apps need at least API 35 to remain available to new users on newer devices.
- Native code compiled with NDK 28.2+ ensuring 16 KB memory page size alignment (required for updates targeting API 35+; enforcement strengthens in 2027).
- allowBackup="false"; usesCleartextTraffic="false"; data extraction rules configured; R8/ProGuard minification and resource shrinking enabled in release.
- Prominent disclosure is shown in-app before any sensitive permission request (e.g., microphone). See required text above. Failure to show this disclosure is a policy violation.
- FLAG_SECURE is set to prevent screenshots of sensitive learning content in the app switcher (disabled only in debug builds).
- Edge-to-edge display enabled for API 35+ compatibility.
- Predictive back navigation enabled via android:enableOnBackInvokedCallback="true" for Android 16 compatibility and Core App Quality.
- No Play Integrity or other network-dependent integrity APIs are included, consistent with the fully offline design. Integrity is maintained through Play App Signing, code minification, and platform sandboxing. Basic runtime checks for debugger/root/emulator are present in release builds.

## Children's Privacy

The app is suitable for general audiences. We do not knowingly collect data from children under 13.

## Changes to This Policy

We may update this policy. The latest version is always available at the public URL above, linked from the Play Store listing and within the app (Profile / Privacy Policy).

## Contact

For questions about this privacy policy or data practices, contact the developer via GitHub Issues on the deutsch-bilarabi-privacy repository.

---

**Compliance notes:** Link the public URL in Play Console App content (Privacy policy). Complete Data safety form accurately matching the answers above (no collection/sharing). Provide in-app link and prominent disclosure before RECORD_AUDIO (mandatory). The public URL is live on Netlify. Target SDK 36, signing, 16 KB page size support for native libs, and offline permissions are in place for production readiness.
