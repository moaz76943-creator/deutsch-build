import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_home_services/craft_repair_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_home_services/home_services_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_home_services/home_services_models.dart';
import 'package:deutsch_bilarabi/features/life_home_services/home_services_screen.dart';
import 'package:deutsch_bilarabi/features/life_home_services/locksmith_emergency_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeServicesMasterOrchestrator', () {
    test('defaults to locksmith, searches locally, and switches domains', () {
      final orchestrator = HomeServicesMasterOrchestrator();

      expect(orchestrator.domain, HomeServicesDomain.locksmithEmergency);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'locksmith-door-fell-shut',
        ),
        isTrue,
      );

      orchestrator.setQuery('Festpreis');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.domain == HomeServicesDomain.locksmithEmergency,
        ),
        isTrue,
      );

      orchestrator
        ..clearSearch()
        ..setDomain(HomeServicesDomain.urgentRepairs);

      expect(orchestrator.domain, HomeServicesDomain.urgentRepairs);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'repair-heating-winter',
        ),
        isTrue,
      );
    });

    test('consumer warning bar prioritizes price and identity verification', () {
      final orchestrator = HomeServicesMasterOrchestrator();
      final joined = orchestrator.consumerWarnings
          .map((warning) => '${warning.german} ${warning.arabic}')
          .join(' ')
          .toLowerCase();

      expect(joined, contains('festpreis'));
      expect(joined, contains('anfahrt'));
      expect(joined, contains('rechnung'));
      expect(joined, contains('ausweis'));
      expect(joined, contains('السعر'));
    });
  });

  test('locksmith agent distinguishes shut vs locked door and prevents abuse', () {
    const agent = LocksmithEmergencySubAgent();
    final byId = <String, HomeServicePhrase>{
      for (final phrase in agent.phrases) phrase.id: phrase,
    };

    expect(
      byId['locksmith-door-fell-shut']!.german.toLowerCase(),
      contains('zugefallen'),
    );
    expect(
      byId['locksmith-door-locked']!.german.toLowerCase(),
      contains('abgeschlossen'),
    );
    expect(
      byId['locksmith-fixed-price']!.german,
      contains('verbindlichen Festpreis'),
    );
    expect(
      byId['locksmith-fixed-price']!.german,
      contains('Anfahrt'),
    );
    expect(
      byId['locksmith-credentials']!.german.toLowerCase(),
      anyOf(contains('ausweis'), contains('firma')),
    );
  });

  test('repair agent covers winter heating, blocked drain, leak, and landlord emergency line', () {
    const agent = CraftRepairSubAgent();
    final joined = agent.phrases
        .map((phrase) => '${phrase.german} ${phrase.contextDe}')
        .join(' ')
        .toLowerCase();

    expect(joined, contains('heizung'));
    expect(joined, contains('winter'));
    expect(joined, contains('abfluss'));
    expect(joined, contains('wasser'));
    expect(joined, contains('hausverwaltung'));
    expect(joined, contains('notdienst'));
  });

  test('search matches German and Arabic without crossing active domain', () {
    final orchestrator = HomeServicesMasterOrchestrator()
      ..setQuery('مغلق');

    expect(orchestrator.visiblePhrases, isNotEmpty);
    expect(
      orchestrator.visiblePhrases.every(
        (phrase) => phrase.domain == HomeServicesDomain.locksmithEmergency,
      ),
      isTrue,
    );

    orchestrator
      ..clearSearch()
      ..setDomain(HomeServicesDomain.urgentRepairs)
      ..setQuery('تسرب');

    expect(orchestrator.visiblePhrases, isNotEmpty);
    expect(
      orchestrator.visiblePhrases.every(
        (phrase) => phrase.domain == HomeServicesDomain.urgentRepairs,
      ),
      isTrue,
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, and domain controls',
    (tester) async {
      final orchestrator = HomeServicesMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: HomeServicesMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      expect(
        find.text('Abzocke vermeiden · Festpreis vereinbaren'),
        findsOneWidget,
      );
      expect(find.textContaining('Schlüsseldienst'), findsWidgets);

      await tester.tap(
        find.byKey(
          const ValueKey<String>('home-services-domain-urgentRepairs'),
        ),
      );
      await tester.pump();

      expect(orchestrator.domain, HomeServicesDomain.urgentRepairs);
      expect(find.textContaining('Heizung'), findsWidgets);
    },
  );
}
