import '../domain/safety_models.dart';

final class RoadsideAssistanceSubAgent {
  const RoadsideAssistanceSubAgent();

  List<SafetyLearningItem> get items => const <SafetyLearningItem>[
        SafetyLearningItem(
          id: 'breakdown_adac',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.breakdown,
          german: 'Ich habe eine Panne und brauche Hilfe vom ADAC.',
          arabic: 'تعطلت سيارتي وأحتاج إلى مساعدة من نادي ADAC.',
          tags: <String>['ADAC', 'Panne', 'Auto', 'عطل', 'سيارة'],
        ),
        SafetyLearningItem(
          id: 'breakdown_engine',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.breakdown,
          german: 'Der Motor startet nicht mehr.',
          arabic: 'المحرك لم يعد يعمل.',
          tags: <String>['Motor', 'starten', 'Panne', 'محرك', 'عطل'],
        ),
        SafetyLearningItem(
          id: 'flat_tire',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.flatTire,
          german: 'Ich habe einen platten Reifen.',
          arabic: 'لدي إطار مثقوب.',
          tags: <String>['Reifen', 'platt', 'Reifenpanne', 'إطار'],
        ),
        SafetyLearningItem(
          id: 'flat_tire_help',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.flatTire,
          german: 'Können Sie mir beim Reifenwechsel helfen?',
          arabic: 'هل يمكنكم مساعدتي في تبديل الإطار؟',
          tags: <String>['Reifenwechsel', 'Reifen', 'Hilfe', 'تبديل الإطار'],
        ),
        SafetyLearningItem(
          id: 'tow_request',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.towing,
          german: 'Ich brauche einen Abschleppdienst.',
          arabic: 'أحتاج إلى خدمة سحب للسيارة.',
          tags: <String>['Abschleppdienst', 'abschleppen', 'Panne', 'سحب'],
        ),
        SafetyLearningItem(
          id: 'tow_destination',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.towing,
          german: 'Bitte schleppen Sie das Fahrzeug zur nächsten Werkstatt.',
          arabic: 'يرجى سحب المركبة إلى أقرب ورشة.',
          tags: <String>['Werkstatt', 'Fahrzeug', 'Abschleppen', 'ورشة'],
        ),
        SafetyLearningItem(
          id: 'highway_km_marker',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.highwayLocation,
          german:
              'Ich stehe auf der A3 in Fahrtrichtung Köln bei Kilometer 245,5.',
          arabic:
              'أنا على الطريق A3 باتجاه كولن عند علامة الكيلومتر 245,5.',
          tags: <String>[
            'Autobahn',
            'Kilometer',
            'Fahrtrichtung',
            'Standort',
            'موقع',
          ],
        ),
        SafetyLearningItem(
          id: 'highway_marker_readback',
          category: SafetyCategory.roadsideAssistance,
          topic: SafetyTopic.highwayLocation,
          german:
              'Der letzte Kilometerstein zeigte Kilometer 246; ich stehe davor auf dem Seitenstreifen.',
          arabic:
              'آخر علامة كيلومتر كانت 246؛ أنا قبلها على كتف الطريق.',
          tags: <String>[
            'Kilometerstein',
            'Seitenstreifen',
            'Autobahn',
            'كتف الطريق',
          ],
        ),
      ];
}
