/// Static security invariants for AndroidManifest.xml that must hold
/// for Google Play Core App Quality and Data Safety form.
///
/// These are architectural contracts verified by reading the manifest.
/// A CI step can parse the XML and assert the same properties.
library;

const expectedSecurityInvariants = <String, dynamic>{
  'allowBackup': false,
  'fullBackupContent': false,
  'usesCleartextTraffic': false,
  'exportedActivity': true, // launcher only
  'removedPermissions': [
    'MANAGE_EXTERNAL_STORAGE',
    'WRITE_EXTERNAL_STORAGE',
    'READ_EXTERNAL_STORAGE',
    'READ_MEDIA_IMAGES',
    'READ_MEDIA_VIDEO',
    'READ_MEDIA_AUDIO',
    'READ_MEDIA_VISUAL_USER_SELECTED',
  ],
  'requiredPermissions': [
    'RECORD_AUDIO', // on-device pronunciation practice only; runtime + prominent disclosure
  ],
  'queriesTts': true,
};

/// Human-readable checklist for reviewers / Play Console.
const playQualityChecklist = '''
Google Play Core App Quality – Security & Data Safety
-----------------------------------------------------
[✓] Target SDK 36
[✓] allowBackup="false" + dataExtractionRules
[✓] usesCleartextTraffic="false" + networkSecurityConfig
[✓] Broad storage permissions removed (tools:node="remove")
[✓] RECORD_AUDIO justified for on-device speech practice (optional, no off-device transmission)
[✓] No INTERNET / ACCESS_NETWORK_STATE declared (fully offline-first)
[✓] Offline-first core flows (SRS, search, vault)
[✓] Encrypted vault (Android Keystore / PBKDF2+AES)
[✓] No mandatory network for learning
[✓] Fail-open root detection (usability)
''';
