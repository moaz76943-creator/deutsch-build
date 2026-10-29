enum CareerStage {
  application,
  interview,
  followUp;

  String get labelDe => switch (this) {
        CareerStage.application => 'Bewerbung',
        CareerStage.interview => 'Vorstellungsgespräch',
        CareerStage.followUp => 'Nachfassen',
      };

  String get labelAr => switch (this) {
        CareerStage.application => 'التقديم',
        CareerStage.interview => 'المقابلة',
        CareerStage.followUp => 'المتابعة',
      };
}

enum CareerTopic {
  cv,
  coverLetter,
  openPosition,
  selfIntroduction,
  experience,
  qualifications,
  workingHours,
  teamStructure,
  followUp;
}

final class CareerPhrase {
  const CareerPhrase({
    required this.id,
    required this.stage,
    required this.topic,
    required this.german,
    required this.arabic,
    this.noteAr,
    this.urgent = false,
  });

  final String id;
  final CareerStage stage;
  final CareerTopic topic;
  final String german;
  final String arabic;
  final String? noteAr;
  final bool urgent;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return german.toLowerCase().contains(normalized) ||
        arabic.toLowerCase().contains(normalized) ||
        (noteAr?.toLowerCase().contains(normalized) ?? false) ||
        stage.labelDe.toLowerCase().contains(normalized) ||
        stage.labelAr.contains(normalized);
  }
}
