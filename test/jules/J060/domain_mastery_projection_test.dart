import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';

void main() {
  group('DomainMasteryProjection J060', () {
    test('mastery percentage calculates correctly', () {
      final projection = DomainMasteryProjection(
        domainId: 'domain_1',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        eligibleCardCount: 10,
        introducedCardCount: 5,
        recalledCardCount: 3,
        masteredCardCount: 2,
        dueCardCount: 2,
        lastEvidenceUtc: DateTime.now(),
        masteryRevision: 1,
      );

      expect(projection.masteryPercentage, 0.2); // 2 / 10
      expect(projection.masteryState, DomainMasteryState.inProgress);
    });

    test('mastered state', () {
       final projection = DomainMasteryProjection(
        domainId: 'domain_1',
        sourceLanguageId: 'ar',
        targetLanguageId: 'de',
        eligibleCardCount: 10,
        introducedCardCount: 10,
        recalledCardCount: 10,
        masteredCardCount: 10,
        dueCardCount: 0,
        lastEvidenceUtc: DateTime.now(),
        masteryRevision: 1,
      );

      expect(projection.masteryPercentage, 1.0);
      expect(projection.masteryState, DomainMasteryState.mastered);
    });
  });
}
