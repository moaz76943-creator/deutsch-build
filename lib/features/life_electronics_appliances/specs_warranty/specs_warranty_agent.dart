import 'package:flutter/foundation.dart';

import 'specs_warranty_models.dart';
import 'specs_warranty_phrase_bank.dart';

final class SpecsWarrantyAgent extends ChangeNotifier {
  SpecsWarrantyTopic _topic = SpecsWarrantyTopic.all;
  String _query = '';

  SpecsWarrantyTopic get topic => _topic;
  String get query => _query;
  List<SpecsWarrantyPhrase> get allPhrases =>
      List<SpecsWarrantyPhrase>.unmodifiable(SpecsWarrantyPhraseBank.all);

  List<SpecsWarrantyPhrase> get visiblePhrases =>
      List<SpecsWarrantyPhrase>.unmodifiable(
        SpecsWarrantyPhraseBank.all.where(
          (item) =>
              (_topic == SpecsWarrantyTopic.all || item.topic == _topic) &&
              item.matches(_query),
        ),
      );

  String get guidanceDe =>
      'Modellnummer, Datenblatt und Kaufunterlagen konkret prüfen. Eine freiwillige Garantie kann eigene Bedingungen haben und ist nicht dasselbe wie gesetzliche Gewährleistungsrechte.';

  String get guidanceAr =>
      'تحقق من رقم الموديل والمواصفات وإثبات الشراء. Garantie قد تكون بشروط خاصة وهي ليست نفسها حقوق Gewährleistung القانونية.';

  void setTopic(SpecsWarrantyTopic value) {
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
