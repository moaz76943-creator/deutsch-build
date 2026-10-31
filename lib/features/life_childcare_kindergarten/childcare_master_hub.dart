enum ChildcareCategory {
  enrollmentAttendance,
  parentCommunication,
}

extension ChildcareCategoryLabels on ChildcareCategory {
  String get labelDe => switch (this) {
        ChildcareCategory.enrollmentAttendance => 'Anmeldung & Alltag',
        ChildcareCategory.parentCommunication => 'Elterngespräche',
      };

  String get labelAr => switch (this) {
        ChildcareCategory.enrollmentAttendance => 'التسجيل والحضور',
        ChildcareCategory.parentCommunication => 'التواصل واجتماعات الأهل',
      };
}

enum ChildcareStatus {
  planningEnrollment,
  enrolled,
  absentToday,
  parentMeeting,
}

extension ChildcareStatusLabels on ChildcareStatus {
  String get labelDe => switch (this) {
        ChildcareStatus.planningEnrollment => 'Anmeldung planen',
        ChildcareStatus.enrolled => 'Angemeldet',
        ChildcareStatus.absentToday => 'Heute abwesend',
        ChildcareStatus.parentMeeting => 'Elterngespräch',
      };

  String get labelAr => switch (this) {
        ChildcareStatus.planningEnrollment => 'تجهيز التسجيل',
        ChildcareStatus.enrolled => 'مسجّل',
        ChildcareStatus.absentToday => 'غائب اليوم',
        ChildcareStatus.parentMeeting => 'اجتماع أولياء الأمور',
      };
}

final class ChildcarePhrase {
  const ChildcarePhrase({
    required this.id,
    required this.category,
    required this.topicDe,
    required this.topicAr,
    required this.german,
    required this.arabic,
    this.tags = const <String>[],
  });

  final String id;
  final ChildcareCategory category;
  final String topicDe;
  final String topicAr;
  final String german;
  final String arabic;
  final List<String> tags;
}

final class ChildcareMasterHub {
  ChildcareMasterHub({required Iterable<ChildcarePhrase> entries})
      : _entries = List<ChildcarePhrase>.unmodifiable(entries);

  final List<ChildcarePhrase> _entries;
  final Set<ChildcareCategory> _selected = <ChildcareCategory>{
    ChildcareCategory.enrollmentAttendance,
    ChildcareCategory.parentCommunication,
  };

  String _query = '';
  ChildcareStatus _status = ChildcareStatus.planningEnrollment;

  String get query => _query;
  ChildcareStatus get status => _status;
  Set<ChildcareCategory> get selected =>
      Set<ChildcareCategory>.unmodifiable(_selected);

  List<ChildcarePhrase> get visibleEntries {
    final q = _normalize(_query);
    return List<ChildcarePhrase>.unmodifiable(
      _entries.where((entry) {
        if (!_selected.contains(entry.category)) return false;
        if (q.isEmpty) return true;
        final text = _normalize(<String>[
          entry.topicDe,
          entry.topicAr,
          entry.german,
          entry.arabic,
          ...entry.tags,
        ].join(' '));
        return text.contains(q);
      }),
    );
  }

  void setQuery(String value) => _query = value.trim();

  void toggleCategory(ChildcareCategory category) {
    if (_selected.contains(category)) {
      _selected.remove(category);
    } else {
      _selected.add(category);
    }
  }

  void setStatus(ChildcareStatus value) => _status = value;

  String get statusPromptDe => switch (_status) {
        ChildcareStatus.planningEnrollment =>
          'Welche Unterlagen und Fristen gelten für die Anmeldung meines Kindes?',
        ChildcareStatus.enrolled =>
          'Wo finde ich die aktuellen Informationen zu Bringzeit, Abholzeit und Ansprechpartnern?',
        ChildcareStatus.absentToday =>
          'Mein Kind kann heute nicht kommen. Ich möchte die Abwesenheit rechtzeitig melden.',
        ChildcareStatus.parentMeeting =>
          'Ich möchte einen Termin für ein Elterngespräch vereinbaren und wissen, welche Themen vorbereitet werden.',
      };

  String get statusPromptAr => switch (_status) {
        ChildcareStatus.planningEnrollment =>
          'ما الوثائق والمواعيد المطلوبة لتسجيل طفلي؟',
        ChildcareStatus.enrolled =>
          'أين أجد المعلومات الحالية عن وقت الحضور والاستلام والأشخاص المسؤولين؟',
        ChildcareStatus.absentToday =>
          'طفلي لن يتمكن من الحضور اليوم، وأريد إبلاغكم بالغياب في الوقت المناسب.',
        ChildcareStatus.parentMeeting =>
          'أريد تحديد موعد لاجتماع مع الأهل ومعرفة المواضيع التي يُفضّل التحضير لها.',
      };

  static String _normalize(String value) {
    var out = value.toLowerCase()
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss');
    out = out.replaceAll(RegExp(r'[^a-z0-9ء-ي ]'), ' ');
    return out.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
