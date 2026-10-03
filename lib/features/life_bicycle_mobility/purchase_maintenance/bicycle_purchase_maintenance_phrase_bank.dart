import 'bicycle_purchase_maintenance_models.dart';

abstract final class BicyclePurchaseMaintenancePhraseBank {
  static const List<BicycleShopPhrase> all = <BicycleShopPhrase>[
    BicycleShopPhrase(
      id: 'buy-use-case',
      topic: BicycleShopTopic.purchaseAdvice,
      german:
          'Ich suche ein Fahrrad für den täglichen Weg zur Arbeit. Welcher Typ passt zu dieser Nutzung?',
      arabic:
          'أبحث عن دراجة للتنقل اليومي إلى العمل. أي نوع يناسب هذا الاستخدام؟',
      contextDe: 'Einsatzbereich erklären',
      contextAr: 'شرح طريقة الاستخدام للبائع',
      keywords: <String>['Citybike', 'Trekkingrad', 'Alltag', 'شراء'],
    ),
    BicycleShopPhrase(
      id: 'buy-budget',
      topic: BicycleShopTopic.purchaseAdvice,
      german:
          'Mein Budget liegt ungefähr bei diesem Betrag. Welche Modelle kommen dafür infrage?',
      arabic:
          'ميزانيتي تقارب هذا المبلغ. ما الموديلات المناسبة ضمنها؟',
      contextDe: 'Budget nennen und Optionen vergleichen',
      contextAr: 'ذكر الميزانية ومقارنة الخيارات',
      keywords: <String>['Budget', 'Preis', 'Modell', 'سعر'],
    ),
    BicycleShopPhrase(
      id: 'buy-test-ride',
      topic: BicycleShopTopic.purchaseAdvice,
      german:
          'Kann ich dieses Fahrrad kurz Probe fahren, bevor ich mich entscheide?',
      arabic:
          'هل يمكنني تجربة قيادة هذه الدراجة قليلًا قبل أن أقرر؟',
      contextDe: 'Probefahrt anfragen',
      contextAr: 'طلب تجربة الدراجة',
      keywords: <String>['Probefahrt', 'testen', 'تجربة'],
    ),
    BicycleShopPhrase(
      id: 'fit-frame-size',
      topic: BicycleShopTopic.fitAndSize,
      german:
          'Welche Rahmengröße empfehlen Sie für meine Körpergröße und meine Sitzposition?',
      arabic:
          'ما مقاس الإطار الذي تنصح به لطولي ووضعية جلوسي؟',
      contextDe: 'Passende Rahmengröße bestimmen',
      contextAr: 'تحديد مقاس إطار مناسب',
      keywords: <String>['Rahmengröße', 'Körpergröße', 'مقاس'],
    ),
    BicycleShopPhrase(
      id: 'fit-saddle',
      topic: BicycleShopTopic.fitAndSize,
      german:
          'Können Sie bitte die Sattelhöhe und den Lenker passend für mich einstellen?',
      arabic:
          'هل يمكنكم ضبط ارتفاع المقعد والمقود ليناسبا وضعيتي؟',
      contextDe: 'Sattel und Lenker einstellen',
      contextAr: 'ضبط المقعد والمقود',
      keywords: <String>['Sattel', 'Lenker', 'einstellen', 'مقعد'],
    ),
    BicycleShopPhrase(
      id: 'repair-flat',
      topic: BicycleShopTopic.repair,
      german:
          'Mein Reifen verliert Luft. Können Sie prüfen, ob der Schlauch oder der Reifen beschädigt ist?',
      arabic:
          'الإطار يفقد الهواء. هل يمكنكم فحص ما إذا كان الأنبوب الداخلي أو الإطار تالفًا؟',
      contextDe: 'Platten oder Luftverlust beschreiben',
      contextAr: 'وصف ثقب أو فقدان الهواء',
      keywords: <String>['Reifen', 'Schlauch', 'Platten', 'هواء'],
    ),
    BicycleShopPhrase(
      id: 'repair-brake',
      topic: BicycleShopTopic.repair,
      german:
          'Die Bremse greift schwach und macht Geräusche. Bitte prüfen Sie Beläge und Einstellung.',
      arabic:
          'الفرامل ضعيفة وتصدر صوتًا. يرجى فحص البطانات والضبط.',
      contextDe: 'Bremsproblem sicher beschreiben',
      contextAr: 'وصف مشكلة الفرامل بوضوح',
      keywords: <String>['Bremse', 'Bremsbeläge', 'Geräusch', 'فرامل'],
    ),
    BicycleShopPhrase(
      id: 'repair-gears',
      topic: BicycleShopTopic.repair,
      german:
          'Die Schaltung springt zwischen den Gängen. Können Sie sie einstellen und den Antrieb prüfen?',
      arabic:
          'ناقل السرعات يقفز بين الغيارات. هل يمكنكم ضبطه وفحص منظومة الحركة؟',
      contextDe: 'Schaltungsproblem melden',
      contextAr: 'شرح مشكلة ناقل السرعات',
      keywords: <String>['Schaltung', 'Gänge', 'Antrieb', 'غيارات'],
    ),
    BicycleShopPhrase(
      id: 'repair-estimate',
      topic: BicycleShopTopic.repair,
      german:
          'Könnten Sie mir vor der Reparatur einen Kostenvoranschlag geben und mich bei Mehrkosten informieren?',
      arabic:
          'هل يمكنكم إعطائي تقديرًا للتكلفة قبل الإصلاح وإبلاغي إذا ظهرت تكاليف إضافية؟',
      contextDe: 'Kosten vor Freigabe klären',
      contextAr: 'تحديد التكلفة قبل الموافقة',
      keywords: <String>['Kostenvoranschlag', 'Kosten', 'تكلفة'],
    ),
    BicycleShopPhrase(
      id: 'maintenance-chain',
      topic: BicycleShopTopic.maintenance,
      german:
          'Können Sie Kette, Kassette und Verschleiß prüfen und mir sagen, was gewartet werden sollte?',
      arabic:
          'هل يمكنكم فحص السلسلة والتروس والتآكل وإخباري بما يحتاج إلى صيانة؟',
      contextDe: 'Antrieb warten lassen',
      contextAr: 'طلب صيانة منظومة الحركة',
      keywords: <String>['Kette', 'Kassette', 'Verschleiß', 'سلسلة'],
    ),
    BicycleShopPhrase(
      id: 'maintenance-safety-check',
      topic: BicycleShopTopic.maintenance,
      german:
          'Ich möchte einen Sicherheitscheck für Bremsen, Reifen, Schrauben und Beleuchtung.',
      arabic:
          'أريد فحص سلامة للفرامل والإطارات والبراغي والإضاءة.',
      contextDe: 'Regelmäßigen Sicherheitscheck anfragen',
      contextAr: 'طلب فحص سلامة دوري',
      keywords: <String>['Sicherheitscheck', 'Beleuchtung', 'Wartung', 'سلامة'],
    ),
    BicycleShopPhrase(
      id: 'maintenance-pickup',
      topic: BicycleShopTopic.maintenance,
      german:
          'Wann kann ich das Fahrrad abholen, und welche Arbeiten wurden tatsächlich durchgeführt?',
      arabic:
          'متى يمكنني استلام الدراجة، وما الأعمال التي تم تنفيذها فعليًا؟',
      contextDe: 'Abholung und erledigte Arbeiten bestätigen',
      contextAr: 'تأكيد موعد الاستلام والأعمال المنفذة',
      keywords: <String>['Abholung', 'Rechnung', 'Arbeiten', 'استلام'],
    ),
  ];
}
