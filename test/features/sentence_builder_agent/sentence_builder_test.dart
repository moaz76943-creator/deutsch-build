import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/features/sentence_builder_agent/application/sentence_builder_notifier.dart';
import 'package:deutsch_bilarabi/features/sentence_builder_agent/data/local_sentence_builder_repository.dart';
import 'package:deutsch_bilarabi/features/sentence_builder_agent/domain/sentence_builder_models.dart';

List<String> _correctIds(SentencePuzzle puzzle) {
  final tiles = List<WordTileItem>.of(puzzle.shuffledTiles)
    ..sort((left, right) => left.correctPosition.compareTo(right.correctPosition));
  return tiles.map((tile) => tile.id).toList(growable: false);
}

void main() {
  test('repository validates only the canonical word arrangement', () async {
    final repository = LocalSentenceBuilderRepository();
    final puzzles = await repository.getPuzzlesByLevel('A1');
    final puzzle = puzzles.first;

    final correct = _correctIds(puzzle);
    final wrong = List<String>.of(correct.reversed);

    expect(
      await repository.validateArrangement(puzzle.id, correct),
      isTrue,
    );
    expect(
      await repository.validateArrangement(puzzle.id, wrong),
      isFalse,
    );
  });

  test('subordinate weil puzzle keeps the finite verb at the end', () async {
    final repository = LocalSentenceBuilderRepository();
    final puzzles = await repository.getPuzzlesByLevel('A2');
    final puzzle = puzzles.firstWhere(
      (item) => item.structureType == SentenceStructureType.subordinateWeil,
    );

    final ordered = List<WordTileItem>.of(puzzle.shuffledTiles)
      ..sort(
        (left, right) => left.correctPosition.compareTo(right.correctPosition),
      );

    expect(ordered.any((tile) => tile.germanText == 'weil'), isTrue);
    expect(ordered.last.grammaticalFunction, WordGrammaticalFunction.verb);
    expect(ordered.last.germanText, 'bin');
    expect(
      await repository.validateArrangement(
        puzzle.id,
        ordered.map((tile) => tile.id).toList(growable: false),
      ),
      isTrue,
    );
  });

  test('notifier emits targeted weil feedback for incorrect order', () async {
    final repository = LocalSentenceBuilderRepository();
    final notifier = SentenceBuilderNotifier(repository);
    addTearDown(notifier.dispose);

    await notifier.loadLevel('A2');
    final puzzle = notifier.activePuzzle!;
    expect(puzzle.structureType, SentenceStructureType.subordinateWeil);

    final wrongOrder = List<WordTileItem>.of(puzzle.shuffledTiles)
      ..sort(
        (left, right) => right.correctPosition.compareTo(left.correctPosition),
      );
    for (final tile in wrongOrder) {
      notifier.pickTile(tile);
    }

    await notifier.verifySentence();

    expect(notifier.isCorrect, isFalse);
    expect(notifier.feedbackMessage, contains('weil'));
    expect(notifier.feedbackMessage, contains('الفعل'));
    expect(notifier.feedbackMessage, contains('النهاية'));
  });

  test('notifier accepts the correct arrangement and explains the rule', () async {
    final repository = LocalSentenceBuilderRepository();
    final notifier = SentenceBuilderNotifier(repository);
    addTearDown(notifier.dispose);

    await notifier.loadLevel('A1');
    final puzzle = notifier.activePuzzle!;
    final ordered = List<WordTileItem>.of(puzzle.shuffledTiles)
      ..sort(
        (left, right) => left.correctPosition.compareTo(right.correctPosition),
      );
    for (final tile in ordered) {
      notifier.pickTile(tile);
    }

    await notifier.verifySentence();

    expect(notifier.isCorrect, isTrue);
    expect(notifier.feedbackMessage, isNotEmpty);
  });
}
