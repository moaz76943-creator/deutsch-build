import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';

class SemanticColorTagging {
  final LanguageGrammarRuleProvider ruleProvider;

  const SemanticColorTagging({required this.ruleProvider});

  /// إرجاع اللون الدلالي بناءً على الجنس النحوي المستقل عن اللغة
  Color getColorForWord(String word, {String? article}) {
    final gender = ruleProvider.determineGender(word, article: article);

    switch (gender) {
      case GrammaticalGender.masculine:
        return Colors.blue.shade600; // أزرق قياسي للمذكر
      case GrammaticalGender.feminine:
        return Colors.red.shade600;  // أحمر قياسي للمؤنث
      case GrammaticalGender.neuter:
        return Colors.green.shade600;// أخضر قياسي للمحايد
      case GrammaticalGender.common:
      case GrammaticalGender.none:
        return Colors.grey.shade700;
    }
  }
}
