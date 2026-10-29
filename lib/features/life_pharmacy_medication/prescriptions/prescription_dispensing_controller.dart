import 'package:flutter/foundation.dart';

import 'prescription_dispensing_sub_agent.dart';
import 'prescription_models.dart';

final class PrescriptionDispensingController extends ChangeNotifier {
  PrescriptionDispensingController({
    PrescriptionDispensingSubAgent agent =
        const PrescriptionDispensingSubAgent(),
  }) : _agent = agent;

  final PrescriptionDispensingSubAgent _agent;

  PrescriptionChannel _channel = PrescriptionChannel.ePrescription;
  String _query = '';

  PrescriptionChannel get channel => _channel;
  String get query => _query;

  List<PrescriptionPhrase> get visiblePhrases =>
      List<PrescriptionPhrase>.unmodifiable(
        _agent.phrases.where(
          (phrase) =>
              phrase.channel == _channel &&
              phrase.matches(_query),
        ),
      );

  void setChannel(PrescriptionChannel value) {
    if (_channel == value && _query.isEmpty) return;
    _channel = value;
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
