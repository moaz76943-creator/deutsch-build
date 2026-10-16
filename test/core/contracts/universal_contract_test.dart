import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/contracts/linguistic_capability.dart';
import 'package:deutsch_bilarabi/core/contracts/universal_scenario_contract.dart';
import 'package:deutsch_bilarabi/core/contracts/contract_evaluator.dart';

void main() {
  group('Universal Data Contract & Fail-Closed Tests', () {
    const pair = LanguagePair(sourceIso: 'ar', targetIso: 'de');

    test('يتم تعطيل الميزة صراحة إذا لم تكن موثقة لسانياً (Fail-Closed)', () {
      const unverifiedContract = UniversalScenarioContract<String>(
        scenarioId: 'W05-01-PILOT',
        languagePair: pair,
        requiredCapabilities: {LinguisticCapability.morphologicalStacking},
        acceptedAnswers: ['Krankenhaus'],
        localExplanation: 'اسم مركب',
        payload: 'test_payload',
        isLinguisticallyVerified: false, // غير موثقة
      );

      final result = ContractEvaluator.process(
        contract: unverifiedContract,
        userInput: 'Krankenhaus',
      );

      expect(unverifiedContract.isAvailable, isFalse);
      expect(result.status, ContractStatus.unverifiedLinguistics);
      expect(result.isSuccess, isFalse);
    });

    test('تعمل الميزة بنجاح وتقيم محلياً عند اكتمال العقد والتوثيق', () {
      const verifiedContract = UniversalScenarioContract<String>(
        scenarioId: 'W05-01-PILOT',
        languagePair: pair,
        requiredCapabilities: {LinguisticCapability.morphologicalStacking},
        acceptedAnswers: ['Krankenhaus'],
        localExplanation: 'تحليل دقيق للكلمة المركبة.',
        payload: 'test_payload',
        isLinguisticallyVerified: true, // موثقة
      );

      final result = ContractEvaluator.process(
        contract: verifiedContract,
        userInput: 'Krankenhaus',
      );

      expect(verifiedContract.isAvailable, isTrue);
      expect(result.status, ContractStatus.active);
      expect(result.isSuccess, isTrue);
    });
  });
}
