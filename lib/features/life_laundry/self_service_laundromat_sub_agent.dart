import 'laundry_models.dart';

final class SelfServiceLaundromatSubAgent {
  const SelfServiceLaundromatSubAgent();

  List<LaundryPhrase> get phrases => _phrases;

  static const List<LaundryPhrase> _phrases = <LaundryPhrase>[
    LaundryPhrase(
      id: 'laundromat-token-machine',
      domain: LaundryDomain.selfServiceLaundromat,
      german:
          'Wo bekomme ich Waschmarken, und kann ich sie am Kassenautomaten mit Karte kaufen?',
      arabic:
          'من أين أحصل على رموز الغسيل، وهل يمكن شراؤها من جهاز الدفع بالبطاقة؟',
      contextDe: 'Waschmarken oder Zahlung am Automaten klären',
      contextAr: 'السؤال عن رموز الغسيل وطريقة الدفع في الجهاز',
      keywords: <String>[
        'Waschmarken',
        'Kassenautomat',
        'Münzen',
        'Token',
        'bezahlen',
      ],
    ),
    LaundryPhrase(
      id: 'laundromat-programs',
      domain: LaundryDomain.selfServiceLaundromat,
      german:
          'Welches Programm soll ich wählen: Kochwäsche, Buntwäsche oder Feinwäsche?',
      arabic:
          'أي برنامج أختار: الغسيل الساخن، الغسيل الملوّن أم الغسيل الناعم؟',
      contextDe: 'Das passende Waschprogramm auswählen',
      contextAr: 'اختيار برنامج الغسيل المناسب لنوع الملابس',
      keywords: <String>[
        'Kochwäsche',
        'Buntwäsche',
        'Feinwäsche',
        'Waschprogramm',
        'Temperatur',
      ],
    ),
    LaundryPhrase(
      id: 'laundromat-detergent',
      domain: LaundryDomain.selfServiceLaundromat,
      german:
          'Ist Waschmittel im Preis enthalten, oder muss ich eigenes Waschmittel mitbringen?',
      arabic:
          'هل مسحوق الغسيل مشمول في السعر أم يجب أن أحضر منظفًا خاصًا بي؟',
      contextDe: 'Waschmittel vor dem Start klären',
      contextAr: 'التأكد مما إذا كان المنظف متوفرًا أو يجب إحضاره',
      keywords: <String>[
        'Waschmittel',
        'Preis',
        'mitbringen',
        'inklusive',
      ],
    ),
    LaundryPhrase(
      id: 'laundromat-dryer-time',
      domain: LaundryDomain.selfServiceLaundromat,
      german:
          'Wie stelle ich beim Wäschetrockner die Zeit ein, und kann ich später Minuten nachkaufen?',
      arabic:
          'كيف أضبط الوقت في مجفف الملابس، وهل يمكنني شراء دقائق إضافية لاحقًا؟',
      contextDe: 'Die Trocknungszeit am Wäschetrockner einstellen',
      contextAr: 'ضبط وقت المجفف والاستفسار عن إضافة وقت',
      keywords: <String>[
        'Wäschetrockner',
        'Trockner',
        'Zeit einstellen',
        'Minuten',
        'nachkaufen',
      ],
    ),
    LaundryPhrase(
      id: 'laundromat-large-dryer',
      domain: LaundryDomain.selfServiceLaundromat,
      german:
          'Welcher Wäschetrockner ist für eine große Ladung geeignet, ohne ihn zu überfüllen?',
      arabic:
          'أي مجفف مناسب لكمية كبيرة من الملابس من دون تعبئته بشكل زائد؟',
      contextDe: 'Einen Trockner mit passender Kapazität wählen',
      contextAr: 'اختيار مجفف بسعة مناسبة للحمولة',
      keywords: <String>[
        'Kapazität',
        'große Ladung',
        'Trockner',
        'überfüllen',
      ],
    ),
  ];
}
