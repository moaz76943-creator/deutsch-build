enum AnswerValidationResult { correct, incorrect, unavailable }

/// Conservative multilingual validation.
///
/// The validator keeps accents, umlauts and Arabic diacritics meaningful. It
/// only performs case folding for the currently verified Latin pilot languages
/// and composes common decomposed Latin accents to their canonical forms.
class LanguageAwareAnswerValidator {
  const LanguageAwareAnswerValidator._();

  static AnswerValidationResult validate({
    required String answer,
    required Iterable<String> acceptedAnswers,
    required String languageCode,
  }) {
    final accepted = acceptedAnswers
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
    if (accepted.isEmpty) {
      return AnswerValidationResult.unavailable;
    }

    final candidate = _normalize(answer, languageCode);
    if (candidate.isEmpty) {
      return AnswerValidationResult.incorrect;
    }
    for (final expected in accepted) {
      if (_normalize(expected, languageCode) == candidate) {
        return AnswerValidationResult.correct;
      }
    }
    return AnswerValidationResult.incorrect;
  }

  static String _normalize(String value, String languageCode) {
    var normalized = value.trim().replaceAll(
      RegExp(r'\s+', unicode: true),
      ' ',
    );
    final baseLanguage = languageCode
        .trim()
        .toLowerCase()
        .replaceAll('_', '-')
        .split('-')
        .first;

    if (const <String>{'de', 'en', 'es', 'fr'}.contains(baseLanguage)) {
      normalized = normalized.toLowerCase();
      normalized = _composePilotLatinMarks(normalized);
    }
    return normalized;
  }

  static String _composePilotLatinMarks(String value) {
    const replacements = <String, String>{
      'a\u0301': 'á',
      'e\u0301': 'é',
      'i\u0301': 'í',
      'o\u0301': 'ó',
      'u\u0301': 'ú',
      'y\u0301': 'ý',
      'a\u0300': 'à',
      'e\u0300': 'è',
      'i\u0300': 'ì',
      'o\u0300': 'ò',
      'u\u0300': 'ù',
      'a\u0302': 'â',
      'e\u0302': 'ê',
      'i\u0302': 'î',
      'o\u0302': 'ô',
      'u\u0302': 'û',
      'a\u0308': 'ä',
      'e\u0308': 'ë',
      'i\u0308': 'ï',
      'o\u0308': 'ö',
      'u\u0308': 'ü',
      'y\u0308': 'ÿ',
      'n\u0303': 'ñ',
      'c\u0327': 'ç',
    };
    var composed = value;
    for (final entry in replacements.entries) {
      composed = composed.replaceAll(entry.key, entry.value);
    }
    return composed;
  }
}
