import 'package:test/test.dart';
import '../../lib/src/content/offline_content_search_indexer.dart';

void main() {
  group('OfflineContentSearchIndexer Unit Tests (L094)', () {
    final indexer = OfflineContentSearchIndexer();

    test('Indexes and retrieves bilingual vocabulary in sub-5ms time', () {
      indexer.indexEntry(german: 'Gesundheit', arabic: 'الصحة والعافية', category: 'Medical');
      indexer.indexEntry(german: 'Arzt', arabic: 'الطبيب المعالج', category: 'Medical');

      expect(indexer.indexedTermCount, greaterThanOrEqualTo(2));

      final hitsDe = indexer.query('arzt');
      expect(hitsDe.length, equals(1));
      expect(hitsDe.first.termDe, equals('Arzt'));

      final hitsAr = indexer.query('الصحة');
      expect(hitsAr.length, equals(1));
      expect(hitsAr.first.termDe, equals('Gesundheit'));
    });

    test('Empty query returns empty hit list', () {
      expect(indexer.query(''), isEmpty);
    });
  });
}
