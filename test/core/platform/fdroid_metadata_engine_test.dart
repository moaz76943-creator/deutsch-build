import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/platform/fdroid_metadata_engine.dart';

void main() {
  group('FdroidMetadataEngine Tests', () {
    const engine = FdroidMetadataEngine();

    test('Certifies that Polyglot has strictly zero anti-features for F-Droid compliance', () {
      final metadata = engine.buildDefaultMetadata();
      final isClean = engine.verifyZeroAntiFeatures(metadata);

      expect(isClean, isTrue);
      expect(metadata.antiFeatures, isEmpty);
      expect(metadata.license, equals('GPL-3.0-only'));
    });

    test('Generates valid F-Droid YAML recipe format', () {
      final metadata = engine.buildDefaultMetadata();
      final yaml = metadata.toFdroidYamlRecipe(
        versionName: '3.0.0',
        versionCode: 300,
        commitHash: 'a1b2c3d4e5f6',
      );

      expect(yaml, contains('License: GPL-3.0-only'));
      expect(yaml, contains('AutoName: DEUTSCH بالعربي - Polyglot Sovereign'));
      expect(yaml, contains('versionName: 3.0.0'));
      expect(yaml, contains('commit: a1b2c3d4e5f6'));
      expect(yaml, isNot(contains('AntiFeatures:'))); // Zero anti-features badge
    });
  });
}
