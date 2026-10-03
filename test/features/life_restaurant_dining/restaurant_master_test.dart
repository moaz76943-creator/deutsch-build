import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/restaurant_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/restaurant_models.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestaurantDiningMasterOrchestrator', () {
    test('filters menu items by query and meal option', () {
      final orchestrator = RestaurantDiningMasterOrchestrator();

      expect(orchestrator.venue, DiningVenueType.restaurant);
      expect(orchestrator.visibleMenu, isNotEmpty);

      orchestrator.setQuery('Suppe');
      expect(orchestrator.visibleMenu, hasLength(1));
      expect(orchestrator.visibleMenu.single.id, 'menu-tomato-soup');

      orchestrator
        ..clearSearch()
        ..setMealOption(MealOption.glutenFree);
      expect(
        orchestrator.visibleMenu.every(
          (item) => item.options.contains(MealOption.glutenFree),
        ),
        isTrue,
      );
    });

    test('shared bill and tipping language covers together and separate bills', () {
      final orchestrator = RestaurantDiningMasterOrchestrator();
      final ids = orchestrator.billTipPhrases.map((item) => item.id);

      expect(ids, contains('bill-together'));
      expect(ids, contains('bill-separate'));
      expect(ids, contains('tip-stimmt-so'));
    });

    test('dependency factory creates independent orchestrators', () {
      const factory = RestaurantDiningDependencyFactory();

      final first = factory.create();
      final second = factory.create();

      expect(first, isNot(same(second)));
      first.setVenue(DiningVenueType.cafe);
      expect(second.venue, DiningVenueType.restaurant);
    });
  });

  testWidgets('master hub exposes route, glass UI, scrolling, and BiDi', (tester) async {
    final orchestrator = RestaurantDiningMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        routes: <String, WidgetBuilder>{
          RestaurantDiningMasterHub.routeName: (_) =>
              RestaurantDiningMasterHub(orchestrator: orchestrator),
        },
        initialRoute: RestaurantDiningMasterHub.routeName,
      ),
    );

    expect(RestaurantDiningMasterHub.routeName, '/life/restaurant-dining');
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();
    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));

    await tester.tap(
      find.byKey(const ValueKey<String>('restaurant-venue-cafe')),
    );
    await tester.pump();

    expect(orchestrator.venue, DiningVenueType.cafe);
  });
}
