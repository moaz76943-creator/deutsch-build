import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/platform/fdroid_reproducible_packager.dart';

void main() {
  group('FdroidReproduciblePackager Unit Tests (N085)', () {
    final packager = FdroidReproduciblePackager();

    const sampleManifest = FdroidBuildManifest(
      applicationId: 'com.polyglot.sovereign',
      versionName: '4.0.0',
      versionCode: 400,
      commitHash: 'f9aec727',
      license: 'Apache-2.0',
      hasZeroProprietaryBlobs: true,
      buildCommand: 'flutter build apk --release --split-per-abi',
    );

    test('Generates valid F-Droid YAML specification containing education categories', () {
      final yaml = packager.generateFdroidYaml(sampleManifest);
      expect(yaml, contains('Categories:'));
      expect(yaml, contains('License: Apache-2.0'));
      expect(yaml, contains('versionName: 4.0.0'));
      expect(yaml, contains('versionCode: 400'));
      expect(yaml, contains('commit: f9aec727'));
    });

    test('Passes strict zero proprietary blob sovereignty verification', () {
      final isCompliant = packager.verifyZeroProprietaryBlobs(sampleManifest);
      expect(isCompliant, isTrue);
    });

    test('Fails verification if proprietary blobs or non-FOSS licenses are detected', () {
      const taintedManifest = FdroidBuildManifest(
        applicationId: 'com.test',
        versionName: '1.0',
        versionCode: 1,
        commitHash: '123',
        license: 'Proprietary',
        hasZeroProprietaryBlobs: false,
        buildCommand: '',
      );
      expect(packager.verifyZeroProprietaryBlobs(taintedManifest), isFalse);
    });
  });
}
