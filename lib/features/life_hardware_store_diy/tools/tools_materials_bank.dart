import '../../life_diy/diy_models.dart';

abstract final class ToolsMaterialsBank {
  static const List<DiyPhrase> phrases = <DiyPhrase>[
    DiyPhrase(
      id: 'tools-screw-size',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich brauche Schrauben 5 × 50 mm. Welchen Dübel empfehlen Sie laut Herstellerangabe für diese Wand?',
      arabic:
          'أحتاج براغي بقياس 5 × 50 مم. أي وتد تثبيت تنصح به حسب تعليمات الشركة لهذا الجدار؟',
      contextDe: 'Schraubengröße und passenden Dübel mit dem Mitarbeiter klären',
      contextAr: 'توضيح مقاس البرغي وقطعة التثبيت المناسبة مع موظف القسم',
      keywords: <String>['Schrauben', 'Dübel', '5 × 50 mm', 'Befestigung'],
    ),
    DiyPhrase(
      id: 'tools-nail-purpose',
      domain: DiyDomain.materialsHardware,
      german:
          'Welche Nägel eignen sich für diese Holzleiste, ohne dass das Holz leicht splittert?',
      arabic:
          'أي مسامير تناسب هذه القطعة الخشبية مع تقليل احتمال تشقق الخشب؟',
      contextDe: 'Nägel passend zum Material auswählen',
      contextAr: 'اختيار المسامير المناسبة حسب نوع المادة',
      keywords: <String>['Nägel', 'Holzleiste', 'Material', 'splittern'],
    ),
    DiyPhrase(
      id: 'tools-drill-bit',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich bohre in eine Fliese. Welchen Bohrer brauche ich für dieses Material?',
      arabic:
          'سأحفر في بلاطة. ما نوع رأس المثقاب المناسب لهذه المادة؟',
      contextDe: 'Den passenden Bohrer für den Untergrund erfragen',
      contextAr: 'سؤال الموظف عن رأس المثقاب المناسب لنوع السطح',
      keywords: <String>['Bohrer', 'Fliese', 'Bohrmaschine', 'Untergrund'],
    ),
    DiyPhrase(
      id: 'materials-interior-paint',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich suche eine Innenwandfarbe für den Flur. Welche Farbe ist robust und abwischbar?',
      arabic:
          'أبحث عن دهان جدران داخلي للممر. أي دهان متين ويمكن مسحه؟',
      contextDe: 'Eigenschaften einer Innenfarbe vergleichen',
      contextAr: 'مقارنة خصائص دهان داخلي مع موظف قسم الدهان',
      keywords: <String>['Farbe', 'دهان', 'Innenwandfarbe', 'abwischbar'],
    ),
    DiyPhrase(
      id: 'materials-adhesive',
      domain: DiyDomain.materialsHardware,
      german:
          'Welcher Klebstoff ist für Holz auf Metall geeignet? Bitte zeigen Sie mir die Herstellerangaben.',
      arabic:
          'أي مادة لاصقة مناسبة لتثبيت الخشب على المعدن؟ أرجو أن تريني تعليمات الشركة.',
      contextDe: 'Klebstoff nach Materialpaar auswählen',
      contextAr: 'اختيار اللاصق حسب المادتين والرجوع لتعليمات الشركة',
      keywords: <String>['Klebstoff', 'Holz', 'Metall', 'Herstellerangaben'],
    ),
    DiyPhrase(
      id: 'materials-plumbing',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich brauche eine passende Dichtung für diesen Wasseranschluss. Welche Größe soll ich messen?',
      arabic:
          'أحتاج جلدة إحكام مناسبة لوصلة المياه هذه. أي قياس يجب أن أقيسه؟',
      contextDe: 'Einfache Sanitärteile passend zur vorhandenen Verbindung kaufen',
      contextAr: 'شراء قطعة سباكة بسيطة بعد مطابقة القياس مع الوصلة الموجودة',
      keywords: <String>['Dichtung', 'Wasseranschluss', 'Sanitär', 'Gewinde'],
    ),
    DiyPhrase(
      id: 'materials-electrical',
      domain: DiyDomain.materialsHardware,
      german:
          'Ich brauche ein passendes Verlängerungskabel für ein Haushaltsgerät. Welche Kennzeichnung muss ich beachten?',
      arabic:
          'أحتاج سلك تمديد مناسبًا لجهاز منزلي. ما العلامات والمواصفات التي يجب أن أنتبه لها؟',
      contextDe: 'Ein fertiges, geeignet gekennzeichnetes Elektroprodukt auswählen',
      contextAr: 'اختيار منتج كهربائي جاهز ومناسب دون إرشادات لإصلاحات كهربائية خطرة',
      keywords: <String>['Verlängerungskabel', 'Elektro', 'Kennzeichnung', 'passendes'],
    ),
    DiyPhrase(
      id: 'consultation-stock',
      domain: DiyDomain.materialsHardware,
      german:
          'Haben Sie dieses Teil auch in einer anderen Größe, und wo finde ich die technischen Angaben?',
      arabic:
          'هل تتوفر هذه القطعة بقياس آخر، وأين أجد المواصفات الفنية؟',
      contextDe: 'Alternative Größe und technische Daten erfragen',
      contextAr: 'السؤال عن قياس بديل والمواصفات الفنية داخل المتجر',
      keywords: <String>['Größe', 'technische Angaben', 'Alternative', 'Beratung'],
    ),
  ];
}
