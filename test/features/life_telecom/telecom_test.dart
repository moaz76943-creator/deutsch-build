import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_telecom/home_internet_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_telecom/mobile_and_sim_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_telecom/telecom_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_telecom/telecom_models.dart';
import 'package:deutsch_bilarabi/features/life_telecom/telecom_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TelecomMasterOrchestrator', () {
    test('defaults to home internet, searches locally, and switches domains', () {
      final orchestrator = TelecomMasterOrchestrator();

      expect(orchestrator.domain, TelecomDomain.homeInternet);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'home-router-setup',
        ),
        isTrue,
      );

      orchestrator.setQuery('Technikerfenster');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'home-technician-window',
      );

      orchestrator
        ..clearSearch()
        ..setDomain(TelecomDomain.mobilePrepaid)
        ..setQuery('PostIdent');

      expect(orchestrator.domain, TelecomDomain.mobilePrepaid);
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'mobile-identity-verification',
      );
    });

    test('network outage action bar exposes safe troubleshooting guidance', () {
      final orchestrator = TelecomMasterOrchestrator();

      expect(orchestrator.outageHelpExpanded, isFalse);
      expect(orchestrator.outageSteps, hasLength(4));

      orchestrator.expandOutageHelp();

      expect(orchestrator.outageHelpExpanded, isTrue);
      expect(
        orchestrator.outageSteps.map((step) => step.german).join(' '),
        allOf(
          contains('Router'),
          contains('Kabel'),
          contains('Störungsmeldung'),
        ),
      );
      expect(
        orchestrator.outagePrompt.german,
        contains('Störung'),
      );

      orchestrator.dismissOutageHelp();
      expect(orchestrator.outageHelpExpanded, isFalse);
    });
  });

  test('home internet agent covers router, technician, contract and bandwidth', () {
    const agent = HomeInternetSubAgent();
    final searchable = agent.phrases
        .expand(
          (phrase) => <String>[
            phrase.topicDe,
            phrase.german,
            ...phrase.keywords,
          ],
        )
        .join(' ');

    expect(searchable, contains('Router einrichten'));
    expect(searchable, contains('Technikerfenster'));
    expect(searchable, contains('Glasfaser'));
    expect(searchable, contains('Kabel'));
    expect(searchable, contains('DSL'));
    expect(searchable, contains('Vertragslaufzeit'));
    expect(searchable, contains('Bandbreite messen'));
  });

  test('mobile agent covers prepaid activation, identity and number porting', () {
    const agent = MobileAndSimSubAgent();
    final searchable = agent.phrases
        .expand(
          (phrase) => <String>[
            phrase.topicDe,
            phrase.german,
            ...phrase.keywords,
          ],
        )
        .join(' ');

    expect(searchable, contains('Prepaid-Aktivierung'));
    expect(searchable, contains('Video-Ident'));
    expect(searchable, contains('PostIdent'));
    expect(searchable, contains('Rufnummernmitnahme'));
  });

  testWidgets(
    'telecom hub uses glass cards, safe scrolling, BiDi, domain switching and outage help',
    (tester) async {
      final orchestrator = TelecomMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: TelecomMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      expect(find.textContaining('Router einrichten'), findsWidgets);

      final mobileDomain = find.byKey(
        const ValueKey<String>('telecom-domain-mobilePrepaid'),
      );
      await tester.ensureVisible(mobileDomain);
      await tester.tap(mobileDomain);
      await tester.pump();

      expect(orchestrator.domain, TelecomDomain.mobilePrepaid);
      expect(find.textContaining('Prepaid'), findsWidgets);

      final search =
          find.byKey(const ValueKey<String>('telecom-search-field'));
      await tester.ensureVisible(search);
      await tester.enterText(search, 'Rufnummernmitnahme');
      await tester.pump();

      expect(
        find.byKey(
          const ValueKey<String>('telecom-phrase-mobile-number-porting'),
        ),
        findsOneWidget,
      );

      final outage =
          find.byKey(const ValueKey<String>('telecom-outage-action-bar'));
      await tester.ensureVisible(outage);
      await tester.tap(outage);
      await tester.pumpAndSettle();

      expect(orchestrator.outageHelpExpanded, isTrue);
      expect(find.text('Störungshilfe'), findsWidgets);
      expect(find.textContaining('Störungsmeldung'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}
