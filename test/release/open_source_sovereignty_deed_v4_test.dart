import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/release/open_source_sovereignty_deed_v4.dart';

void main() {
  group('OpenSourceSovereigntyDeedV4 Unit Tests (N099)', () {
    final deed = OpenSourceSovereigntyDeedV4();

    test('Confirms complete offline sovereignty and Apache-2.0 license deed', () {
      final report = deed.auditSovereignty();

      expect(report.releaseVersion, equals('4.0.0-GOLD-MASTER'));
      expect(report.licenseType, equals('Apache-2.0'));
      expect(report.isZeroCloudVerified, isTrue);
      expect(report.isTelemetryForbidden, isTrue);
      expect(report.isProhibitedLocaleAuditPassed, isTrue);
      expect(report.legalDeclaration, contains('Learners own 100% of their data'));
    });

    test('Prohibited locales list covers Hebrew exclusions without exception', () {
      expect(OpenSourceSovereigntyDeedV4.strictlyProhibitedLocales.contains('he'), isTrue);
      expect(OpenSourceSovereigntyDeedV4.strictlyProhibitedLocales.contains('iw'), isTrue);
      expect(OpenSourceSovereigntyDeedV4.strictlyProhibitedLocales.contains('heb'), isTrue);
    });
  });
}
