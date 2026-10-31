import 'package:test/test.dart';
import '../../lib/src/content/offline_packs_store_catalog.dart';

void main() {
  group('OfflinePacksStoreCatalog Unit Tests (L083)', () {
    final catalog = OfflinePacksStoreCatalog();

    test('Contains essential language packs with accurate size and CEFR coverage', () {
      expect(OfflinePacksStoreCatalog.catalog.length, greaterThanOrEqualTo(4));

      final deAr = catalog.resolvePack('de', 'ar');
      expect(deAr, isNotNull);
      expect(deAr!.targetLanguageName, equals('Deutsch'));
      expect(deAr.maximumCefrLevel, equals('C1'));
      expect(deAr.totalWordCount, greaterThan(8000));
    });

    test('Strictly excludes prohibited locales from catalog', () {
      for (final pack in OfflinePacksStoreCatalog.catalog) {
        expect(pack.targetLanguageCode, isNot(equals('he')));
        expect(pack.nativeLanguageCode, isNot(equals('he')));
      }
    });
  });
}
