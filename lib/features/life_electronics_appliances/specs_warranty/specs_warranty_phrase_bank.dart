import 'specs_warranty_models.dart';

abstract final class SpecsWarrantyPhraseBank {
  static const List<SpecsWarrantyPhrase> all = <SpecsWarrantyPhrase>[
    SpecsWarrantyPhrase(
      id: 'spec-memory',
      topic: SpecsWarrantyTopic.specifications,
      german:
          'Wie viel Arbeitsspeicher und internen Speicher hat dieses Modell, und lässt sich der Speicher später erweitern?',
      arabic:
          'كم حجم ذاكرة RAM والتخزين الداخلي في هذا الموديل، وهل يمكن توسيع التخزين لاحقًا؟',
      contextDe: 'Speicherangaben konkret prüfen',
      contextAr: 'التحقق من الذاكرة والتخزين',
      keywords: <String>['RAM', 'Speicher', 'SSD', 'ذاكرة'],
    ),
    SpecsWarrantyPhrase(
      id: 'spec-connectors',
      topic: SpecsWarrantyTopic.specifications,
      german:
          'Welche Anschlüsse und Funkstandards unterstützt das Gerät, und welche davon kann ich gleichzeitig nutzen?',
      arabic:
          'ما المنافذ وتقنيات الاتصال اللاسلكي التي يدعمها الجهاز، وأيها يمكن استخدامه معًا؟',
      contextDe: 'Anschlüsse und Konnektivität prüfen',
      contextAr: 'فحص المنافذ والاتصال',
      keywords: <String>['USB-C', 'HDMI', 'WLAN', 'Bluetooth', 'منافذ'],
    ),
    SpecsWarrantyPhrase(
      id: 'spec-energy',
      topic: SpecsWarrantyTopic.specifications,
      german:
          'Wie hoch ist der typische Energieverbrauch, und wo finde ich die Energiekennzeichnung dieses konkreten Modells?',
      arabic:
          'ما استهلاك الطاقة المعتاد، وأين أجد ملصق الطاقة لهذا الموديل تحديدًا؟',
      contextDe: 'Energieverbrauch am konkreten Modell vergleichen',
      contextAr: 'مقارنة استهلاك الطاقة',
      keywords: <String>['Energieverbrauch', 'Energielabel', 'طاقة'],
    ),
    SpecsWarrantyPhrase(
      id: 'spec-dimensions',
      topic: SpecsWarrantyTopic.specifications,
      german:
          'Welche Außenmaße hat das Gerät, und wie viel Platz muss ich für Lüftung, Türen oder Anschlüsse zusätzlich einplanen?',
      arabic:
          'ما الأبعاد الخارجية للجهاز، وكم مساحة إضافية أحتاج للتهوية أو الأبواب أو التوصيلات؟',
      contextDe: 'Aufstellmaß statt nur Gehäusemaß prüfen',
      contextAr: 'التحقق من مساحة التركيب الفعلية',
      keywords: <String>['Maße', 'Breite', 'Tiefe', 'Lüftung', 'أبعاد'],
    ),
    SpecsWarrantyPhrase(
      id: 'compare-models',
      topic: SpecsWarrantyTopic.comparison,
      german:
          'Was sind die wichtigsten Unterschiede zwischen diesen beiden Modellen bei Leistung, Ausstattung und Folgekosten?',
      arabic:
          'ما أهم الفروقات بين هذين الموديلين من حيث الأداء والتجهيز والتكاليف اللاحقة؟',
      contextDe: 'Modelle anhand relevanter Kriterien vergleichen',
      contextAr: 'مقارنة الأجهزة بمعايير مفيدة',
      keywords: <String>['Unterschied', 'Modelle', 'Leistung', 'مقارنة'],
    ),
    SpecsWarrantyPhrase(
      id: 'compare-delivery',
      topic: SpecsWarrantyTopic.comparison,
      german:
          'Was gehört genau zum Lieferumfang, und welche Kabel, Halterungen oder Adapter müsste ich separat kaufen?',
      arabic:
          'ما الذي يأتي داخل العلبة تحديدًا، وما الكابلات أو الحوامل أو المحولات التي يجب شراؤها منفصلة؟',
      contextDe: 'Lieferumfang vor dem Kauf klären',
      contextAr: 'تحديد محتويات العلبة قبل الشراء',
      keywords: <String>['Lieferumfang', 'Kabel', 'Adapter', 'محتويات'],
    ),
    SpecsWarrantyPhrase(
      id: 'compare-installation',
      topic: SpecsWarrantyTopic.comparison,
      german:
          'Ist Lieferung, Anschluss oder Einbau im Preis enthalten, und welche Voraussetzungen muss der Aufstellort erfüllen?',
      arabic:
          'هل التوصيل أو التركيب مشمول بالسعر، وما المتطلبات التي يجب أن تتوفر في مكان الجهاز؟',
      contextDe: 'Liefer- und Installationsleistung klären',
      contextAr: 'تحديد خدمة التوصيل والتركيب',
      keywords: <String>['Lieferung', 'Einbau', 'Anschluss', 'تركيب'],
    ),
    SpecsWarrantyPhrase(
      id: 'warranty-provider',
      topic: SpecsWarrantyTopic.warranty,
      german:
          'Wer gibt die Garantie für dieses Gerät, wie lange gilt sie und welche Bedingungen oder Ausschlüsse stehen in den Garantieunterlagen?',
      arabic:
          'من الجهة التي تقدم الكفالة لهذا الجهاز، وكم مدتها، وما الشروط أو الاستثناءات المذكورة في وثائقها؟',
      contextDe: 'Freiwillige Garantiebedingungen konkret lesen',
      contextAr: 'التحقق من شروط Garantie الاختيارية',
      keywords: <String>['Garantie', 'Hersteller', 'Bedingungen', 'كفالة'],
    ),
    SpecsWarrantyPhrase(
      id: 'warranty-rights',
      topic: SpecsWarrantyTopic.warranty,
      german:
          'Wie läuft die Reklamation bei einem Mangel über meine gesetzlichen Gewährleistungsrechte, und welche Unterlagen brauchen Sie?',
      arabic:
          'كيف أقدّم مطالبة بوجود عيب ضمن حقوق Gewährleistung القانونية، وما الوثائق التي تحتاجونها؟',
      contextDe: 'Gewährleistung von freiwilliger Garantie trennen',
      contextAr: 'فصل الحقوق القانونية عن الكفالة الاختيارية',
      keywords: <String>['Gewährleistung', 'Mangel', 'Reklamation', 'عيب'],
    ),
    SpecsWarrantyPhrase(
      id: 'warranty-proof',
      topic: SpecsWarrantyTopic.warranty,
      german:
          'Welchen Kaufnachweis soll ich für einen Garantie- oder Gewährleistungsfall aufbewahren?',
      arabic:
          'ما إثبات الشراء الذي ينبغي الاحتفاظ به لحالة Garantie أو Gewährleistung؟',
      contextDe: 'Kaufnachweis sichern',
      contextAr: 'الاحتفاظ بإثبات الشراء',
      keywords: <String>['Kassenbon', 'Rechnung', 'Kaufnachweis', 'فاتورة'],
    ),
    SpecsWarrantyPhrase(
      id: 'return-store-policy',
      topic: SpecsWarrantyTopic.returnExchange,
      german:
          'Welche Rückgabe- oder Umtauschregel bietet Ihr Geschäft für ein mangelfreies Gerät, das ich direkt im Laden kaufe?',
      arabic:
          'ما سياسة متجركم لإرجاع أو استبدال جهاز سليم تم شراؤه مباشرة من المتجر؟',
      contextDe: 'Freiwillige Ladenregel vor dem Kauf klären',
      contextAr: 'فهم سياسة المتجر الطوعية قبل الشراء',
      keywords: <String>['Rückgabe', 'Umtausch', 'Ladenkauf', 'إرجاع'],
    ),
    SpecsWarrantyPhrase(
      id: 'return-defect',
      topic: SpecsWarrantyTopic.returnExchange,
      german:
          'Das Gerät hat einen Mangel. Welche Schritte gelten jetzt für Prüfung, Nacherfüllung oder weitere Abwicklung?',
      arabic:
          'الجهاز فيه عيب. ما الخطوات الآن للفحص أو المعالجة أو متابعة المطالبة؟',
      contextDe: 'Mangel nicht mit freiwilligem Umtausch verwechseln',
      contextAr: 'عدم الخلط بين العيب والاستبدال الطوعي',
      keywords: <String>['Mangel', 'Nacherfüllung', 'Reklamation', 'عطل'],
    ),
  ];
}
