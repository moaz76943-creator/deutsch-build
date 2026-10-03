import 'diy_models.dart';

final class HardwareStoreSubAgent {
  const HardwareStoreSubAgent();

  List<DiyPhrase> get phrases => _phrases;

  static const List<DiyPhrase> _phrases = <DiyPhrase>[
    DiyPhrase(
      id: 'hardware-screws-dowels',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich brauche Schrauben mit einem Durchmesser von fünf Millimetern und passende Dübel. Können Sie mir etwas für diese Wand empfehlen?',
      arabic:
          'أحتاج براغي بقطر خمسة مليمترات وقطع تثبيت مناسبة. هل يمكنك أن تقترح شيئًا مناسبًا لهذا الجدار؟',
      contextDe: 'Nach Schrauben und passenden Dübeln fragen',
      contextAr: 'طلب براغي وقطع تثبيت مناسبة من موظف المتجر',
      keywords: <String>[
        'Schraube',
        'Schrauben',
        'Dübel',
        'Durchmesser',
        'Wand',
        'Befestigung',
      ],
    ),
    DiyPhrase(
      id: 'hardware-paint-type',
      domain: DiyDomain.materialsHardware,
      german:
          'Welche Innenwandfarbe ist abwischbar und für Küche oder Flur geeignet?',
      arabic:
          'أي نوع من دهان الجدران الداخلي قابل للمسح ومناسب للمطبخ أو الممر؟',
      contextDe: 'Die passende Innenfarbe auswählen',
      contextAr: 'السؤال عن نوع دهان داخلي مناسب للاستخدام اليومي',
      keywords: <String>[
        'Farbe',
        'Innenwandfarbe',
        'Wandfarbe',
        'abwischbar',
        'Küche',
      ],
    ),
    DiyPhrase(
      id: 'hardware-wood-cut',
      domain: DiyDomain.materialsHardware,
      german:
          'Können Sie diese Holzplatte bitte auf achtzig mal vierzig Zentimeter zuschneiden?',
      arabic:
          'هل يمكنك قص هذا اللوح الخشبي إلى مقاس ثمانين في أربعين سنتيمترًا؟',
      contextDe: 'Holzzuschnitt nach Maß bestellen',
      contextAr: 'طلب قص لوح خشبي حسب المقاس',
      keywords: <String>[
        'Holzzuschnitt',
        'Zuschnitt',
        'Holzplatte',
        'Maß',
        'Zentimeter',
      ],
    ),
    DiyPhrase(
      id: 'hardware-cut-tolerance',
      domain: DiyDomain.materialsHardware,
      german:
          'Wie genau ist der Zuschnitt, und welche Mindestmaße gelten für diesen Service?',
      arabic:
          'ما دقة القص، وما الحد الأدنى للمقاسات المطلوبة لهذه الخدمة؟',
      contextDe: 'Vor dem Zuschnitt Toleranz und Mindestmaß klären',
      contextAr: 'التأكد من دقة القص والحد الأدنى للمقاس قبل الطلب',
      keywords: <String>[
        'Toleranz',
        'Mindestmaß',
        'Zuschnittservice',
        'genau',
      ],
    ),
  ];
}
