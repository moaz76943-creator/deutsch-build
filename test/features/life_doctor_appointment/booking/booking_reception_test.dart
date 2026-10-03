import 'package:deutsch_bilarabi/features/life_doctor_appointment/booking/booking_reception_agent.dart';
import 'package:deutsch_bilarabi/features/life_doctor_appointment/booking/booking_reception_screen.dart';
import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookingReceptionAgent', () {
    const agent = BookingReceptionAgent();

    test('covers booking, reception, anamnesis and rescheduling', () {
      expect(agent.itemsFor(BookingStage.booking), isNotEmpty);
      expect(agent.itemsFor(BookingStage.reception), isNotEmpty);
      expect(agent.itemsFor(BookingStage.anamnesis), isNotEmpty);
      expect(agent.itemsFor(BookingStage.reschedule), isNotEmpty);

      final corpus = agent.allItems
          .map((item) => '${item.german} ${item.arabic}')
          .join(' ');
      expect(corpus, contains('Doctolib'));
      expect(corpus, contains('Gesundheitskarte'));
      expect(corpus, contains('Anamnesebogen'));
      expect(corpus, contains('verschieben'));
      expect(corpus, contains('absagen'));
    });

    test('search works in German and Arabic', () {
      expect(agent.search('Termin'), isNotEmpty);
      expect(agent.search('الاستقبال'), isNotEmpty);
    });
  });

  testWidgets('booking reception screen uses glass shell and BiDi',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BookingReceptionScreen(agent: BookingReceptionAgent()),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Termin & Empfang'), findsOneWidget);
    expect(find.textContaining('Sprachtraining'), findsOneWidget);
  });
}
