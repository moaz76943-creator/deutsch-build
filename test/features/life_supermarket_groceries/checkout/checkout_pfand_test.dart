import 'package:deutsch_bilarabi/features/life_supermarket_groceries/checkout/checkout_pfand_models.dart';
import 'package:deutsch_bilarabi/features/life_supermarket_groceries/checkout/checkout_pfand_sub_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutPfandSubAgent', () {
    test('covers Pfandautomat and Pfandbon redemption', () {
      const agent = CheckoutPfandSubAgent();

      final pfand = agent.phrases.where(
        (phrase) => phrase.kind == CheckoutSituation.pfand,
      );

      expect(pfand.length, greaterThanOrEqualTo(3));
      expect(
        pfand.map((phrase) => phrase.german).join(' '),
        allOf(
          contains('Pfandautomat'),
          contains('Pfandbon'),
          contains('Kasse'),
        ),
      );
    });

    test('covers checkout receipt, card payment and loyalty points', () {
      const agent = CheckoutPfandSubAgent();
      final checkoutText = agent.phrases
          .where((phrase) => phrase.kind == CheckoutSituation.checkout)
          .map((phrase) => phrase.german)
          .join(' ');

      expect(checkoutText, contains('Kassenbon'));
      expect(checkoutText, contains('Karte'));
      expect(checkoutText, contains('Payback'));
      expect(checkoutText, contains('Punkte'));
    });

    test('covers wrong products, returns and exchanges', () {
      const agent = CheckoutPfandSubAgent();
      final returns = agent.phrases.where(
        (phrase) => phrase.kind == CheckoutSituation.returnExchange,
      );

      expect(returns.length, greaterThanOrEqualTo(3));
      expect(
        returns.map((phrase) => phrase.german).join(' '),
        allOf(
          contains('falsche'),
          contains('umtauschen'),
          contains('zurückgeben'),
        ),
      );
    });

    test('search works in German and Arabic', () {
      const agent = CheckoutPfandSubAgent();

      expect(agent.search('Pfandbon'), isNotEmpty);
      expect(agent.search('إرجاع'), isNotEmpty);
      expect(agent.search('Payback'), isNotEmpty);
    });
  });
}
