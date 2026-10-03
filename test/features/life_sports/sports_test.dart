import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_sports/sports_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_sports/sports_models.dart';
import 'package:deutsch_bilarabi/features/life_sports/sports_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SportsMasterOrchestrator', () {
    test('combines gym and community club content by default', () {
      final orchestrator = SportsMasterOrchestrator();

      final facilities =
          orchestrator.visiblePhrases.map((item) => item.facility).toSet();

      expect(facilities, contains(SportsFacilityType.gym));
      expect(facilities, contains(SportsFacilityType.communityClub));
    });

    test('facility switch isolates gym content', () {
      final orchestrator = SportsMasterOrchestrator();

      orchestrator.setFacility(SportsFacilityType.gym);

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.facility == SportsFacilityType.gym,
        ),
        isTrue,
      );
    });

    test('difficulty filter keeps only requested CEFR level', () {
      final orchestrator = SportsMasterOrchestrator();

      orchestrator.setLevel(SportsLevel.b1);

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.level == SportsLevel.b1,
        ),
        isTrue,
      );
    });

    test('search matches German and Arabic community sport terms', () {
      final orchestrator = SportsMasterOrchestrator();

      orchestrator.setQuery('Schwimmen');
      expect(
        orchestrator.visiblePhrases.any(
          (item) => item.facility == SportsFacilityType.communityClub,
        ),
        isTrue,
      );

      orchestrator.setQuery('اشتراك');
      expect(orchestrator.visiblePhrases, isNotEmpty);
    });

    test('membership pause copy remains available independently of filters', () {
      final orchestrator = SportsMasterOrchestrator()
        ..setFacility(SportsFacilityType.communityClub)
        ..setLevel(SportsLevel.b2)
        ..setQuery('athletik');

      expect(orchestrator.membershipPauseGerman, contains('pausieren'));
      expect(orchestrator.membershipPauseArabic, contains('إيقاف'));
    });
  });

  testWidgets(
      'sports hub uses glass shell, safe scrolling, filters and pause bar',
      (tester) async {
    final orchestrator = SportsMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: SportsMasterHub(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Sport & Fitness'), findsOneWidget);
    expect(find.byKey(const ValueKey('sports-search')), findsOneWidget);
    expect(find.byKey(const ValueKey('sports-pause-bar')), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('sports-facility-communityClub'),
      ),
    );
    await tester.pump();

    expect(orchestrator.facility, SportsFacilityType.communityClub);
    expect(
      orchestrator.visiblePhrases.every(
        (item) => item.facility == SportsFacilityType.communityClub,
      ),
      isTrue,
    );

    await tester.tap(find.byKey(const ValueKey('sports-level-b1')));
    await tester.pump();

    expect(orchestrator.level, SportsLevel.b1);
  });
}
