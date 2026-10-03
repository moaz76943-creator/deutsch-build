import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_travel_agency/flight_hotel_booking_agent.dart';
import 'package:deutsch_bilarabi/features/life_travel_agency/holiday_package_agent.dart';
import 'package:deutsch_bilarabi/features/life_travel_agency/travel_agency_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_travel_agency/travel_agency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TravelAgencyMasterHub _hub() => TravelAgencyMasterHub(
      entries: <TravelAgencyPhrase>[
        ...FlightHotelBookingAgent.entries,
        ...HolidayPackageAgent.entries,
      ],
    );

void main() {
  group('TravelAgencyMasterHub', () {
    test('starts with three categories and bilingual search', () {
      final hub = _hub();

      expect(hub.selected.length, 3);
      expect(hub.visibleEntries.length, 12);

      hub.setQuery('Stornierung');
      expect(hub.visibleEntries, isNotEmpty);
      expect(
        hub.visibleEntries.any((entry) => entry.id == 'flight-change-rules'),
        isTrue,
      );

      hub.setQuery('مطار');
      expect(
        hub.visibleEntries.any((entry) => entry.id == 'holiday-transfer'),
        isTrue,
      );
    });

    test('category filters isolate hotels', () {
      final hub = _hub();
      hub.toggleCategory(TravelAgencyCategory.flights);
      hub.toggleCategory(TravelAgencyCategory.holidays);

      expect(
        hub.visibleEntries.every(
          (entry) => entry.category == TravelAgencyCategory.hotels,
        ),
        isTrue,
      );
    });

    test('trip planner clamps travellers and records flexible dates', () {
      final hub = _hub();

      hub.setDestination('Hamburg');
      hub.setTravellers(20);
      hub.toggleFlexibleDates();

      expect(hub.tripSummary.destination, 'Hamburg');
      expect(hub.tripSummary.travellers, 9);
      expect(hub.tripSummary.flexibleDates, isTrue);
      expect(hub.tripSummary.german, contains('Hamburg'));
      expect(hub.tripSummary.arabic, contains('نعم'));
    });
  });

  test('branch agents fully cover required travel domains', () {
    final flightHotel = FlightHotelBookingAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');
    final holiday = HolidayPackageAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');

    expect(flightHotel, contains('Hin- und Rückflug'));
    expect(flightHotel, contains('Gepäck'));
    expect(flightHotel, contains('Familienzimmer'));
    expect(flightHotel, contains('Check-in'));
    expect(holiday, contains('Pauschalreise'));
    expect(holiday, contains('Flughafentransfer'));
    expect(holiday, contains('Reiserücktritt'));
  });

  testWidgets('travel agency screen uses safe glass bilingual master hub',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: TravelAgencyMasterScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Reisebüro · Flüge · Hotels · Urlaub'), findsOneWidget);

    final search = find.byKey(const ValueKey<String>('travel-agency-search'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Familienzimmer');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('travel-entry-hotel-family-room')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('travel-entry-flight-round-trip')),
      findsNothing,
    );
  });
}
