import '../domain/placement_agent_models.dart';
import '../domain/placement_agent_repository.dart';

final class LocalPlacementAgentRepository
    implements PlacementAgentRepository, AdaptivePlacementQuestionSource {
  LocalPlacementAgentRepository();

  PlacementAssessmentResult? _latestResult;

  static final List<PlacementQuestionItem> _questionBank =
      <PlacementQuestionItem>[
    PlacementQuestionItem(
      id: 'a11_vocab_greeting',
      questionText: 'Welche Antwort passt? – „Guten Morgen!“',
      options: <String>['Guten Morgen!', 'Gute Nacht!', 'Bis morgen Abend!'],
      correctAnswerIndex: 0,
      difficulty: 1,
      targetSkill: 'Alltagsbegrüßungen',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a11_grammar_sein',
      questionText: 'Ich ___ Salim.',
      options: <String>['bin', 'bist', 'ist'],
      correctAnswerIndex: 0,
      difficulty: 1,
      targetSkill: 'sein im Präsens',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a11_vocab_numbers',
      questionText: 'Welche Zahl ist „siebzehn“?',
      options: <String>['16', '17', '70'],
      correctAnswerIndex: 1,
      difficulty: 1,
      targetSkill: 'Zahlen 1–100',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a12_grammar_verb_position',
      questionText: 'Welche Reihenfolge ist richtig?',
      options: <String>[
        'Heute ich lerne Deutsch.',
        'Heute lerne ich Deutsch.',
        'Heute Deutsch ich lerne.',
      ],
      correctAnswerIndex: 1,
      difficulty: 2,
      targetSkill: 'Verbposition im Hauptsatz',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a12_vocab_food',
      questionText: 'Was bedeutet „das Gemüse“?',
      options: <String>['الخضار', 'الفاكهة', 'الخبز'],
      correctAnswerIndex: 0,
      difficulty: 2,
      targetSkill: 'Lebensmittelwortschatz',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a21_grammar_accusative',
      questionText: 'Ich kaufe ___ Mantel.',
      options: <String>['ein', 'einen', 'einem'],
      correctAnswerIndex: 1,
      difficulty: 3,
      targetSkill: 'Akkusativ mit unbestimmtem Artikel',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a21_vocab_travel',
      questionText: 'Wo wartet man auf einen Zug?',
      options: <String>['am Bahnhof', 'in der Küche', 'im Schlafzimmer'],
      correctAnswerIndex: 0,
      difficulty: 3,
      targetSkill: 'Reise- und Verkehrswortschatz',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a21_grammar_dative',
      questionText: 'Ich bin ___ Balkon.',
      options: <String>['auf dem', 'auf den', 'auf der'],
      correctAnswerIndex: 0,
      difficulty: 4,
      targetSkill: 'Wechselpräpositionen mit Dativ',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a21_vocab_health',
      questionText: 'Welche Aussage passt zu „Kopfschmerzen“?',
      options: <String>[
        'Mein Kopf tut weh.',
        'Ich habe Hunger.',
        'Mein Zug kommt.',
      ],
      correctAnswerIndex: 0,
      difficulty: 4,
      targetSkill: 'Gesundheit und Beschwerden',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a22_grammar_perfect',
      questionText: 'Welche Form ist richtig?',
      options: <String>[
        'Ich habe gestern gearbeitet.',
        'Ich bin gestern gearbeitet.',
        'Ich habe gestern arbeiten.',
      ],
      correctAnswerIndex: 0,
      difficulty: 4,
      targetSkill: 'Perfekt mit haben',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a22_grammar_subordinate',
      questionText: 'Ich bleibe zu Hause, weil ich krank ___.',
      options: <String>['bin', 'bist', 'sein'],
      correctAnswerIndex: 0,
      difficulty: 5,
      targetSkill: 'Verb am Ende im Nebensatz',
      focus: PlacementQuestionFocus.grammar,
    ),
    PlacementQuestionItem(
      id: 'a22_vocab_context',
      questionText: '„Ich habe den Termin verschoben.“ Was ist passiert?',
      options: <String>[
        'Der Termin findet später statt.',
        'Der Termin ist sofort vorbei.',
        'Der Termin wurde vergessen.',
      ],
      correctAnswerIndex: 0,
      difficulty: 5,
      targetSkill: 'Kontextwortschatz Termine',
      focus: PlacementQuestionFocus.vocabulary,
    ),
    PlacementQuestionItem(
      id: 'a22_grammar_modal',
      questionText: 'Welche Aussage ist grammatisch richtig?',
      options: <String>[
        'Ich muss morgen früh aufstehen.',
        'Ich morgen muss früh aufstehen.',
        'Ich muss aufstehe morgen früh.',
      ],
      correctAnswerIndex: 0,
      difficulty: 5,
      targetSkill: 'Modalverb und Infinitiv',
      focus: PlacementQuestionFocus.grammar,
    ),
  ];

  @override
  Future<List<PlacementQuestionItem>> getCalibratedQuestions() async =>
      List<PlacementQuestionItem>.unmodifiable(_questionBank);

  @override
  Future<void> saveAssessmentResult(PlacementAssessmentResult result) async {
    _latestResult = result;
  }

  @override
  Future<PlacementAssessmentResult?> getLatestResult() async => _latestResult;

  @override
  PlacementQuestionItem? selectNextQuestion({
    required Set<String> answeredIds,
    required int targetDifficulty,
  }) {
    final available = _questionBank
        .where((question) => !answeredIds.contains(question.id))
        .toList(growable: false);
    if (available.isEmpty) return null;

    final safeTarget = targetDifficulty.clamp(1, 5).toInt();
    final ranked = List<PlacementQuestionItem>.of(available)
      ..sort((left, right) {
        final leftDistance = (left.difficulty - safeTarget).abs();
        final rightDistance = (right.difficulty - safeTarget).abs();
        final distanceOrder = leftDistance.compareTo(rightDistance);
        if (distanceOrder != 0) return distanceOrder;

        final difficultyOrder = safeTarget >= 3
            ? right.difficulty.compareTo(left.difficulty)
            : left.difficulty.compareTo(right.difficulty);
        if (difficultyOrder != 0) return difficultyOrder;
        return left.id.compareTo(right.id);
      });
    return ranked.first;
  }
}
