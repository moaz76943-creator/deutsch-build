import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/release/apk_signature_scheme_v4_pipeline.dart';

void main() {
  group('ApkSignatureSchemeV4Pipeline Tests', () {
    const pipeline = ApkSignatureSchemeV4Pipeline();

    test('Computes v4 Merkle tree root and generates streaming-ready signature manifest', () {
      final dummyApk = Uint8List.fromList(List.generate(10000, (i) => i % 256));

      final manifest = pipeline.signApkPackage(
        apkBytes: dummyApk,
        keyAlias: 'polyglot_release_key',
      );

      expect(manifest.isV4StreamingReady, isTrue);
      expect(manifest.idsigTreeRootHex, contains('idsig_root_'));
      expect(manifest.signatureAlgorithm, equals('SHA256withECDSA'));
      expect(manifest.minAndroidSdkVersion, equals(26));
    });

    test('Strictly rejects downgrade rollback attacks', () {
      final dummyApk = Uint8List.fromList([1, 2, 3, 4]);
      final manifest = pipeline.signApkPackage(apkBytes: dummyApk, keyAlias: 'test');

      // Attempting to install version 200 over currently installed version 300
      final isValid = pipeline.verifySignatureIntegrity(manifest, 300, 200);
      expect(isValid, isFalse);

      // Upgrade version 300 to 301 is permitted
      final isUpgradeValid = pipeline.verifySignatureIntegrity(manifest, 300, 301);
      expect(isUpgradeValid, isTrue);
    });

    test('Manifest serializes to standard release artifact JSON descriptor', () {
      final manifest = pipeline.signApkPackage(
        apkBytes: Uint8List(64),
        keyAlias: 'polyglot_sovereign',
      );
      final json = manifest.toJson();

      expect(json['keyAlias'], equals('polyglot_sovereign'));
      expect(json['isV4StreamingReady'], isTrue);
    });
  });
}
