import 'dart:math';

import 'package:flutter/foundation.dart';

import '../domain/verb_models.dart';
import '../domain/verb_repository.dart';

enum VerbDrillMode { multipleChoice, letterOrder }

class VerbLetterTile {
  const VerbLetterTile({required this.id, required this.letter});

  final String id;
  final String letter;
}

class VerbDrillQuestion {
  const VerbDrillQuestion({
    required this.id,
    required this.verb,
    required this.tense,
    required this.pronoun,
    required this.mode,
    required this.correctAnswer,
    required this.options,
    required this.letterTiles,
  });

  final String id;
  final VerbItem verb;
  final VerbTense tense;
  final GermanPronoun pronoun;
  final VerbDrillMode mode;
  final String correctAnswer;
  final List<String> options;
  final List<VerbLetterTile> letterTiles;

  String get mistakeKey =>
      '${verb.infinitive}|${tense.name}|${pronoun.name}';
}

class VerbDrillNotifier extends ChangeNotifier {
  VerbDrillNotifier(
    this._repository, {
    Random? random,
    DateTime Function()? now,
  })  : _random = random ?? Random(),
        _now = now ?? DateTime.now;

  final VerbRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  bool _started = false;
  bool _completed = false;
  bool _answered = false;
  bool _lastCorrect = false;
  bool _timedOut = false;
  int _questionIndex = 0;
  int _totalQuestions = 10;
  int _secondsPerQuestion = 12;
  int _remainingSeconds = 12;
  int _score = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  int _totalResponseMillis = 0;
  int _answeredCount = 0;
  Duration _lastResponseTime = Duration.zero;
  DateTime? _questionStartedAt;
  VerbDrillQuestion? _currentQuestion;
  final Map<String, int> _mistakes = <String, int>{};
  final List<VerbLetterTile> _chosenLetterTiles = <VerbLetterTile>[];

  bool get started => _started;
  bool get completed => _completed;
  bool get answered => _answered;
  bool get lastCorrect => _lastCorrect;
  bool get timedOut => _timedOut;
  int get questionIndex => _questionIndex;
  int get totalQuestions => _totalQuestions;
  int get secondsPerQuestion => _secondsPerQuestion;
  int get remainingSeconds => _remainingSeconds;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get streak => _streak;
  Duration get lastResponseTime => _lastResponseTime;
  VerbDrillQuestion? get currentQuestion => _currentQuestion;
  Map<String, int> get repeatedMistakes => Map.unmodifiable(_mistakes);
  List<VerbLetterTile> get chosenLetterTiles =>
      List.unmodifiable(_chosenLetterTiles);

  double get accuracy =>
      _answeredCount == 0 ? 0 : _correctAnswers / _answeredCount;

  Duration get averageResponseTime => _answeredCount == 0
      ? Duration.zero
      : Duration(milliseconds: _totalResponseMillis ~/ _answeredCount);

  List<VerbLetterTile> get availableLetterTiles {
    final question = _currentQuestion;
    if (question == null) return const <VerbLetterTile>[];
    final chosenIds = _chosenLetterTiles.map((tile) => tile.id).toSet();
    return question.letterTiles
        .where((tile) => !chosenIds.contains(tile.id))
        .toList(growable: false);
  }

  String get letterAnswer =>
      _chosenLetterTiles.map((tile) => tile.letter).join();

  void start({int totalQuestions = 10, int secondsPerQuestion = 12}) {
    if (totalQuestions <= 0) {
      throw ArgumentError.value(totalQuestions, 'totalQuestions', 'must be > 0');
    }
    if (secondsPerQuestion < 3) {
      throw ArgumentError.value(
        secondsPerQuestion,
        'secondsPerQuestion',
        'must be at least 3',
      );
    }
    if (_repository.commonVerbs.isEmpty) {
      throw StateError('verb repository is empty');
    }

    _started = true;
    _completed = false;
    _answered = false;
    _lastCorrect = false;
    _timedOut = false;
    _questionIndex = 0;
    _totalQuestions = totalQuestions;
    _secondsPerQuestion = secondsPerQuestion;
    _remainingSeconds = secondsPerQuestion;
    _score = 0;
    _correctAnswers = 0;
    _streak = 0;
    _totalResponseMillis = 0;
    _answeredCount = 0;
    _lastResponseTime = Duration.zero;
    _mistakes.clear();
    _chosenLetterTiles.clear();
    _currentQuestion = _buildQuestion(0);
    _questionStartedAt = _now();
    notifyListeners();
  }

  void tick() {
    if (!_started || _completed || _answered || _questionStartedAt == null) {
      return;
    }
    final elapsed = _now().difference(_questionStartedAt!);
    final nextRemaining = max(0, _secondsPerQuestion - elapsed.inSeconds);
    if (nextRemaining != _remainingSeconds) {
      _remainingSeconds = nextRemaining;
      notifyListeners();
    }
    if (nextRemaining == 0) {
      submit('', forceTimeout: true);
    }
  }

