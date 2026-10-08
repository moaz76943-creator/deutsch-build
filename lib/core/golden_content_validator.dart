class GoldenValidationResult {
  final bool isValid;
  final List<String> issues;

  const GoldenValidationResult({required this.isValid, required this.issues});
}

class GoldenContentValidator {
  static final List<String> _validGermanArticles = ['der', 'die', 'das'];
  static final RegExp _repeatedLettersRegex = RegExp(r'(ieie|iee|eee)');

  static GoldenValidationResult validateEntry({
    required String targetWord,
    required String sourceTranslation,
    String? article,
  }) {
    final List<String> issues = [];

    if (targetWord.trim().isEmpty) {
      issues.add('المفردة المستهدفة فارغة.');
    }

    if (sourceTranslation.trim().isEmpty) {
      issues.add('الترجمة المقابلة فارغة.');
    }

    if (article != null && article.isNotEmpty) {
      if (!_validGermanArticles.contains(article.toLowerCase().trim())) {
        issues.add('أداة التعريف غير صحيحة: $article');
      }
    }

    if (_repeatedLettersRegex.hasMatch(targetWord)) {
      issues.add('يوجد نمط حروف مكرر مشبوه في الكلمة: $targetWord');
    }

    return GoldenValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }
}
