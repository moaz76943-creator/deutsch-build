import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/platform/android15_permissions_governor.dart';

void main() {
  group('Android15PermissionsGovernor Tests', () {
    test('Microphone permission rationale delivers strict on-device privacy guarantee', () {
      final governor = Android15PermissionsGovernor();
      final rationale = governor.getRationale(SovereignPermissionType.recordAudio);

      expect(rationale.androidManifestKey, equals('android.permission.RECORD_AUDIO'));
      expect(rationale.privacyGuaranteeExplanation, contains('100% Offline'));
      expect(rationale.isStrictlyOptional, isTrue);
    });

    test('Provides graceful keyboard fallback when microphone permission is denied', () {
      final governor = Android15PermissionsGovernor();
      governor.updatePermissionStatus(SovereignPermissionType.recordAudio, false);

      expect(governor.isGranted(SovereignPermissionType.recordAudio), isFalse);
      final fallback = governor.resolveFallbackStrategy(SovereignPermissionType.recordAudio);
      expect(fallback, contains('FALLBACK_KEYBOARD_TEXT_INPUT'));
    });

    test('Supports Android 15 foreground media playback permission rationale', () {
      final governor = Android15PermissionsGovernor();
      final rationale = governor.getRationale(SovereignPermissionType.mediaPlaybackForeground);

      expect(rationale.androidManifestKey, equals('android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK'));
      expect(rationale.userTitle, contains('Hintergrund-Audiowiedergabe'));
    });
  });
}
