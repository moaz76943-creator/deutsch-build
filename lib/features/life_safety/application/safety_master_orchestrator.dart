import '../domain/safety_models.dart';
import 'official_reporting_sub_agent.dart';
import 'roadside_assistance_sub_agent.dart';

final class SafetyMasterOrchestrator {
  const SafetyMasterOrchestrator({
    required this.roadsideAssistance,
    required this.officialReporting,
  });

  final RoadsideAssistanceSubAgent roadsideAssistance;
  final OfficialReportingSubAgent officialReporting;

  List<SafetyLearningItem> get allItems => List<SafetyLearningItem>.unmodifiable(
        <SafetyLearningItem>[
          ...roadsideAssistance.items,
          ...officialReporting.items,
        ],
      );

  List<SafetyPanicAction> get panicActions => const <SafetyPanicAction>[
        SafetyPanicAction(
          id: 'panic_112',
          phoneNumber: '112',
          authorityGerman: 'Rettungsdienst / Feuerwehr',
          authorityArabic: 'الإسعاف / الإطفاء',
          germanScript:
              'Es gab einen Verkehrsunfall. Eine Person ist verletzt. Wir sind auf der A3 Richtung Köln bei Kilometer 245.',
          arabicGuide:
              'لحالة طبية أو حريق أو إنقاذ عاجل: اذكر ما حدث، عدد المصابين، والطريق والاتجاه وعلامة الكيلومتر.',
        ),
        SafetyPanicAction(
          id: 'panic_110',
          phoneNumber: '110',
          authorityGerman: 'Polizei',
          authorityArabic: 'الشرطة',
          germanScript:
              'Ich brauche die Polizei. Es besteht eine unmittelbare Gefahr. Wir sind auf der A3 Richtung Köln bei Kilometer 245.',
          arabicGuide:
              'عند خطر فوري يحتاج الشرطة: اذكر نوع الخطر، موقعك، الطريق والاتجاه وعلامة الكيلومتر.',
        ),
      ];

  List<SafetyLearningItem> itemsForCategory(SafetyCategory category) =>
      List<SafetyLearningItem>.unmodifiable(
        allItems.where((item) => item.category == category),
      );

  List<SafetyLearningItem> search(
    String query, {
    SafetyCategory? category,
  }) =>
      List<SafetyLearningItem>.unmodifiable(
        allItems.where(
          (item) =>
              (category == null || item.category == category) &&
              item.matches(query),
        ),
      );
}
