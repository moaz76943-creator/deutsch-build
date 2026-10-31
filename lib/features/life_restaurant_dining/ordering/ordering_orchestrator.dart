import 'package:flutter/foundation.dart';

import 'menu_ordering_agent.dart';
import 'ordering_models.dart';
import 'reservation_seating_agent.dart';

final class RestaurantOrderingOrchestrator extends ChangeNotifier {
  RestaurantOrderingOrchestrator({
    ReservationSeatingAgent reservation = const ReservationSeatingAgent(),
    MenuOrderingAgent menu = const MenuOrderingAgent(),
  })  : _reservation = reservation,
        _menu = menu;

  final ReservationSeatingAgent _reservation;
  final MenuOrderingAgent _menu;

  OrderingStage _stage = OrderingStage.reservationSeating;
  String _query = '';

  OrderingStage get stage => _stage;
  String get query => _query;

  List<OrderingPhrase> get visiblePhrases {
    final source = switch (_stage) {
      OrderingStage.reservationSeating => _reservation.phrases,
      OrderingStage.menuOrdering => _menu.phrases,
    };
    return List<OrderingPhrase>.unmodifiable(
      source.where((item) => item.matches(_query)),
    );
  }

  String buildReservation(ReservationPlan plan) =>
      _reservation.reservationRequest(plan);

  void setStage(OrderingStage value) {
    if (_stage == value) return;
    _stage = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
