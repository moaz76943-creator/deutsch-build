enum ServiceCategory {
  postal,
  telecom,
}

extension ServiceCategoryLabels on ServiceCategory {
  String get labelDe => switch (this) {
        ServiceCategory.postal => 'Post & Pakete',
        ServiceCategory.telecom => 'Internet & Mobilfunk',
      };

  String get labelAr => switch (this) {
        ServiceCategory.postal => 'البريد والطرود',
        ServiceCategory.telecom => 'الإنترنت والاتصالات',
      };
}

enum PackageTrackingStatus {
  expected,
  inTransit,
  readyForPickup,
  delayed,
  missing,
}

extension PackageTrackingStatusLabels on PackageTrackingStatus {
  String get labelDe => switch (this) {
        PackageTrackingStatus.expected => 'Angekündigt',
        PackageTrackingStatus.inTransit => 'Unterwegs',
        PackageTrackingStatus.readyForPickup => 'Abholbereit',
        PackageTrackingStatus.delayed => 'Verspätet',
        PackageTrackingStatus.missing => 'Nicht angekommen',
      };

  String get labelAr => switch (this) {
        PackageTrackingStatus.expected => 'تم إنشاء الشحنة',
        PackageTrackingStatus.inTransit => 'في الطريق',
        PackageTrackingStatus.readyForPickup => 'جاهزة للاستلام',
        PackageTrackingStatus.delayed => 'متأخرة',
        PackageTrackingStatus.missing => 'لم تصل',
      };
}

final class ServicePhrase {
  const ServicePhrase({
    required this.id,
    required this.category,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.tags = const <String>[],
  });

  final String id;
  final ServiceCategory category;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> tags;
}

final class PackageStatusGuidance {
  const PackageStatusGuidance({
    required this.titleDe,
    required this.titleAr,
    required this.detailDe,
    required this.detailAr,
  });

  final String titleDe;
  final String titleAr;
  final String detailDe;
  final String detailAr;
}

final class MissingPackageStep {
  const MissingPackageStep({
    required this.titleDe,
    required this.titleAr,
  });

  final String titleDe;
  final String titleAr;
}

final class ServicesMasterOrchestrator {
  ServicesMasterOrchestrator({
    required Iterable<ServicePhrase> entries,
  }) : _entries = List<ServicePhrase>.unmodifiable(entries);

  final List<ServicePhrase> _entries;
  final Set<ServiceCategory> _selectedCategories = <ServiceCategory>{
    ServiceCategory.postal,
    ServiceCategory.telecom,
  };

  String _query = '';
  PackageTrackingStatus _trackingStatus = PackageTrackingStatus.inTransit;
  bool _missingPackageExpanded = false;

  String get query => _query;

  PackageTrackingStatus get trackingStatus => _trackingStatus;

  bool get missingPackageExpanded => _missingPackageExpanded;

  Set<ServiceCategory> get selectedCategories =>
      Set<ServiceCategory>.unmodifiable(_selectedCategories);

  List<ServicePhrase> get visibleEntries {
    final normalizedQuery = _normalize(_query);

    final filtered = _entries.where((entry) {
      if (!_selectedCategories.contains(entry.category)) return false;
      if (normalizedQuery.isEmpty) return true;

      final searchable = _normalize(
        <String>[
          entry.topicDe,
          entry.topicAr,
          entry.german,
          entry.arabic,
          ...entry.tags,
        ].join(' '),
      );
      return searchable.contains(normalizedQuery);
    }).toList(growable: false);

    return List<ServicePhrase>.unmodifiable(filtered);
  }

  void setQuery(String value) {
    _query = value.trim();
  }

  void toggleCategory(ServiceCategory category) {
    if (_selectedCategories.contains(category)) {
      _selectedCategories.remove(category);
    } else {
      _selectedCategories.add(category);
    }
  }

  void setTrackingStatus(PackageTrackingStatus status) {
    _trackingStatus = status;
    if (status != PackageTrackingStatus.missing) {
      _missingPackageExpanded = false;
    }
  }

  void activateMissingPackagePanic() {
    _trackingStatus = PackageTrackingStatus.missing;
    _missingPackageExpanded = true;
  }

  void dismissMissingPackagePanic() {
    _missingPackageExpanded = false;
  }

  PackageStatusGuidance get trackingGuidance => switch (_trackingStatus) {
        PackageTrackingStatus.expected => const PackageStatusGuidance(
            titleDe: 'Sendung angekündigt',
            titleAr: 'تم إنشاء بيانات الشحنة',
            detailDe:
                'Prüfen Sie, ob der Absender das Paket bereits an den Dienstleister übergeben hat.',
            detailAr:
                'تحقق مما إذا كان المرسل قد سلّم الطرد فعلياً إلى شركة الشحن.',
          ),
        PackageTrackingStatus.inTransit => const PackageStatusGuidance(
            titleDe: 'Sendung ist unterwegs',
            titleAr: 'الشحنة في الطريق',
            detailDe:
                'Behalten Sie den letzten Scan, den Ort und das voraussichtliche Zustellfenster im Blick.',
            detailAr:
                'راقب آخر تحديث للمسح والموقع وموعد التسليم المتوقع.',
          ),
        PackageTrackingStatus.readyForPickup => const PackageStatusGuidance(
            titleDe: 'Abholung vorbereiten',
            titleAr: 'جهّز معلومات الاستلام',
            detailDe:
                'Halten Sie Abholcode, Benachrichtigung und gegebenenfalls einen Ausweis bereit.',
            detailAr:
                'جهّز رمز الاستلام والإشعار، ومعرّف الهوية إذا طُلب.',
          ),
        PackageTrackingStatus.delayed => const PackageStatusGuidance(
            titleDe: 'Verzögerung dokumentieren',
            titleAr: 'وثّق التأخير',
            detailDe:
                'Notieren Sie Sendungsnummer und letzten Scan und stellen Sie eine sachliche Statusanfrage.',
            detailAr:
                'دوّن رقم الشحنة وآخر تحديث ثم أرسل استفساراً رسمياً عن الحالة.',
          ),
        PackageTrackingStatus.missing => const PackageStatusGuidance(
            titleDe: 'Sendung nicht angekommen',
            titleAr: 'الشحنة لم تصل',
            detailDe:
                'Prüfen Sie Zustellort und Zustellnachweis und melden Sie die Abweichung mit der Sendungsnummer.',
            detailAr:
                'تحقق من مكان وإثبات التسليم ثم بلّغ عن المشكلة باستخدام رقم الشحنة.',
          ),
      };

  static const List<MissingPackageStep> missingPackageSteps =
      <MissingPackageStep>[
    MissingPackageStep(
      titleDe: 'Sendungsnummer und letzten Tracking-Scan sichern.',
      titleAr: 'احفظ رقم الشحنة وآخر تحديث للتتبع.',
    ),
    MissingPackageStep(
      titleDe: 'Ablageort, Nachbarn und Zustellnachweis prüfen.',
      titleAr: 'تحقق من مكان التسليم والجيران وإثبات التسليم.',
    ),
    MissingPackageStep(
      titleDe: 'Beim Zustelldienst eine sachliche Nachforschung anfragen.',
      titleAr: 'اطلب من شركة التوصيل فتح متابعة رسمية للشحنة.',
    ),
  ];

  static String _normalize(String value) {
    var normalized = value.toLowerCase();
    normalized = normalized
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
