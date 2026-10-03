import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/automatic_wash/automatic_carwash_agent.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/automatic_wash/automatic_carwash_models.dart';
import 'package:deutsch_bilarabi/features/life_gas_station_carwash/automatic_wash/automatic_carwash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AutomaticCarwashAgent', () {
    test('covers program, preparation, conveyor and aftercare', () {
      final agent = AutomaticCarwashAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(CarwashTopic.program));
      expect(topics, contains(CarwashTopic.preparation));
      expect(topics, contains(CarwashTopic.conveyor));
      expect(topics, contains(CarwashTopic.aftercare));
    });

    test('filters and searches bilingual wash terms', () {
      final agent = AutomaticCarwashAgent();

      agent.setTopic(CarwashTopic.preparation);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == CarwashTopic.preparation,
        ),
        isTrue,
      );

      agent.setTopic(CarwashTopic.all);
      agent.setQuery('Waschcode');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('مرايا');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('automatic wash hub renders complete glass UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AutomaticCarwashHub()));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Automatische Autowäsche'), findsOneWidget);
    expect(find.byKey(const ValueKey('carwash-search')), findsOneWidget);
  });
}
