import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';
import 'package:deutsch_bilarabi/core/registry/feature_registry.dart';

void main() {
  group('FeatureRegistry & Architecture Isolation Tests', () {
    const validScenario = UniversalScenarioContract<String>(
      scenarioId: 'W05-CONSOLIDATED-01',
      languagePair: LanguagePair(sourceIso: 'ar', targetIso: 'de'),
      requiredCapabilities: {LinguisticCapability.morphologicalStacking},
      acceptedAnswers: ['Haustür'],
      localExplanation: 'دمج ناجح',
      payload: 'data',
      isLinguisticallyVerified: true,
    );

    const unverifiedScenario = UniversalScenarioContract<String>(
      scenarioId: 'W05-CONSOLIDATED-02',
      languagePair: LanguagePair(sourceIso: 'ar', targetIso: 'de'),
      requiredCapabilities: {LinguisticCapability.morphologicalStacking},
      acceptedAnswers: ['Haustür'],
      localExplanation: 'غير مكتمل',
      payload: 'data',
      isLinguisticallyVerified: false,
    );

    test('الميزة تعمل فقط إذا كانت مفعلة في السجل والسيناريو موثق لسانياً', () {
      final canRun = FeatureRegistry.isFeatureOperable(
        featureId: FeatureId.morphologyStacker,
        scenario: validScenario,
      );
      expect(canRun, isTrue);
    });

    test('تُعطل الميزة فوراً إذا كان السيناريو غير موثق حتى لو كانت الميزة مفعلة عالمياً', () {
      final canRun = FeatureRegistry.isFeatureOperable(
        featureId: FeatureId.morphologyStacker,
        scenario: unverifiedScenario,
      );
      expect(canRun, isFalse);
    });
  });
}
