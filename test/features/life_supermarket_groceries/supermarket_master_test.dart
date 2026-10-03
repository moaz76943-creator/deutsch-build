import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_supermarket_groceries/supermarket_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_supermarket_groceries/supermarket_models.dart';
import 'package:deutsch_bilarabi/features/life_supermarket_groceries/supermarket_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupermarketMasterOrchestrator', () {
    test('exposes shared product, offer and receipt models', () {
      final orchestrator = SupermarketMasterOrchestrator();

      expect(orchestrator.products, isNotEmpty);
      expect(orchestrator.offers, isNotEmpty);
      expect(orchestrator.receipt.lines, isNotEmpty);
      expect(orchestrator.receipt.total, greaterThan(0));

      final oats = orchestrator.products.firstWhere(
        (product) => product.id == 'product-oats',
      );
      expect(oats.dietaryFlags, contains(GroceryDietFlag.vegan));
      expect(oats.dietaryFlags, contains(GroceryDietFlag.glutenFree));
      expect(oats.aisleDe, contains('Frühstück'));
    });

    test('search filters products and offers without changing source data', () {
      final orchestrator = SupermarketMasterOrchestrator();

      orchestrator.setQuery('Hafer');

      expect(orchestrator.visibleProducts, hasLength(1));
      expect(orchestrator.visibleProducts.single.id, 'product-oats');
      expect(orchestrator.visibleOffers, hasLength(1));
      expect(orchestrator.products.length, greaterThan(1));

      orchestrator.clearSearch();
      expect(orchestrator.visibleProducts, hasLength(orchestrator.products.length));
    });
  });

  test('module registry exposes stable child routes and creates orchestrator', () {
    const module = SupermarketGroceriesModule();

    expect(
      module.routes.map((route) => route.id),
      containsAll(<String>[
        'products-ingredients',
        'checkout-pfand',
      ]),
    );
    expect(module.createOrchestrator(), isA<SupermarketMasterOrchestrator>());
  });

  testWidgets('master hub uses glass cards, safe scrolling and explicit BiDi',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SupermarketGroceriesMasterHub(),
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

    expect(find.textContaining('Supermarkt'), findsWidgets);
    expect(find.textContaining('Angebote'), findsWidgets);
    expect(find.textContaining('Kassenbon'), findsWidgets);

    final search =
        find.byKey(const ValueKey<String>('supermarket-master-search'));
    await tester.enterText(search, 'Hafer');
    await tester.pump();

    expect(find.textContaining('Haferflocken'), findsWidgets);
    expect(find.textContaining('Haferflocken'), findsWidgets);
  });
}
