import '../domain/health_models.dart';
import 'hausarzt_agent.dart';
import 'pharmacy_agent.dart';

final class HealthMasterOrchestrator {
  const HealthMasterOrchestrator({
    required this.pharmacy,
    required this.hausarzt,
  });

  final PharmacyAgent pharmacy;
  final HausarztAgent hausarzt;

  List<HealthLearningItem> get allItems =>
      List<HealthLearningItem>.unmodifiable(
        <HealthLearningItem>[
          ...pharmacy.items,
          ...hausarzt.items,
        ],
      );

  List<EmergencyQuickAction> get emergencyActions =>
      const <EmergencyQuickAction>[
        EmergencyQuickAction(
          id: 'emergency_112',
          german: 'Es ist ein Notfall. Bitte rufen Sie 112.',
          arabic: 'هذه حالة طارئة. يرجى الاتصال بالرقم 112.',
          phoneNumber: '112',
          isEmergency: true,
        ),
        EmergencyQuickAction(
          id: 'emergency_help',
          german: 'Ich brauche sofort medizinische Hilfe.',
          arabic: 'أحتاج إلى مساعدة طبية فوراً.',
          phoneNumber: '112',
          isEmergency: true,
        ),
      ];

  List<HealthLearningItem> filterByLevel(HealthLevel level) =>
      List<HealthLearningItem>.unmodifiable(
        allItems.where((item) => item.level == level),
      );

  List<HealthLearningItem> searchSymptoms(
    String query, {
    HealthLevel? level,
  }) {
    final symptomTopics = <HealthTopic>{
      HealthTopic.symptom,
      HealthTopic.commonRemedy,
    };

    return List<HealthLearningItem>.unmodifiable(
      allItems.where(
        (item) =>
            symptomTopics.contains(item.topic) &&
            (level == null || item.level == level) &&
            item.matches(query),
      ),
    );
  }

  List<HealthLearningItem> itemsForService(
    HealthService service, {
    HealthLevel? level,
  }) =>
      List<HealthLearningItem>.unmodifiable(
        allItems.where(
          (item) =>
              item.service == service &&
              (level == null || item.level == level),
        ),
      );
}
