import 'package:deutsch_bilarabi/features/life_clothing_alterations/clothing_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/clothing_master_screen.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/clothing_models.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/clothing_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClothingMasterOrchestrator', () {
    const orchestrator = ClothingMasterOrchestrator();

    test('searches fitting and tailoring content through one hub', () {
      expect(orchestrator.search('Hose'), isNotEmpty);
      expect(orchestrator.search('Reißverschluss'), isNotEmpty);
    });

    test('exposes cotton and wool plus classic daily size references', () {
      expect(
        ClothingMasterOrchestrator.fabricGuide
            .map((entry) => entry.fabric)
            .toSet(),
        containsAll(<ClothingFabric>[
          ClothingFabric.cotton,
          ClothingFabric.wool,
        ]),
      );
      expect(ClothingMasterOrchestrator.sizeGuide, hasLength(4));
    });

    test('creates a valid alteration receipt and rejects invalid dates', () {
      final received = DateTime.utc(2026, 10, 4, 8);
      final ready = DateTime.utc(2026, 10, 6, 16);

      final receipt = orchestrator.createReceipt(
        receiptId: 'ALT-1001',
        garment: ClothingGarment.trousers,
        serviceDe: 'Hose kürzen',
        serviceAr: 'تقصير البنطال',
        receivedAt: received,
        readyAt: ready,
        agreedPriceEuro: 12,
      );

      expect(receipt.isChronologicallyValid, isTrue);
      expect(receipt.agreedPriceEuro, 12);

      expect(
        () => orchestrator.createReceipt(
          receiptId: 'ALT-1002',
          garment: ClothingGarment.jacket,
          serviceDe: 'Ärmel anpassen',
          serviceAr: 'تعديل الأكمام',
          receivedAt: ready,
          readyAt: received,
        ),
        throwsArgumentError,
      );
    });
  });

  testWidgets('master hub renders its three module tabs', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ClothingAlterationsMasterScreen()),
    );

    expect(find.text('الملابس والخياطة'), findsOneWidget);
    expect(find.text('المركز'), findsOneWidget);
    expect(find.text('القياس'), findsOneWidget);
    expect(find.text('الخياطة'), findsOneWidget);
  });

  test('module exposes an injectable route', () {
    const module = ClothingAlterationsModule();
    expect(module.buildRoute(), isA<MaterialPageRoute<void>>());
  });
}
