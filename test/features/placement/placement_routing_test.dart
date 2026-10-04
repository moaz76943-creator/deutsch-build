import 'package:deutsch_bilarabi/models/diagnostic_placement.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placement diagnostic route survives persistence round-trip', () {
    final record = PlacementDiagnosticRecord(
      id: 'placement-route',
      at: DateTime.utc(2026, 10, 4),
      answered: 7,
      scoredAnswers: 7,
      score: 91,
      confidence: .92,
      band: DiagnosticPlacementBand.strong,
      dimensionScores: const <DiagnosticDimension, double>{},
      weakDimensions: const <DiagnosticDimension>[],
      reviewItemIds: const <String>[],
      curriculumStartLevel: 'B2',
      recommendedStartTaskOrder: 41,
      learningGoal: 'work',
    );

    final restored = PlacementDiagnosticRecord.fromJson(record.toJson());

    expect(restored.curriculumStartLevel, 'B2');
    expect(restored.recommendedStartTaskOrder, 41);
    expect(restored.learningGoal, 'work');
  });
}
