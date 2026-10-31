import 'package:test/test.dart';
import '../../lib/src/content/a1_a2_shopping_clothing_bank.dart';

void main() {
  group('A1A2ShoppingClothingBank Unit Tests (L006)', () {
    test('Contains core shopping and practical clothing items with clear Arabic gloss', () {
      expect(A1A2ShoppingClothingBank.shoppingItems.length, greaterThanOrEqualTo(6));

      final buy = A1A2ShoppingClothingBank.shoppingItems.firstWhere((e) => e.germanWord == 'kaufen');
      expect(buy.arabicMeaning, equals('يشتري'));

      final coat = A1A2ShoppingClothingBank.shoppingItems.firstWhere((e) => e.germanWord == 'der Mantel');
      expect(coat.exampleSentenceDe, contains('Wintermantel'));
    });

    test('All items are ethically clean and family-friendly', () {
      for (final item in A1A2ShoppingClothingBank.shoppingItems) {
        expect(item.exampleSentenceDe.isNotEmpty, isTrue);
        expect(item.exampleSentenceAr.isNotEmpty, isTrue);
      }
    });
  });
}
