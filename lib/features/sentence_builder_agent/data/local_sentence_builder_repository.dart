import '../domain/sentence_builder_models.dart';
import '../domain/sentence_builder_repository.dart';

final class LocalSentenceBuilderRepository
    implements SentenceBuilderRepository {
  LocalSentenceBuilderRepository();

  static final List<_PuzzleSeed> _seeds = <_PuzzleSeed>[
    _PuzzleSeed(
      level: 'A1',
      puzzle: SentencePuzzle(
        id: 'a1_morning_coffee',
        completedSentence: 'Ich trinke morgens Kaffee.',
        arabicTranslation: 'أنا أشرب القهوة صباحًا.',
        structureType: SentenceStructureType.mainClause,
        ruleExplanation:
            'في الجملة الرئيسية يأتي الفعل المصرف في الموقع الثاني: '
            'Ich + trinke + morgens + Kaffee.',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a1_coffee_adverb',
            germanText: 'morgens',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
          WordTileItem(
            id: 'a1_coffee_subject',
            germanText: 'Ich',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a1_coffee_object',
            germanText: 'Kaffee',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a1_coffee_verb',
            germanText: 'trinke',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 1,
          ),
        ],
      ),
    ),
    _PuzzleSeed(
      level: 'A1',
      puzzle: SentencePuzzle(
        id: 'a1_make_break',
        completedSentence: 'Wir machen heute eine Pause.',
        arabicTranslation: 'نحن نأخذ استراحة اليوم.',
        structureType: SentenceStructureType.mainClause,
        ruleExplanation:
            'التعبير الشائع eine Pause machen يعني أخذ استراحة، '
            'والفعل المصرف يبقى في الموقع الثاني.',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a1_break_object',
            germanText: 'eine Pause',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a1_break_verb',
            germanText: 'machen',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 1,
          ),
          WordTileItem(
            id: 'a1_break_subject',
            germanText: 'Wir',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a1_break_adverb',
            germanText: 'heute',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
        ],
      ),
    ),
    _PuzzleSeed(
      level: 'A1',
      puzzle: SentencePuzzle(
        id: 'a1_question_coffee',
        completedSentence: 'Trinkst du morgens Kaffee?',
        arabicTranslation: 'هل تشرب القهوة صباحًا؟',
        structureType: SentenceStructureType.questionInversion,
        ruleExplanation:
            'في سؤال نعم/لا يبدأ الفعل المصرف ثم يأتي الفاعل: '
            'Trinkst + du + ...',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a1_question_object',
            germanText: 'Kaffee',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a1_question_subject',
            germanText: 'du',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 1,
          ),
          WordTileItem(
            id: 'a1_question_verb',
            germanText: 'Trinkst',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a1_question_adverb',
            germanText: 'morgens',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
        ],
      ),
    ),
    _PuzzleSeed(
      level: 'A2',
      puzzle: SentencePuzzle(
        id: 'a2_weil_sick',
        completedSentence: 'Ich bleibe zu Hause, weil ich krank bin.',
        arabicTranslation: 'أبقى في المنزل لأنني مريض.',
        structureType: SentenceStructureType.subordinateWeil,
        ruleExplanation:
            'بعد weil تبدأ جملة فرعية، ويذهب الفعل المصرف إلى النهاية: '
            'weil ich krank bin.',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a2_weil_connector',
            germanText: 'weil',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a2_weil_main_verb',
            germanText: 'bleibe',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 1,
          ),
          WordTileItem(
            id: 'a2_weil_complement',
            germanText: 'krank',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 5,
          ),
          WordTileItem(
            id: 'a2_weil_main_subject',
            germanText: 'Ich',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a2_weil_sub_subject',
            germanText: 'ich',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 4,
          ),
          WordTileItem(
            id: 'a2_weil_place',
            germanText: 'zu Hause,',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
          WordTileItem(
            id: 'a2_weil_final_verb',
            germanText: 'bin',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 6,
          ),
        ],
      ),
    ),
    _PuzzleSeed(
      level: 'A2',
      puzzle: SentencePuzzle(
        id: 'a2_learn_german',
        completedSentence: 'Wir lernen jeden Abend Deutsch.',
        arabicTranslation: 'نحن نتعلم الألمانية كل مساء.',
        structureType: SentenceStructureType.mainClause,
        ruleExplanation:
            'Deutsch lernen تركيب شائع، وفي الجملة الرئيسية يبقى '
            'الفعل المصرف في الموقع الثاني.',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a2_learn_time',
            germanText: 'jeden Abend',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
          WordTileItem(
            id: 'a2_learn_object',
            germanText: 'Deutsch',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a2_learn_subject',
            germanText: 'Wir',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a2_learn_verb',
            germanText: 'lernen',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 1,
          ),
        ],
      ),
    ),
    _PuzzleSeed(
      level: 'A2',
      puzzle: SentencePuzzle(
        id: 'a2_question_appointment',
        completedSentence: 'Hast du morgen einen Termin?',
        arabicTranslation: 'هل لديك موعد غدًا؟',
        structureType: SentenceStructureType.questionInversion,
        ruleExplanation:
            'في سؤال نعم/لا يأتي الفعل أولًا ثم الفاعل. '
            'einen Termin haben تركيب يومي شائع.',
        shuffledTiles: const <WordTileItem>[
          WordTileItem(
            id: 'a2_appointment_object',
            germanText: 'einen Termin',
            grammaticalFunction: WordGrammaticalFunction.object,
            correctPosition: 3,
          ),
          WordTileItem(
            id: 'a2_appointment_verb',
            germanText: 'Hast',
            grammaticalFunction: WordGrammaticalFunction.verb,
            correctPosition: 0,
          ),
          WordTileItem(
            id: 'a2_appointment_time',
            germanText: 'morgen',
            grammaticalFunction: WordGrammaticalFunction.adverbial,
            correctPosition: 2,
          ),
          WordTileItem(
            id: 'a2_appointment_subject',
            germanText: 'du',
            grammaticalFunction: WordGrammaticalFunction.subject,
            correctPosition: 1,
          ),
        ],
      ),
    ),
  ];

  late final Map<String, SentencePuzzle> _byId = <String, SentencePuzzle>{
    for (final seed in _seeds) seed.puzzle.id: seed.puzzle,
  };

  @override
  Future<List<SentencePuzzle>> getPuzzlesByLevel(String level) async {
    final normalized = level.trim().toUpperCase();
    final requestedBand = normalized.startsWith('A2') ? 'A2' : 'A1';
    return List<SentencePuzzle>.unmodifiable(
      _seeds
          .where((seed) => seed.level == requestedBand)
          .map((seed) => seed.puzzle),
    );
  }

  @override
  Future<bool> validateArrangement(
    String puzzleId,
    List<String> arrangedTileIds,
  ) async {
    final puzzle = _byId[puzzleId];
    if (puzzle == null) return false;
    final expected = puzzle.correctArrangement
        .map((tile) => tile.id)
        .toList(growable: false);
    if (arrangedTileIds.length != expected.length) return false;

    final seen = <String>{};
    for (var index = 0; index < expected.length; index += 1) {
      final actualId = arrangedTileIds[index];
      if (!seen.add(actualId) || actualId != expected[index]) return false;
    }
    return true;
  }
}

final class _PuzzleSeed {
  const _PuzzleSeed({
    required this.level,
    required this.puzzle,
  });

  final String level;
  final SentencePuzzle puzzle;
}
