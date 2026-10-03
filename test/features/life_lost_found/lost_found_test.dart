import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_lost_found/lost_found_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_lost_found/lost_found_models.dart';
import 'package:deutsch_bilarabi/features/life_lost_found/lost_found_screen.dart';
import 'package:deutsch_bilarabi/features/life_lost_found/municipal_lost_property_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_lost_found/transit_recovery_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MunicipalLostPropertySubAgent', () {
    test('covers online search, precise loss report, ownership, and fees', () {
      const agent = MunicipalLostPropertySubAgent();

      final ids = agent.items.map((item) => item.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          'municipal_online_catalog',
          'municipal_loss_report',
          'municipal_ownership_fee',
        }),
      );

      final corpus = agent.items
          .expand(
            (item) => <String>[
              item.titleDe,
              item.german,
              item.arabic,
              item.contextDe,
              item.contextAr,
              ...item.tags,
            ],
          )
          .join(' ');

      expect(corpus, contains('Online-Fundservice'));
      expect(corpus, contains('Farbe'));
      expect(corpus, contains('Marke'));
      expect(corpus, contains('Seriennummer'));
      expect(corpus, contains('Eigentumsnachweis'));
      expect(corpus, contains('Verwaltungsgebühr'));
    });
  });

  group('TransitRecoverySubAgent', () {
    test('covers DB trains, stations, and local bus or tram recovery', () {
      const agent = TransitRecoverySubAgent();

      final ids = agent.items.map((item) => item.id).toSet();
      expect(
        ids,
        containsAll(<String>{
          'transit_db_fundservice',
          'transit_station_platform',
          'transit_local_operator',
          'transit_finder_reward',
        }),
      );

      final corpus = agent.items
          .expand(
            (item) => <String>[
              item.titleDe,
              item.german,
              item.contextDe,
              ...item.tags,
            ],
          )
          .join(' ');

      expect(corpus, contains('DB Fundservice'));
      expect(corpus, contains('Bahnhof'));
      expect(corpus, contains('Verkehrsbetriebe'));
      expect(corpus, contains('Finderlohn'));
    });

    test('calculates statutory finder reward guidance for ordinary finds', () {
      const agent = TransitRecoverySubAgent();

      expect(agent.finderRewardEuro(itemValueEuro: 100), 5);
      expect(agent.finderRewardEuro(itemValueEuro: 1000), 40);
    });

    test('applies public-transport special rule and minimum value threshold', () {
      const agent = TransitRecoverySubAgent();

      expect(
        agent.finderRewardEuro(
          itemValueEuro: 49,
          foundInPublicTransport: true,
        ),
        0,
      );
      expect(
        agent.finderRewardEuro(
          itemValueEuro: 100,
          foundInPublicTransport: true,
        ),
        2.5,
      );
      expect(
        agent.finderRewardEuro(
          itemValueEuro: 1000,
          foundInPublicTransport: true,
        ),
        20,
      );
    });
  });

  group('LostFoundMasterOrchestrator', () {
    test('switches domains and searches German and Arabic content', () {
      final orchestrator = LostFoundMasterOrchestrator();

      expect(orchestrator.domain, LostFoundDomain.municipal);

      orchestrator.setQuery('Seriennummer');
      expect(
        orchestrator.visibleItems.single.id,
        'municipal_loss_report',
      );

      orchestrator.switchDomain(LostFoundDomain.publicTransit);
      orchestrator.setQuery('القطار');
      expect(
        orchestrator.visibleItems.any(
          (item) => item.id == 'transit_db_fundservice',
        ),
        isTrue,
      );
    });

    test('immediate-action checklist tracks loss-report readiness', () {
      final orchestrator = LostFoundMasterOrchestrator();

      expect(orchestrator.immediateActions, hasLength(5));
      expect(orchestrator.completedActionCount, 0);
      expect(orchestrator.isImmediateChecklistComplete, isFalse);

      for (final action in orchestrator.immediateActions) {
        orchestrator.setActionComplete(action.id, true);
      }

      expect(orchestrator.completedActionCount, 5);
      expect(orchestrator.isImmediateChecklistComplete, isTrue);

      orchestrator.setActionComplete(
        orchestrator.immediateActions.first.id,
        false,
      );
      expect(orchestrator.completedActionCount, 4);
      expect(orchestrator.isImmediateChecklistComplete, isFalse);
    });

    test('rejects unknown checklist action ids', () {
      final orchestrator = LostFoundMasterOrchestrator();

      expect(
        () => orchestrator.setActionComplete('unknown', true),
        throwsArgumentError,
      );
    });
  });

  testWidgets(
    'master hub uses glass cards, SafeArea, scrolling, and explicit BiDi',
    (tester) async {
      final orchestrator = LostFoundMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: LostFoundMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final german = tester.widget<AppDirectionalText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppDirectionalText &&
              widget.text == 'Fundbüro & DB Fundservice',
        ),
      );
      expect(german.languageCode, 'de');

      final arabic = tester.widget<AppDirectionalText>(
        find.byWidgetPredicate(
          (widget) =>
              widget is AppDirectionalText &&
              widget.text == 'المفقودات واستعادة الأغراض',
        ),
      );
      expect(arabic.languageCode, 'ar');
    },
  );
}
