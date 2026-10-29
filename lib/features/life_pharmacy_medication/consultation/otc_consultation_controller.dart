import 'package:flutter/foundation.dart';

import 'otc_consultation_sub_agent.dart';
import 'otc_models.dart';

final class OtcConsultationController extends ChangeNotifier {
  OtcConsultationController({
    OtcConsultationSubAgent agent = const OtcConsultationSubAgent(),
  }) : _agent = agent;

  final OtcConsultationSubAgent _agent;

  OtcTopic _topic = OtcTopic.mildPain;
  String _query = '';

  OtcTopic get topic => _topic;
  String get query => _query;

  List<OtcPhrase> get visiblePhrases => List<OtcPhrase>.unmodifiable(
        _agent.phrases.where(
          (phrase) =>
              phrase.topic == _topic &&
              phrase.matches(_query),
        ),
      );

  void setTopic(OtcTopic value) {
    if (_topic == value && _query.isEmpty) return;
    _topic = value;
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
