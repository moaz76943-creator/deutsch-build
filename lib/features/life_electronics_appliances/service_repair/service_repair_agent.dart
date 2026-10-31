import 'package:flutter/foundation.dart';

import 'service_repair_models.dart';
import 'service_repair_phrase_bank.dart';

final class ServiceRepairAgent extends ChangeNotifier {
  ServiceRepairTopic _topic = ServiceRepairTopic.all;
  String _query = '';

  ServiceRepairTopic get topic => _topic;
  String get query => _query;
  List<ServiceRepairPhrase> get allPhrases =>
      List<ServiceRepairPhrase>.unmodifiable(ServiceRepairPhraseBank.all);

  List<ServiceRepairPhrase> get visiblePhrases =>
      List<ServiceRepairPhrase>.unmodifiable(
        ServiceRepairPhraseBank.all.where(
          (item) =>
              (_topic == ServiceRepairTopic.all || item.topic == _topic) &&
              item.matches(_query),
        ),
      );

  String get safetyNoteDe =>
      'Bei Rauch, ungewöhnlichem Geruch, Überhitzung, beschädigten Leitungen oder anderer Sicherheitsgefahr Gerät nicht weiter betreiben. Keine riskanten Eigenreparaturen an Netzspannung oder Hochenergie-Komponenten.';

  String get safetyNoteAr =>
      'عند وجود دخان أو رائحة غير طبيعية أو حرارة زائدة أو أسلاك تالفة أو خطر آخر، توقف عن استخدام الجهاز. لا تنفذ إصلاحات ذاتية خطرة على الكهرباء أو المكونات عالية الطاقة.';

  void setTopic(ServiceRepairTopic value) {
    if (_topic == value) return;
    _topic = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}
