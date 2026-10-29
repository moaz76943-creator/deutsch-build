import '../rent_housing_models.dart';

final class HandoverProtocolSubAgent {
  const HandoverProtocolSubAgent();

  List<RentHousingEntry> get entries => _entries;

  static const List<RentHousingEntry> _entries = <RentHousingEntry>[
    RentHousingEntry(
      id: 'handover-protocol-condition',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Zustand im Übergabeprotokoll',
      titleAr: 'حالة الشقة في محضر التسليم',
      german:
          'Bitte halten wir den Zustand jedes Zimmers und sichtbare Schäden gemeinsam im Übergabeprotokoll fest.',
      arabic:
          'من فضلك لنسجل حالة كل غرفة وأي أضرار ظاهرة معًا في محضر التسليم.',
      contextDe: 'Räume und sichtbare Auffälligkeiten sachlich dokumentieren',
      contextAr: 'توثيق حالة الغرف والملاحظات الظاهرة بوضوح وحياد',
      keywords: <String>[
        'Übergabeprotokoll',
        'Zustand',
        'Schäden',
        'Einzug',
        'Auszug',
      ],
    ),
    RentHousingEntry(
      id: 'handover-meter-readings',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Zählerstände notieren',
      titleAr: 'تسجيل قراءات العدادات',
      german:
          'Bitte tragen wir die Zählerstände für Strom, Wasser und Heizung mit Datum in das Protokoll ein.',
      arabic:
          'من فضلك لنسجل قراءات عدادات الكهرباء والمياه والتدفئة مع التاريخ في المحضر.',
      contextDe: 'Messwerte eindeutig mit Zählerart und Datum erfassen',
      contextAr: 'تسجيل القراءة مع نوع العداد والتاريخ بشكل واضح',
      keywords: <String>[
        'Zählerstand',
        'Zählerstände',
        'Strom',
        'Wasser',
        'Heizung',
      ],
    ),
    RentHousingEntry(
      id: 'handover-keys',
      section: RentHousingSection.handoverAndDefects,
      titleDe: 'Schlüsselübergabe',
      titleAr: 'تسليم المفاتيح',
      german:
          'Wie viele Schlüssel werden heute übergeben? Bitte tragen wir die Anzahl im Protokoll ein.',
      arabic:
          'كم مفتاحًا سيتم تسليمه اليوم؟ من فضلك لنسجل العدد في المحضر.',
      contextDe: 'Anzahl und Art der übergebenen Schlüssel dokumentieren',
      contextAr: 'توثيق عدد وأنواع المفاتيح التي تم تسليمها',
      keywords: <String>['Schlüssel', 'Anzahl', 'Übergabe', 'Protokoll'],
    ),
  ];
}
