import 'package:flutter/foundation.dart';

import 'career_content.dart';
import 'career_models.dart';

final class CareerMasterOrchestrator extends ChangeNotifier {
  CareerMasterOrchestrator({
    CareerStage initialStage = CareerStage.application,
  }) : _stage = initialStage;

  CareerStage _stage;
  String _query = '';

  CareerStage get stage => _stage;
  String get query => _query;

  static const List<CareerPhrase> _allItems = <CareerPhrase>[
    ...ApplicationDocsSubAgent.items,
    ...JobInterviewSubAgent.items,
  ];

  List<CareerPhrase> get visibleItems => List<CareerPhrase>.unmodifiable(
        _allItems.where(
          (item) => (_query.trim().isNotEmpty || item.stage == _stage) &&
              item.matches(_query),
        ),
      );

  List<CareerPhrase> get urgentPrep => List<CareerPhrase>.unmodifiable(
        JobInterviewSubAgent.items.where((item) => item.urgent),
      );

  void setStage(CareerStage stage) {
    if (_stage == stage) return;
    _stage = stage;
    notifyListeners();
  }

  void setQuery(String query) {
    final normalized = query.trimLeft();
    if (_query == normalized) return;
    _query = normalized;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }
}
