import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/core/language_intelligence/language_grammar_rule_provider.dart';
import 'package:deutsch_bilarabi/languages/german/german_grammar_provider.dart';
import 'package:deutsch_bilarabi/features/semantic_color_tagging/semantic_presentation_engine.dart';
import 'package:deutsch_bilarabi/design_system/app_colors.dart';

void main() {
  group('Language Intelligence Decoupling Tests', () {
    final germanProvider = GermanGrammarProvider.instance;
    final engine = SemanticPresentationEngine(
      ruleProvider: germanProvider,
      packVersion: 'test_1.0',
    );

    test('GermanGrammarProvider يستنتج الجنس النحوي للأدوات واللواحق بشكل معزول', () {
      expect(germanProvider.determineGender('Tisch', article: 'der'), GrammaticalGender.masculine);
      expect(germanProvider.determineGender('Zeitung'), GrammaticalGender.feminine); // لاحقة ung
      expect(germanProvider.determineGender('Mädchen'), GrammaticalGender.neuter);   // لاحقة chen
    });

    test('SemanticPresentationEngine يلون الكلمات بناءً على استنتاج المزود دون تضمين نصوص صلبة', () {
      final masculinePresentation = engine.getPresentationForWord('Hund', article: 'der');
      expect(masculinePresentation.color, AppColors.articleDer);

      final femininePresentation = engine.getPresentationForWord('Freiheit');
      expect(femininePresentation.color, AppColors.articleDie);
    });
  });
}
