import 'package:flutter/foundation.dart';

import 'bike_repair_sub_agent.dart';
import 'cycle_traffic_sub_agent.dart';
import 'cycling_models.dart';

final class CyclingMasterOrchestrator extends ChangeNotifier {
  CyclingMasterOrchestrator({
    CycleTrafficSubAgent traffic = const CycleTrafficSubAgent(),
    BikeRepairSubAgent repair = const BikeRepairSubAgent(),
  })  : _traffic = traffic,
        _repair = repair;

  final CycleTrafficSubAgent _traffic;
  final BikeRepairSubAgent _repair;

  CyclingCategory _category = CyclingCategory.trafficSafety;
  String _query = '';

  CyclingCategory get category => _category;
  String get query => _query;

  List<BikeSafetyCheckItem> get safetyChecklist => _traffic.safetyChecklist;

  List<CyclingPhrase> get visiblePhrases {
    final source = switch (_category) {
      CyclingCategory.trafficSafety => _traffic.phrases,
      CyclingCategory.workshopRepair => _repair.phrases,
    };

    return List<CyclingPhrase>.unmodifiable(
      source.where((phrase) => phrase.matches(_query)),
    );
  }

  void setCategory(CyclingCategory value) {
    if (_category == value) return;
    _category = value;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
