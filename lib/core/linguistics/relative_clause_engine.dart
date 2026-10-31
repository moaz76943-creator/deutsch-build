enum AntecedentGender { masculine, feminine, neutral, plural }
enum RelativeCase { nominative, accusative, dative, genitive }

class RelativePronounResult {
  final String pronoun;
  final String fullClauseOpening;
  final String grammaticalExplanation;

  const RelativePronounResult({
    required this.pronoun,
    required this.fullClauseOpening,
    required this.grammaticalExplanation,
  });
}

/// Offline linguistic engine resolving and validating German relative pronouns and verb-final syntax.
class RelativeClauseEngine {
  // مصفوفة ضمائر الوصل الألمانية الكاملة
  static const Map<AntecedentGender, Map<RelativeCase, String>> _pronounMatrix = {
    AntecedentGender.masculine: {
      RelativeCase.nominative: 'der',
      RelativeCase.accusative: 'den',
      RelativeCase.dative: 'dem',
      RelativeCase.genitive: 'dessen',
    },
    AntecedentGender.feminine: {
      RelativeCase.nominative: 'die',
      RelativeCase.accusative: 'die',
      RelativeCase.dative: 'der',
      RelativeCase.genitive: 'deren',
    },
    AntecedentGender.neutral: {
      RelativeCase.nominative: 'das',
      RelativeCase.accusative: 'das',
      RelativeCase.dative: 'dem',
      RelativeCase.genitive: 'dessen',
    },
    AntecedentGender.plural: {
      RelativeCase.nominative: 'die',
      RelativeCase.accusative: 'die',
      RelativeCase.dative: 'denen',  // استثناء جوهري: denen وليس den
      RelativeCase.genitive: 'deren', // استثناء جوهري: deren
    },
  };

  /// استخراج ضمير الوصل الدقيق بناءً على الموصوف والحالة الإعرابية في جملة الصلة
  RelativePronounResult resolvePronoun({
    required AntecedentGender antecedentGender,
    required RelativeCase internalCase,
    String? preposition, // في حال اقترن ضمير الوصل بحرف جر
  }) {
    final basePronoun = _pronounMatrix[antecedentGender]![internalCase]!;
    final opening = preposition != null ? '$preposition $basePronoun' : basePronoun;

    return RelativePronounResult(
      pronoun: basePronoun,
      fullClauseOpening: opening,
      grammaticalExplanation: 'الموصوف (${antecedentGender.name}) مع حالة (${internalCase.name}) يُنتج ضمير الوصل "$basePronoun".',
    );
  }

  /// التحقق من موقع الفعل المصرف في جملة الصلة (يجب أن يكون في نهاية الجملة تماماً: Verbletzt)
  bool validateVerbFinalPlacement(List<String> clauseTokens, String conjugatedVerb) {
    if (clauseTokens.isEmpty) return false;
    final lastToken = clauseTokens.last.replaceAll(RegExp(r'[,.!?]'), '').trim().toLowerCase();
    return lastToken == conjugatedVerb.trim().toLowerCase();
  }
}
