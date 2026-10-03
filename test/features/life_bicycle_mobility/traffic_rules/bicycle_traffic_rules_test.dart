import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/traffic_rules/bicycle_traffic_rules_agent.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/traffic_rules/bicycle_traffic_rules_models.dart';
import 'package:deutsch_bilarabi/features/life_bicycle_mobility/traffic_rules/bicycle_traffic_rules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BicycleTrafficRulesAgent', () {
    test('covers lanes, signals, lighting and safe riding', () {
      final agent = BicycleTrafficRulesAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(BicycleRuleTopic.cycleLane));
      expect(topics, contains(BicycleRuleTopic.trafficSignals));
      expect(topics, contains(BicycleRuleTopic.lighting));
      expect(topics, contains(BicycleRuleTopic.safeRiding));
    });

    test('filters by topic and searches bilingual safety phrases', () {
      final agent = BicycleTrafficRulesAgent();

      agent.setTopic(BicycleRuleTopic.lighting);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == BicycleRuleTopic.lighting,
        ),
        isTrue,
      );

      agent.setTopic(BicycleRuleTopic.all);
      agent.setQuery('Radweg');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('إشارة');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('traffic rules hub renders safe glass UI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: BicycleTrafficRulesHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Fahrrad im Straßenverkehr'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('bicycle-rules-search')),
      findsOneWidget,
    );
  });
}
