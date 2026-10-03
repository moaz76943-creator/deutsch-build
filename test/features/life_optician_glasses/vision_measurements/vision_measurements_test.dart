import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/vision_measurements/vision_measurements_agent.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/vision_measurements/vision_measurements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = VisionMeasurementsAgent();

  test('covers sight testing and lens measurements', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Sehschärfe'));
    expect(corpus, contains('Dioptrien'));
    expect(corpus, contains('Zylinder'));
    expect(corpus, contains('Achse'));
    expect(corpus, contains('Pupillendistanz'));
    expect(corpus, contains('Nähe'));
  });

  test('bilingual search returns relevant phrases', () {
    expect(agent.search('Pupillendistanz'), isNotEmpty);
    expect(agent.search('قريب'), isNotEmpty);
  });

  testWidgets('screen is glass based and explicitly bidirectional', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: VisionMeasurementsScreen(agent: VisionMeasurementsAgent()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Sehtest & Messwerte'), findsOneWidget);
  });
}
