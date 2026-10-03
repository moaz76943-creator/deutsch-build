import 'package:flutter/foundation.dart';

import 'fuel_payment_models.dart';
import 'fuel_payment_phrase_bank.dart';

final class FuelPaymentAgent extends ChangeNotifier {
  FuelPaymentTopic _topic = FuelPaymentTopic.all;
  String _query = '';

  FuelPaymentTopic get topic => _topic;
  String get query => _query;
  List<FuelPaymentPhrase> get allPhrases =>
      List<FuelPaymentPhrase>.unmodifiable(FuelPaymentPhraseBank.all);

  List<FuelPaymentPhrase> get visiblePhrases =>
      List<FuelPaymentPhrase>.unmodifiable(
        FuelPaymentPhraseBank.all.where(
          (item) =>
              (_topic == FuelPaymentTopic.all || item.topic == _topic) &&
              item.matches(_query),
        ),
      );

  String get safetyNoteDe =>
      'Kraftstoff nie nach Farbe oder Gewohnheit auswählen. Fahrzeugfreigabe und Kennzeichnung vergleichen; bei vermuteter Fehlbetankung Motor nicht starten und Hilfe holen.';

  String get safetyNoteAr =>
      'لا تختَر الوقود حسب اللون أو العادة. قارن النوع المسموح بعلامة المضخة، وإذا اشتبهت بخطأ في التعبئة فلا تشغل المحرك واطلب المساعدة.';

  void setTopic(FuelPaymentTopic value) {
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
