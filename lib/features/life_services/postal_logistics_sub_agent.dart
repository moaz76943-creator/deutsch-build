import 'services_master_orchestrator.dart';

final class PostalLogisticsSubAgent {
  const PostalLogisticsSubAgent();

  static const List<ServicePhrase> entries = <ServicePhrase>[
    ServicePhrase(
      id: 'postal-parcel-tracking',
      category: ServiceCategory.postal,
      topicDe: 'Paket mit Sendungsverfolgung',
      topicAr: 'إرسال طرد مع التتبع',
      german:
          'Ich möchte dieses Paket mit Sendungsverfolgung verschicken. Welche Versandart passt dafür?',
      arabic:
          'أريد إرسال هذا الطرد مع خدمة التتبع. ما نوع الشحن المناسب لذلك؟',
      tags: <String>[
        'Paket',
        'versenden',
        'Sendungsverfolgung',
        'tracking',
        'طرد',
        'تتبع',
      ],
    ),
    ServicePhrase(
      id: 'postal-registered-letter',
      category: ServiceCategory.postal,
      topicDe: 'Einschreiben',
      topicAr: 'رسالة مسجلة',
      german:
          'Ich möchte diesen Brief per Einschreiben versenden und bitte um einen Einlieferungsbeleg.',
      arabic:
          'أريد إرسال هذه الرسالة كبريد مسجل، وأرجو إعطائي إيصال الإيداع.',
      tags: <String>[
        'Einschreiben',
        'Brief',
        'Einlieferungsbeleg',
        'registered letter',
        'رسالة',
        'مسجل',
      ],
    ),
    ServicePhrase(
      id: 'postal-customs-declaration',
      category: ServiceCategory.postal,
      topicDe: 'Zollinhaltserklärung',
      topicAr: 'التصريح الجمركي',
      german:
          'Wo trage ich Inhalt und Wert der Sendung in der Zollinhaltserklärung ein?',
      arabic:
          'أين أكتب محتوى الشحنة وقيمتها في نموذج التصريح الجمركي؟',
      tags: <String>[
        'Zoll',
        'Zollinhaltserklärung',
        'Inhalt',
        'Wert',
        'جمارك',
        'تصريح',
      ],
    ),
    ServicePhrase(
      id: 'postal-packstation-pickup',
      category: ServiceCategory.postal,
      topicDe: 'Abholung aus der Packstation',
      topicAr: 'الاستلام من Packstation',
      german:
          'Ich möchte meine Sendung aus der Packstation abholen. Wo finde ich den Abholcode?',
      arabic:
          'أريد استلام شحنتي من جهاز Packstation. أين أجد رمز الاستلام؟',
      tags: <String>[
        'Packstation',
        'Abholung',
        'Abholcode',
        'pickup',
        'استلام',
        'رمز',
      ],
    ),
    ServicePhrase(
      id: 'postal-tracking-stalled',
      category: ServiceCategory.postal,
      topicDe: 'Tracking-Status unverändert',
      topicAr: 'حالة التتبع لم تتغير',
      german:
          'Laut Sendungsverfolgung hat sich der Status seit drei Tagen nicht geändert. Können Sie das bitte prüfen?',
      arabic:
          'بحسب التتبع لم تتغير حالة الشحنة منذ ثلاثة أيام. هل يمكنكم التحقق من ذلك من فضلكم؟',
      tags: <String>[
        'Status',
        'Verspätung',
        'Nachforschung',
        'tracking',
        'تأخير',
        'متابعة',
      ],
    ),
    ServicePhrase(
      id: 'postal-marked-delivered-missing',
      category: ServiceCategory.postal,
      topicDe: 'Als zugestellt markiert, aber nicht angekommen',
      topicAr: 'مسجلة كمُسلّمة لكنها لم تصل',
      german:
          'Meine Sendung ist als zugestellt markiert, aber sie ist nicht angekommen. Bitte prüfen Sie den Zustellnachweis.',
      arabic:
          'الشحنة مسجلة على أنها سُلّمت، لكنها لم تصل. أرجو التحقق من إثبات التسليم.',
      tags: <String>[
        'zugestellt',
        'fehlend',
        'Zustellnachweis',
        'missing',
        'مفقود',
        'إثبات التسليم',
      ],
    ),
  ];
}
