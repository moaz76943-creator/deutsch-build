final class LifeCurriculumLink {
  const LifeCurriculumLink({
    required this.ordinal,
    required this.featureKey,
    required this.titleDe,
    required this.titleAr,
    required this.curriculumTaskId,
  });

  final int ordinal;
  final String featureKey;
  final String titleDe;
  final String titleAr;
  final String curriculumTaskId;
}

final class LifeCurriculumCatalog {
  LifeCurriculumCatalog._(List<LifeCurriculumLink> links)
      : links = List<LifeCurriculumLink>.unmodifiable(links),
        _byFeatureKey = <String, LifeCurriculumLink>{
          for (final link in links) link.featureKey: link,
        } {
    if (this.links.length != 50) {
      throw StateError('Life curriculum catalog must contain exactly 50 tasks.');
    }
    if (_byFeatureKey.length != this.links.length) {
      throw StateError('Life feature keys must be unique.');
    }
    final ordinals = this.links.map((link) => link.ordinal).toSet();
    if (ordinals.length != 50 ||
        !List<int>.generate(50, (index) => index + 1)
            .every(ordinals.contains)) {
      throw StateError('Life task ordinals must be exactly 1..50.');
    }
  }

  factory LifeCurriculumCatalog.standard() =>
      LifeCurriculumCatalog._(_standardLinks);

  final List<LifeCurriculumLink> links;
  final Map<String, LifeCurriculumLink> _byFeatureKey;

  LifeCurriculumLink? find(String featureKey) =>
      _byFeatureKey[featureKey.trim()];

  LifeCurriculumLink require(String featureKey) {
    final link = find(featureKey);
    if (link == null) {
      throw StateError('Unknown life feature key: $featureKey');
    }
    return link;
  }

