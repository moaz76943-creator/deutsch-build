import 'package:deutsch_bilarabi/core/localization/german_article_style.dart';
import 'package:deutsch_bilarabi/features/prepositions_arena/domain/preposition_case_rules.dart';
import 'package:deutsch_bilarabi/features/prepositions_arena/domain/preposition_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const rules = PrepositionCaseRules();

  const inItem = PrepositionItem(
    id: 'in',
    preposition: 'in',
    type: PrepositionType.twoWay,
    meaningAr: 'في / إلى داخل',
    level: 'A1',
  );

  test('two-way preposition uses Akkusativ for Wohin movement', () {
    final grammaticalCase = rules.caseFor(
      preposition: inItem,
      spatialQuestion: SpatialQuestion.wohin,
    );
    final form = rules.articleForm(
      baseArticle: GermanArticle.der,
      grammaticalCase: grammaticalCase,
    );

    expect(grammaticalCase, GermanGrammaticalCase.accusative);
    expect(form.surfaceArticle, 'den');
    expect(form.baseArticle, GermanArticle.der);
  });

  test('two-way preposition uses Dativ for Wo location', () {
    final grammaticalCase = rules.caseFor(
      preposition: inItem,
      spatialQuestion: SpatialQuestion.wo,
    );
    final form = rules.articleForm(
      baseArticle: GermanArticle.der,
      grammaticalCase: grammaticalCase,
    );

    expect(grammaticalCase, GermanGrammaticalCase.dative);
    expect(form.surfaceArticle, 'dem');
    expect(form.baseArticle, GermanArticle.der);
  });

  test('fixed Dativ ignores movement/location cue', () {
    const mit = PrepositionItem(
      id: 'mit',
      preposition: 'mit',
      type: PrepositionType.dative,
      meaningAr: 'مع / بواسطة',
      level: 'A1',
    );

    expect(
      rules.caseFor(
        preposition: mit,
        spatialQuestion: SpatialQuestion.wohin,
      ),
      GermanGrammaticalCase.dative,
    );
  });

  test('feminine Dativ becomes der while preserving feminine identity', () {
    final form = rules.articleForm(
      baseArticle: GermanArticle.die,
      grammaticalCase: GermanGrammaticalCase.dative,
    );

    expect(form.surfaceArticle, 'der');
    expect(form.baseArticle, GermanArticle.die);
  });

  test('neuter Dativ becomes dem while preserving neuter identity', () {
    final form = rules.articleForm(
      baseArticle: GermanArticle.das,
      grammaticalCase: GermanGrammaticalCase.dative,
    );

    expect(form.surfaceArticle, 'dem');
    expect(form.baseArticle, GermanArticle.das);
  });
}
