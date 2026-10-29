class GoldenValidationResult {
  final bool isValid;
  final List<String> issues;

  const GoldenValidationResult({required this.isValid, required this.issues});
}

class GoldenContentValidator {
  static final List<String> _validGermanArticles = ['der', 'die', 'das'];

  /// خريطة أدوات التعريف المعتمدة لأشهر اللغات
  static final Map<String, List<String>> _articlesByLanguage = {
    'de': ['der', 'die', 'das'],
    'en': ['the', 'a', 'an'],
    'fr': ['le', 'la', "l'", 'les', 'un', 'une', 'des'],
    'es': ['el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas'],
    'it': ['il', 'lo', 'la', 'i', 'gli', 'le', 'un', 'uno', 'una'],
    'ar': ['ال'],
  };

  static final RegExp _germanRepeatedLetters = RegExp(r'(ieie|ieee)');
  static final RegExp _universalRepeatedLetters = RegExp(r'(.)\1{3,}');

  /// التحقق المعياري الذهبي من جودة الكلمة وترجمتها وأداتها
  static GoldenValidationResult validateEntry({
    required String targetWord,
    required String sourceTranslation,
    String? article,
    String languageCode = 'de',
  }) {
    final List<String> issues = [];

    if (targetWord.trim().isEmpty) {
      issues.add('المفردة المستهدفة فارغة.');
    }

    if (sourceTranslation.trim().isEmpty) {
      issues.add('الترجمة المقابلة فارغة.');
    }

    if (article != null && article.isNotEmpty) {
      final validList =
          _articlesByLanguage[languageCode] ?? _validGermanArticles;
      if (!validList.contains(article.toLowerCase().trim())) {
        issues.add('أداة التعريف غير صحيحة: $article');
      }
    }

    final hasRepeated = languageCode == 'de'
        ? _germanRepeatedLetters.hasMatch(targetWord)
        : _universalRepeatedLetters.hasMatch(targetWord);

    if (hasRepeated) {
      issues.add('الكلمة $targetWord تحتوي على حروف مكررة مشبوهة.');
    }

    return GoldenValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }
}
