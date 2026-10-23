# Privacy Policy for Deutsch بالعربي

**Last updated:** October 23, 2026

**Developer:** moaz76943-creator

**Public URL:** https://moaz76943-creator.github.io/deutsch-bilarabi-privacy/privacy.html

**Contact:** For privacy inquiries, please open an issue on the GitHub repository or contact via the app's feedback mechanism if available.

## Introduction

Deutsch بالعربي is an offline-first German language learning application designed for Arabic speakers. We prioritize user privacy. This policy explains how the app accesses, processes, and handles data.

The app is designed to function primarily without an internet connection. Most learning content, progress, and features operate entirely on your device.

## Data We Access and Process

### Microphone / Audio (RECORD_AUDIO)

- **Purpose:** The pronunciation trainer feature may request microphone access to record your voice for on-device speech analysis or practice (e.g., comparing pronunciation).
- **Collection:** Audio is processed **locally on your device only**. We do not transmit, store on servers, or share audio recordings.
- **Data Safety:** This is on-device processing. No voice data is collected or shared off the device.
- You can deny the permission; the feature will degrade gracefully (text-based practice remains available).

### Network Access (INTERNET, ACCESS_NETWORK_STATE)

- **Purpose:** Optional features such as checking for content updates, downloading additional packs (if implemented), or Play Integrity checks. The core app works offline.
- **Data:** No personal data is required or collected via the network for core functionality. Any network requests are minimal and for app functionality only.

### Local Storage

- Learning progress, preferences, and vocabulary data are stored locally on your device (using SharedPreferences or similar secure local storage).
- We do not upload this data to any servers.

### No Other Sensitive Data

The app does **not** collect:
- Location data
- Contacts, calendar, or SMS
- Photos or videos (storage permissions are explicitly removed)
- Advertising IDs or tracking data
- Account information (no user accounts required for core use)
- Any personal identifiable information (PII)

## Data Safety Declaration (for Google Play)

- **Data collected:** None (or only anonymous on-device processing).
- **Data shared:** None.
- **Security practices:** Data encrypted in transit where applicable (HTTPS); local data protected by Android sandbox.
- **Users can request data deletion:** Since no server-side data is stored, uninstalling the app removes all local data. No account deletion needed.

## Permissions Summary

| Permission              | Required? | Purpose                              | Off-device transmission? |
|-------------------------|-----------|--------------------------------------|--------------------------|
| RECORD_AUDIO            | Optional  | Pronunciation practice (on-device)  | No                       |
| INTERNET                | Optional  | Updates / integrity checks          | Minimal, no PII          |
| ACCESS_NETWORK_STATE    | Optional  | Connectivity checks                 | No                       |
| Storage permissions     | Removed   | Not used                            | N/A                      |

## Children's Privacy

The app is suitable for general audiences. We do not knowingly collect data from children under 13.

## Changes to This Policy

We may update this policy. The latest version will always be available at the public URL above, linked from the Play Store listing and within the app (Settings / About).

## Contact

For questions about this privacy policy or data practices, please contact the developer via GitHub Issues on the project repository.

---

**This privacy policy is required for Google Play publication, especially due to the RECORD_AUDIO permission. Link the public URL in the Play Console App content section and display a link inside the app.**
