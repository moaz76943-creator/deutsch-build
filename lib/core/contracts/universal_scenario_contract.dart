import 'linguistic_capability.dart';

class UniversalScenarioContract<T> {
  final String scenarioId;
  final LanguagePair languagePair;
  final Set<LinguisticCapability> requiredCapabilities;
  final List<String> acceptedAnswers;
  final String localExplanation;
  final T payload;
  final bool isLinguisticallyVerified; // شرط التحقق اللساني

  const UniversalScenarioContract({
    required this.scenarioId,
    required this.languagePair,
    required this.requiredCapabilities,
    required this.acceptedAnswers,
    required this.localExplanation,
    required this.payload,
    this.isLinguisticallyVerified = false,
  });

  /// مبدأ التعطيل الصريح (Fail-Closed)
  /// إذا كانت البيانات غير مكتملة أو غير موثقة لسانياً، تُعطل الميزة برمجياً فوراً
  bool get isAvailable =>
      isLinguisticallyVerified &&
      scenarioId.isNotEmpty &&
      acceptedAnswers.isNotEmpty &&
      localExplanation.isNotEmpty;

  /// تحقق صارم من مطابقة الإجابة محلياً (Zero External Calls)
  bool evaluateInput(String userInput) {
    if (!isAvailable) return false;
    final normalizedInput = userInput.trim().toLowerCase();
    return acceptedAnswers.any(
      (ans) => ans.trim().toLowerCase() == normalizedInput,
    );
  }
}
