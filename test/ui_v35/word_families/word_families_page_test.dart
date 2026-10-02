import 'package:deutsch_bilarabi/language/german/german_word_family_repository.dart';
import 'package:deutsch_bilarabi/models/content.dart';
import 'package:deutsch_bilarabi/models/linguistics/german_word_family.dart';
import 'package:deutsch_bilarabi/models/linguistics/linguistic_concept.dart';
import 'package:deutsch_bilarabi/ui_v35/word_families/word_families_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _FamilyRepository implements GermanWordFamilyRepository {
  const _FamilyRepository(this.families);

  final List<GermanWordFamily> families;

  @override
  Future<List<GermanWordFamily>> listFamilies({int limit = 100}) async =>
      families;
}

void main() {
  testWidgets('grid renders German and Arabic without mixed string heuristics',
      (tester) async {
    const base = LinguisticConcept(
      id: 'verb.fahren',
      senseId: 'fahren.travel',
      lemma: 'fahren',
      partOfSpeech: LinguisticPartOfSpeech.verb,
      register: LanguageRegister.neutral,
      cefr: CefrLevel.a1,
    );
    const driver = LinguisticConcept(
      id: 'noun.fahrer',
      senseId: 'fahrer.person',
      lemma: 'Fahrer',
      partOfSpeech: LinguisticPartOfSpeech.noun,
      register: LanguageRegister.neutral,
      cefr: CefrLevel.a1,
    );
    const family = GermanWordFamily(
      familyId: 'fahren',
      baseConceptId: 'verb.fahren',
      members: <GermanWordFamilyMember>[
        GermanWordFamilyMember(
          concept: base,
          relationType: GermanWordFamilyRelationType.base,
          semanticDistance: GermanSemanticDistance.low,
          pedagogicalLevel: CefrLevel.a1,
          interferenceRisk: false,
        ),
        GermanWordFamilyMember(
          concept: driver,
          relationType: GermanWordFamilyRelationType.agentNoun,
          suffix: 'er',
          semanticDistance: GermanSemanticDistance.low,
          pedagogicalLevel: CefrLevel.a1,
          interferenceRisk: false,
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: WordFamiliesPage(
          repository: _FamilyRepository(<GermanWordFamily>[family]),
          corpus: <ContentItem>[
            ContentItem(
              id: 'verb.fahren',
              german: 'fahren',
              arabic: 'يقود / يذهب',
              sentence: '',
              sentenceAr: '',
              topic: 'transport',
              skill: 'recall',
            ),
            ContentItem(
              id: 'noun.fahrer',
              german: 'Fahrer',
              arabic: 'سائق',
              sentence: '',
              sentenceAr: '',
              topic: 'transport',
              skill: 'recall',
              article: 'der',
            ),
          ],
          learnedIds: <String>{'verb.fahren'},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('fahren'), findsOneWidget);
    expect(find.text('der Fahrer'), findsOneWidget);
    expect(find.text('سائق'), findsOneWidget);
    expect(find.text('اسم الفاعل'), findsOneWidget);
  });

  testWidgets('empty repository refuses to invent morphological families',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WordFamiliesPage(
          repository: _FamilyRepository(<GermanWordFamily>[]),
          corpus: <ContentItem>[],
          learnedIds: <String>{},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('لن يخمّن التطبيق'), findsOneWidget);
  });
}
