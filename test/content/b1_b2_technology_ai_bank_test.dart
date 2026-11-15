import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/b1_b2_technology_ai_bank.dart';

void main() {
  group('B1B2TechnologyAiBank Unit Tests (L012)', () {
    test('Contains core tech, AI, and digital privacy terms with accurate Arabic translations', () {
      expect(B1B2TechnologyAiBank.techEntries.length, greaterThanOrEqualTo(5));

      final ai = B1B2TechnologyAiBank.techEntries.firstWhere((e) => e.germanWord == 'die künstliche Intelligenz');
      expect(ai.arabicMeaning, equals('الذكاء الاصطناعي'));

      final privacy = B1B2TechnologyAiBank.techEntries.firstWhere((e) => e.germanWord == 'der Datenschutz');
      expect(privacy.cefrLevel, equals('B2'));

      final algo = B1B2TechnologyAiBank.techEntries.firstWhere((e) => e.germanWord == 'der Algorithmus');
      expect(algo.arabicMeaning, contains('الخوارزمي'));
    });
  });
}
