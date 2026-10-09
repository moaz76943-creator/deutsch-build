import '../contracts/linguistic_capability.dart';
import '../contracts/universal_scenario_contract.dart';

enum FeatureId {
  morphologyStacker,
  semanticMapper,
  pragmaticMasker,
  evidentialityCalibrator,
  collocationField,
  rhythmRegulator,
  honorificDistanceGauge,
  discourseAnaphoraMesh,
  implicatureProbe,
  hesitationBuffer,
  phonotacticSieve,
  scalarPolarityGauge,
  prosodicFocusTracker,
  taxonomicGranularitySieve,
  counterfactualCompass,
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
    FeatureId.rhythmRegulator: FeatureMetadata(
      id: FeatureId.rhythmRegulator,
      title: 'ناظم التزامن الإيقاعي والمقطعي',
      capabilities: {LinguisticCapability.phonologicalStress},
      isGloballyEnabled: true,
    ),
    FeatureId.honorificDistanceGauge: FeatureMetadata(
      id: FeatureId.honorificDistanceGauge,
      title: 'مقياس المسافة الاجتماعية وصيغ الخطاب',
      capabilities: {LinguisticCapability.honorificDistance},
      isGloballyEnabled: true,
    ),
    FeatureId.discourseAnaphoraMesh: FeatureMetadata(
      id: FeatureId.discourseAnaphoraMesh,
      title: 'شبكة الترابط الإحالي النصي',
      capabilities: {LinguisticCapability.anaphoraCohesion},
      isGloballyEnabled: true,
    ),
    FeatureId.implicatureProbe: FeatureMetadata(
      id: FeatureId.implicatureProbe,
      title: 'مستشعر الاستلزام الحواري والتضمين',
      capabilities: {LinguisticCapability.conversationalImplicature},
      isGloballyEnabled: true,
    ),
    FeatureId.hesitationBuffer: FeatureMetadata(
      id: FeatureId.hesitationBuffer,
      title: 'مخزن حشوات التردد وتدارك الكلام',
      capabilities: {LinguisticCapability.hesitationRepair},
      isGloballyEnabled: true,
    ),
    FeatureId.phonotacticSieve: FeatureMetadata(
      id: FeatureId.phonotacticSieve,
      title: 'منخل التناغم الصوتي والقيود الفونوتكتيكية',
      capabilities: {LinguisticCapability.phonotacticHarmony},
      isGloballyEnabled: true,
    ),
    FeatureId.scalarPolarityGauge: FeatureMetadata(
      id: FeatureId.scalarPolarityGauge,
      title: 'مقياس السلالم الدلالية والاستلزام التدرجي',
      capabilities: {LinguisticCapability.scalarImplicature},
      isGloballyEnabled: true,
    ),
    FeatureId.prosodicFocusTracker: FeatureMetadata(
      id: FeatureId.prosodicFocusTracker,
      title: 'محاكي النبر البؤري والتنغيم النغمي',
      capabilities: {LinguisticCapability.prosodicFocus},
      isGloballyEnabled: true,
    ),
    FeatureId.taxonomicGranularitySieve: FeatureMetadata(
      id: FeatureId.taxonomicGranularitySieve,
      title: 'منخل التخصيص المعجمي ومستويات التجريد',
      capabilities: {LinguisticCapability.taxonomicGranularity},
      isGloballyEnabled: true,
    ),
    FeatureId.counterfactualCompass: FeatureMetadata(
      id: FeatureId.counterfactualCompass,
      title: 'بوصلة الشك والافتراض المضاد للواقع',
      capabilities: {LinguisticCapability.counterfactualMood},
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
