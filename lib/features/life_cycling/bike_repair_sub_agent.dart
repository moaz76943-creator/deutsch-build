import 'cycling_models.dart';

final class BikeRepairSubAgent {
  const BikeRepairSubAgent();

  List<CyclingPhrase> get phrases => _phrases;

  static const List<CyclingPhrase> _phrases = <CyclingPhrase>[
    CyclingPhrase(
      id: 'repair-patch-tyre',
      category: CyclingCategory.workshopRepair,
      topic: CyclingTopic.tyre,
      titleDe: 'Reifen flicken',
      german:
          'Mein Reifen verliert Luft. Können Sie bitte prüfen, ob er geflickt werden kann?',
      arabic:
          'إطاري يفقد الهواء. هل يمكنك فحص ما إذا كان يمكن ترقيعه؟',
      keywords: <String>['Reifen flicken', 'Luft', 'Loch', 'إطار', 'ترقيع'],
    ),
    CyclingPhrase(
      id: 'repair-change-tube',
      category: CyclingCategory.workshopRepair,
      topic: CyclingTopic.innerTube,
      titleDe: 'Schlauch wechseln',
      german:
          'Der Schlauch ist beschädigt. Ich möchte ihn wechseln lassen.',
      arabic:
          'الأنبوب الداخلي تالف. أريد استبداله.',
      keywords: <String>[
        'Schlauch wechseln',
        'Fahrradschlauch',
        'beschädigt',
        'أنبوب داخلي',
      ],
    ),
    CyclingPhrase(
      id: 'repair-chain',
      category: CyclingCategory.workshopRepair,
      topic: CyclingTopic.chain,
      titleDe: 'Kette spannen',
      german:
          'Die Kette ist zu locker und springt manchmal ab. Können Sie sie prüfen und richtig einstellen?',
      arabic:
          'السلسلة مرتخية جداً وتسقط أحياناً. هل يمكنك فحصها وضبطها بشكل صحيح؟',
      keywords: <String>[
        'Kette spannen',
        'Kette',
        'locker',
        'einstellen',
        'سلسلة',
      ],
    ),
    CyclingPhrase(
      id: 'repair-workshop-estimate',
      category: CyclingCategory.workshopRepair,
      topic: CyclingTopic.workshop,
      titleDe: 'In der Fahrradwerkstatt',
      german:
          'Können Sie mir vor der Reparatur ungefähr sagen, was die Arbeit und die Ersatzteile kosten?',
      arabic:
          'هل يمكنك إخباري تقريباً قبل الإصلاح بتكلفة العمل وقطع الغيار؟',
      keywords: <String>[
        'Fahrradwerkstatt',
        'Reparatur',
        'Ersatzteile',
        'Kosten',
        'ورشة',
      ],
    ),
    CyclingPhrase(
      id: 'repair-workshop-pickup',
      category: CyclingCategory.workshopRepair,
      topic: CyclingTopic.workshop,
      titleDe: 'Abholung vereinbaren',
      german:
          'Wann kann ich das Fahrrad nach der Reparatur wieder abholen?',
      arabic:
          'متى يمكنني استلام الدراجة بعد الإصلاح؟',
      keywords: <String>[
        'Fahrradwerkstatt',
        'Abholung',
        'Termin',
        'Reparatur',
        'استلام',
      ],
    ),
  ];
}
