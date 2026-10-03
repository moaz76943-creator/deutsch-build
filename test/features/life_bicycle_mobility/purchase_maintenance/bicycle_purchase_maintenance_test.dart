import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/purchase_maintenance/bicycle_purchase_maintenance_agent.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/purchase_maintenance/bicycle_purchase_maintenance_models.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/purchase_maintenance/bicycle_purchase_maintenance_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BicyclePurchaseMaintenanceAgent', () {
    test('covers purchase, fitting and repair topics', () {
      final agent = BicyclePurchaseMaintenanceAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(BicycleShopTopic.purchaseAdvice));
      expect(topics, contains(BicycleShopTopic.fitAndSize));
      expect(topics, contains(BicycleShopTopic.repair));
      expect(topics, contains(BicycleShopTopic.maintenance));
    });

    test('filters by topic and searches bilingual phrases', () {
      final agent = BicyclePurchaseMaintenanceAgent();

      agent.setTopic(BicycleShopTopic.repair);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == BicycleShopTopic.repair,
        ),
        isTrue,
      );

      agent.setTopic(BicycleShopTopic.all);
      agent.setQuery('Reifen');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('فرامل');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('purchase maintenance hub renders full glass UI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BicyclePurchaseMaintenanceHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Fahrradkauf & Werkstatt'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bicycle-shop-search')),
      findsOneWidget,
    );
  });
}
