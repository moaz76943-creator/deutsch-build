import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/cleaning_booking/dentist_cleaning_booking_agent.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/cleaning_booking/dentist_cleaning_booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = DentistCleaningBookingAgent();

  test('covers tartar cleaning, PZR and appointment administration', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Zahnstein'));
    expect(corpus, contains('professionelle Zahnreinigung'));
    expect(corpus, contains('Kosten'));
    expect(corpus, contains('Termin'));
    expect(corpus, contains('verschieben'));
    expect(corpus, contains('absagen'));
  });

  test('search works in both languages', () {
    expect(agent.search('Zahnstein'), isNotEmpty);
    expect(agent.search('موعد'), isNotEmpty);
  });

  testWidgets('cleaning booking screen keeps glass and BiDi', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DentistCleaningBookingScreen(
        agent: DentistCleaningBookingAgent(),
      ),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Zahnreinigung & Termin'), findsOneWidget);
  });
}
