import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/features/sync/infrastructure/http_cloud_storage_service.dart';
import 'package:deutsch_build/src/core/content/sovereign_content_compliance_validator.dart';
import 'package:deutsch_build/src/ui/bridges/vol_111_ui_bridge.dart';

void main() {
  group('Volume 111 Security & Architecture Integration Tests', () {
    test('PRIV-001: Airgap Network Access Denied when Offline', () async {
      final service = HttpCloudStorageService(offlineModeEnforced: true);

      expect(service.isOfflineModeActive, isTrue);
      expect(
        () => service.uploadPackTelemetry('https://example.com/sync', {}),
        throwsA(isA<NetworkAccessDeniedException>()),
      );

      // Local storage must work seamlessly without network
      await service.storeLocalPack('de_vol_111', Uint8List.fromList([1, 2, 3, 4]));
      final retrieved = await service.getLocalPack('de_vol_111');
      expect(retrieved, isNotNull);
      expect(retrieved!.length, equals(4));
    });

    test('PRIV-003: Sovereign Content Validator Blocks Prohibited Languages & Topics', () {
      // Must allow legitimate language codes
      expect(() => SovereignContentComplianceValidator.validateLanguageCode('de'), returnsNormally);
      expect(() => SovereignContentComplianceValidator.validateLanguageCode('ar'), returnsNormally);

      // Must block prohibited languages
      expect(
        () => SovereignContentComplianceValidator.validateLanguageCode('he'),
        throwsA(isA<SovereignComplianceViolationException>()),
      );
      expect(
        () => SovereignContentComplianceValidator.validateLanguageCode('syc'),
        throwsA(isA<SovereignComplianceViolationException>()),
      );
      expect(
        () => SovereignContentComplianceValidator.validateLanguageCode('ber'),
        throwsA(isA<SovereignComplianceViolationException>()),
      );
      expect(
        () => SovereignContentComplianceValidator.validateLanguageCode('zgh'),
        throwsA(isA<SovereignComplianceViolationException>()),
      );

      // Must block citizenship test topics
      expect(
        () => SovereignContentComplianceValidator.validateContentPackage(
          packageId: 'test_pkg',
          languageCode: 'de',
          lessons: ['Dies ist ein Einbuergerungstest Vorbereitungskurs'],
          zeroPiiAttested: true,
          openLicenseAttested: true,
        ),
        throwsA(isA<SovereignComplianceViolationException>()),
      );
    });

    test('UI Bridge correctly aggregates all 10 verified remediation subsystems', () {
      final bridge = Vol111UIBridge();
      final report = bridge.getSubsystemDiagnosticReport();

      expect(report['volume'], equals(111));
      expect(report['tasks_range'], equals('4821-4832'));
      expect(report['overall_health'], equals('healthy'));
      expect(bridge.verifyLanguageAcceptance('de'), isTrue);
      expect(bridge.verifyLanguageAcceptance('he'), isFalse);
    });
  });
}
