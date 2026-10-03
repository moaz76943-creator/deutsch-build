import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/service_repair/service_repair_agent.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/service_repair/service_repair_models.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/service_repair/service_repair_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceRepairAgent', () {
    test('covers fault reporting, diagnosis, estimate and repair status', () {
      final agent = ServiceRepairAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(ServiceRepairTopic.faultReport));
      expect(topics, contains(ServiceRepairTopic.diagnosis));
      expect(topics, contains(ServiceRepairTopic.costEstimate));
      expect(topics, contains(ServiceRepairTopic.repairStatus));
    });

    test('filters topics and searches bilingual service terms', () {
      final agent = ServiceRepairAgent();

      agent.setTopic(ServiceRepairTopic.costEstimate);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == ServiceRepairTopic.costEstimate,
        ),
        isTrue,
      );

      agent.setTopic(ServiceRepairTopic.all);
      agent.setQuery('Kostenvoranschlag');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('صيانة');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('service repair hub renders full glass UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ServiceRepairHub()));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Service & Reparatur'), findsOneWidget);
    expect(find.byKey(const ValueKey('service-repair-search')), findsOneWidget);
  });
}
