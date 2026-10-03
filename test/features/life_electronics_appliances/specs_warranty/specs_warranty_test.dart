import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/specs_warranty/specs_warranty_agent.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/specs_warranty/specs_warranty_models.dart';
import 'package:deutsch_bilarabi/features/life_electronics_appliances/specs_warranty/specs_warranty_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpecsWarrantyAgent', () {
    test('covers specifications, comparison, warranty and returns', () {
      final agent = SpecsWarrantyAgent();
      final topics = agent.allPhrases.map((item) => item.topic).toSet();

      expect(topics, contains(SpecsWarrantyTopic.specifications));
      expect(topics, contains(SpecsWarrantyTopic.comparison));
      expect(topics, contains(SpecsWarrantyTopic.warranty));
      expect(topics, contains(SpecsWarrantyTopic.returnExchange));
    });

    test('filters topics and searches bilingual product terms', () {
      final agent = SpecsWarrantyAgent();

      agent.setTopic(SpecsWarrantyTopic.warranty);
      expect(
        agent.visiblePhrases.every(
          (item) => item.topic == SpecsWarrantyTopic.warranty,
        ),
        isTrue,
      );

      agent.setTopic(SpecsWarrantyTopic.all);
      agent.setQuery('Garantie');
      expect(agent.visiblePhrases, isNotEmpty);

      agent.setQuery('ذاكرة');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('specs warranty hub renders full glass UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SpecsWarrantyHub()));

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Geräteberatung & Garantie'), findsOneWidget);
    expect(find.byKey(const ValueKey('specs-warranty-search')), findsOneWidget);
  });
}
