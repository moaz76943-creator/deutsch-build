enum HaircutServiceKind {
  classicHaircut,
  beardTrim,
  moustacheTrim,
  washDry,
  basicCare,
}

final class HaircutServiceOption {
  const HaircutServiceOption({
    required this.id,
    required this.kind,
    required this.germanName,
    required this.arabicName,
    required this.estimatedMinutes,
  });

  final String id;
  final HaircutServiceKind kind;
  final String germanName;
  final String arabicName;
  final int estimatedMinutes;
}

final class SalonOpeningHours {
  const SalonOpeningHours({
    required this.dayDe,
    required this.opensAt,
    required this.closesAt,
  });

  final String dayDe;
  final String opensAt;
  final String closesAt;

  String get labelDe => '$dayDe · $opensAt–$closesAt';
}

enum HaircutAppointmentMode {
  reserved,
  walkIn,
}

final class HaircutAppointmentPreference {
  const HaircutAppointmentPreference({
    required this.mode,
    this.preferredDayDe,
    this.preferredTime,
  });

  final HaircutAppointmentMode mode;
  final String? preferredDayDe;
  final String? preferredTime;
}

final class ClassicGroomingPreference {
  const ClassicGroomingPreference({
    required this.haircutNoteDe,
    this.beardNoteDe,
    this.washHair = false,
    this.gentleDrying = false,
  });

  final String haircutNoteDe;
  final String? beardNoteDe;
  final bool washHair;
  final bool gentleDrying;
}

abstract final class HaircutBarbershopCatalog {
  static const List<HaircutServiceOption> services = <HaircutServiceOption>[
    HaircutServiceOption(
      id: 'classic-cut',
      kind: HaircutServiceKind.classicHaircut,
      germanName: 'Klassischer Haarschnitt',
      arabicName: 'قصة شعر كلاسيكية',
      estimatedMinutes: 30,
    ),
    HaircutServiceOption(
      id: 'beard-trim',
      kind: HaircutServiceKind.beardTrim,
      germanName: 'Bart stutzen',
      arabicName: 'تهذيب اللحية',
      estimatedMinutes: 15,
    ),
    HaircutServiceOption(
      id: 'moustache-trim',
      kind: HaircutServiceKind.moustacheTrim,
      germanName: 'Schnurrbart kürzen',
      arabicName: 'تهذيب الشارب',
      estimatedMinutes: 10,
    ),
    HaircutServiceOption(
      id: 'wash-dry',
      kind: HaircutServiceKind.washDry,
      germanName: 'Waschen und föhnen',
      arabicName: 'غسل وتجفيف الشعر',
      estimatedMinutes: 20,
    ),
    HaircutServiceOption(
      id: 'basic-care',
      kind: HaircutServiceKind.basicCare,
      germanName: 'Einfache Haarpflege',
      arabicName: 'عناية أساسية بالشعر',
      estimatedMinutes: 10,
    ),
  ];

  static const List<SalonOpeningHours> sampleOpeningHours =
      <SalonOpeningHours>[
    SalonOpeningHours(dayDe: 'Montag', opensAt: '09:00', closesAt: '18:00'),
    SalonOpeningHours(dayDe: 'Dienstag', opensAt: '09:00', closesAt: '18:00'),
    SalonOpeningHours(dayDe: 'Mittwoch', opensAt: '09:00', closesAt: '18:00'),
    SalonOpeningHours(
      dayDe: 'Donnerstag',
      opensAt: '09:00',
      closesAt: '19:00',
    ),
    SalonOpeningHours(dayDe: 'Freitag', opensAt: '09:00', closesAt: '18:00'),
    SalonOpeningHours(dayDe: 'Samstag', opensAt: '09:00', closesAt: '15:00'),
  ];
}
