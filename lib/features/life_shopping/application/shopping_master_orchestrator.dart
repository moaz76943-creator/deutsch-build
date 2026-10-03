import 'package:flutter/foundation.dart';

import '../domain/shopping_models.dart';

final class ShoppingMasterOrchestrator extends ChangeNotifier {
  ShoppingMasterOrchestrator({
    required ShoppingSubAgent groceryAgent,
    required ShoppingSubAgent returnWarrantyAgent,
  })  : _groceryAgent = groceryAgent,
        _returnWarrantyAgent = returnWarrantyAgent {
    if (_groceryAgent.type != ShoppingAgentType.grocery) {
      throw ArgumentError.value(
        groceryAgent.type,
        'groceryAgent',
        'must expose ShoppingAgentType.grocery',
      );
    }
    if (_returnWarrantyAgent.type != ShoppingAgentType.returnWarranty) {
      throw ArgumentError.value(
        returnWarrantyAgent.type,
        'returnWarrantyAgent',
        'must expose ShoppingAgentType.returnWarranty',
      );
    }
  }

  final ShoppingSubAgent _groceryAgent;
  final ShoppingSubAgent _returnWarrantyAgent;

  String _query = '';
  ShoppingLevel? _activeLevel;
  bool _isPanicBarOpen = false;

  String get query => _query;
  ShoppingLevel? get activeLevel => _activeLevel;
  bool get isPanicBarOpen => _isPanicBarOpen;

  List<ShoppingPhrase> get results => List<ShoppingPhrase>.unmodifiable(
        <ShoppingPhrase>[
          ..._groceryAgent.search(_query, level: _activeLevel),
          ..._returnWarrantyAgent.search(_query, level: _activeLevel),
        ],
      );

  List<ShoppingPhrase> get panicPhrases => List<ShoppingPhrase>.unmodifiable(
        <ShoppingPhrase>[
          ..._groceryAgent.panicPhrases,
          ..._returnWarrantyAgent.panicPhrases,
        ],
      );

  int get groceryResultCount =>
      results.where((item) => item.agent == ShoppingAgentType.grocery).length;

  int get returnWarrantyResultCount => results
      .where((item) => item.agent == ShoppingAgentType.returnWarranty)
      .length;

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearSearch() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }

  void setLevel(ShoppingLevel? level) {
    if (_activeLevel == level) return;
    _activeLevel = level;
    notifyListeners();
  }

  void togglePanicBar() {
    _isPanicBarOpen = !_isPanicBarOpen;
    notifyListeners();
  }

  void closePanicBar() {
    if (!_isPanicBarOpen) return;
    _isPanicBarOpen = false;
    notifyListeners();
  }

  void resetFilters() {
    final changed = _query.isNotEmpty || _activeLevel != null;
    _query = '';
    _activeLevel = null;
    if (changed) notifyListeners();
  }
}
