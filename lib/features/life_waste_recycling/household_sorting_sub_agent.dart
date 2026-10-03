import 'waste_models.dart';

final class HouseholdSortingSubAgent {
  const HouseholdSortingSubAgent();

  List<WastePhrase> get phrases => _phrases;

  static const List<WastePhrase> _phrases = <WastePhrase>[
    WastePhrase(
      id: 'household-yellow-packaging',
      category: WasteCategory.householdSortingPfand,
      german:
          'Gehört diese leere Verpackung in den Gelben Sack oder in die Gelbe Tonne? Welche Regel gilt in unserer Kommune?',
      arabic:
          'هل توضع هذه العبوة الفارغة في الكيس الأصفر أم الحاوية الصفراء؟ وما القاعدة المعمول بها في بلديتنا؟',
      contextDe: 'Leichtverpackungen nach lokaler Kennzeichnung sortieren',
      contextAr: 'فرز العبوات الخفيفة حسب نظام البلدية المحلي',
      keywords: <String>[
        'Gelber Sack',
        'Gelbe Tonne',
        'Verpackung',
        'Kunststoff',
        'Metall',
      ],
    ),
    WastePhrase(
      id: 'household-bio-bin',
      category: WasteCategory.householdSortingPfand,
      german:
          'Darf dieser Küchenabfall bei uns in die Biotonne, oder gibt es dafür besondere örtliche Regeln?',
      arabic:
          'هل يمكن وضع هذه النفايات المنزلية في حاوية العضويات، أم توجد لها قواعد محلية خاصة؟',
      contextDe: 'Biomüll-Regeln vor Ort klären',
      contextAr: 'التأكد من قواعد النفايات العضوية محلياً',
      keywords: <String>[
        'Biotonne',
        'Biomüll',
        'Bioabfall',
        'Küchenabfall',
        'braune Tonne',
      ],
    ),
    WastePhrase(
      id: 'household-paper',
      category: WasteCategory.householdSortingPfand,
      german:
          'Kann dieser saubere Karton zum Altpapier, und soll ich ihn vorher klein machen?',
      arabic:
          'هل يمكن وضع هذا الكرتون النظيف مع الورق القديم، وهل يجب تفكيكه أو تصغيره أولاً؟',
      contextDe: 'Papier und Karton richtig vorbereiten',
      contextAr: 'تجهيز الورق والكرتون للفرز بطريقة مناسبة',
      keywords: <String>[
        'Altpapier',
        'Papier',
        'Karton',
        'Papiertonne',
        'blaue Tonne',
      ],
    ),
    WastePhrase(
      id: 'household-residual',
      category: WasteCategory.householdSortingPfand,
      german:
          'Ist das Restmüll, oder gibt es dafür eine getrennte Sammlung in unserer Stadt?',
      arabic:
          'هل هذه من النفايات المتبقية، أم يوجد لها جمع منفصل في مدينتنا؟',
      contextDe: 'Restmüll nur nach Ausschluss besserer Sammelwege nutzen',
      contextAr: 'التأكد من عدم وجود مسار فرز منفصل قبل استخدام النفايات المتبقية',
      keywords: <String>[
        'Restmüll',
        'Restmülltonne',
        'graue Tonne',
        'schwarze Tonne',
      ],
    ),
    WastePhrase(
      id: 'household-pfand-types',
      category: WasteCategory.householdSortingPfand,
      german:
          'Ist das Einwegpfand oder Mehrwegpfand, und wo kann ich die Flasche zurückgeben?',
      arabic:
          'هل هذه عبوة ذات تأمين للاستخدام الواحد أم قابلة لإعادة الاستخدام، وأين يمكنني إرجاعها؟',
      contextDe: 'Einwegpfand und Mehrwegpfand unterscheiden',
      contextAr: 'التمييز بين عبوات التأمين أحادية الاستخدام ومتعددة الاستخدام',
      keywords: <String>[
        'Pfand',
        'Einwegpfand',
        'Mehrwegpfand',
        'Pfandflasche',
        'Rückgabe',
      ],
    ),
    WastePhrase(
      id: 'household-glass-times',
      category: WasteCategory.householdSortingPfand,
      german:
          'In welchen Altglascontainer gehört dieses Glas, und welche Einwurfzeiten gelten hier?',
      arabic:
          'في أي حاوية زجاج توضع هذه القطعة حسب اللون، وما أوقات الإلقاء المسموح بها هنا؟',
      contextDe: 'Altglas nach Farbe und örtlichen Einwurfzeiten entsorgen',
      contextAr: 'فرز الزجاج حسب اللون والالتزام بأوقات الإلقاء المحلية',
      keywords: <String>[
        'Altglas',
        'Glas',
        'Weißglas',
        'Braunglas',
        'Grünglas',
        'Einwurfzeiten',
        'Ruhezeiten',
      ],
    ),
  ];
}
