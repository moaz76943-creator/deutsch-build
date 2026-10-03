import 'otc_models.dart';

final class OtcConsultationSubAgent {
  const OtcConsultationSubAgent();

  List<OtcPhrase> get phrases => _phrases;

  static const List<OtcPhrase> _phrases = <OtcPhrase>[
    OtcPhrase(
      id: 'otc-mild-pain',
      topic: OtcTopic.mildPain,
      german:
          'Ich habe leichte Schmerzen. Können Sie mich beraten, welches rezeptfreie Medikament für mich infrage kommt?',
      arabic:
          'لدي ألم خفيف. هل يمكنك أن تنصحني بما إذا كان هناك دواء دون وصفة مناسب لحالتي؟',
      contextDe: 'Bei leichten Schmerzen um Beratung bitten',
      contextAr: 'طلب استشارة من الصيدلي لألم خفيف',
      keywords: <String>[
        'rezeptfrei',
        'Schmerzen',
        'Schmerzmittel',
        'Beratung',
        'ألم',
        'دون وصفة',
      ],
    ),
    OtcPhrase(
      id: 'otc-cold',
      topic: OtcTopic.coldSymptoms,
      german:
          'Ich habe seit kurzem Erkältungssymptome. Was sollte ich Ihnen zu meinen Beschwerden und anderen Medikamenten sagen?',
      arabic:
          'لدي أعراض نزلة برد منذ فترة قصيرة. ما المعلومات التي تحتاجها عن الأعراض والأدوية الأخرى التي أستخدمها؟',
      contextDe: 'Erkältungssymptome beschreiben und Rückfragen zulassen',
      contextAr: 'وصف أعراض نزلة البرد وذكر الأدوية الأخرى',
      keywords: <String>[
        'Erkältung',
        'Erkältungssymptome',
        'Medikamente',
        'Beschwerden',
        'نزلة برد',
      ],
    ),
    OtcPhrase(
      id: 'otc-dosage',
      topic: OtcTopic.dosage,
      german:
          'Wie lautet die Dosierung für dieses Medikament laut Packungsbeilage oder Ihrer Beratung?',
      arabic:
          'ما الجرعة الموصى بها لهذا الدواء وفق النشرة أو إرشادك؟',
      contextDe: 'Dosierung sicher nachfragen',
      contextAr: 'التأكد من الجرعة من الصيدلي أو النشرة',
      keywords: <String>[
        'Dosierung',
        'Dosis',
        'Packungsbeilage',
        'الجرعة',
      ],
    ),
    OtcPhrase(
      id: 'otc-meal-timing',
      topic: OtcTopic.mealTiming,
      german:
          'Soll ich das Medikament vor dem Essen, nach dem Essen oder unabhängig von einer Mahlzeit einnehmen?',
      arabic:
          'هل أتناول الدواء قبل الطعام أم بعده أم بغض النظر عن الوجبة؟',
      contextDe: 'Einnahmezeit in Bezug auf Mahlzeiten klären',
      contextAr: 'فهم وقت التناول بالنسبة للطعام',
      keywords: <String>[
        'vor dem Essen',
        'nach dem Essen',
        'Mahlzeit',
        'Einnahme',
        'قبل الأكل',
        'بعد الأكل',
      ],
    ),
    OtcPhrase(
      id: 'otc-leaflet',
      topic: OtcTopic.leaflet,
      german:
          'Wo finde ich in der Packungsbeilage die Hinweise zur Anwendung, Dosierung und zu Wechselwirkungen?',
      arabic:
          'أين أجد في النشرة الداخلية تعليمات الاستخدام والجرعة والتداخلات الدوائية؟',
      contextDe: 'Packungsbeilage gezielt lesen',
      contextAr: 'قراءة الأقسام المهمة في النشرة الداخلية',
      keywords: <String>[
        'Packungsbeilage',
        'Beipackzettel',
        'Anwendung',
        'Wechselwirkungen',
        'النشرة الداخلية',
      ],
    ),
    OtcPhrase(
      id: 'otc-side-effects',
      topic: OtcTopic.sideEffects,
      german:
          'Welche Nebenwirkungen stehen in der Packungsbeilage, und wann sollte ich ärztlichen oder pharmazeutischen Rat suchen?',
      arabic:
          'ما الآثار الجانبية المذكورة في النشرة، ومتى يجب أن أطلب مشورة طبية أو صيدلانية؟',
      contextDe: 'Nebenwirkungen und passende Ansprechstelle verstehen',
      contextAr: 'فهم الآثار الجانبية ومتى يجب طلب المشورة',
      keywords: <String>[
        'Nebenwirkungen',
        'Rat',
        'Apotheke',
        'Arzt',
        'آثار جانبية',
      ],
    ),
    OtcPhrase(
      id: 'otc-expiry-storage',
      topic: OtcTopic.expiryAndStorage,
      german:
          'Wo steht das Verfallsdatum, und wie soll ich das Medikament nach dem Öffnen aufbewahren?',
      arabic:
          'أين يوجد تاريخ انتهاء الصلاحية، وكيف يجب حفظ الدواء بعد فتحه؟',
      contextDe: 'Verfallsdatum und Lagerung prüfen',
      contextAr: 'التحقق من الصلاحية وطريقة الحفظ',
      keywords: <String>[
        'Verfallsdatum',
        'MHD',
        'haltbar',
        'Lagerung',
        'Aufbewahrung',
        'تاريخ الصلاحية',
        'الحفظ',
      ],
    ),
  ];
}
