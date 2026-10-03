import 'dialogue_models.dart';

abstract interface class DialogueAudioPort {
  Future<bool> speak(DialogueTurn turn);
}

final class SilentDialogueAudioPort implements DialogueAudioPort {
  const SilentDialogueAudioPort();

  @override
  Future<bool> speak(DialogueTurn turn) async => false;
}

final class DialogueSessionResult {
  const DialogueSessionResult({
    required this.scenarioId,
    required this.points,
    required this.maxPoints,
    required this.scorePercent,
    required this.answeredChoices,
    required this.transcript,
  });

  final String scenarioId;
  final int points;
  final int maxPoints;
  final int scorePercent;
  final int answeredChoices;
  final List<DialogueTurn> transcript;
}

final class DialogueStepResult {
  const DialogueStepResult({
    required this.selectedTurn,
    required this.currentNode,
    required this.completed,
    required this.scorePercent,
  });

  final DialogueTurn selectedTurn;
  final DialogueNode currentNode;
  final bool completed;
  final int scorePercent;
}

final class DialogueProgress {
  const DialogueProgress({
    required this.scenarioId,
    required this.completedRuns,
    required this.bestScorePercent,
    required this.lastScorePercent,
    required this.lastCompletedAt,
  });

  const DialogueProgress.empty(String scenarioId)
      : this(
          scenarioId: scenarioId,
          completedRuns: 0,
          bestScorePercent: 0,
          lastScorePercent: 0,
          lastCompletedAt: null,
        );

  final String scenarioId;
  final int completedRuns;
  final int bestScorePercent;
  final int lastScorePercent;
  final DateTime? lastCompletedAt;

  bool get isCompleted => completedRuns > 0;
}

abstract interface class DialogueRepository {
  List<DialogueScenario> get scenarios;

  DialogueScenario? scenarioById(String scenarioId);

  DialogueProgress progressFor(String scenarioId);

  void recordCompletion(
    DialogueSessionResult result, {
    DateTime? completedAt,
  });
}

final class DialogueEngine {
  DialogueEngine(this.scenario)
      : _currentNodeId = scenario.startNodeId,
        _completed = scenario.startNode.isTerminal,
        _transcript = <DialogueTurn>[scenario.startNode.turn];

  final DialogueScenario scenario;
  final List<DialogueTurn> _transcript;
  String _currentNodeId;
  int _points = 0;
  int _maxPoints = 0;
  int _answeredChoices = 0;
  bool _completed;

  DialogueNode get currentNode => scenario.node(_currentNodeId);

  List<DialogueTurn> get transcript =>
      List<DialogueTurn>.unmodifiable(_transcript);

  bool get isCompleted => _completed;

  int get scorePercent {
    if (_maxPoints == 0) return _completed ? 100 : 0;
    return ((_points / _maxPoints) * 100).round().clamp(0, 100).toInt();
  }

  DialogueStepResult choose(String choiceId) {
    if (_completed) {
      throw StateError('Dialogue session is already complete.');
    }
    final node = currentNode;
    DialogueChoice? choice;
    for (final candidate in node.choices) {
      if (candidate.id == choiceId) {
        choice = candidate;
        break;
      }
    }
    if (choice == null) {
      throw ArgumentError.value(
        choiceId,
        'choiceId',
        'Choice is not available from node ${node.id}.',
      );
    }

    final learnerTurn = DialogueTurn(
      id: '${node.id}:${choice.id}',
      speaker: DialogueSpeaker.learner,
      germanText: choice.germanText,
      arabicTranslation: choice.arabicTranslation,
      audioConceptId: choice.id,
    );
    _transcript.add(learnerTurn);
    _points += choice.points;
    _maxPoints += node.maxChoicePoints;
    _answeredChoices += 1;

    _currentNodeId = choice.nextNodeId;
    final next = currentNode;
    _transcript.add(next.turn);
    _completed = next.isTerminal;

    return DialogueStepResult(
      selectedTurn: learnerTurn,
      currentNode: next,
      completed: _completed,
      scorePercent: scorePercent,
    );
  }

  DialogueSessionResult get result {
    return DialogueSessionResult(
      scenarioId: scenario.id,
      points: _points,
      maxPoints: _maxPoints,
      scorePercent: scorePercent,
      answeredChoices: _answeredChoices,
      transcript: transcript,
    );
  }
}
