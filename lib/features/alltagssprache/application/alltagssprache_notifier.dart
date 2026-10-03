import 'package:flutter/foundation.dart';

import '../data/local_alltagssprache_repository.dart';
import '../domain/alltagssprache_models.dart';

class AlltagsspracheNotifier extends ChangeNotifier {
  AlltagsspracheNotifier(this.repository) : _items = repository.all();

  final LocalAlltagsspracheRepository repository;

  List<AlltagScenario> _items;
  AlltagTopic? _topic;
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _checked = false;

  List<AlltagScenario> get items => List<AlltagScenario>.unmodifiable(_items);
  AlltagTopic? get topic => _topic;
  int get currentIndex => _currentIndex;
  int? get selectedIndex => _selectedIndex;
  bool get checked => _checked;

  AlltagScenario get current {
    if (_items.isEmpty) {
      throw StateError('No Alltagssprache scenarios are available.');
    }
    return _items[_currentIndex];
  }

  bool? get isCorrect {
    if (!_checked || _selectedIndex == null) return null;
    return repository.isChoiceCorrect(current, _selectedIndex!);
  }

  String get feedbackAr => _checked ? current.feedbackAr : '';

  void filterByTopic(AlltagTopic? topic) {
    _topic = topic;
    _items = topic == null ? repository.all() : repository.byTopic(topic);
    _currentIndex = 0;
    _resetAnswer();
    notifyListeners();
  }

  void selectChoice(int index) {
    if (index < 0 || index >= current.optionsDe.length) {
      throw RangeError.range(
        index,
        0,
        current.optionsDe.length - 1,
        'index',
      );
    }
    if (_checked) return;

    _selectedIndex = index;
    notifyListeners();
  }

  void checkSelection() {
    if (_selectedIndex == null) {
      throw StateError('Select an answer before checking it.');
    }
    if (_checked) return;

    _checked = true;
    notifyListeners();
  }

  void nextScenario() {
    if (_items.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % _items.length;
    _resetAnswer();
    notifyListeners();
  }

  void _resetAnswer() {
    _selectedIndex = null;
    _checked = false;
  }
}
