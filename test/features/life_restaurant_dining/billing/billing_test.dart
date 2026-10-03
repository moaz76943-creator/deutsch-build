import 'package:deutsch_bilarabi/features/life_restaurant_dining/billing/billing_models.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/billing/feedback_agent.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/billing/payment_agent.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/billing/tipping_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('payment agent covers bill request, together, separate, cash, and card', () {
    const agent = PaymentAgent();
    final ids = agent.phrases.map((item) => item.id);

    expect(
      ids,
      containsAll(<String>[
        'bill-request',
        'bill-together',
        'bill-separate',
        'payment-card',
        'payment-cash',
      ]),
    );
  });

  test('tipping agent explains voluntary tipping and rounding language', () {
    const agent = TippingAgent();

    expect(agent.cultureNoteDe, contains('freiwillig'));
    expect(
      agent.phrases.map((item) => item.id),
      containsAll(<String>['tip-stimmt-so', 'tip-round-total']),
    );
    expect(agent.roundedTotalPhrase(32), 'Machen Sie bitte 32 Euro.');
  });

  test('feedback agent provides polite satisfaction and correction phrases', () {
    const agent = FeedbackAgent();
    final byId = <String, BillingPhrase>{
      for (final phrase in agent.phrases) phrase.id: phrase,
    };

    expect(byId['feedback-satisfied']?.kind, BillingPhraseKind.feedback);
    expect(byId['feedback-wrong-order']?.german, contains('bestellt'));
    expect(byId['feedback-cold-food']?.german, contains('kalt'));
  });
}
