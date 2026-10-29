import 'package:flutter/foundation.dart';

import 'packstation_models.dart';
import 'packstation_sub_agent.dart';

final class PackstationOrchestrator extends ChangeNotifier {
  PackstationOrchestrator({
    PackstationSubAgent agent = const PackstationSubAgent(),
  }) : _agent = agent;

  final PackstationSubAgent _agent;

  PackstationScenario _scenario = PackstationScenario.packstation;
  String _query = '';

  PackstationScenario get scenario => _scenario;
  String get query => _query;

  List<PackstationPhrase> get visiblePhrases =>
      List<PackstationPhrase>.unmodifiable(
        _agent.phrases.where(
          (phrase) =>
              (_query.trim().isNotEmpty || phrase.scenario == _scenario) &&
              phrase.matches(_query),
        ),
      );

  void setScenario(PackstationScenario value) {
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
