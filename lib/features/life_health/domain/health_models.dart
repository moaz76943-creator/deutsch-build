enum HealthLevel { a1a2, b1, b2 }

enum HealthService { pharmacy, hausarzt }

enum HealthTopic {
  prescription,
  dosage,
  activeIngredient,
  commonRemedy,
  appointment,
  symptom,
  sickLeaveNote,
}

extension HealthLevelLabels on HealthLevel {
  String get german => switch (this) {
        HealthLevel.a1a2 => 'A1/A2',
        HealthLevel.b1 => 'B1',
        HealthLevel.b2 => 'B2',
      };

  String get arabic => switch (this) {
        HealthLevel.a1a2 => 'مبتدئ',
        HealthLevel.b1 => 'متوسط',
        HealthLevel.b2 => 'متقدم',
      };
}

extension HealthServiceLabels on HealthService {
  String get german => switch (this) {
        HealthService.pharmacy => 'Apotheke',
        HealthService.hausarzt => 'Hausarzt',
      };

  String get arabic => switch (this) {
        HealthService.pharmacy => 'الصيدلية',
        HealthService.hausarzt => 'طبيب الأسرة',
      };
}

final class HealthLearningItem {
  const HealthLearningItem({
    required this.id,
    required this.level,
    required this.service,
    required this.topic,
    required this.german,
    required this.arabic,
    required this.tags,
  });

  final String id;
  final HealthLevel level;
  final HealthService service;
  final HealthTopic topic;
  final String german;
  final String arabic;
  final List<String> tags;

  bool matches(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;

    return german.toLowerCase().contains(needle) ||
        arabic.toLowerCase().contains(needle) ||
        tags.any((tag) => tag.toLowerCase().contains(needle));
  }
}

final class EmergencyQuickAction {
  const EmergencyQuickAction({
    required this.id,
    required this.german,
    required this.arabic,
    required this.phoneNumber,
    required this.isEmergency,
  });

  final String id;
  final String german;
  final String arabic;
  final String phoneNumber;
  final bool isEmergency;
}
