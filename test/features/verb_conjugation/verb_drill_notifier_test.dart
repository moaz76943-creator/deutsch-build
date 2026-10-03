import 'dart:math';

import 'package:deutsch_bilarabi/features/verb_conjugation/application/verb_drill_notifier.dart';
import 'package:deutsch_bilarabi/features/verb_conjugation/data/local_verb_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts a deterministic speed round with the correct answer in options', () {
    var now = DateTime.utc(2026, 10, 3, 12);
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(7),
      now: () => now,
    );

    notifier.start(totalQuestions: 4, secondsPerQuestion: 12);

    expect(notifier.started, isTrue);
    expect(notifier.completed, isFalse);
    expect(notifier.currentQuestion, isNotNull);
    expect(
      notifier.currentQuestion!.options,
      contains(notifier.currentQuestion!.correctAnswer),
    );
    expect(notifier.remainingSeconds, 12);
  });

  test('fast correct answer awards base, speed and streak points', () {
    var now = DateTime.utc(2026, 10, 3, 12);
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(3),
      now: () => now,
    );
    notifier.start(totalQuestions: 2, secondsPerQuestion: 12);
    final correct = notifier.currentQuestion!.correctAnswer;

    now = now.add(const Duration(seconds: 2));
    notifier.submit(correct);

    expect(notifier.lastCorrect, isTrue);
    expect(notifier.correctAnswers, 1);
    expect(notifier.streak, 1);
    expect(notifier.score, greaterThan(100));
    expect(notifier.lastResponseTime, const Duration(seconds: 2));
  });

  test('direct submit after deadline is rejected even before timer tick', () {
    var now = DateTime.utc(2026, 10, 3, 12);
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(19),
      now: () => now,
    );
    notifier.start(totalQuestions: 1, secondsPerQuestion: 5);
    final question = notifier.currentQuestion!;
    final key = question.mistakeKey;

    now = now.add(const Duration(seconds: 5));
    notifier.submit(question.correctAnswer);

    expect(notifier.answered, isTrue);
    expect(notifier.timedOut, isTrue);
    expect(notifier.lastCorrect, isFalse);
    expect(notifier.score, 0);
    expect(notifier.remainingSeconds, 0);
    expect(notifier.repeatedMistakes[key], 1);
  });

  test('wrong answer records the exact conjugation error key', () {
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(11),
      now: () => DateTime.utc(2026, 10, 3, 12),
    );
    notifier.start(totalQuestions: 2, secondsPerQuestion: 12);
    final key = notifier.currentQuestion!.mistakeKey;

    notifier.submit('definitely-wrong');

    expect(notifier.lastCorrect, isFalse);
    expect(notifier.repeatedMistakes[key], 1);
    expect(notifier.streak, 0);
  });

  test('timeout is evaluated by application state and counts as an error', () {
    var now = DateTime.utc(2026, 10, 3, 12);
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(13),
      now: () => now,
    );
    notifier.start(totalQuestions: 1, secondsPerQuestion: 5);
    final key = notifier.currentQuestion!.mistakeKey;

    now = now.add(const Duration(seconds: 5));
    notifier.tick();

    expect(notifier.answered, isTrue);
    expect(notifier.timedOut, isTrue);
    expect(notifier.lastCorrect, isFalse);
    expect(notifier.repeatedMistakes[key], 1);
  });

  test('second question uses letter-order mode and completes after next', () {
    final notifier = VerbDrillNotifier(
      LocalVerbRepository(),
      random: Random(17),
      now: () => DateTime.utc(2026, 10, 3, 12),
    );
    notifier.start(totalQuestions: 2, secondsPerQuestion: 12);
    notifier.submit(notifier.currentQuestion!.correctAnswer);
    notifier.next();

    expect(notifier.currentQuestion!.mode, VerbDrillMode.letterOrder);
    final correctLetters = notifier.currentQuestion!.correctAnswer
        .replaceAll(RegExp(r'\s+'), '')
        .runes
        .map(String.fromCharCode)
        .join();
    final remaining = List<VerbLetterTile>.from(
      notifier.currentQuestion!.letterTiles,
    );
    for (final char in correctLetters.runes.map(String.fromCharCode)) {
      final tile = remaining.firstWhere(
        (candidate) => candidate.letter == char,
      );
      notifier.chooseLetter(tile.id);
      remaining.removeWhere((candidate) => candidate.id == tile.id);
    }
    notifier.submitLetterAnswer();

    expect(notifier.lastCorrect, isTrue);
    notifier.next();
    expect(notifier.completed, isTrue);
    expect(notifier.accuracy, 1);
  });
}
