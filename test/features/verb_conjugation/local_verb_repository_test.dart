import 'package:deutsch_bilarabi/features/verb_conjugation/data/local_verb_repository.dart';
import 'package:deutsch_bilarabi/features/verb_conjugation/domain/verb_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalVerbRepository', () {
    final repository = LocalVerbRepository();

    test('contains exactly 50 unique common verbs', () {
      final verbs = repository.commonVerbs;
      expect(verbs, hasLength(50));
      expect(
        verbs.map((verb) => verb.infinitive).toSet(),
        hasLength(50),
      );
    });

    test('every verb has all six pronouns for all three tenses', () {
      for (final verb in repository.commonVerbs) {
        for (final tense in VerbTense.values) {
          final table = verb.tableFor(tense);
          expect(
            table.forms.keys.toSet(),
            GermanPronoun.values.toSet(),
            reason: '${verb.infinitive} ${tense.label}',
          );
          for (final pronoun in GermanPronoun.values) {
            expect(
              table.formFor(pronoun).trim(),
              isNotEmpty,
              reason:
                  '${verb.infinitive} ${tense.label} ${pronoun.label}',
            );
          }
        }
      }
    });

    test('Perfekt tables carry explicit auxiliary and Partizip II', () {
      for (final verb in repository.commonVerbs) {
        final perfekt = verb.tableFor(VerbTense.perfekt);
        expect(perfekt.auxiliary, isNotNull);
        expect(perfekt.participle, isNotEmpty);
        for (final pronoun in GermanPronoun.values) {
          expect(
            perfekt.formFor(pronoun),
            endsWith(perfekt.participle!),
          );
        }
      }
    });

    test('core irregular and separable forms are preserved', () {
      final sein = repository.byInfinitive('sein')!;
      expect(
        sein.tableFor(VerbTense.praesens).formFor(GermanPronoun.ich),
        'bin',
      );
      expect(
        sein.tableFor(VerbTense.praeteritum).formFor(GermanPronoun.wir),
        'waren',
      );
      expect(
        sein.tableFor(VerbTense.perfekt).formFor(GermanPronoun.ich),
        'bin gewesen',
      );

      final fahren = repository.byInfinitive('fahren')!;
      expect(
        fahren.tableFor(VerbTense.praesens).formFor(GermanPronoun.du),
        'fährst',
      );
      expect(
        fahren.tableFor(VerbTense.praeteritum).formFor(GermanPronoun.ich),
        'fuhr',
      );
      expect(
        fahren.tableFor(VerbTense.perfekt).formFor(GermanPronoun.erSieEs),
        'ist gefahren',
      );

      final anfangen = repository.byInfinitive('anfangen')!;
      expect(anfangen.kind, VerbKind.separable);
      expect(
        anfangen.tableFor(VerbTense.praesens).formFor(GermanPronoun.du),
        'fängst an',
      );
      expect(
        anfangen.tableFor(VerbTense.praeteritum).formFor(GermanPronoun.wir),
        'fingen an',
      );
      expect(
        anfangen.tableFor(VerbTense.perfekt).formFor(GermanPronoun.ich),
        'habe angefangen',
      );
    });
    test('fahren bank entry is limited to the movement sense using sein', () {
      final fahren = repository.byInfinitive('fahren')!;
      expect(fahren.meaningAr, 'يسافر / ينتقل بمركبة');
      expect(
        fahren.tableFor(VerbTense.perfekt).auxiliary,
        PerfectAuxiliary.sein,
      );
      expect(
        fahren.tableFor(VerbTense.perfekt).formFor(GermanPronoun.ich),
        'bin gefahren',
      );
    });
  });
}
