import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/mastery_calculator.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';

void main() {
  test('rejects negative or impossible mastery calculations', () {
    final reviews = [
      ReviewTransactionEnvelope(reviewEventId: 'e1', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
      ReviewTransactionEnvelope(reviewEventId: 'e2', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 2), languagePairKey: 'ar_de'),
      ReviewTransactionEnvelope(reviewEventId: 'e3', learnerContentKey: 'c1', rating: 2, timestamp: DateTime(2023, 1, 3), languagePairKey: 'ar_de'),
      ReviewTransactionEnvelope(reviewEventId: 'e4', learnerContentKey: 'c2', rating: 2, timestamp: DateTime(2023, 1, 1), languagePairKey: 'ar_de'),
    ];

    // eligible cards is -5, should be clamped to 0
    final proj1 = MasteryCalculator.calculateDomainMastery(
      domainId: 'd1', sourceLanguageId: 'ar', targetLanguageId: 'de', eligibleCardCount: -5, reviews: reviews, masteryRevision: 1,
    );
    expect(proj1.eligibleCardCount, 0);
    expect(proj1.masteredCardCount, 0); // clamped to eligible
    expect(proj1.introducedCardCount, 0); // clamped to eligible

    // eligible is 1, but we have 2 cards introduced. Should be clamped to 1.
    final proj2 = MasteryCalculator.calculateDomainMastery(
      domainId: 'd1', sourceLanguageId: 'ar', targetLanguageId: 'de', eligibleCardCount: 1, reviews: reviews, masteryRevision: 1,
    );
    expect(proj2.eligibleCardCount, 1);
    expect(proj2.introducedCardCount, 1);
    expect(proj2.masteredCardCount, 1);
  });
}
