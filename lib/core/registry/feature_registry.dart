import '../contracts/linguistic_capability.dart';
import '../contracts/universal_scenario_contract.dart';

enum FeatureId {
  morphologyStacker,
  semanticMapper,
  pragmaticMasker,
  evidentialityCalibrator,
  collocationField,
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
      capabilities: {
        LinguisticCapability.pragmaticMitigation,
        LinguisticCapability.zeroEquivalence,
      },
      isGloballyEnabled: true,
    ),
    FeatureId.evidentialityCalibrator: FeatureMetadata(
      id: FeatureId.evidentialityCalibrator,
      title: 'محاكي الشاهدية واليقين المعرفي',
      capabilities: {LinguisticCapability.evidentiality},
      isGloballyEnabled: true,
    ),
    FeatureId.collocationField: FeatureMetadata(
      id: FeatureId.collocationField,
      title: 'محرك الجذب والتلازم اللفظي',
      capabilities: {LinguisticCapability.collocationalTension},
      isGloballyEnabled: true,
    ),
  };

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
