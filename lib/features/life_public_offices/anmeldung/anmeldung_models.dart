enum RegistrationAction {
  all,
  anmeldung,
  ummeldung,
  meldebestaetigung;

  String get labelDe => switch (this) {
        RegistrationAction.all => 'Alle',
        RegistrationAction.anmeldung => 'Anmeldung',
        RegistrationAction.ummeldung => 'Ummeldung',
        RegistrationAction.meldebestaetigung => 'Meldebestätigung',
      };

  String get labelAr => switch (this) {
        RegistrationAction.all => 'الكل',
        RegistrationAction.anmeldung => 'تسجيل السكن',
        RegistrationAction.ummeldung => 'تغيير السكن',
        RegistrationAction.meldebestaetigung => 'شهادة التسجيل',
      };
}

enum AppointmentAction {
  all,
  book,
  confirm,
  reschedule;

  String get labelDe => switch (this) {
        AppointmentAction.all => 'Alle Termine',
        AppointmentAction.book => 'Buchen',
        AppointmentAction.confirm => 'Bestätigen',
        AppointmentAction.reschedule => 'Ändern',
      };

  String get labelAr => switch (this) {
        AppointmentAction.all => 'كل المواعيد',
        AppointmentAction.book => 'حجز',
        AppointmentAction.confirm => 'تأكيد',
        AppointmentAction.reschedule => 'تعديل',
      };
}

final class AnmeldungPhrase {
  const AnmeldungPhrase({
    required this.id,
    required this.registrationAction,
    required this.german,
    required this.arabic,
    required this.contextDe,
    required this.contextAr,
    this.appointmentAction,
    this.keywords = const <String>[],
  });

  final String id;
  final RegistrationAction registrationAction;
  final AppointmentAction? appointmentAction;
  final String german;
  final String arabic;
  final String contextDe;
  final String contextAr;
  final List<String> keywords;

  bool matches(String query) {
    final needle = _normalize(query);
    if (needle.isEmpty) return true;

    return _normalize(<String>[
      german,
      arabic,
      contextDe,
      contextAr,
      registrationAction.labelDe,
      registrationAction.labelAr,
      if (appointmentAction != null) appointmentAction!.labelDe,
      if (appointmentAction != null) appointmentAction!.labelAr,
      ...keywords,
    ].join(' ')).contains(needle);
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('ـ', '');
  }
}
