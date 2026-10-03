enum DrivingCategory {
  fahrschule,
  vehicleAdmin,
}

enum DrivingTopic {
  enrollment,
  theoryClass,
  practicalLesson,
  firstAid,
  registration,
  inspection,
  emissionsSticker,
}

extension DrivingCategoryLabels on DrivingCategory {
  String get germanLabel => switch (this) {
        DrivingCategory.fahrschule => 'Fahrschule',
        DrivingCategory.vehicleAdmin => 'Zulassung & TÜV',
      };

  String get arabicLabel => switch (this) {
        DrivingCategory.fahrschule => 'مدرسة القيادة',
        DrivingCategory.vehicleAdmin => 'تسجيل المركبة والفحص',
      };
}

extension DrivingTopicLabels on DrivingTopic {
  String get germanLabel => switch (this) {
        DrivingTopic.enrollment => 'Anmeldung',
        DrivingTopic.theoryClass => 'Theorieunterricht',
        DrivingTopic.practicalLesson => 'Fahrstunde',
        DrivingTopic.firstAid => 'Erste-Hilfe-Kurs',
        DrivingTopic.registration => 'Kfz-Zulassung',
        DrivingTopic.inspection => 'Hauptuntersuchung',
        DrivingTopic.emissionsSticker => 'Umweltplakette',
      };

  String get arabicLabel => switch (this) {
        DrivingTopic.enrollment => 'التسجيل',
        DrivingTopic.theoryClass => 'دروس النظري',
        DrivingTopic.practicalLesson => 'درس القيادة العملي',
        DrivingTopic.firstAid => 'دورة الإسعافات الأولية',
        DrivingTopic.registration => 'تسجيل المركبة',
        DrivingTopic.inspection => 'الفحص الدوري',
        DrivingTopic.emissionsSticker => 'الملصق البيئي',
      };
}

final class DrivingLearningItem {
  const DrivingLearningItem({
    required this.id,
    required this.category,
    required this.topic,
    required this.titleDe,
    required this.german,
    required this.arabic,
    required this.tags,
  });

  final String id;
  final DrivingCategory category;
  final DrivingTopic topic;
  final String titleDe;
  final String german;
  final String arabic;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return titleDe.toLowerCase().contains(needle) ||
        german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        topic.germanLabel.toLowerCase().contains(needle) ||
        topic.arabicLabel.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}

final class DrivingExamPrepItem {
  const DrivingExamPrepItem({
    required this.id,
    required this.focusDe,
    required this.german,
    required this.arabic,
  });

  final String id;
  final String focusDe;
  final String german;
  final String arabic;
}
