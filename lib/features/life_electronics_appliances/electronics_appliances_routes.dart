import 'electronics_appliances_models.dart';

abstract final class ElectronicsAppliancesRoutes {
  static const ElectronicsRouteDescriptor specificationsWarranty =
      ElectronicsRouteDescriptor(
    id: ElectronicsRouteId.specificationsWarranty,
    domain: ElectronicsDomain.specificationsWarranty,
    routeName: '/life-electronics-appliances/specs-warranty',
    titleDe: 'Geräteberatung & Garantie',
    titleAr: 'مواصفات الأجهزة والكفالة',
    descriptionDe:
        'Technische Daten verstehen, Modelle vergleichen, Lieferumfang und Garantiebedingungen klären.',
    descriptionAr:
        'فهم المواصفات ومقارنة الأجهزة والتأكد من المحتويات وشروط الكفالة.',
    searchTerms: <String>[
      'Speicher',
      'RAM',
      'Energieverbrauch',
      'Anschlüsse',
      'Garantie',
      'Gewährleistung',
      'مواصفات',
      'ذاكرة',
      'كفالة',
    ],
  );

  static const ElectronicsRouteDescriptor serviceRepair =
      ElectronicsRouteDescriptor(
    id: ElectronicsRouteId.serviceRepair,
    domain: ElectronicsDomain.serviceRepair,
    routeName: '/life-electronics-appliances/service-repair',
    titleDe: 'Service & Reparatur',
    titleAr: 'الصيانة والإصلاح',
    descriptionDe:
        'Defekte beschreiben, Diagnose und Kostenvoranschlag klären, Reparaturstatus verfolgen.',
    descriptionAr:
        'وصف الأعطال وطلب التشخيص وتقدير التكلفة ومتابعة حالة الإصلاح.',
    searchTerms: <String>[
      'Reparatur',
      'Service',
      'Defekt',
      'Kostenvoranschlag',
      'Ersatzteil',
      'صيانة',
      'إصلاح',
      'عطل',
    ],
  );

  static const List<ElectronicsRouteDescriptor> all =
      <ElectronicsRouteDescriptor>[
    specificationsWarranty,
    serviceRepair,
  ];
}
