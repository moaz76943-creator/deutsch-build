# Privacy Policy for Deutsch بالعربي

**Last updated:** October 28, 2026

**Developer / Entity:** moaz76943-creator (matches Google Play developer account listing)

**Public URL:** https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html

**Contact for privacy inquiries:** Open a GitHub issue on the deutsch-bilarabi-privacy repository or use the in-app feedback / privacy dialog. We respond to legitimate privacy requests.

## Introduction

Deutsch بالعربي is an offline-first German language learning application designed for Arabic speakers. We prioritize user privacy. This policy explains how the app accesses, processes, and handles data in compliance with Google Play User Data policy, Data safety requirements, Core App Quality guidelines, and security standards.

The app is designed to function primarily without an internet connection. Most learning content, progress, and features operate entirely on your device.

## Data We Access and Process

### Microphone / Audio (RECORD_AUDIO)

- **Purpose:** The optional pronunciation trainer feature may request microphone access to record your voice for on-device speech analysis or practice (e.g., comparing pronunciation). Permission is requested at the time of use (not at app launch), immediately after a prominent in-app disclosure explaining the purpose, and the feature degrades gracefully if denied.
- **Collection:** Audio is processed **locally on your device only**. We do not transmit, store on servers, or share audio recordings. Per Google Play Data safety guidelines, pure on-device processing that never leaves the device is not considered "collection" or "sharing".
- **Data Safety:** No voice data is collected or shared off the device. Declare "No" for Audio files / Voice or sound recordings in the Play Console Data safety form.
- You can deny the permission; text-based practice remains available.

### Network Access (INTERNET, ACCESS_NETWORK_STATE)

- **Purpose:** Optional features such as checking for content updates, downloading additional packs (if implemented), or Play Integrity checks. The core app works offline.
- **Data:** No personal data is required or collected via the network for core functionality. Any network requests are minimal and for app functionality only. Data in transit uses modern cryptography (HTTPS).

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
- Device identifiers beyond what is necessary for Play Integrity (and only when network is available)

## Data Safety Declaration (for Google Play)

- **Data collected:** None. On-device processing of optional microphone input does not leave the device and is not declared as collected data.
- **Data shared:** None.
- **Security practices:** Data encrypted in transit where applicable (HTTPS); local data protected by Android sandbox and encryption where used. App uses Google Play App Signing and Play Integrity API.
- **Users can request data deletion:** Since no server-side data is stored, uninstalling the app removes all local data. No account deletion needed.

## Permissions Summary

| Permission              | Required? | Purpose                              | Off-device transmission? |
|-------------------------|-----------|--------------------------------------|--------------------------|
| RECORD_AUDIO            | Optional (runtime, on-demand)  | Pronunciation practice (on-device)  | No                       |
| INTERNET                | Optional  | Updates / integrity checks          | Minimal, no PII          |
| ACCESS_NETWORK_STATE    | Optional  | Connectivity checks                 | No                       |
| Storage / media permissions     | Removed   | Not used                            | N/A                      |
| POST_NOTIFICATIONS      | Removed (release) | Not used                       | N/A                      |

## App Integrity, Signing, Target SDK, and Security

- Distributed via Google Play App Signing (upload key separate from the signing key managed by Google).
- Play Integrity API for device and app integrity checks (requires CLOUD_PROJECT_NUMBER for production).
- Targets Android 16 (API level 36), meeting the August 31, 2026 requirement for new apps and updates. Existing apps need at least API 35 to remain available to new users on newer devices.
- allowBackup="false"; usesCleartextTraffic="false"; data extraction rules configured; R8/ProGuard minification and resource shrinking enabled in release.
- Prominent disclosure is shown in-app before any sensitive permission request (e.g., microphone).

## Children's Privacy

The app is suitable for general audiences. We do not knowingly collect data from children under 13.

## Changes to This Policy

We may update this policy. The latest version is always available at the public URL above, linked from the Play Store listing and within the app (Profile / Privacy Policy).

## Contact

For questions about this privacy policy or data practices, contact the developer via GitHub Issues on the deutsch-bilarabi-privacy repository.

---

**Compliance notes:** Link the public URL in Play Console App content (Privacy policy). Complete Data safety form accurately (no collection/sharing). Provide in-app link and prominent disclosure before RECORD_AUDIO. Ensure GitHub Pages is enabled for the public URL. Target SDK 36, signing, and integrity protections are in place for production readiness.
