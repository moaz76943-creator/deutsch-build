enum BewerbungDocumentType {
  lebenslauf,
  anschreiben,
}

enum CareerTrack {
  general,
  medicine,
  pharmacy,
  it,
  trades,
}

extension BewerbungDocumentTypeLabel on BewerbungDocumentType {
  String get labelDe => switch (this) {
        BewerbungDocumentType.lebenslauf => 'Tabellarischer Lebenslauf',
        BewerbungDocumentType.anschreiben => 'Anschreiben',
      };

  String get labelAr => switch (this) {
        BewerbungDocumentType.lebenslauf => 'السيرة الذاتية الجدولية',
        BewerbungDocumentType.anschreiben => 'رسالة التقديم',
      };
}

extension CareerTrackLabel on CareerTrack {
  String get labelDe => switch (this) {
        CareerTrack.general => 'Allgemein',
        CareerTrack.medicine => 'Medizin',
        CareerTrack.pharmacy => 'Pharmazie',
        CareerTrack.it => 'IT',
        CareerTrack.trades => 'Handwerk',
      };

  String get labelAr => switch (this) {
        CareerTrack.general => 'عام',
        CareerTrack.medicine => 'الطب',
        CareerTrack.pharmacy => 'الصيدلة',
        CareerTrack.it => 'تقنية المعلومات',
        CareerTrack.trades => 'المهن والحرف',
      };
}

final class BewerbungProfile {
  const BewerbungProfile({
    required this.fullName,
    required this.city,
    required this.email,
    required this.phone,
    required this.targetRole,
    required this.employer,
    required this.professionalSummary,
    required this.education,
    required this.experience,
    required this.skills,
    required this.languages,
  });

  final String fullName;
  final String city;
  final String email;
  final String phone;
  final String targetRole;
  final String employer;
  final String professionalSummary;
  final List<String> education;
  final List<String> experience;
  final List<String> skills;
  final List<String> languages;

  BewerbungProfile copyWith({
    String? fullName,
    String? city,
    String? email,
    String? phone,
    String? targetRole,
    String? employer,
    String? professionalSummary,
    List<String>? education,
    List<String>? experience,
    List<String>? skills,
    List<String>? languages,
  }) {
    return BewerbungProfile(
      fullName: fullName ?? this.fullName,
      city: city ?? this.city,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      targetRole: targetRole ?? this.targetRole,
      employer: employer ?? this.employer,
      professionalSummary:
          professionalSummary ?? this.professionalSummary,
      education: education ?? this.education,
      experience: experience ?? this.experience,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
    );
  }

  static const BewerbungProfile empty = BewerbungProfile(
    fullName: '',
    city: '',
    email: '',
    phone: '',
    targetRole: '',
    employer: '',
    professionalSummary: '',
    education: <String>[],
    experience: <String>[],
    skills: <String>[],
    languages: <String>[],
  );
}

final class BewerbungTemplate {
  BewerbungTemplate({
    required this.id,
    required this.documentType,
    required this.careerTrack,
    required this.titleDe,
    required this.guidanceAr,
    required List<String> suggestedSkillsDe,
  }) : suggestedSkillsDe =
            List<String>.unmodifiable(suggestedSkillsDe) {
    if (id.trim().isEmpty ||
        titleDe.trim().isEmpty ||
        guidanceAr.trim().isEmpty) {
      throw ArgumentError('template fields must not be empty');
    }
  }

  final String id;
  final BewerbungDocumentType documentType;
  final CareerTrack careerTrack;
  final String titleDe;
  final String guidanceAr;
  final List<String> suggestedSkillsDe;
}

final class BewerbungPreviewBlock {
  const BewerbungPreviewBlock({
    required this.headingDe,
    required this.bodyDe,
    required this.guidanceAr,
  });

  final String headingDe;
  final String bodyDe;
  final String guidanceAr;
}

final class BewerbungPreview {
  BewerbungPreview({
    required this.documentType,
    required this.templateId,
    required this.titleDe,
    required List<BewerbungPreviewBlock> blocks,
  }) : blocks = List<BewerbungPreviewBlock>.unmodifiable(blocks);

  final BewerbungDocumentType documentType;
  final String templateId;
  final String titleDe;
  final List<BewerbungPreviewBlock> blocks;
}
