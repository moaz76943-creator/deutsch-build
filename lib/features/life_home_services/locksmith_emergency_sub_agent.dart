import 'home_services_models.dart';

final class LocksmithEmergencySubAgent {
  const LocksmithEmergencySubAgent();

  List<HomeServicePhrase> get phrases => _phrases;

  static const List<HomeServicePhrase> _phrases = <HomeServicePhrase>[
    HomeServicePhrase(
      id: 'locksmith-door-fell-shut',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Die Tür ist nur zugefallen, nicht abgeschlossen. Ich habe mich ausgesperrt.',
      arabic:
          'الباب انغلق خلفي فقط وليس مقفلاً بالمفتاح. لقد بقيت خارج المنزل.',
      contextDe: 'Klar sagen: Tür zugefallen, nicht abgeschlossen',
      contextAr:
          'توضيح أن الباب أغلق فقط ولم يُقفل بالمفتاح لتجنب خدمة غير ضرورية',
      keywords: <String>[
        'zugefallen',
        'ausgesperrt',
        'nicht abgeschlossen',
        'باب مغلق',
        'خارج المنزل',
      ],
    ),
    HomeServicePhrase(
      id: 'locksmith-door-locked',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Die Tür ist abgeschlossen, und ich habe den Schlüssel verloren.',
      arabic:
          'الباب مقفل بالمفتاح وقد فقدت المفتاح.',
      contextDe: 'Klar sagen: Tür tatsächlich abgeschlossen',
      contextAr:
          'توضيح أن الباب مقفل فعلاً بالمفتاح وأن المفتاح مفقود',
      keywords: <String>[
        'abgeschlossen',
        'Schlüssel verloren',
        'مقفل',
        'مغلق',
        'مفتاح مفقود',
      ],
    ),
    HomeServicePhrase(
      id: 'locksmith-fixed-price',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Bevor Sie jemanden losschicken: Nennen Sie mir bitte einen '
          'verbindlichen Festpreis inklusive Anfahrt und aller Zuschläge.',
      arabic:
          'قبل إرسال الفني: أعطني من فضلك سعراً ثابتاً وملزماً يشمل أجرة الوصول وجميع الرسوم الإضافية.',
      contextDe: 'Verbindlichen Gesamtpreis vor der Anfahrt klären',
      contextAr:
          'الاتفاق على السعر الإجمالي الثابت قبل تحرك الفني',
      keywords: <String>[
        'Festpreis',
        'verbindlich',
        'Anfahrt',
        'Zuschläge',
        'Gesamtpreis',
        'السعر',
        'أجرة الوصول',
      ],
    ),
    HomeServicePhrase(
      id: 'locksmith-no-damage-first',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Bitte versuchen Sie zuerst eine möglichst beschädigungsfreie Öffnung '
          'und erklären Sie mir vorher, falls ein Austausch nötig sein sollte.',
      arabic:
          'يرجى محاولة فتح الباب بأقل ضرر ممكن أولاً، وإبلاغي مسبقاً إذا كان الاستبدال ضرورياً.',
      contextDe: 'Keine unnötige Zerstörung oder Ersatzteile akzeptieren',
      contextAr:
          'طلب محاولة الفتح دون إتلاف قبل الموافقة على استبدال قطع',
      keywords: <String>[
        'beschädigungsfrei',
        'Austausch',
        'Schloss',
        'Zylinder',
        'فتح بدون ضرر',
      ],
    ),
    HomeServicePhrase(
      id: 'locksmith-credentials',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Bitte zeigen Sie mir vor Beginn Ihren Ausweis oder einen '
          'Firmennachweis und nennen Sie mir den Firmennamen.',
      arabic:
          'يرجى إظهار بطاقة هوية أو إثبات الشركة قبل بدء العمل وذكر اسم الشركة.',
      contextDe: 'Identität und Firmenzugehörigkeit vor Arbeitsbeginn prüfen',
      contextAr:
          'التحقق من هوية الفني واسم الشركة قبل بدء العمل',
      keywords: <String>[
        'Ausweis',
        'Firmennachweis',
        'Firmenname',
        'Techniker',
        'هوية',
        'شركة',
      ],
    ),
    HomeServicePhrase(
      id: 'locksmith-invoice',
      domain: HomeServicesDomain.locksmithEmergency,
      german:
          'Ich möchte nach der Arbeit eine vollständige Rechnung mit '
          'Firmenname, Leistung und Einzelbeträgen erhalten.',
      arabic:
          'أريد بعد انتهاء العمل فاتورة كاملة تتضمن اسم الشركة والخدمة والمبالغ المفصلة.',
      contextDe: 'Vollständige Rechnung verlangen',
      contextAr: 'طلب فاتورة مفصلة وواضحة بعد الخدمة',
      keywords: <String>[
        'Rechnung',
        'Einzelbeträge',
        'Leistung',
        'فاتورة',
      ],
    ),
  ];
}
