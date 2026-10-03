import 'laundry_models.dart';

final class DryCleaningSubAgent {
  const DryCleaningSubAgent();

  List<LaundryPhrase> get phrases => _phrases;

  static const List<LaundryPhrase> _phrases = <LaundryPhrase>[
    LaundryPhrase(
      id: 'cleaning-suit-delivery',
      domain: LaundryDomain.professionalCleaning,
      german:
          'Ich möchte diesen Anzug zur chemischen Reinigung abgeben. Wann kann ich ihn abholen?',
      arabic:
          'أريد تسليم هذه البدلة للتنظيف الكيميائي. متى يمكنني استلامها؟',
      contextDe: 'Einen Anzug zur Chemischen Reinigung abgeben',
      contextAr: 'تسليم بدلة للتنظيف الاحترافي وتحديد موعد الاستلام',
      keywords: <String>[
        'Chemische Reinigung',
        'Anzug',
        'abgeben',
        'abholen',
      ],
    ),
    LaundryPhrase(
      id: 'cleaning-stain-treatment',
      domain: LaundryDomain.professionalCleaning,
      german:
          'Hier ist ein Fleck. Können Sie bitte prüfen, welche Fleckenbehandlung für diesen Stoff geeignet ist?',
      arabic:
          'توجد هنا بقعة. هل يمكنكم التحقق من معالجة البقع المناسبة لهذا القماش؟',
      contextDe: 'Vorher auf einen Fleck und empfindlichen Stoff hinweisen',
      contextAr: 'التنبيه إلى البقعة ونوع القماش قبل التنظيف',
      keywords: <String>[
        'Fleck',
        'Fleckenbehandlung',
        'Stoff',
        'empfindlich',
      ],
    ),
    LaundryPhrase(
      id: 'cleaning-shirt-ironing',
      domain: LaundryDomain.professionalCleaning,
      german:
          'Bieten Sie einen Hemdenservice mit Waschen und Bügeln an, und wie wird pro Hemd berechnet?',
      arabic:
          'هل تقدمون خدمة للقمصان تشمل الغسيل والكيّ، وكيف تُحسب التكلفة لكل قميص؟',
      contextDe: 'Hemdenservice und Bügeln anfragen',
      contextAr: 'الاستفسار عن خدمة غسل وكي القمصان',
      keywords: <String>[
        'Hemdenservice',
        'Bügeln',
        'Hemd',
        'Waschen',
        'Preis',
      ],
    ),
    LaundryPhrase(
      id: 'cleaning-pickup-receipt',
      domain: LaundryDomain.professionalCleaning,
      german:
          'Hier ist mein Abholschein. Können Sie bitte prüfen, ob alle Teile vollständig fertig sind?',
      arabic:
          'هذه إيصال الاستلام الخاص بي. هل يمكنكم التحقق من أن جميع القطع جاهزة بالكامل؟',
      contextDe: 'Beim Abholen den Abholschein vorzeigen',
      contextAr: 'إبراز إيصال الاستلام والتأكد من اكتمال الطلب',
      keywords: <String>[
        'Abholschein',
        'abholen',
        'fertig',
        'Beleg',
        'Quittung',
      ],
    ),
    LaundryPhrase(
      id: 'cleaning-final-inspection',
      domain: LaundryDomain.professionalCleaning,
      german:
          'Darf ich das Kleidungsstück kurz ansehen, bevor ich es mitnehme?',
      arabic:
          'هل يمكنني فحص قطعة الملابس سريعًا قبل أخذها؟',
      contextDe: 'Das gereinigte Kleidungsstück bei der Abholung prüfen',
      contextAr: 'فحص القطعة بعد التنظيف وقبل مغادرة المحل',
      keywords: <String>[
        'ansehen',
        'prüfen',
        'Abholung',
        'Kleidungsstück',
      ],
    ),
  ];
}
