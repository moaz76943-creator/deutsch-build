enum WorkplaceTopic {
  meetingMinutes,
  scheduling,
  delegation,
  politeRequests,
  formalTelephone,
}

extension WorkplaceTopicLabels on WorkplaceTopic {
  String get germanLabel => switch (this) {
        WorkplaceTopic.meetingMinutes => 'Protokoll',
        WorkplaceTopic.scheduling => 'Terminabstimmung',
        WorkplaceTopic.delegation => 'Aufgaben delegieren',
        WorkplaceTopic.politeRequests => 'Höflich bitten',
        WorkplaceTopic.formalTelephone => 'Telefon im Büro',
      };

  String get arabicLabel => switch (this) {
        WorkplaceTopic.meetingMinutes => 'كتابة محضر الاجتماع',
        WorkplaceTopic.scheduling => 'تنسيق المواعيد',
        WorkplaceTopic.delegation => 'تفويض المهام',
        WorkplaceTopic.politeRequests => 'الطلب بأدب من الزملاء',
        WorkplaceTopic.formalTelephone => 'الهاتف الرسمي في المكتب',
      };
}

enum WorkplaceRegister {
  formalSie,
  collegialSie,
  writtenFormal,
}

extension WorkplaceRegisterLabels on WorkplaceRegister {
  String get germanLabel => switch (this) {
        WorkplaceRegister.formalSie => 'formell · Sie',
        WorkplaceRegister.collegialSie => 'kollegial · Sie',
        WorkplaceRegister.writtenFormal => 'schriftlich · formell',
      };

  String get arabicLabel => switch (this) {
        WorkplaceRegister.formalSie => 'رسمي بصيغة Sie',
        WorkplaceRegister.collegialSie => 'مهني وودي بصيغة Sie',
        WorkplaceRegister.writtenFormal => 'كتابي رسمي',
      };
}

final class WorkplacePhrase {
  const WorkplacePhrase({
    required this.id,
    required this.topic,
    required this.register,
    required this.german,
    required this.arabic,
    required this.usageArabic,
  });

  final String id;
  final WorkplaceTopic topic;
  final WorkplaceRegister register;
  final String german;
  final String arabic;
  final String usageArabic;
}

final class ProtocolTask {
  const ProtocolTask({
    required this.task,
    required this.responsible,
    required this.deadline,
  });

  final String task;
  final String responsible;
  final String deadline;
}

final class ProtocolDraft {
  const ProtocolDraft({
    required this.date,
    required this.participants,
    required this.discussionPoints,
    required this.decisions,
    required this.tasks,
  });

  final String date;
  final List<String> participants;
  final List<String> discussionPoints;
  final List<String> decisions;
  final List<ProtocolTask> tasks;

  String renderGerman() {
    if (date.trim().isEmpty) {
      throw ArgumentError.value(date, 'date', 'must not be empty');
    }
    if (participants.isEmpty) {
      throw ArgumentError.value(
        participants,
        'participants',
        'must contain at least one participant',
      );
    }

    final buffer = StringBuffer()
      ..writeln('Protokoll')
      ..writeln('Datum: ${date.trim()}')
      ..writeln('Teilnehmende: ${participants.map(_clean).join(', ')}')
      ..writeln()
      ..writeln('Besprochene Punkte:');

    _writeBulletSection(buffer, discussionPoints);
    buffer
      ..writeln()
      ..writeln('Beschlüsse:');
    _writeBulletSection(buffer, decisions);
    buffer
      ..writeln()
      ..writeln('Aufgaben:');

    if (tasks.isEmpty) {
      buffer.writeln('- Keine offenen Aufgaben.');
    } else {
      for (final task in tasks) {
        buffer.writeln(
          '- ${_clean(task.task)} | Zuständig: ${_clean(task.responsible)} '
          '| Frist: ${_clean(task.deadline)}',
        );
      }
    }

    return buffer.toString().trimRight();
  }

  static void _writeBulletSection(StringBuffer buffer, List<String> values) {
    if (values.isEmpty) {
      buffer.writeln('- Keine Einträge.');
      return;
    }
    for (final value in values) {
      buffer.writeln('- ${_clean(value)}');
    }
  }

  static String _clean(String value) => value.trim().replaceAll(
        RegExp(r'\s+'),
        ' ',
      );
}

abstract interface class BerufsspracheRepository {
  Future<List<WorkplacePhrase>> getPhrases({WorkplaceTopic? topic});

  Future<WorkplacePhrase?> getPhraseById(String id);

  Future<bool> validateGermanPhrase(String id, String candidate);
}
