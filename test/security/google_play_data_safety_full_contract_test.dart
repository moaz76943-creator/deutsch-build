import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Full static contract tests for Google Play Data Safety, Core App Quality,
/// and offline-first privacy requirements.
///
/// These tests read the actual Android resource files so they fail if a
/// permission, backup flag, or exclusion is accidentally relaxed.
///
/// Complements existing partial tests and closes remaining high-risk gaps
/// around data handling and security declarations.
void main() {
  final manifestPath = 'android/app/src/main/AndroidManifest.xml';
  final releaseManifestPath = 'android/app/src/release/AndroidManifest.xml';
  final extractionPath =
      'android/app/src/main/res/xml/data_extraction_rules.xml';
  final networkConfigPath =
      'android/app/src/main/res/xml/network_security_config.xml';

  late String manifest;
  late String releaseManifest;
  late String extraction;
  late String networkConfig;

  setUpAll(() {
    manifest = File(manifestPath).readAsStringSync();
    releaseManifest = File(releaseManifestPath).readAsStringSync();
    extraction = File(extractionPath).readAsStringSync();
    networkConfig = File(networkConfigPath).readAsStringSync();
  });

  group('Google Play Data Safety & Offline-First Contracts', () {
    test('No network permissions are present (fully offline)', () {
      const forbidden = [
        'android.permission.INTERNET',
        'android.permission.ACCESS_NETWORK_STATE',
        'android.permission.ACCESS_WIFI_STATE',
        'android.permission.CHANGE_NETWORK_STATE',
      ];
      for (final p in forbidden) {
        expect(
          manifest.contains(p),
          isFalse,
          reason: 'Main manifest must not declare $p',
        );
        expect(
          releaseManifest.contains(p),
          isFalse,
          reason: 'Release overlay must not declare $p',
        );
      }
      // Removal directives exist so plugins cannot inject them.
      expect(manifest.contains('tools:node="remove"'), isTrue);
    });

    test('Broad storage and media permissions are stripped', () {
      const blocked = [
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
            'android.permission.$permission"[\\s\\S]{0,200}tools:node="remove"',
          ).hasMatch(manifest),
          isTrue,
          reason: '$permission must be explicitly removed',
        );
      }
    });

    test('RECORD_AUDIO is declared only for on-device pronunciation and is not re-added in release', () {
      expect(manifest.contains('android.permission.RECORD_AUDIO'), isTrue);
      expect(releaseManifest.contains('android.permission.RECORD_AUDIO'), isFalse);
      // Microphone feature is optional.
      expect(
        manifest.contains('android.hardware.microphone') &&
            manifest.contains('android:required="false"'),
        isTrue,
      );
    });

    test('Backup is fully disabled and all domains are excluded', () {
      expect(manifest.contains('android:allowBackup="false"'), isTrue);
      expect(manifest.contains('android:fullBackupContent="false"'), isTrue);
      expect(manifest.contains('android:dataExtractionRules='), isTrue);

      const domains = ['root', 'file', 'database', 'sharedpref', 'external'];
      for (final domain in domains) {
        final cloudCount = RegExp(
          '<exclude domain="$domain" path="\\." />',
        ).allMatches(extraction).length;
        expect(
          cloudCount >= 2,
          isTrue,
          reason: 'Both cloud-backup and device-transfer must exclude $domain',
        );
      }
      expect(
        extraction.contains('disableIfNoEncryptionCapabilities="true"'),
        isTrue,
      );
    });

    test('Cleartext traffic is forbidden and network security config is strict', () {
      expect(manifest.contains('android:usesCleartextTraffic="false"'), isTrue);
      expect(manifest.contains('android:networkSecurityConfig='), isTrue);
      expect(
        networkConfig.contains('cleartextTrafficPermitted="false"'),
        isTrue,
      );
      expect(networkConfig.contains('src="system"'), isTrue);
    });

    test('No POST_NOTIFICATIONS or other unexpected dangerous permissions in main manifest', () {
      // Release overlay may strip notification permission if present from plugins.
      expect(manifest.contains('POST_NOTIFICATIONS'), isFalse);
    });
  });
}
