import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/platform/aab_feature_modules_engine.dart';

void main() {
  group('AabFeatureModulesEngine Tests', () {
    test('Base install-time APK footprint is strictly compact under 20MB', () {
      final engine = AabFeatureModulesEngine();
      final baseFootprint = engine.calculateInstalledFootprintMb();

      expect(baseFootprint, lessThan(20.0));
      expect(baseFootprint, greaterThan(15.0));
    });

    test('Dynamically installs on-demand speech module and updates storage budget', () {
      final engine = AabFeatureModulesEngine();
      expect(engine.listAllModules().firstWhere((m) => m.moduleId == 'feature_speech_asr').isInstalled, isFalse);

      final success = engine.installOnDemandModule('feature_speech_asr');
      expect(success, isTrue);

      final updatedFootprint = engine.calculateInstalledFootprintMb();
      expect(updatedFootprint, greaterThan(50.0));
    });

    test('Prevents eviction of base core module while permitting feature eviction', () {
      final engine = AabFeatureModulesEngine();

      final baseEvictResult = engine.evictModule('base_core');
      expect(baseEvictResult, isFalse); // Protected

      engine.installOnDemandModule('feature_dialogue_llm');
      final featureEvictResult = engine.evictModule('feature_dialogue_llm');
      expect(featureEvictResult, isTrue);
    });
  });
}
