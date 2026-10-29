import 'universal_scenario_contract.dart';

enum ContractStatus {
  active,
  disabledMissingData,
  unverifiedLinguistics,
}

class ContractEvaluationResult {
  final bool isSuccess;
  final ContractStatus status;
  final String feedback;

  const ContractEvaluationResult({
    required this.isSuccess,
    required this.status,
    required this.feedback,
  });

  factory ContractEvaluationResult.disabled(String reason) {
    return ContractEvaluationResult(
      isSuccess: false,
      status: ContractStatus.disabledMissingData,
      feedback: reason,
    );
  }
}

class ContractEvaluator {
  static ContractEvaluationResult process<T>({
    required UniversalScenarioContract<T> contract,
    required String userInput,
  }) {
    // 1. فحص مبدأ Fail-Closed
    if (!contract.isLinguisticallyVerified) {
      return const ContractEvaluationResult(
        isSuccess: false,
        status: ContractStatus.unverifiedLinguistics,
        feedback: 'الميزة معطلة صراحةً: بانتظار مراجعة وتوثيق لغوي معتمد.',
      );
    }

    if (!contract.isAvailable) {
      return ContractEvaluationResult.disabled(
        'تعذر تشغيل الميزة: نقص في معايير العقد الهندسي (إجابات أو شرح مفقود).',
      );
    }

    // 2. التحقق الدلالي المحلي
    final isMatch = contract.evaluateInput(userInput);
    return ContractEvaluationResult(
      isSuccess: isMatch,
      status: ContractStatus.active,
      feedback: isMatch ? contract.localExplanation : 'إجابة غير مطابقة للمعيار.',
    );
  }
}
