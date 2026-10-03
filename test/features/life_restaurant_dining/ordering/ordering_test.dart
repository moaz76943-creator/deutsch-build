import 'package:deutsch_bilarabi/features/life_restaurant_dining/ordering/menu_ordering_agent.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/ordering/ordering_models.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/ordering/ordering_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_restaurant_dining/ordering/reservation_seating_agent.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RestaurantOrderingOrchestrator', () {
    test('builds singular and group reservation requests with seating choice', () {
      const agent = ReservationSeatingAgent();

      expect(
        agent.reservationRequest(
          const ReservationPlan(
            partySize: 1,
            seating: SeatingPreference.indoor,
          ),
        ),
        contains('eine Person'),
      );
      expect(
        agent.reservationRequest(
          const ReservationPlan(
            partySize: 4,
            seating: SeatingPreference.outdoor,
          ),
        ),
        contains('vier Personen'),
      );
      expect(
        agent.reservationRequest(
          const ReservationPlan(
            partySize: 4,
            seating: SeatingPreference.outdoor,
          ),
        ),
        contains('draußen'),
      );
    });

    test('search and stage switching keep reservation and ordering isolated', () {
      final orchestrator = RestaurantOrderingOrchestrator();

      expect(orchestrator.stage, OrderingStage.reservationSeating);
      expect(
        orchestrator.visiblePhrases.any((item) => item.id == 'reservation-time'),
        isTrue,
      );

      orchestrator
        ..setStage(OrderingStage.menuOrdering)
        ..setQuery('Tagesgericht');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'order-daily-special');
    });
  });

  test('menu agent covers ingredients, drinks, and requested modifications', () {
    const agent = MenuOrderingAgent();
    final ids = agent.phrases.map((item) => item.id);

    expect(
      ids,
      containsAll(<String>[
        'order-dish',
        'order-drink',
        'order-ingredients',
        'order-daily-special',
        'modify-no-sauce',
        'modify-gluten-free',
        'modify-halal-question',
      ]),
    );
  });
}
