import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/global_localization_inventory_auditor.dart';

void main() {
  group('GlobalLocalizationInventoryAuditor Unit Tests (L099)', () {
    final auditor = GlobalLocalizationInventoryAuditor();

    test('Certifies clean multi-language inventory with Syriac and Maltese active and Hebrew excluded', () {
      final sampleLocales = ['de', 'ar', 'en', 'syc', 'mt', 'tr', 'fa', 'ckb', 'bs', 'sq'];
      final report = auditor.auditCatalog(sampleLocales);

      expect(report.isHebrewStrictlyExcluded, isTrue);
      expect(report.isSyriacAndMalteseActive, isTrue);
      expect(report.isArabicRtlFullySupported, isTrue);
      expect(report.isUniversalInventoryCertified, isTrue);
    });

    test('Rejects catalog containing prohibited Hebrew code', () {
      final tainted = ['de', 'ar', 'he'];
      final report = auditor.auditCatalog(tainted);
      expect(report.isHebrewStrictlyExcluded, isFalse);
      expect(report.isUniversalInventoryCertified, isFalse);
    });
  });
}
