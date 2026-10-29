import 'prescription_models.dart';

final class PrescriptionDispensingSubAgent {
  const PrescriptionDispensingSubAgent();

  List<PrescriptionPhrase> get phrases => _phrases;

  static const List<PrescriptionPhrase> _phrases = <PrescriptionPhrase>[
    PrescriptionPhrase(
      id: 'prescription-e-rezept',
      channel: PrescriptionChannel.ePrescription,
      german:
          'Ich möchte mein E-Rezept einlösen. Kann ich dafür meine elektronische Gesundheitskarte verwenden?',
      arabic:
          'أريد صرف وصفتي الإلكترونية. هل يمكنني استخدام بطاقة التأمين الصحي الإلكترونية لذلك؟',
      contextDe: 'E-Rezept in der Apotheke einlösen',
      contextAr: 'صرف الوصفة الإلكترونية في الصيدلية',
      keywords: <String>[
        'E-Rezept',
        'Gesundheitskarte',
        'eGK',
        'einlösen',
        'وصفة إلكترونية',
      ],
    ),
    PrescriptionPhrase(
      id: 'prescription-private',
      channel: PrescriptionChannel.privatePrescription,
      german:
          'Ist das ein Privatrezept? Können Sie mir sagen, welche Kosten ich selbst bezahlen muss?',
      arabic:
          'هل هذه وصفة خاصة؟ هل يمكنك أن تخبرني ما التكاليف التي يجب أن أدفعها بنفسي؟',
      contextDe: 'Privatrezept und Selbstzahlung klären',
      contextAr: 'فهم الوصفة الخاصة والدفع الذاتي',
      keywords: <String>[
        'Privatrezept',
        'privat',
        'Kosten',
        'Selbstzahlung',
        'وصفة خاصة',
      ],
    ),
    PrescriptionPhrase(
      id: 'prescription-green',
      channel: PrescriptionChannel.greenRecommendation,
      german:
          'Ist dieses Grüne Rezept eine Empfehlung für ein nicht verschreibungspflichtiges Arzneimittel?',
      arabic:
          'هل هذه الوصفة الخضراء توصية لدواء لا يحتاج إلى وصفة طبية؟',
      contextDe: 'Grünes Rezept von einem Privatrezept unterscheiden',
      contextAr: 'تمييز الوصفة الخضراء عن الوصفة الخاصة',
      keywords: <String>[
        'Grünes Rezept',
        'Empfehlung',
        'nicht verschreibungspflichtig',
        'rezeptfrei',
        'الوصفة الخضراء',
      ],
    ),
    PrescriptionPhrase(
      id: 'prescription-copayment',
      channel: PrescriptionChannel.ePrescription,
      german:
          'Muss ich für dieses Arzneimittel eine Zuzahlung leisten, und wie hoch ist sie in meinem Fall?',
      arabic:
          'هل يجب أن أدفع مساهمة مالية لهذا الدواء، وكم تبلغ في حالتي؟',
      contextDe: 'Zuzahlung vor der Zahlung klären',
      contextAr: 'السؤال عن رسوم الوصفة قبل الدفع',
      keywords: <String>[
        'Zuzahlung',
        'Kassenrezept',
        'bezahlen',
        'رسوم الوصفة',
      ],
    ),
    PrescriptionPhrase(
      id: 'prescription-exemption',
      channel: PrescriptionChannel.ePrescription,
      german:
          'Ich habe eine Zuzahlungsbefreiung. Reicht dieser Nachweis für die Abgabe aus?',
      arabic:
          'لدي إعفاء من رسوم الوصفة. هل هذا الإثبات كافٍ عند صرف الدواء؟',
      contextDe: 'Befreiungsnachweis vorlegen',
      contextAr: 'إبراز إثبات الإعفاء من الرسوم',
      keywords: <String>[
        'Befreiung',
        'Zuzahlungsbefreiung',
        'Nachweis',
        'إعفاء',
      ],
    ),
    PrescriptionPhrase(
      id: 'prescription-generic',
      channel: PrescriptionChannel.ePrescription,
      german:
          'Gibt es ein wirkstoffgleiches Generikum, das nach den Vorgaben dieses Rezepts austauschbar ist? Ist Aut-idem ausgeschlossen?',
      arabic:
          'هل يوجد دواء جنيس بنفس المادة الفعالة ويمكن استبداله وفق تعليمات هذه الوصفة؟ وهل تم منع الاستبدال بخانة Aut-idem؟',
      contextDe: 'Nach einem zulässigen wirkstoffgleichen Präparat fragen',
      contextAr: 'السؤال عن بديل مسموح من نفس المادة الفعالة',
      keywords: <String>[
        'Aut-idem',
        'Generikum',
        'Wirkstoff',
        'wirkstoffgleich',
        'austauschbar',
        'بديل',
        'مادة فعالة',
      ],
    ),
  ];
}
