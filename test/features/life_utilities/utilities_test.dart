import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_utilities/energy_contracts_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_utilities/meter_and_invoice_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_utilities/utilities_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_utilities/utilities_models.dart';
import 'package:deutsch_bilarabi/features/life_utilities/utilities_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MeterAndInvoiceSubAgent', () {
    test('covers meter number, reading submission, settlement, and Abschlag', () {
      const agent = MeterAndInvoiceSubAgent();

      final ids = agent.phrases.map((phrase) => phrase.id).toSet();
      expect(
        ids,
        containsAll(<String>[
          'meter-identify-number',
          'meter-submit-reading',
          'invoice-annual-settlement',
          'invoice-adjust-payment',
        ]),
      );

      final corpus = agent.phrases
          .expand(
            (phrase) => <String>[
              phrase.german,
              phrase.contextDe,
              ...phrase.keywords,
            ],
          )
          .join(' ');

      expect(corpus, contains('Zählernummer'));
      expect(corpus, contains('Zählerstand'));
      expect(corpus, contains('Nachzahlung'));
      expect(corpus, contains('Guthaben'));
      expect(corpus, contains('Abschlag'));
    });

    test('exposes a dedicated quick meter reading guide', () {
      const agent = MeterAndInvoiceSubAgent();

      expect(agent.quickMeterReadingGuide.id, 'meter-submit-reading');
      expect(agent.quickMeterReadingGuide.german, contains('Zählerstand'));
      expect(agent.quickMeterReadingGuide.german, contains('melden'));
    });
  });

  group('EnergyContractsSubAgent', () {
    test('covers Grundversorger, tariff comparison, and cancellation period', () {
      const agent = EnergyContractsSubAgent();

      final ids = agent.phrases.map((phrase) => phrase.id).toSet();
      expect(
        ids,
        containsAll(<String>[
          'contract-register-move-in',
          'contract-compare-tariffs',
          'contract-cancellation-period',
        ]),
      );

      final corpus = agent.phrases
          .expand(
            (phrase) => <String>[
              phrase.german,
              phrase.contextDe,
              ...phrase.keywords,
            ],
          )
          .join(' ');

      expect(corpus, contains('Grundversorger'));
      expect(corpus, contains('kWh-Preis'));
      expect(corpus, contains('Grundpreis'));
      expect(corpus, contains('Kündigungsfrist'));
    });
  });

  group('UtilitiesMasterOrchestrator', () {
    test('defaults to meter/invoices, searches locally, and switches category', () {
      final orchestrator = UtilitiesMasterOrchestrator();

      expect(
        orchestrator.category,
        UtilitiesCategory.meterReadingsInvoices,
      );

      orchestrator.setQuery('Nachzahlung');
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'invoice-annual-settlement',
      );

      orchestrator.setCategory(UtilitiesCategory.contractsSwitching);
      expect(orchestrator.query, isEmpty);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'contract-compare-tariffs',
        ),
        isTrue,
      );
    });

    test('quick meter guide resets category/search and isolates submission phrase', () {
      final orchestrator = UtilitiesMasterOrchestrator()
        ..setCategory(UtilitiesCategory.contractsSwitching)
        ..setQuery('Tarif');

      orchestrator.openQuickMeterReadingGuide();

      expect(
        orchestrator.category,
        UtilitiesCategory.meterReadingsInvoices,
      );
      expect(orchestrator.query, 'Zählerstand melden');
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'meter-submit-reading',
      );
    });

    test('search supports Arabic household utility terms', () {
      final orchestrator = UtilitiesMasterOrchestrator()
        ..setQuery('قراءة العداد');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'meter-submit-reading',
      );
    });
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, and quick meter bar',
    (tester) async {
      final orchestrator = UtilitiesMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: UtilitiesMasterHub(orchestrator: orchestrator),
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

      expect(find.text('Strom, Gas & Zählerstand'), findsOneWidget);
      expect(find.textContaining('Zählerstand melden'), findsWidgets);

      await tester.tap(
        find.byKey(const ValueKey<String>('utilities-category-contractsSwitching')),
      );
      await tester.pump();

      expect(
        orchestrator.category,
        UtilitiesCategory.contractsSwitching,
      );
      expect(find.textContaining('Grundversorger'), findsWidgets);

      await tester.tap(
        find.byKey(const ValueKey<String>('utilities-quick-meter-guide')),
      );
      await tester.pump();

      expect(
        orchestrator.category,
        UtilitiesCategory.meterReadingsInvoices,
      );
      expect(orchestrator.visiblePhrases.single.id, 'meter-submit-reading');
    },
  );
}
