enum EmailRegister {
  formalOfficial,
  semiFormalWork,
  informalFriendly,
}

enum LetterSection {
  salutation,
  openingHook,
  mainBodyReason,
  requestOrComplaint,
  closingSignoff,
}

final class EmailScenario {
  const EmailScenario({
    required this.id,
    required this.titleDe,
    required this.titleAr,
    required this.level,
    required this.promptDe,
    required this.targetRegister,
  });

  final String id;
  final String titleDe;
  final String titleAr;
  final String level;
  final String promptDe;
  final EmailRegister targetRegister;
}

final class EmailTemplateBlock {
  const EmailTemplateBlock({
    required this.id,
    required this.scenarioId,
    required this.section,
    required this.text,
    required this.register,
    required this.toneAr,
    required this.translationAr,
    required this.punctuationNoteAr,
    required this.applications,
  });

  final String id;
  final String scenarioId;
  final LetterSection section;
  final String text;
  final EmailRegister register;
  final String toneAr;
  final String translationAr;
  final String punctuationNoteAr;
  final List<String> applications;

  String get registerLabelAr => switch (register) {
        EmailRegister.formalOfficial => 'رسمي',
        EmailRegister.semiFormalWork => 'مهني شبه رسمي',
        EmailRegister.informalFriendly => 'ودي غير رسمي',
      };

  String get sectionLabelAr => switch (section) {
        LetterSection.salutation => 'التحية',
        LetterSection.openingHook => 'البداية',
        LetterSection.mainBodyReason => 'سبب الرسالة',
        LetterSection.requestOrComplaint => 'الطلب أو الشكوى',
        LetterSection.closingSignoff => 'الخاتمة',
      };
}
