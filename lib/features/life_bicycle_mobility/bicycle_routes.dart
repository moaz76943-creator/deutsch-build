import 'bicycle_models.dart';

abstract final class BicycleRoutes {
  static const BicycleRouteDescriptor purchaseMaintenance =
      BicycleRouteDescriptor(
    id: BicycleRouteId.purchaseMaintenance,
    domain: BicycleDomain.purchaseMaintenance,
    routeName: '/life-bicycle-mobility/purchase-maintenance',
    titleDe: 'Fahrradkauf & Werkstatt',
    titleAr: 'شراء الدراجة وصيانتها',
    descriptionDe:
        'Beratung beim Fahrradkauf, passende Größe, Reparaturen und regelmäßige Wartung.',
    descriptionAr:
        'اختيار الدراجة والمقاس المناسب وإصلاح الأعطال والصيانة الدورية.',
    searchTerms: <String>[
      'Fahrrad kaufen',
      'Rahmengröße',
      'Reifen',
      'Bremse',
      'Kette',
      'Werkstatt',
      'شراء',
      'صيانة',
      'إصلاح',
    ],
  );

  static const BicycleRouteDescriptor trafficRules = BicycleRouteDescriptor(
    id: BicycleRouteId.trafficRules,
    domain: BicycleDomain.trafficRules,
    routeName: '/life-bicycle-mobility/traffic-rules',
    titleDe: 'Fahrrad im Straßenverkehr',
    titleAr: 'الدراجة في حركة المرور',
    descriptionDe:
        'Radwege, Ampeln, Beleuchtung, Abbiegen und sichere Kommunikation im Straßenverkehr.',
    descriptionAr:
        'مسارات الدراجات والإشارات والإضاءة والانعطاف والتصرف الآمن على الطريق.',
    searchTerms: <String>[
      'Radweg',
      'Ampel',
      'Beleuchtung',
      'Abbiegen',
      'StVO',
      'إشارة',
      'مرور',
      'سلامة',
    ],
  );

  static const List<BicycleRouteDescriptor> all =
      <BicycleRouteDescriptor>[
    purchaseMaintenance,
    trafficRules,
  ];
}
