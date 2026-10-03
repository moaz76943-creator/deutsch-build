import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/life_haircut_barbershop/payment/payment_summary.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/payment/washing_payment_agent.dart';
import 'package:deutsch_bilarabi/features/life_haircut_barbershop/styles/haircut_phrase.dart';

void main() {
  const agent = WashingPaymentAgent();

  test('covers washing, drying and water temperature requests', () {
    final text =
        agent.washingPhrases.map((phrase) => phrase.german).join(' ').toLowerCase();

    expect(text, contains('waschen'));
    expect(text, contains('föhnen'));
    expect(text, anyOf(contains('wasser'), contains('heiß')));
  });

  test('covers ordinary shampoo and basic hair care', () {
    final text =
        agent.carePhrases.map((phrase) => phrase.german).join(' ').toLowerCase();

    expect(text, contains('shampoo'));
    expect(text, contains('pflege'));
  });

  test('covers cash desk, invoice and customary tip language', () {
    final text =
        agent.paymentPhrases.map((phrase) => phrase.german).join(' ').toLowerCase();

    expect(text, contains('kasse'));
    expect(text, contains('rechnung'));
    expect(text, contains('trinkgeld'));
  });

  test('search filters washing and payment content by level', () {
    final result = agent.search('bitte', level: HaircutLevel.a1a2);

    expect(result, isNotEmpty);
    expect(result.every((phrase) => phrase.level == HaircutLevel.a1a2), isTrue);
  });

  test('payment summary keeps tip separate and calculates total', () {
    final summary = SalonPaymentSummary(
      serviceTotal: 24,
      tip: 3,
      receiptRequested: true,
    );

    expect(summary.total, 27);
    expect(summary.tip, 3);
    expect(summary.receiptRequested, isTrue);
  });

  test('payment summary rejects negative values', () {
    expect(
      () => SalonPaymentSummary(serviceTotal: -1, tip: 0),
      throwsArgumentError,
    );
    expect(
      () => SalonPaymentSummary(serviceTotal: 10, tip: -1),
      throwsArgumentError,
    );
  });
}
