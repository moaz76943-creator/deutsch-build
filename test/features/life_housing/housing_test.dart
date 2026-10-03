import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_housing/application/housing_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_housing/domain/housing_models.dart';
import 'package:deutsch_bilarabi/features/life_housing/presentation/housing_master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HousingMasterOrchestrator', () {
    test('starts in apartment hunting at A1/A2 and filters strictly by level', () {
      final orchestrator = HousingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(orchestrator.category, HousingCategory.apartmentHunting);
      expect(orchestrator.level, HousingLevel.a1a2);
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) =>
              item.category == HousingCategory.apartmentHunting &&
              item.level == HousingLevel.a1a2,
        ),
        isTrue,
      );
    });

    test('switches category and level without leaking phrases from other agent', () {
      final orchestrator = HousingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      orchestrator.switchCategory(HousingCategory.maintenanceRepair);
      orchestrator.setLevel(HousingLevel.b2);

      expect(orchestrator.category, HousingCategory.maintenanceRepair);
      expect(orchestrator.level, HousingLevel.b2);
      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (item) =>
              item.category == HousingCategory.maintenanceRepair &&
              item.level == HousingLevel.b2,
        ),
        isTrue,
      );
    });

    test('apartment hunting sub-agent covers landlord, listing, and Kaution', () {
      const agent = ApartmentHuntingSubAgent();

      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.textDe}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('vermieter'));
      expect(joined, contains('anzeige'));
      expect(joined, contains('kaution'));
    });

    test('maintenance sub-agent covers plumbing, heating, and internet', () {
      const agent = MaintenanceRepairSubAgent();

      final joined = agent.phrases
          .map((item) => '${item.titleDe} ${item.textDe}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('wasser'));
      expect(joined, contains('heizung'));
      expect(joined, contains('internet'));
    });

    test('quick-action bar changes with category and records selected action', () {
      final orchestrator = HousingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(
        orchestrator.availableQuickActions,
        contains(HousingQuickAction.contactLandlord),
      );
      expect(
        orchestrator.availableQuickActions,
        contains(HousingQuickAction.askAboutKaution),
      );

      final landlordText = orchestrator.runQuickAction(
        HousingQuickAction.contactLandlord,
      );
      expect(landlordText, contains('Wohnung'));
      expect(
        orchestrator.lastQuickAction,
        HousingQuickAction.contactLandlord,
      );

      orchestrator.switchCategory(HousingCategory.maintenanceRepair);

      expect(
        orchestrator.availableQuickActions,
        containsAll(<HousingQuickAction>[
          HousingQuickAction.reportPlumbing,
          HousingQuickAction.reportHeating,
          HousingQuickAction.arrangeInternet,
        ]),
      );
      expect(
        orchestrator.availableQuickActions,
        isNot(contains(HousingQuickAction.contactLandlord)),
      );
    });

    test('quick actions reject actions owned by the inactive sub-agent', () {
      final orchestrator = HousingMasterOrchestrator();
      addTearDown(orchestrator.dispose);

      expect(
        () => orchestrator.runQuickAction(HousingQuickAction.reportHeating),
        throwsArgumentError,
      );
    });
  });

  testWidgets('housing screen uses glass cards, safe scrolling, and explicit BiDi', (
    tester,
  ) async {
    final orchestrator = HousingMasterOrchestrator();
    addTearDown(orchestrator.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: HousingMasterScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('housing-german-direction')),
    );
    final arabic = tester.widget<Directionality>(
      find.byKey(const ValueKey<String>('housing-arabic-direction')),
    );

    expect(german.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(find.text('Wohnungssuche'), findsWidgets);
    expect(find.text('Handwerker'), findsWidgets);
  });
}
