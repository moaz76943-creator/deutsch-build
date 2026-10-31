import 'package:flutter/foundation.dart';

import 'applications_models.dart';
import 'applications_phrase_bank.dart';

final class ApplicationsNoticesOrchestrator extends ChangeNotifier {
  ApplicationsNoticesOrchestrator({
    ApplicationsPhraseBank bank = const ApplicationsPhraseBank(),
  }) : _bank = bank;

  final ApplicationsPhraseBank _bank;

  ApplicationsTopic _activeTopic = ApplicationsTopic.hauptantrag;
  String _query = '';

  ApplicationsTopic get activeTopic => _activeTopic;
  String get query => _query;

  List<ApplicationsPhrase> get visiblePhrases =>
      List<ApplicationsPhrase>.unmodifiable(
        _bank.phrases.where(
          (phrase) =>
              phrase.topic == _activeTopic &&
              phrase.matches(_query),
        ),
      );

  void setTopic(ApplicationsTopic topic) {
    if (_activeTopic == topic) return;
    _activeTopic = topic;
    _query = '';
    notifyListeners();
  }

  void setQuery(String value) {
    final next = value.trim();
    if (_query == next) return;
    _query = next;
    notifyListeners();
  }

  void clearSearch() => setQuery('');
}
