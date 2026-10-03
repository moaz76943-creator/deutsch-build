import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/postal_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/postal_models.dart';
import 'package:deutsch_bilarabi/features/life_postal_delivery/postal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('postal shared models', () {
    test('normalizes tracking numbers without changing user-visible value', () {
      const tracking = PostalTrackingNumber(
        carrier: PostalCarrier.dhl,
        value: 'JD 01 234 567 DE',
      );

      expect(tracking.value, 'JD 01 234 567 DE');
      expect(tracking.normalized, 'JD01234567DE');
      expect(tracking.carrier.labelDe, 'DHL');
    });

    test('parcel dimensions expose a compact German size label', () {
      const size = ParcelDimensions(
        lengthCm: 40,
        widthCm: 30,
        heightCm: 15,
        weightKg: 2.5,
      );

      expect(size.dimensionLabelDe, '40 × 30 × 15 cm');
      expect(size.weightLabelDe, '2.5 kg');
    });

    test('notification card keeps pickup location and deadline explicit', () {
      const card = DeliveryNotificationCard(
        carrier: PostalCarrier.deutschePost,
        pickupLocation: 'Filiale 123',
        pickupDeadline: '12.10.2026',
        referenceNumber: 'BN-2048',
      );

      expect(card.pickupLocation, 'Filiale 123');
      expect(card.pickupDeadline, '12.10.2026');
      expect(card.referenceNumber, 'BN-2048');
    });
  });

  group('PostalDeliveryMasterOrchestrator', () {
    test('switches service areas and searches bilingual overview actions', () {
      final orchestrator = PostalDeliveryMasterOrchestrator();

      expect(orchestrator.area, PostalServiceArea.shipping);
      expect(orchestrator.visibleActions, isNotEmpty);

      orchestrator.setQuery('Packstation');
      expect(orchestrator.visibleActions, hasLength(1));
      expect(
        orchestrator.visibleActions.single.area,
        PostalServiceArea.packstationIssues,
      );

      orchestrator
        ..clearSearch()
        ..setArea(PostalServiceArea.packstationIssues);
      expect(orchestrator.area, PostalServiceArea.packstationIssues);
    });

    test('module exposes stable route and creates isolated orchestrators', () {
      const module = PostalDeliveryModule();

      expect(PostalDeliveryModule.routeName, '/life/postal-delivery');
      expect(
        identical(module.createOrchestrator(), module.createOrchestrator()),
        isFalse,
      );
    });
  });

  testWidgets('master hub uses glass cards, safe scrolling and explicit BiDi',
      (tester) async {
    final orchestrator = PostalDeliveryMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: PostalDeliveryMasterHub(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Post, Pakete & Versand'), findsOneWidget);
    expect(find.text('البريد والطرود والشحن'), findsOneWidget);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));

    await tester.enterText(
      find.byKey(const ValueKey<String>('postal-master-search')),
      'Benachrichtigungskarte',
    );
    await tester.pump();

    expect(
      orchestrator.visibleActions.single.id,
      'postal-notification-card',
    );
  });
}
