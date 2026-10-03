import 'package:flutter/foundation.dart';

import 'consultation_models.dart';
import 'consultation_phrase_bank.dart';

final class ConsultationJobsOrchestrator extends ChangeNotifier {
  ConsultationJobsOrchestrator({
    ConsultationPhraseBank bank = const ConsultationPhraseBank(),
  }) : _bank = bank;

  final ConsultationPhraseBank _bank;

  ConsultationTopic _activeTopic =
      ConsultationTopic.adviserMeeting;
  String _query = '';

  ConsultationTopic get activeTopic => _activeTopic;
  String get query => _query;

  List<ConsultationPhrase> get visiblePhrases =>
      List<ConsultationPhrase>.unmodifiable(
        _bank.phrases.where(
          (phrase) =>
              phrase.topic == _activeTopic &&
              phrase.matches(_query),
        ),
      );

  void setTopic(ConsultationTopic topic) {
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
