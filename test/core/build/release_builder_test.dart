import 'package:test/test.dart';
import 'package:deutsch_build/src/core/build/release_builder.dart';

void main() {
  group('ReleaseBuilder Production APK Tests', () {
    const builder = ReleaseBuilder();

    test('Generates production release metadata confirming 100/100 tasks and sovereignty', () {
      final manifest = builder.generateReleaseManifest();

      expect(manifest.totalTasksCompleted, equals(100));
      expect(manifest.releaseApkName, equals('polyglot-release.apk'));
      expect(manifest.is16KbPageAligned, isTrue);
      expect(manifest.isZeroTelemetryVerified, isTrue);
      expect(manifest.isOfflineSovereign, isTrue);
      expect(manifest.toJson()['status'], equals('PRODUCTION_RELEASE_READY'));
    });
  });
}
