import '../contracts/linguistic_capability.dart';
import '../contracts/universal_scenario_contract.dart';

enum FeatureId {
  morphologyStacker,    // دمج الكلمات المركبة + المغناطيسية الصرفية
  semanticMapper,       // دمج الأصدقاء الكاذبين + الاستعارات
  pragmaticMasker,      // دمج فجوة المعلومات + تحمل الغموض
}

class FeatureMetadata {
  final FeatureId id;
  final String title;
  final Set<LinguisticCapability> capabilities;
  final bool isGloballyEnabled;

  const FeatureMetadata({
    required this.id,
    required this.title,
    required this.capabilities,
    this.isGloballyEnabled = true,
  });
}

class FeatureRegistry {
  static const Map<FeatureId, FeatureMetadata> _registry = {
    FeatureId.morphologyStacker: FeatureMetadata(
      id: FeatureId.morphologyStacker,
      title: 'محرك البناء الصرفي والتركيبي الموحد',
      capabilities: {
        LinguisticCapability.morphologicalStacking,
        LinguisticCapability.syntacticBranching,
      },
      isGloballyEnabled: true,
    ),
    FeatureId.semanticMapper: FeatureMetadata(
      id: FeatureId.semanticMapper,
      title: 'محرك العلاقات الدلالية العابرة للغات',
      capabilities: {},
      isGloballyEnabled: true,
    ),
    FeatureId.pragmaticMasker: FeatureMetadata(
      id: FeatureId.pragmaticMasker,
      title: 'محرك الحجب الدلالي والتداولية',
      capabilities: {LinguisticCapability.pragmaticMitigation},
      isGloballyEnabled: true,
    ),
  };

  /// فحص توفر الميزة وسيناريوهاتها مع تطبيق Fail-Closed المزدوج
  static bool isFeatureOperable<T>({
    required FeatureId featureId,
    required UniversalScenarioContract<T> scenario,
  }) {
    final meta = _registry[featureId];
    if (meta == null || !meta.isGloballyEnabled) return false;
    return scenario.isAvailable;
  }

  static List<FeatureMetadata> get activeFeatures =>
      _registry.values.where((m) => m.isGloballyEnabled).toList();
}
