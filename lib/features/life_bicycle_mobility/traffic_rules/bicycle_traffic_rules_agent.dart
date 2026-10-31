import 'package:flutter/foundation.dart';

import 'bicycle_traffic_rules_models.dart';
import 'bicycle_traffic_rules_phrase_bank.dart';

final class BicycleTrafficRulesAgent extends ChangeNotifier {
  BicycleRuleTopic _topic = BicycleRuleTopic.all;
  String _query = '';

  BicycleRuleTopic get topic => _topic;
  String get query => _query;

  List<BicycleRulePhrase> get allPhrases =>
      List<BicycleRulePhrase>.unmodifiable(BicycleTrafficRulesPhraseBank.all);

  List<BicycleRulePhrase> get visiblePhrases {
    return List<BicycleRulePhrase>.unmodifiable(
      BicycleTrafficRulesPhraseBank.all.where(
        (item) =>
            (_topic == BicycleRuleTopic.all || item.topic == _topic) &&
            item.matches(_query),
      ),
    );
  }

  String get legalNoteDe =>
      'Die konkrete Beschilderung vor Ort geht allgemeinen Lernbeispielen vor. Radwegpflicht, Ampelführung und örtliche Verkehrsführung immer anhand der aktuellen Zeichen prüfen.';

  String get legalNoteAr =>
      'الإشارات الفعلية في المكان مقدمة على أمثلة التعلم العامة. تحقق دائمًا من إلزامية المسار وإشارة الدراجة وتنظيم الطريق الحالي.';

  void setTopic(BicycleRuleTopic value) {
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
