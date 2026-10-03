import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/anmeldung/anmeldung_appointments_agent.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/anmeldung/anmeldung_models.dart';
import 'package:deutsch_bilarabi/features/life_public_offices/anmeldung/anmeldung_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnmeldungAppointmentsAgent', () {
    test('covers Anmeldung, Ummeldung and Meldebestätigung', () {
      final agent = AnmeldungAppointmentsAgent();
      final actions = agent.allPhrases.map((item) => item.registrationAction).toSet();

      expect(actions, contains(RegistrationAction.anmeldung));
      expect(actions, contains(RegistrationAction.ummeldung));
      expect(actions, contains(RegistrationAction.meldebestaetigung));
    });

    test('filters appointment scenarios', () {
      final agent = AnmeldungAppointmentsAgent();

      agent.setAppointmentAction(AppointmentAction.reschedule);

      expect(agent.visiblePhrases, isNotEmpty);
      expect(
        agent.visiblePhrases.every(
          (item) => item.appointmentAction == AppointmentAction.reschedule,
        ),
        isTrue,
      );
    });

    test('searches bilingual counter phrases', () {
      final agent = AnmeldungAppointmentsAgent();

      agent.setQuery('Meldebestätigung');
      expect(
        agent.visiblePhrases.any(
          (item) => item.registrationAction == RegistrationAction.meldebestaetigung,
        ),
        isTrue,
      );

      agent.setQuery('موعد');
      expect(agent.visiblePhrases, isNotEmpty);
    });
  });

  testWidgets('Anmeldung hub renders safe glass UI', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AnmeldungAppointmentsHub()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Anmeldung & Termine'), findsOneWidget);
    expect(find.byKey(const ValueKey('anmeldung-search')), findsOneWidget);
  });
}
