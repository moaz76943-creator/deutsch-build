import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/i18n/canonical_language_catalog.dart';

void main() {
  group('CanonicalLanguageCatalog - 100-Language Core Architecture', () {
    test('catalog contains exactly 100 registered languages', () {
      expect(CanonicalLanguageCatalog.totalCount, equals(100));
      expect(CanonicalLanguageCatalog.getAllProfiles().length, equals(100));
    });

    test('BCP 47 codes and ISO 15924 scripts are valid and unique', () {
      final codes = <String>{};
      for (final profile in CanonicalLanguageCatalog.getAllProfiles()) {
        expect(profile.bcp47.isNotEmpty, isTrue);
        expect(profile.nativeName.isNotEmpty, isTrue);
        expect(profile.nameAr.isNotEmpty, isTrue);
        expect(profile.flag.isNotEmpty, isTrue);
        expect(profile.script.code.isNotEmpty, isTrue);
        expect(codes.contains(profile.bcp47), isFalse, reason: 'Duplicate code: ${profile.bcp47}');
        codes.add(profile.bcp47);
      }
      expect(codes.length, equals(100));
    });

    test('RTL languages are correctly identified by ISO 15924 script profile', () {
      final rtlProfiles = CanonicalLanguageCatalog.getRtlProfiles();
      final rtlCodes = rtlProfiles.map((p) => p.bcp47).toSet();
      
      // Known RTL languages in the 100 catalog: ar, fa, ur, ps, sd, ku, yi
      expect(rtlCodes.contains('ar'), isTrue);
      expect(rtlCodes.contains('fa'), isTrue);
      expect(rtlCodes.contains('ur'), isTrue);
      expect(rtlCodes.contains('ps'), isTrue);
      expect(rtlCodes.contains('sd'), isTrue);
      expect(rtlCodes.contains('ku'), isTrue);
      expect(rtlCodes.contains('yi'), isTrue);

      // Owner policy: Hebrew is permanently excluded from the supported registry.
      expect(rtlCodes.contains('he'), isFalse);
      expect(CanonicalLanguageCatalog.getProfile('he'), isNull);

      // LTR languages must not be RTL
      expect(CanonicalLanguageCatalog.getProfile('de')!.isRtl, isFalse);
      expect(CanonicalLanguageCatalog.getProfile('en')!.isRtl, isFalse);
      expect(CanonicalLanguageCatalog.getProfile('zh')!.isRtl, isFalse);
      expect(CanonicalLanguageCatalog.getProfile('ru')!.isRtl, isFalse);
    });

    test('Readiness state distinguishes production-ready from registered', () {
      final de = CanonicalLanguageCatalog.getProfile('de')!;
      final ar = CanonicalLanguageCatalog.getProfile('ar')!;
      final ja = CanonicalLanguageCatalog.getProfile('ja')!;

      expect(de.isProductionReady, isTrue);
      expect(ar.isProductionReady, isTrue);
      expect(ja.readiness, equals(LanguageReadiness.registered));
      expect(ja.isProductionReady, isFalse);
    });

    test('DirectedPairRegistry enforces valid pairs, prevents reflexive pairs, and manages active pair', () {
      DirectedPairRegistry.clearActivePair();
      expect(DirectedPairRegistry.activePairId, isNull);

      DirectedPairRegistry.setActivePair('ar', 'de');
      expect(DirectedPairRegistry.activePairId, equals('ar_de'));

      DirectedPairRegistry.setActivePair('de', 'ar');
      expect(DirectedPairRegistry.activePairId, equals('de_ar'));

      // Reflexive pair throws
      expect(() => DirectedPairRegistry.setActivePair('de', 'de'), throwsArgumentError);
      expect(() => DirectedPairRegistry.setActivePair('ar', 'ar'), throwsArgumentError);

      // Unsupported code throws
      expect(() => DirectedPairRegistry.setActivePair('xyz', 'de'), throwsArgumentError);
    });
  });
}
