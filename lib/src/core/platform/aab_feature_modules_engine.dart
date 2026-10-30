enum ModuleDeliveryType {
  installTime, // Bundled inside initial base APK
  onDemand,    // Downloaded or sideloaded when requested
  conditional, // Installed conditionally based on device RAM/Language
}

class FeatureModuleSpec {
  final String moduleId;
  final String displayName;
  final ModuleDeliveryType deliveryType;
  final double estimatedSizeMb;
  bool isInstalled;

  FeatureModuleSpec({
    required this.moduleId,
    required this.displayName,
    required this.deliveryType,
    required this.estimatedSizeMb,
    this.isInstalled = false,
  });

  Map<String, dynamic> toJson() => {
    'moduleId': moduleId,
    'displayName': displayName,
    'deliveryType': deliveryType.name,
    'estimatedSizeMb': estimatedSizeMb,
    'isInstalled': isInstalled,
  };
}

class AabFeatureModulesEngine {
  final Map<String, FeatureModuleSpec> _registeredModules = {};

  AabFeatureModulesEngine() {
    _initializeDefaultModules();
  }

  void _initializeDefaultModules() {
    _register(FeatureModuleSpec(
      moduleId: 'base_core',
      displayName: 'Polyglot Sovereign Core & Local DB',
      deliveryType: ModuleDeliveryType.installTime,
      estimatedSizeMb: 18.2,
      isInstalled: true,
    ));

    _register(FeatureModuleSpec(
      moduleId: 'feature_speech_asr',
      displayName: 'Sherpa-ONNX Mobile ASR & Pronunciation Models',
      deliveryType: ModuleDeliveryType.onDemand,
      estimatedSizeMb: 42.5,
      isInstalled: false,
    ));

    _register(FeatureModuleSpec(
      moduleId: 'feature_dialogue_llm',
      displayName: 'Gemma 2 2B Mobile Quantized Dialogue Weights',
      deliveryType: ModuleDeliveryType.onDemand,
      estimatedSizeMb: 125.0,
      isInstalled: false,
    ));

    _register(FeatureModuleSpec(
      moduleId: 'feature_audio_highres',
      displayName: 'High-Fidelity Piper TTS Audio Synthesizer Packs',
      deliveryType: ModuleDeliveryType.conditional,
      estimatedSizeMb: 35.0,
      isInstalled: false,
    ));
  }

  void _register(FeatureModuleSpec spec) {
    _registeredModules[spec.moduleId] = spec;
  }

  List<FeatureModuleSpec> listAllModules() => _registeredModules.values.toList();

  /// Calculates total installed disk footprint.
  double calculateInstalledFootprintMb() {
    return _registeredModules.values
        .where((m) => m.isInstalled)
        .fold(0.0, (sum, m) => sum + m.estimatedSizeMb);
  }

  /// Simulates atomic installation of an on-demand feature split slice.
  bool installOnDemandModule(String moduleId) {
    if (!_registeredModules.containsKey(moduleId)) {
      return false;
    }
    _registeredModules[moduleId]!.isInstalled = true;
    return true;
  }

  /// Uninstall or evict module to reclaim device flash storage.
  bool evictModule(String moduleId) {
    if (!_registeredModules.containsKey(moduleId)) return false;
    if (_registeredModules[moduleId]!.deliveryType == ModuleDeliveryType.installTime) {
      return false; // Base module cannot be evicted
    }
    _registeredModules[moduleId]!.isInstalled = false;
    return true;
  }
}
