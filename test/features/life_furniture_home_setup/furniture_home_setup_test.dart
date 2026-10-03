import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/furniture_home_models.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/furniture_home_module.dart';
import 'package:deutsch_bilarabi/features/life_furniture_home_setup/furniture_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared purchase and delivery models preserve furniture details', () {
    const purchase = FurniturePurchaseRequest(
      id: 'order-1',
      itemNameDe: 'Kleiderschrank',
      itemNameAr: 'خزانة ملابس',
      quantity: 1,
      heightCm: 210,
      widthCm: 120,
      depthCm: 60,
    );
    const delivery = FurnitureDeliveryRequest(
      orderId: 'order-1',
      level: FurnitureDeliveryLevel.apartment,
      addressNote: '3. Stock, Aufzug vorhanden',
    );

    expect(
      purchase.dimensionsLabel,
      'Höhe 210 cm · Breite 120 cm · Tiefe 60 cm',
    );
    expect(delivery.labelDe, 'Lieferung bis in die Wohnung');
  });

  test('module exposes stable route and isolated controller state', () {
    const module = FurnitureHomeSetupModule();
    final first = module.createController();
    final second = module.createController();

    first.addPurchase(
      const FurniturePurchaseRequest(
        id: 'chair-1',
        itemNameDe: 'Stuhl',
        itemNameAr: 'كرسي',
        quantity: 2,
      ),
    );

    expect(FurnitureHomeSetupModule.routeName, '/life/furniture-home-setup');
    expect(first.purchases, hasLength(1));
    expect(second.purchases, isEmpty);

    first.dispose();
    second.dispose();
  });

  testWidgets('master hub uses safe scrolling, glass cards, and routed sections',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FurnitureHomeMasterScreen()),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    await tester.tap(
      find.byKey(
        const ValueKey<String>('furniture-home-section-delivery'),
      ),
    );
    await tester.pump();

    expect(find.text('Lieferung und Transport planen'), findsOneWidget);
  });
}
