import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_app/core/srs/srs_pair_binding.dart';

void main() {
  group('SRS Pair Switching Concurrency', () {
    test('Persists reviews into originating pair when active pair switches mid-write', () async {
      final store = SafePairSrsStore();
      store.currentActivePair = 'de_ar';

      // 1. Dispatch review initiated for German-Arabic pair
      final review1 = SrsReviewEntry(
        pairId: 'de_ar',
        cardId: 'card_de_001',
        rating: 4,
        timestamp: DateTime.now(),
      );

      final writeFuture1 = store.saveReview(review1);

      // 2. Immediate user action: switch active language pair to Spanish-Arabic in the same tick
      store.currentActivePair = 'es_ar';

      // 3. Dispatch review initiated for new pair
      final review2 = SrsReviewEntry(
        pairId: 'es_ar',
        cardId: 'card_es_001',
        rating: 5,
        timestamp: DateTime.now(),
      );

      final writeFuture2 = store.saveReview(review2);

      await Future.wait([writeFuture1, writeFuture2]);

      // 4. Assert absolute isolation between language pairs
      final deReviews = store.getReviewsForPair('de_ar');
      final esReviews = store.getReviewsForPair('es_ar');

      expect(deReviews.length, equals(1));
      expect(deReviews.first.cardId, equals('card_de_001'));
      expect(deReviews.first.pairId, equals('de_ar'));

      expect(esReviews.length, equals(1));
      expect(esReviews.first.cardId, equals('card_es_001'));
      expect(esReviews.first.pairId, equals('es_ar'));
    });
  });
}
