import '../language/language_text_normalizer.dart';

class WritingIssue {
  final String code;
  final String message;
  const WritingIssue(this.code, this.message);
}

/// Conservative offline German writing checks. It reports structural hints,
/// never claims full grammatical correctness.
class WritingAnalyzer {
  static List<WritingIssue> analyze(
    String input, {
    required LanguageTextNormalizer textNormalizer,
  }) {
    final text = input.trim();
    if (text.isEmpty) return const [WritingIssue('empty', 'اكتب جملة أولًا.')];
    final issues = <WritingIssue>[];
    if (!RegExp(r'[.!?]$').hasMatch(text)) {
      issues.add(
        const WritingIssue('punctuation', 'أضف علامة ترقيم في نهاية الجملة.'),
      );
    }
    if (text[0] != text[0].toUpperCase()) {
      issues.add(
        const WritingIssue('capital', 'ابدأ الجملة الألمانية بحرف كبير.'),
      );
    }
    final tokens = textNormalizer
        .answer(text)
        .split(' ')
        .where((x) => x.isNotEmpty)
        .toList();
    if (tokens.length >= 2) {
      const subjects = {'ich', 'du', 'er', 'sie', 'es', 'wir', 'ihr'};
      if (subjects.contains(tokens.first)) {
        final second = tokens[1];
        const commonVerbs = {
          'bin',
          'bist',
          'ist',
          'sind',
          'seid',
          'habe',
          'hast',
          'hat',
          'lernen',
          'lerne',
          'lernst',
          'lernt',
          'wohne',
          'wohnst',
          'wohnt',
          'gehe',
          'gehst',
          'geht',
          'komme',
          'kommst',
          'kommt',
          'mache',
          'machst',
          'macht',
          'arbeite',
          'arbeitest',
          'arbeitet',
          'spreche',
          'sprichst',
          'spricht',
          'esse',
          'isst',
          'trinke',
          'trinkst',
          'kauft',
          'kaufe',
          'fahre',
          'fährst',
          'fahrt',
          'kann',
          'kannst',
          'können',
          'möchte',
          'mochte',
        };
        if (!commonVerbs.contains(second)) {
          issues.add(
            const WritingIssue(
              'verb_position',
              'بعد الفاعل في الجملة الرئيسية راجع وجود الفعل المصرف في الموضع الثاني.',
            ),
          );
        }
      }
    }
    final repeated = <String>{};
    for (var i = 1; i < tokens.length; i++) {
      if (tokens[i] == tokens[i - 1] && tokens[i].length > 2)
        repeated.add(tokens[i]);
    }
    if (repeated.isNotEmpty) {
      issues.add(
        WritingIssue(
          'repetition',
          'تكرار كلمة متتالٍ: ${repeated.join(', ')}.',
        ),
      );
    }
    return issues;
  }
}
