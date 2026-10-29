import 'package:flutter/foundation.dart';

import 'bicycle_purchase_maintenance_models.dart';
import 'bicycle_purchase_maintenance_phrase_bank.dart';

final class BicyclePurchaseMaintenanceAgent extends ChangeNotifier {
  BicycleShopTopic _topic = BicycleShopTopic.all;
  String _query = '';

  BicycleShopTopic get topic => _topic;
  String get query => _query;

  List<BicycleShopPhrase> get allPhrases =>
      List<BicycleShopPhrase>.unmodifiable(
        BicyclePurchaseMaintenancePhraseBank.all,
      );

  List<BicycleShopPhrase> get visiblePhrases {
    return List<BicycleShopPhrase>.unmodifiable(
      BicyclePurchaseMaintenancePhraseBank.all.where(
        (item) =>
            (_topic == BicycleShopTopic.all || item.topic == _topic) &&
            item.matches(_query),
      ),
    );
  }

  String get safetyNoteDe =>
      'Bei Problemen an Bremsen, Lenkung, Laufrädern oder anderen sicherheitsrelevanten Teilen das Fahrrad nicht weiterfahren, wenn die sichere Funktion unklar ist.';

  String get safetyNoteAr =>
      'إذا كانت المشكلة في الفرامل أو المقود أو العجلات أو أي جزء مؤثر على السلامة، فلا تستخدم الدراجة إذا لم تكن سلامتها مؤكدة.';

  void setTopic(BicycleShopTopic value) {
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
