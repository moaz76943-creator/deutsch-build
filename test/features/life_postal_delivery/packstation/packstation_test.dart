import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/postal_models.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/packstation/packstation_models.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/packstation/packstation_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/packstation/packstation_screen.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/packstation/packstation_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PackstationSubAgent', () {
    test('covers locker steps, neighbors, loss and free return labels', () {
      const agent = PackstationSubAgent();
      final ids = agent.phrases.map((phrase) => phrase.id);

      expect(
        ids,
        containsAll(<String>[
          'packstation-scan-barcode',
          'packstation-enter-code',
          'packstation-open-locker',
          'delivery-neighbor',
          'delivery-loss',
          'return-free-label',
        ]),
      );

      expect(
        agent.phrases
            .firstWhere((phrase) => phrase.id == 'packstation-scan-barcode')
            .carriers,
        contains(PostalCarrier.dhl),
      );
    });
  });

  group('PackstationOrchestrator', () {
    test('switches workflow domains and searches German and Arabic', () {
      final orchestrator = PackstationOrchestrator();

      expect(orchestrator.scenario, PackstationScenario.packstation);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.scenario == PackstationScenario.packstation,
        ),
        isTrue,
      );

      orchestrator.setQuery('Nachbarn');
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'delivery-neighbor');

      orchestrator
        ..clearSearch()
        ..setScenario(PackstationScenario.deliveryProblems);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'delivery-loss',
        ),
        isTrue,
      );

      orchestrator.setQuery('الإرجاع');
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'return-free-label');
    });
  });

  testWidgets('Packstation screen keeps glass UI and explicit BiDi',
      (tester) async {
    final orchestrator = PackstationOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: PackstationIssuesScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.textContaining('Barcode'), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));

    await tester.tap(
      find.byKey(
        const ValueKey<String>('packstation-scenario-deliveryProblems'),
      ),
    );
    await tester.pump();

    expect(orchestrator.scenario, PackstationScenario.deliveryProblems);
    expect(find.textContaining('Sendungsverlust'), findsWidgets);
  });
}
