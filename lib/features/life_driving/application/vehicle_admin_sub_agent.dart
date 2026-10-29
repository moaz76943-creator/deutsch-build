import '../domain/driving_models.dart';

final class VehicleAdminSubAgent {
  const VehicleAdminSubAgent();

  List<DrivingLearningItem> get items => _items;

  static const List<DrivingLearningItem> _items = <DrivingLearningItem>[
    DrivingLearningItem(
      id: 'vehicle_registration_appointment',
      category: DrivingCategory.vehicleAdmin,
      topic: DrivingTopic.registration,
      titleDe: 'Termin bei der Kfz-Zulassungsstelle',
      german:
          'Ich möchte einen Termin bei der Kfz-Zulassungsstelle vereinbaren.',
      arabic: 'أريد حجز موعد لدى دائرة تسجيل المركبات.',
      tags: <String>[
        'Kfz-Zulassungsstelle',
        'Zulassung',
        'Termin',
        'تسجيل المركبة',
      ],
    ),
    DrivingLearningItem(
      id: 'vehicle_registration_documents',
      category: DrivingCategory.vehicleAdmin,
      topic: DrivingTopic.registration,
      titleDe: 'Unterlagen für die Zulassung',
      german: 'Welche Unterlagen brauche ich für die Kfz-Zulassung?',
      arabic: 'ما الوثائق التي أحتاجها لتسجيل المركبة؟',
      tags: <String>['Unterlagen', 'Kfz-Zulassung', 'Dokumente', 'وثائق'],
    ),
    DrivingLearningItem(
      id: 'vehicle_hu_due',
      category: DrivingCategory.vehicleAdmin,
      topic: DrivingTopic.inspection,
      titleDe: 'Hauptuntersuchung (HU)',
      german: 'Wann ist die nächste Hauptuntersuchung für mein Auto fällig?',
      arabic: 'متى يحين موعد الفحص الدوري القادم لسيارتي؟',
      tags: <String>[
        'TÜV',
        'Hauptuntersuchung',
        'HU',
        'fällig',
        'فحص دوري',
      ],
    ),
    DrivingLearningItem(
      id: 'vehicle_hu_result',
      category: DrivingCategory.vehicleAdmin,
      topic: DrivingTopic.inspection,
      titleDe: 'Nach der HU fragen',
      german: 'Hat das Fahrzeug die Hauptuntersuchung bestanden?',
      arabic: 'هل اجتازت المركبة الفحص الدوري؟',
      tags: <String>['TÜV', 'HU', 'bestanden', 'Prüfung', 'فحص'],
    ),
    DrivingLearningItem(
      id: 'vehicle_emissions_sticker',
      category: DrivingCategory.vehicleAdmin,
      topic: DrivingTopic.emissionsSticker,
      titleDe: 'Umweltplakette',
      german: 'Wo bekomme ich eine Umweltplakette für mein Fahrzeug?',
      arabic: 'من أين أحصل على ملصق بيئي لمركبتي؟',
      tags: <String>[
        'Umweltplakette',
        'Umweltzone',
        'Fahrzeug',
        'ملصق بيئي',
      ],
    ),
  ];
}
