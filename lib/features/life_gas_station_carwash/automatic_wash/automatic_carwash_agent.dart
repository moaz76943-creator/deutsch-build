import 'package:flutter/foundation.dart';

import 'automatic_carwash_models.dart';
import 'automatic_carwash_phrase_bank.dart';

final class AutomaticCarwashAgent extends ChangeNotifier {
  CarwashTopic _topic = CarwashTopic.all;
  String _query = '';

  CarwashTopic get topic => _topic;
  String get query => _query;
  List<CarwashPhrase> get allPhrases =>
      List<CarwashPhrase>.unmodifiable(AutomaticCarwashPhraseBank.all);

  List<CarwashPhrase> get visiblePhrases =>
      List<CarwashPhrase>.unmodifiable(
        AutomaticCarwashPhraseBank.all.where(
          (item) =>
              (_topic == CarwashTopic.all || item.topic == _topic) &&
              item.matches(_query),
        ),
      );

  String get safetyNoteDe =>
      'Waschanlagen unterscheiden sich. Getriebestellung, Motor, Parkbremse, Spiegel und Anbauteile immer nach den Schildern der konkreten Anlage und den Fahrzeughinweisen behandeln.';

  String get safetyNoteAr =>
      'تختلف المغاسل عن بعضها. اتبع دائمًا تعليمات المنشأة والسيارة بشأن ناقل الحركة والمحرك وفرامل التوقف والمرايا والملحقات.';

  void setTopic(CarwashTopic value) {
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
