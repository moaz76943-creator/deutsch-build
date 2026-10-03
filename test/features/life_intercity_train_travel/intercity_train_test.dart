import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_intercity_train_travel/delay_bahncard_agent.dart';
import 'package:deutsch_bilarabi/features/life_intercity_train_travel/ice_booking_agent.dart';
import 'package:deutsch_bilarabi/features/life_intercity_train_travel/intercity_train_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_intercity_train_travel/intercity_train_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

IntercityTrainTravelMasterHub _hub() => IntercityTrainTravelMasterHub(
      entries: <IntercityPhrase>[
        ...IceBookingAgent.entries,
        ...DelayBahnCardAgent.entries,
      ],
    );

void main() {
  group('IntercityTrainTravelMasterHub', () {
    test('searches ICE delay and BahnCard content', () {
      final hub = _hub();

      expect(hub.visibleEntries.length, 13);

      hub.setQuery('Fensterplatz');
      expect(hub.visibleEntries.single.id, 'ice-seat');

      hub.setQuery('تأخير');
      expect(
        hub.visibleEntries.any((entry) => entry.id == 'delay-current'),
        isTrue,
      );

      hub.setQuery('Kündigungsfrist');
      expect(
        hub.visibleEntries.single.id,
        'bahncard-contract',
      );
    });

    test('category filters isolate BahnCard', () {
      final hub = _hub();
      hub.toggleCategory(IntercityTravelCategory.iceBooking);
      hub.toggleCategory(IntercityTravelCategory.delaySupport);

      expect(
        hub.visibleEntries.every(
          (entry) => entry.category == IntercityTravelCategory.bahnCard,
        ),
        isTrue,
      );
    });

    test('missed connection situation gives direct onward-travel language', () {
      final hub = _hub();
      hub.setSituation(JourneySituation.missedConnection);

      expect(hub.situationPromptDe, contains('Anschluss verpasst'));
      expect(hub.situationPromptDe, contains('nächste Verbindung'));
      expect(hub.situationPromptAr, contains('فاتني'));
    });
  });

  test('branch agents cover booking delays and BahnCard', () {
    final booking = IceBookingAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');
    final support = DelayBahnCardAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');

    expect(booking, contains('ICE-Verbindung'));
    expect(booking, contains('Zugbindung'));
    expect(booking, contains('Sitzplatz'));
    expect(booking, contains('Gleis'));
    expect(support, contains('Verspätung'));
    expect(support, contains('Anschluss verpasst'));
    expect(support, contains('Fahrgastrechte'));
    expect(support, contains('BahnCard'));
    expect(support, contains('Kündigungsfrist'));
  });

  testWidgets('intercity train hub is safe scrollable and bilingual',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: IntercityTrainTravelMasterScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('DB Fernverkehr · ICE · BahnCard'), findsOneWidget);

    final search = find.byKey(const ValueKey<String>('intercity-train-search'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Kündigungsfrist');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('intercity-entry-bahncard-contract')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('intercity-entry-ice-connection')),
      findsNothing,
    );
  });
}
