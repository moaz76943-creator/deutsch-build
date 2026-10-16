import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/gamification/domain_mastery_projection.dart';

DomainMasteryProjection projection({
  required int eligible, required int introduced,
  required int recalled, required int mastered, required int due,
}) => DomainMasteryProjection(
  domainId: 'food', sourceLanguageId: 'de', targetLanguageId: 'ar',
  eligibleCardCount: eligible, introducedCardCount: introduced,
  recalledCardCount: recalled, masteredCardCount: mastered,
  dueCardCount: due, lastEvidenceUtc: DateTime.utc(2026),
  masteryRevision: 1,
);

void main() {
  test('negative or impossible counts cannot report mastered domain', () {
    final invalid = projection(eligible: 10, introduced: 2,
        recalled: 1, mastered: 10, due: -1);
    expect(invalid.masteryPercentage, 0.0);
    expect(invalid.masteryState, isNot(DomainMasteryState.mastered));
  });

  test('consistent full completion is still supported', () {
    final valid = projection(eligible: 3, introduced: 3,
        recalled: 3, mastered: 3, due: 0);
    expect(valid.masteryPercentage, 1.0);
    expect(valid.masteryState, DomainMasteryState.mastered);
  });
}
