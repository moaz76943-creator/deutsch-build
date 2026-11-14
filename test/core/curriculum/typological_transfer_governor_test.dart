import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/core/curriculum/typological_transfer_governor.dart';

void main() {
  group('TypologicalTransferGovernor Unit Tests (N032)', () {
    final governor = TypologicalTransferGovernor();

    test('Predicts gender barrier and pronoun retention for English to German', () {
      final risks = governor.predictInterferenceRisk(l1: 'en', l2: 'de');

      expect(risks.any((r) => r.contains('Grammatical Gender Barrier')), isTrue);
      expect(risks.any((r) => r.contains('Pronoun Dropping')), isFalse);
    });

    test('Predicts word order and pro-drop transfer for Arabic to German', () {
      final risks = governor.predictInterferenceRisk(l1: 'ar', l2: 'de');

      expect(risks.any((r) => r.contains('Word Order Interference')), isTrue);
      expect(risks.any((r) => r.contains('Pronoun Dropping Risk')), isTrue);
    });

    test('Turkish to German flags SOV word order mismatch', () {
      final risks = governor.predictInterferenceRisk(l1: 'tr', l2: 'de');
      expect(risks.any((r) => r.contains('SOV')), isTrue);
    });
  });
}
