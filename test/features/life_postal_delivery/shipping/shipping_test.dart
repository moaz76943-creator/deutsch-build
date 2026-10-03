import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/postal_models.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/shipping/shipping_models.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/shipping/shipping_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/shipping/shipping_screen.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/shipping/shipping_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShippingSubAgent', () {
    test('covers stamps, registered mail, parcel insurance and pickup', () {
      const agent = ShippingSubAgent();
      final ids = agent.phrases.map((phrase) => phrase.id);

      expect(
        ids,
        containsAll(<String>[
          'shipping-stamp-label',
          'shipping-registered-return-receipt',
          'shipping-weigh-insurance',
          'shipping-pickup-id',
        ]),
      );

      expect(
        agent.phrases
            .firstWhere(
              (phrase) => phrase.id == 'shipping-registered-return-receipt',
            )
            .carriers,
        contains(PostalCarrier.deutschePost),
      );
    });
  });

  group('ShippingOrchestrator', () {
    test('switches scenarios and searches German and Arabic locally', () {
      final orchestrator = ShippingOrchestrator();

      expect(orchestrator.scenario, ShippingScenario.send);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.scenario == ShippingScenario.send,
        ),
        isTrue,
      );

      orchestrator.setQuery('Rückschein');
      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(
        orchestrator.visiblePhrases.single.id,
        'shipping-registered-return-receipt',
      );

      orchestrator
        ..clearSearch()
        ..setScenario(ShippingScenario.pickup);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'shipping-pickup-id',
        ),
        isTrue,
      );

      orchestrator.setQuery('الهوية');
      expect(orchestrator.visiblePhrases, hasLength(1));
    });
  });

  testWidgets('shipping screen keeps glass UI and explicit BiDi',
      (tester) async {
    final orchestrator = ShippingOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: ShippingSendReceiveScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.textContaining('Einschreiben'), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));

    await tester.tap(
      find.byKey(const ValueKey<String>('shipping-scenario-pickup')),
    );
    await tester.pump();

    expect(orchestrator.scenario, ShippingScenario.pickup);
    expect(find.textContaining('Ausweis'), findsWidgets);
  });
}
