import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_outdoors/application/outdoors_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_outdoors/domain/outdoors_models.dart';
import 'package:deutsch_bilarabi/features/life_outdoors/presentation/outdoors_master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OutdoorsMasterOrchestrator', () {
    test('starts in accommodation and keeps content isolated by category', () {
      final orchestrator = OutdoorsMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(orchestrator.category, OutdoorsCategory.accommodation);
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == OutdoorsCategory.accommodation,
        ),
        isTrue,
      );

      orchestrator.switchCategory(OutdoorsCategory.natureHiking);

      expect(orchestrator.category, OutdoorsCategory.natureHiking);
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == OutdoorsCategory.natureHiking,
        ),
        isTrue,
      );
    });

    test('family stay sub-agent covers hostel family stay essentials', () {
      const agent = FamilyStaySubAgent();

      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.textDe} ${item.tags.join(' ')}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('jugendherberge'));
      expect(joined, contains('familienzimmer'));
      expect(joined, contains('frühstück'));
      expect(joined, contains('hausordnung'));
      expect(joined, contains('check-in'));
      expect(joined, contains('check-out'));
    });

    test('nature trails sub-agent covers markers, etiquette, grilling and conservation', () {
      const agent = NatureTrailsSubAgent();

      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.textDe} ${item.tags.join(' ')}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('wegmarkierung'));
      expect(joined, contains('wanderregeln'));
      expect(joined, contains('grillplatz'));
      expect(joined, contains('naturschutzgebiet'));
    });

    test('search is category-aware and matches German or Arabic terms', () {
      final orchestrator = OutdoorsMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.setSearchQuery('Frühstück');
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == OutdoorsCategory.accommodation,
        ),
        isTrue,
      );

      orchestrator.switchCategory(OutdoorsCategory.natureHiking);
      orchestrator.setSearchQuery('شواء');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) => item.category == OutdoorsCategory.natureHiking,
        ),
        isTrue,
      );
    });

    test('switching category clears stale search text', () {
      final orchestrator = OutdoorsMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.setSearchQuery('Frühstück');
      expect(orchestrator.searchQuery, isNotEmpty);

      orchestrator.switchCategory(OutdoorsCategory.natureHiking);

      expect(orchestrator.searchQuery, isEmpty);
    });

    test('trail etiquette bar exposes conservation-first rules', () {
      final orchestrator = OutdoorsMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      final joined = orchestrator.trailRules
          .map((rule) => '${rule.german} ${rule.arabic}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('wegen'));
      expect(joined, contains('müll'));
      expect(joined, contains('grill'));
      expect(joined, contains('naturschutzgebiet'));
    });
  });

  testWidgets('screen uses glass cards, safe scrolling and explicit BiDi', (
    tester,
  ) async {
    final orchestrator = OutdoorsMasterOrchestrator();
    addTearDown(orchestrator.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: OutdoorsMasterScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('outdoors-german-direction')),
    );
    final arabic = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('outdoors-arabic-direction')),
    );

    expect(german.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(find.text('Jugendherberge, Wandern & Naturschutz'), findsOneWidget);
    expect(find.text('Trail Etiquette · قواعد المسار'), findsOneWidget);
  });
}