  void chooseLetter(String tileId) {
    if (_answered || _completed) return;
    final tile =
        availableLetterTiles.where((item) => item.id == tileId).firstOrNull;
    if (tile == null) return;
    _chosenLetterTiles.add(tile);
    notifyListeners();
  }

  void removeLastLetter() {
    if (_answered || _completed || _chosenLetterTiles.isEmpty) return;
    _chosenLetterTiles.removeLast();
    notifyListeners();
  }

  void clearLetters() {
    if (_answered || _completed || _chosenLetterTiles.isEmpty) return;
    _chosenLetterTiles.clear();
    notifyListeners();
  }

  void submitLetterAnswer() => submit(letterAnswer);

  void submit(String answer, {bool forceTimeout = false}) {
    final question = _currentQuestion;
    if (!_started || _completed || _answered || question == null) return;

    final elapsed = _elapsed();
    final deadlineReached =
        elapsed >= Duration(seconds: _secondsPerQuestion);
    final timedOut = forceTimeout || deadlineReached;
    final correct = !timedOut && _matches(question, answer);
    _answered = true;
    _lastCorrect = correct;
    _timedOut = timedOut;
    if (timedOut) _remainingSeconds = 0;
    _lastResponseTime = elapsed;
    _answeredCount++;
    _totalResponseMillis += elapsed.inMilliseconds;

    if (correct) {
      _correctAnswers++;
      _streak++;
      final speedSeconds = max(0, _secondsPerQuestion - elapsed.inSeconds);
      final speedBonus = speedSeconds * 8;
      final streakBonus = min(_streak, 5) * 10;
      _score += 100 + speedBonus + streakBonus;
    } else {
      _streak = 0;
      _mistakes.update(
        question.mistakeKey,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    notifyListeners();
  }

  void next() {
    if (!_started || _completed || !_answered) return;
    if (_questionIndex + 1 >= _totalQuestions) {
      _completed = true;
      _currentQuestion = null;
      notifyListeners();
      return;
    }

    _questionIndex++;
    _answered = false;
    _lastCorrect = false;
    _timedOut = false;
    _remainingSeconds = _secondsPerQuestion;
    _chosenLetterTiles.clear();
    _currentQuestion = _buildQuestion(_questionIndex);
    _questionStartedAt = _now();
    notifyListeners();
  }

  Duration _elapsed() {
    final startedAt = _questionStartedAt;
    if (startedAt == null) return Duration.zero;
    final elapsed = _now().difference(startedAt);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  bool _matches(VerbDrillQuestion question, String answer) {
    if (question.mode == VerbDrillMode.letterOrder) {
      return _lettersOnly(answer) == _lettersOnly(question.correctAnswer);
    }
    return _normalize(answer) == _normalize(question.correctAnswer);
  }

  VerbDrillQuestion _buildQuestion(int index) {
    final verbs = _repository.commonVerbs;
    final verb = verbs[_random.nextInt(verbs.length)];
    final tense = VerbTense.values[_random.nextInt(VerbTense.values.length)];
    final pronoun = GermanPronoun.values[
      _random.nextInt(GermanPronoun.values.length)
    ];
    final correct = verb.tableFor(tense).formFor(pronoun);
    final mode = index.isEven
        ? VerbDrillMode.multipleChoice
        : VerbDrillMode.letterOrder;

    final options = _buildOptions(
      verbs: verbs,
      currentVerb: verb,
      tense: tense,
      pronoun: pronoun,
      correct: correct,
    );
    final letters = _buildLetterTiles(correct);

    return VerbDrillQuestion(
      id: '${index}_${verb.infinitive}_${tense.name}_${pronoun.name}',
      verb: verb,
      tense: tense,
      pronoun: pronoun,
      mode: mode,
      correctAnswer: correct,
      options: options,
      letterTiles: letters,
    );
  }

  List<String> _buildOptions({
    required List<VerbItem> verbs,
    required VerbItem currentVerb,
    required VerbTense tense,
    required GermanPronoun pronoun,
    required String correct,
  }) {
    final candidates = <String>{correct};
    final shuffled = List<VerbItem>.from(verbs)..shuffle(_random);
    for (final verb in shuffled) {
      if (verb.infinitive == currentVerb.infinitive) continue;
      candidates.add(verb.tableFor(tense).formFor(pronoun));
      if (candidates.length >= 4) break;
    }
    final options = candidates.toList(growable: false)..shuffle(_random);
    return options;
  }

  List<VerbLetterTile> _buildLetterTiles(String answer) {
    final letters = answer
        .replaceAll(RegExp(r'\s+'), '')
        .runes
        .map(String.fromCharCode)
        .toList(growable: false);
    final tiles = <VerbLetterTile>[
      for (var index = 0; index < letters.length; index++)
        VerbLetterTile(
          id: 'letter_${_questionIndex}_${index}_${letters[index]}',
          letter: letters[index],
        ),
    ]..shuffle(_random);
    return tiles;
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _lettersOnly(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'\s+'), '');
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
