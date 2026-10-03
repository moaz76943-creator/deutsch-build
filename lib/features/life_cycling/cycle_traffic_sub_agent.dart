import 'cycling_models.dart';

final class CycleTrafficSubAgent {
  const CycleTrafficSubAgent();

  List<CyclingPhrase> get phrases => _phrases;
  List<BikeSafetyCheckItem> get safetyChecklist => _safetyChecklist;

  static const List<BikeSafetyCheckItem> _safetyChecklist =
      <BikeSafetyCheckItem>[
    BikeSafetyCheckItem(
      id: 'bell',
      labelDe: 'Klingel: mindestens eine helltönende Glocke',
      labelAr: 'جرس واضح الصوت واحد على الأقل',
      legalBasis: 'StVZO § 64a',
    ),
    BikeSafetyCheckItem(
      id: 'brakes',
      labelDe: 'zwei unabhängige Bremsen',
      labelAr: 'فراملان مستقلان عن بعضهما',
      legalBasis: 'StVZO § 65',
    ),
    BikeSafetyCheckItem(
      id: 'front-light',
      labelDe: 'weißer Scheinwerfer und weißer Rückstrahler vorn',
      labelAr: 'مصباح أمامي أبيض وعاكس أبيض في الأمام',
      legalBasis: 'StVZO § 67',
    ),
    BikeSafetyCheckItem(
      id: 'rear-light',
      labelDe: 'rote Schlussleuchte und roter Rückstrahler hinten',
      labelAr: 'ضوء خلفي أحمر وعاكس أحمر في الخلف',
      legalBasis: 'StVZO § 67',
    ),
    BikeSafetyCheckItem(
      id: 'reflectors',
      labelDe: 'Pedal- und seitliche Rückstrahler / zugelassene Alternativen',
      labelAr: 'عواكس للدواسات والجوانب أو بدائل معتمدة',
      legalBasis: 'StVZO § 67',
    ),
  ];

  static const List<CyclingPhrase> _phrases = <CyclingPhrase>[
    CyclingPhrase(
      id: 'traffic-equipment',
      category: CyclingCategory.trafficSafety,
      topic: CyclingTopic.equipment,
      titleDe: 'Verkehrssicheres Fahrrad',
      german:
          'Vor der Fahrt prüfe ich Klingel, beide Bremsen, Scheinwerfer und Rückstrahler.',
      arabic:
          'قبل الانطلاق أفحص الجرس والفراملين والمصباح الأمامي والعواكس.',
      keywords: <String>[
        'Klingel',
        'zwei Bremsen',
        'Reflektoren',
        'Rückstrahler',
        'Scheinwerfer',
        'StVZO',
      ],
    ),
    CyclingPhrase(
      id: 'traffic-radweg',
      category: CyclingCategory.trafficSafety,
      topic: CyclingTopic.radweg,
      titleDe: 'Radwegbenutzungspflicht erkennen',
      german:
          'Eine Radwegbenutzungspflicht besteht nur, wenn sie durch die entsprechenden Verkehrszeichen angeordnet ist.',
      arabic:
          'يصبح استخدام مسار الدراجة إلزامياً فقط عندما تفرضه إشارات المرور المخصصة.',
      keywords: <String>[
        'Radwegbenutzungspflicht',
        'Zeichen 237',
        'Zeichen 240',
        'Zeichen 241',
        'StVO',
      ],
    ),
    CyclingPhrase(
      id: 'traffic-one-way',
      category: CyclingCategory.trafficSafety,
      topic: CyclingTopic.oneWayStreet,
      titleDe: 'Einbahnstraße für Radverkehr freigegeben',
      german:
          'Dieses Zusatzzeichen erlaubt Radverkehr in der Einbahnstraße auch entgegen der Fahrtrichtung.',
      arabic:
          'هذه الإشارة الإضافية تسمح للدراجات بالسير في الشارع أحادي الاتجاه بعكس اتجاه المركبات.',
      keywords: <String>[
        'Einbahnstraße',
        'Radfahrer frei',
        'Gegenrichtung',
        'Zusatzzeichen',
        'StVO',
      ],
    ),
    CyclingPhrase(
      id: 'traffic-hand-signal',
      category: CyclingCategory.trafficSafety,
      topic: CyclingTopic.handSignal,
      titleDe: 'Handzeichen geben',
      german:
          'Ich kündige das Abbiegen rechtzeitig und deutlich mit einem Handzeichen an und achte vorher auf den Verkehr hinter mir.',
      arabic:
          'أعلن عن الانعطاف مبكراً وبوضوح بإشارة اليد وأنتبه أولاً إلى حركة المرور خلفي.',
      keywords: <String>[
        'Handzeichen',
        'abbiegen',
        'Abbiegen',
        'Fahrtrichtung',
        'StVO § 9',
      ],
    ),
  ];
}
