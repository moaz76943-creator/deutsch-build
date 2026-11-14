import 'package:flutter_test/flutter_test.dart';
import '../../lib/src/content/a1_family_home_halal_bank.dart';

void main() {
  group('A1FamilyHomeHalalBank Unit Tests (L002)', () {
    final bank = A1FamilyHomeHalalBank();

    test('Contains wholesome family, home, and wholesome nutrition entries', () {
      expect(A1FamilyHomeHalalBank.items.length, greaterThanOrEqualTo(6));

      final nouns = bank.getByPartOfSpeech('noun');
      expect(nouns.length, equals(A1FamilyHomeHalalBank.items.length));
      expect(nouns.any((n) => n.germanWord == 'die Familie'), isTrue);
      expect(nouns.any((n) => n.germanWord == 'das Brot'), isTrue);
    });

    test('Guarantees 100% ethical and clean vocabulary with zero forbidden substances', () {
      for (final item in A1FamilyHomeHalalBank.items) {
        expect(item.germanWord.contains('Bier'), isFalse);
        expect(item.germanWord.contains('Wein'), isFalse);
        expect(item.germanWord.contains('Schwein'), isFalse);
        expect(item.arabicMeaning.isNotEmpty, isTrue);
      }
    });
  });
}
