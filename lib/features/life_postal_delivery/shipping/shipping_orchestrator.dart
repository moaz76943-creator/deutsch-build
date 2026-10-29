import 'package:flutter/foundation.dart';

import 'shipping_models.dart';
import 'shipping_sub_agent.dart';

final class ShippingOrchestrator extends ChangeNotifier {
  ShippingOrchestrator({
    ShippingSubAgent agent = const ShippingSubAgent(),
  }) : _agent = agent;

  final ShippingSubAgent _agent;

  ShippingScenario _scenario = ShippingScenario.send;
  String _query = '';

  ShippingScenario get scenario => _scenario;
  String get query => _query;

  List<ShippingPhrase> get visiblePhrases => List<ShippingPhrase>.unmodifiable(
        _agent.phrases.where(
          (phrase) =>
              (_query.trim().isNotEmpty || phrase.scenario == _scenario) &&
              phrase.matches(_query),
        ),
      );

  void setScenario(ShippingScenario value) {
    if (_scenario == value) return;
    _scenario = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
