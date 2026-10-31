import 'intercity_train_master_hub.dart';

final class DelayBahnCardAgent {
  const DelayBahnCardAgent();

  static const List<IntercityPhrase> entries = <IntercityPhrase>[
    IntercityPhrase(
      id: 'delay-current',
      category: IntercityTravelCategory.delaySupport,
      topicDe: 'Aktuelle Verspätung',
      topicAr: 'معرفة التأخير الحالي',
      german:
          'Wie viele Minuten Verspätung hat mein ICE aktuell, und ist die geplante Ankunftszeit noch realistisch?',
      arabic:
          'كم دقيقة يبلغ تأخير قطار ICE حالياً، وهل وقت الوصول المخطط ما زال واقعياً؟',
      tags: <String>['Verspätung', 'Ankunft', 'ICE', 'تأخير'],
    ),
    IntercityPhrase(
      id: 'delay-connection',
      category: IntercityTravelCategory.delaySupport,
      topicDe: 'Anschluss verpasst',
      topicAr: 'فوات القطار التالي',
      german:
          'Durch die Verspätung erreiche ich meinen Anschluss wahrscheinlich nicht. Welche nächste Verbindung kann ich nutzen?',
      arabic:
          'بسبب التأخير غالباً لن ألحق القطار التالي. ما الرحلة التالية التي يمكنني استخدامها؟',
      tags: <String>['Anschluss', 'verpasst', 'nächste Verbindung', 'فاتني'],
    ),
    IntercityPhrase(
      id: 'delay-confirmation',
      category: IntercityTravelCategory.delaySupport,
      topicDe: 'Verspätung bestätigen lassen',
      topicAr: 'طلب إثبات التأخير',
      german:
          'Wo kann ich die Verspätung meiner Reise dokumentieren oder bestätigen lassen?',
      arabic:
          'أين يمكنني توثيق أو الحصول على تأكيد لتأخير رحلتي؟',
      tags: <String>['Verspätung', 'Bestätigung', 'dokumentieren', 'إثبات'],
    ),
    IntercityPhrase(
      id: 'delay-rights',
      category: IntercityTravelCategory.delaySupport,
      topicDe: 'Fahrgastrechte erfragen',
      topicAr: 'الاستفسار عن حقوق المسافر',
      german:
          'Wo finde ich die für meine konkrete Verspätung geltenden Informationen zu Fahrgastrechten und Erstattung?',
      arabic:
          'أين أجد المعلومات التي تنطبق على تأخيري تحديداً بخصوص حقوق المسافر والتعويض؟',
      tags: <String>['Fahrgastrechte', 'Erstattung', 'Verspätung', 'تعويض'],
    ),
    IntercityPhrase(
      id: 'bahncard-compare',
      category: IntercityTravelCategory.bahnCard,
      topicDe: 'BahnCard vergleichen',
      topicAr: 'مقارنة بطاقات BahnCard',
      german:
          'Ich fahre regelmäßig mit dem Fernverkehr. Können Sie mir erklären, welche BahnCard-Variante für mein Fahrprofil sinnvoll ist?',
      arabic:
          'أسافر بانتظام على القطارات بين المدن. هل يمكنكم شرح أي نوع من BahnCard يناسب نمط سفري؟',
      tags: <String>['BahnCard', 'Fernverkehr', 'Variante', 'بطاقة'],
    ),
    IntercityPhrase(
      id: 'bahncard-contract',
      category: IntercityTravelCategory.bahnCard,
      topicDe: 'Laufzeit und Kündigung',
      topicAr: 'مدة العقد والإلغاء',
      german:
          'Welche Laufzeit, Verlängerung und Kündigungsfrist gelten für diese BahnCard?',
      arabic:
          'ما مدة العقد وطريقة التجديد ومهلة الإلغاء لهذه البطاقة؟',
      tags: <String>['BahnCard', 'Laufzeit', 'Verlängerung', 'Kündigungsfrist', 'إلغاء'],
    ),
    IntercityPhrase(
      id: 'bahncard-discount',
      category: IntercityTravelCategory.bahnCard,
      topicDe: 'Rabatt anwenden',
      topicAr: 'استخدام الخصم',
      german:
          'Wie wird der BahnCard-Rabatt bei der Buchung angewendet, und wo prüfe ich ihn vor dem Kauf?',
      arabic:
          'كيف يتم تطبيق خصم BahnCard عند الحجز، وأين أتحقق منه قبل الشراء؟',
      tags: <String>['Rabatt', 'Buchung', 'BahnCard', 'خصم'],
    ),
  ];
}
