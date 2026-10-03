import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/fuel_payment/fuel_payment_agent.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/fuel_payment/fuel_payment_models.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/fuel_payment/fuel_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FuelPaymentAgent', () {
    test('covers fuel choice, pump use and payment', () {
      final agent = FuelPaymentAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(FuelPaymentTopic.fuelChoice));
      expect(topics, contains(FuelPaymentTopic.pumpUse));
      expect(topics, contains(FuelPaymentTopic.payment));
      expect(topics, contains(FuelPaymentTopic.receiptHelp));
    });

    test('filters topics and searches bilingual terms', () {
      final agent = FuelPaymentAgent();

      agent.setTopic(FuelPaymentTopic.payment);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == FuelPaymentTopic.payment,
        ),
        isTrue,
      );

      agent.setTopic(FuelPaymentTopic.all);
      agent.setQuery('E10');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('فاتورة');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('fuel payment hub renders complete glass UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FuelPaymentHub()));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Tanken & Bezahlen'), findsOneWidget);
    expect(find.byKey(const ValueKey('fuel-payment-search')), findsOneWidget);
  });
}