  static const List<LifeCurriculumLink> _standardLinks =
      <LifeCurriculumLink>[
    LifeCurriculumLink(
      ordinal: 1,
      featureKey: 'life_bicycle_mobility',
      titleDe: 'Fahrrad & Mobilität',
      titleAr: 'الدراجة والتنقل',
      curriculumTaskId: 'task-15',
    ),
    LifeCurriculumLink(
      ordinal: 2,
      featureKey: 'life_bureaucracy',
      titleDe: 'Behördenwege',
      titleAr: 'المعاملات الرسمية',
      curriculumTaskId: 'task-38',
    ),
    LifeCurriculumLink(
      ordinal: 3,
      featureKey: 'life_car_service',
      titleDe: 'Autowerkstatt',
      titleAr: 'صيانة السيارة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 4,
      featureKey: 'life_career',
      titleDe: 'Bewerbung & Beruf',
      titleAr: 'التقديم والعمل',
      curriculumTaskId: 'task-37',
    ),
    LifeCurriculumLink(
      ordinal: 5,
      featureKey: 'life_childcare_kindergarten',
      titleDe: 'Kita & Kindergarten',
      titleAr: 'الحضانة ورياض الأطفال',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 6,
      featureKey: 'life_clothing_alterations',
      titleDe: 'Kleidung & Änderung',
      titleAr: 'الملابس والتعديلات',
      curriculumTaskId: 'task-13',
    ),
    LifeCurriculumLink(
      ordinal: 7,
      featureKey: 'life_culture',
      titleDe: 'Bibliothek & VHS',
      titleAr: 'المكتبة والتعليم للكبار',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 8,
      featureKey: 'life_cycling',
      titleDe: 'Radfahren im Alltag',
      titleAr: 'ركوب الدراجة يومياً',
      curriculumTaskId: 'task-15',
    ),
    LifeCurriculumLink(
      ordinal: 9,
      featureKey: 'life_dentist_clinic',
      titleDe: 'Zahnarzt',
      titleAr: 'طبيب الأسنان',
      curriculumTaskId: 'task-39',
    ),
    LifeCurriculumLink(
      ordinal: 10,
      featureKey: 'life_diy',
      titleDe: 'Baumarkt & DIY',
      titleAr: 'الأدوات والأعمال المنزلية',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 11,
      featureKey: 'life_doctor_appointment',
      titleDe: 'Arzttermin',
      titleAr: 'موعد الطبيب',
      curriculumTaskId: 'task-17',
    ),
    LifeCurriculumLink(
      ordinal: 12,
      featureKey: 'life_driving',
      titleDe: 'Fahren & Fahrschule',
      titleAr: 'القيادة ومدرسة السياقة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 13,
      featureKey: 'life_drogerie_market',
      titleDe: 'Drogeriemarkt',
      titleAr: 'متجر العناية والمنظفات',
      curriculumTaskId: 'task-13',
    ),
    LifeCurriculumLink(
      ordinal: 14,
      featureKey: 'life_education',
      titleDe: 'Schule & Familie',
      titleAr: 'المدرسة والأسرة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 15,
      featureKey: 'life_electronics_appliances',
      titleDe: 'Elektronik & Geräte',
      titleAr: 'الإلكترونيات والأجهزة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 16,
      featureKey: 'life_emergency_health',
      titleDe: 'Medizinischer Notfall',
      titleAr: 'الطوارئ الصحية',
      curriculumTaskId: 'task-39',
    ),
    LifeCurriculumLink(
      ordinal: 17,
      featureKey: 'life_environment',
      titleDe: 'Wetter & Umwelt',
      titleAr: 'الطقس والبيئة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 18,
      featureKey: 'life_furniture_home_setup',
      titleDe: 'Möbel & Wohnung',
      titleAr: 'الأثاث وتجهيز المنزل',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 19,
      featureKey: 'life_gas_station_carwash',
      titleDe: 'Tankstelle & Autowäsche',
      titleAr: 'محطة الوقود وغسيل السيارة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 20,
      featureKey: 'life_haircut_barbershop',
      titleDe: 'Friseur',
      titleAr: 'الحلاقة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 21,
      featureKey: 'life_hardware_store_diy',
      titleDe: 'Baumarkt & Werkzeug',
      titleAr: 'متجر الأدوات والمواد',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 22,
      featureKey: 'life_health',
      titleDe: 'Gesundheit',
      titleAr: 'الصحة',
      curriculumTaskId: 'task-39',
    ),
    LifeCurriculumLink(
      ordinal: 23,
      featureKey: 'life_home_services',
      titleDe: 'Handwerker & Notdienst',
      titleAr: 'خدمات المنزل والفنيون',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 24,
      featureKey: 'life_housing',
      titleDe: 'Wohnungssuche',
      titleAr: 'البحث عن سكن',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 25,
      featureKey: 'life_intercity_train_travel',
      titleDe: 'Fernzug & ICE',
      titleAr: 'قطارات السفر بين المدن',
      curriculumTaskId: 'task-15',
    ),
    LifeCurriculumLink(
      ordinal: 26,
      featureKey: 'life_jobcenter_employment',
      titleDe: 'Jobcenter',
      titleAr: 'مركز العمل',
      curriculumTaskId: 'task-38',
    ),
    LifeCurriculumLink(
      ordinal: 27,
      featureKey: 'life_laundry',
      titleDe: 'Wäscherei',
      titleAr: 'الغسيل والتنظيف',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 28,
      featureKey: 'life_lost_found',
      titleDe: 'Fundbüro',
      titleAr: 'المفقودات',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 29,
      featureKey: 'life_mobility',
      titleDe: 'Mobilität & Verkehr',
      titleAr: 'التنقل والمواصلات',
      curriculumTaskId: 'task-15',
    ),
    LifeCurriculumLink(
      ordinal: 30,
      featureKey: 'life_optician_glasses',
      titleDe: 'Optiker & Brille',
      titleAr: 'النظارات وفحص النظر',
      curriculumTaskId: 'task-39',
    ),
    LifeCurriculumLink(
      ordinal: 31,
      featureKey: 'life_outdoors',
      titleDe: 'Reisen & Natur',
      titleAr: 'السفر والطبيعة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 32,
      featureKey: 'life_pets',
      titleDe: 'Tierarzt & Haustiere',
      titleAr: 'الحيوانات الأليفة والبيطرة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 33,
      featureKey: 'life_pharmacy_medication',
      titleDe: 'Apotheke & Medikamente',
      titleAr: 'الصيدلية والأدوية',
      curriculumTaskId: 'task-39',
    ),
    LifeCurriculumLink(
      ordinal: 34,
      featureKey: 'life_postal_delivery',
      titleDe: 'Post & Pakete',
      titleAr: 'البريد والطرود',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 35,
      featureKey: 'life_public_offices',
      titleDe: 'Bürgeramt & Dokumente',
      titleAr: 'الدوائر والوثائق',
      curriculumTaskId: 'task-38',
    ),
    LifeCurriculumLink(
      ordinal: 36,
      featureKey: 'life_rent_housing',
      titleDe: 'Miete & Wohnung',
      titleAr: 'الإيجار والسكن',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 37,
      featureKey: 'life_restaurant_dining',
      titleDe: 'Restaurant',
      titleAr: 'المطعم',
      curriculumTaskId: 'task-12',
    ),
    LifeCurriculumLink(
      ordinal: 38,
      featureKey: 'life_safety',
      titleDe: 'Sicherheit & Hilfe',
      titleAr: 'السلامة وطلب المساعدة',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 39,
      featureKey: 'life_secondhand',
      titleDe: 'Secondhand & Spenden',
      titleAr: 'المستعمل والتبرع',
      curriculumTaskId: 'task-13',
    ),
    LifeCurriculumLink(
      ordinal: 40,
      featureKey: 'life_services',
      titleDe: 'Alltagsdienste',
      titleAr: 'الخدمات اليومية',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 41,
      featureKey: 'life_shoe_repair_keys',
      titleDe: 'Schuhreparatur & Schlüssel',
      titleAr: 'إصلاح الأحذية والمفاتيح',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 42,
      featureKey: 'life_shopping',
      titleDe: 'Einkaufen & Reklamation',
      titleAr: 'التسوق والاسترجاع',
      curriculumTaskId: 'task-13',
    ),
    LifeCurriculumLink(
      ordinal: 43,
      featureKey: 'life_social',
      titleDe: 'Nachbarschaft & Soziales',
      titleAr: 'الجيران والمواقف الاجتماعية',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 44,
      featureKey: 'life_sports',
      titleDe: 'Sport & Verein',
      titleAr: 'الرياضة والنادي',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 45,
      featureKey: 'life_supermarket_groceries',
      titleDe: 'Supermarkt',
      titleAr: 'السوبرماركت',
      curriculumTaskId: 'task-13',
    ),
    LifeCurriculumLink(
      ordinal: 46,
      featureKey: 'life_telecom',
      titleDe: 'Internet & Mobilfunk',
      titleAr: 'الإنترنت والاتصالات',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 47,
      featureKey: 'life_travel_agency',
      titleDe: 'Reisebüro',
      titleAr: 'وكالة السفر',
      curriculumTaskId: 'task-47',
    ),
    LifeCurriculumLink(
      ordinal: 48,
      featureKey: 'life_utilities',
      titleDe: 'Strom, Gas & Verträge',
      titleAr: 'الكهرباء والغاز والعقود',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 49,
      featureKey: 'life_waste_recycling',
      titleDe: 'Mülltrennung & Recycling',
      titleAr: 'فرز النفايات وإعادة التدوير',
      curriculumTaskId: 'task-16',
    ),
    LifeCurriculumLink(
      ordinal: 50,
      featureKey: 'life_maintenance',
      titleDe: 'Hauswartung & Entsorgung',
      titleAr: 'صيانة المنزل وإدارة النفايات',
      curriculumTaskId: 'task-16',
    ),
  ];
}
