import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final release = File('android/app/src/release/AndroidManifest.xml').readAsStringSync();
  final extraction =
      File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();

  test('broad storage permissions are removed, not granted', () {
    const blocked = <String>[
      'MANAGE_EXTERNAL_STORAGE',
      'WRITE_EXTERNAL_STORAGE',
      'READ_EXTERNAL_STORAGE',
      'READ_MEDIA_IMAGES',
      'READ_MEDIA_VIDEO',
      'READ_MEDIA_AUDIO',
      'READ_MEDIA_VISUAL_USER_SELECTED',
    ];
    for (final permission in blocked) {
      expect(
        RegExp(
          'android.permission.$permission"[\\s\\S]{0,120}tools:node="remove"',
        ).hasMatch(manifest),
        isTrue,
        reason: permission,
      );
      expect(
        release.contains('android.permission.$permission'),
        isTrue,
        reason: 'release overlay must also strip $permission',
      );
    }
    expect(manifest.contains('android.permission.RECORD_AUDIO"/>'), isTrue);
    expect(
      manifest.contains('android.permission.RECORD_AUDIO"\n        tools:node="remove"'),
      isFalse,
    );
  });

  test('backup stays off and cleartext traffic is refused', () {
    expect(manifest.contains('android:allowBackup="false"'), isTrue);
    expect(manifest.contains('android:usesCleartextTraffic="false"'), isTrue);
    expect(manifest.contains('android:fullBackupContent="false"'), isTrue);
    expect(
      extraction.contains('disableIfNoEncryptionCapabilities="true"'),
      isTrue,
    );
    expect(extraction.contains('<exclude domain="sharedpref" path="." />'), isTrue);
    expect(release.contains('android.permission.POST_NOTIFICATIONS'), isTrue);
    expect(release.contains('tools:node="remove"'), isTrue);
  });
}
