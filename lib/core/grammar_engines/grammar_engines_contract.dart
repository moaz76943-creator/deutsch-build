import 'comparative_superlative_engine.dart';
import 'grammar_engine_models.dart';
import 'konjunktiv_ii_engine.dart';
import 'grammar_training_sessions.dart';

void main() {
  final konjunktiv = KonjunktivIiEngine();
  final comparison = ComparativeSuperlativeEngine();

  _expect(
    konjunktiv.conjugate('haben', GermanPerson.ich).surface,
    'hätte',
    'haben/ich must use the preferred synthetic form',
  );
  _expect(
    konjunktiv.conjugate('sein', GermanPerson.du).surface,
    'wärst',
    'sein/du must use the preferred synthetic form',
  );
  _expect(
    konjunktiv.conjugate('bestellen', GermanPerson.ich).surface,
    'würde bestellen',
    'regular lexical verbs must fall back to würde + infinitive',
  );
  _expect(
    konjunktiv.buildPreference(nounPhrase: 'einen Kaffee'),
    'Ich hätte gern einen Kaffee.',
    'haben preference must produce Ich hätte gern',
  );
  _expect(
    konjunktiv.buildWish(
      person: GermanPerson.ich,
      infinitive: 'bleiben',
      complement: 'länger',
    ),
    'Ich würde gern länger bleiben.',
    'regular wish must preserve infinitive-final würde construction',
  );
  _expect(
    konjunktiv.buildPoliteRequest(
      infinitive: 'helfen',
      complement: 'mir',
      formal: true,
      abilityStyle: true,
    ),
    'Könnten Sie mir bitte helfen?',
    'formal ability request must use könnten Sie',
  );
  _expect(
    konjunktiv.buildHypothetical(
      conditionPerson: GermanPerson.ich,
      conditionInfinitive: 'haben',
      conditionComplement: 'mehr Zeit',
      resultPerson: GermanPerson.ich,
      resultInfinitive: 'reisen',
      resultComplement: 'öfter',
    ),
    'Wenn ich mehr Zeit hätte, würde ich öfter reisen.',
    'hypothetical condition must place the condition verb finally',
  );

  final fast = comparison.formsFor('schnell');
  _expect(fast.comparative, 'schneller', 'regular comparative');
  _expect(
    fast.adverbialSuperlative,
    'am schnellsten',
    'regular adverbial superlative',
  );

  final big = comparison.formsFor('groß');
  _expect(big.comparative, 'größer', 'umlaut comparative');
  _expect(big.adverbialSuperlative, 'am größten', 'umlaut superlative');

  final expensive = comparison.formsFor('teuer');
  _expect(expensive.comparative, 'teurer', '-er stem contraction');
  _expect(
    expensive.adverbialSuperlative,
    'am teuersten',
    'superlative keeps the full teuer stem',
  );

  final dark = comparison.formsFor('dunkel');
  _expect(dark.comparative, 'dunkler', '-el comparative contraction');
  _expect(
    dark.adverbialSuperlative,
    'am dunkelsten',
    'superlative keeps the full dunkel stem',
  );

  final good = comparison.formsFor('gut');
  _expect(good.comparative, 'besser', 'irregular comparative');
  _expect(good.adverbialSuperlative, 'am besten', 'irregular superlative');

  final wide = comparison.formsFor('breit');
  _expect(wide.comparative, 'breiter', 'regular -t comparative');
  _expect(
    wide.adverbialSuperlative,
    'am breitesten',
    '-t superlative needs e before -sten',
  );

  _expect(
    comparison.connectorFor(ComparisonPattern.equality),
    'wie',
    'equality comparison connector',
  );
  _expect(
    comparison.connectorFor(ComparisonPattern.comparative),
    'als',
    'comparative connector',
  );
  _expect(
    comparison.buildComparisonSentence(
      subject: 'Der Zug',
      adjective: 'schnell',
      reference: 'der Bus',
      pattern: ComparisonPattern.comparative,
    ),
    'Der Zug ist schneller als der Bus.',
    'comparative sentence generation',
  );

  final konjA = konjunktiv.generateTrainingItem(seed: 7);
  final konjB = konjunktiv.generateTrainingItem(seed: 7);
  _expect(
    konjA.expectedAnswer,
    konjB.expectedAnswer,
    'Konjunktiv training generation must be deterministic for the same seed',
  );

  final compA = comparison.generateTrainingItem(seed: 11);
  final compB = comparison.generateTrainingItem(seed: 11);
  _expect(
    compA.expectedAnswer,
    compB.expectedAnswer,
    'comparison training generation must be deterministic for the same seed',
  );

  if (konjA.expectedAnswer.trim().isEmpty ||
      konjA.explanationAr.trim().isEmpty ||
      compA.expectedAnswer.trim().isEmpty ||
      compA.explanationAr.trim().isEmpty) {
    throw StateError('Generated training items must be complete.');
  }

  final konjSession = KonjunktivTrainingSession(seed: 7);
  final konjAttempt = konjSession.submit(
    konjSession.current.expectedAnswer,
  );
  _expect(
    konjAttempt.correct,
    true,
    'Konjunktiv interactive session must validate the current item',
  );
  final firstKonjId = konjSession.current.id;
  konjSession.next();
  if (konjSession.current.id == firstKonjId || konjSession.answered) {
    throw StateError(
      'Konjunktiv session next() must advance and clear answer state.',
    );
  }

  final comparisonSession = ComparisonTrainingSession(seed: 11);
  final comparisonAttempt = comparisonSession.submit(
    comparisonSession.current.expectedAnswer,
  );
  _expect(
    comparisonAttempt.correct,
    true,
    'comparison interactive session must validate the current item',
  );
  final firstComparisonId = comparisonSession.current.id;
  comparisonSession.next();
  if (comparisonSession.current.id == firstComparisonId ||
      comparisonSession.answered) {
    throw StateError(
      'Comparison session next() must advance and clear answer state.',
    );
  }
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
