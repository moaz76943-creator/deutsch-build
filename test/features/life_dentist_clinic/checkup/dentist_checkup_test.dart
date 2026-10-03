import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/checkup/dentist_checkup_agent.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/checkup/dentist_checkup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = DentistCheckupAgent();

  test('covers periodic examination and symptom descriptions', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Kontrolluntersuchung'));
    expect(corpus, contains('Zahnfleisch'));
    expect(corpus, contains('empfindlich'));
    expect(corpus, contains('Röntgenbild'));
    expect(corpus, contains('Befund'));
  });

  test('bilingual search finds examination language', () {
    expect(agent.search('Zahnfleisch'), isNotEmpty);
    expect(agent.search('اللثة'), isNotEmpty);
  });

  testWidgets('checkup screen keeps glass and scroll architecture', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DentistCheckupScreen(agent: DentistCheckupAgent()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Kontrolle & Befund'), findsOneWidget);
  });
}
