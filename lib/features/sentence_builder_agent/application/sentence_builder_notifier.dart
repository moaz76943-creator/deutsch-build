import 'package:flutter/foundation.dart';

import '../domain/sentence_builder_models.dart';
import '../domain/sentence_builder_repository.dart';

final class SentenceBuilderNotifier extends ChangeNotifier {
  SentenceBuilderNotifier(this._repository);

  final SentenceBuilderRepository _repository;

  SentencePuzzle? _activePuzzle;
  List<WordTileItem> _currentArrangement = const <WordTileItem>[];
  bool? _isCorrect;
  String _feedbackMessage = '';
  bool _isBusy = false;

  SentencePuzzle? get activePuzzle => _activePuzzle;

  List<WordTileItem> get currentArrangement => _currentArrangement;

  bool? get isCorrect => _isCorrect;

  String get feedbackMessage => _feedbackMessage;

  bool get isBusy => _isBusy;

  List<WordTileItem> get availableTiles {
    final usedIds = _currentArrangement.map((tile) => tile.id).toSet();
    return List<WordTileItem>.unmodifiable(
      (_activePuzzle?.shuffledTiles ?? const <WordTileItem>[])
          .where((tile) => !usedIds.contains(tile.id)),
    );
  }

  Future<void> loadLevel(String level) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      final puzzles = await _repository.getPuzzlesByLevel(level);
      _activePuzzle = puzzles.isEmpty ? null : puzzles.first;
      _currentArrangement = const <WordTileItem>[];
      _isCorrect = null;
      _feedbackMessage = puzzles.isEmpty
          ? 'لا توجد ألغاز متاحة لهذا المستوى بعد.'
          : '';
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  void pickTile(WordTileItem tile) {
    final puzzle = _activePuzzle;
    if (puzzle == null || _isBusy) return;
    final belongsToPuzzle =
        puzzle.shuffledTiles.any((candidate) => candidate.id == tile.id);
    final alreadyPicked =
        _currentArrangement.any((candidate) => candidate.id == tile.id);
    if (!belongsToPuzzle || alreadyPicked) return;

    _currentArrangement = List<WordTileItem>.unmodifiable(
      <WordTileItem>[..._currentArrangement, tile],
    );
    _isCorrect = null;
    _feedbackMessage = '';
    notifyListeners();
  }

  void removeTile(WordTileItem tile) {
    if (_isBusy) return;
    final next = _currentArrangement
        .where((candidate) => candidate.id != tile.id)
        .toList(growable: false);
    if (next.length == _currentArrangement.length) return;

    _currentArrangement = List<WordTileItem>.unmodifiable(next);
    _isCorrect = null;
    _feedbackMessage = '';
    notifyListeners();
  }

  Future<void> verifySentence() async {
    final puzzle = _activePuzzle;
    if (puzzle == null || _isBusy) return;

    if (_currentArrangement.length != puzzle.shuffledTiles.length) {
      _isCorrect = false;
      _feedbackMessage =
          'أكمل جميع أجزاء الجملة أولًا، ثم تحقّق من الترتيب.';
      notifyListeners();
      return;
    }

    _isBusy = true;
    notifyListeners();
    try {
      final arrangedIds =
          _currentArrangement.map((tile) => tile.id).toList(growable: false);
      final correct = await _repository.validateArrangement(
        puzzle.id,
        arrangedIds,
      );
      _isCorrect = correct;
      _feedbackMessage = correct
          ? 'ممتاز. ${puzzle.ruleExplanation}'
          : _incorrectFeedback(puzzle.structureType);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  String _incorrectFeedback(SentenceStructureType type) => switch (type) {
        SentenceStructureType.mainClause =>
          'الترتيب يحتاج تعديلًا: في الجملة الرئيسية يأتي الفعل المصرف '
              'في الموقع الثاني. راجع موضع الفاعل وبقية المكملات.',
        SentenceStructureType.subordinateWeil =>
          'راجع ترتيب weil: بعد weil تبدأ الجملة الفرعية، ويأتي الفاعل '
              'قبل بقية العناصر بينما ينتقل الفعل المصرف إلى النهاية.',
        SentenceStructureType.questionInversion =>
          'راجع صيغة السؤال: في سؤال نعم/لا يبدأ الفعل المصرف، '
              'ثم يأتي الفاعل وبعده بقية عناصر الجملة.',
      };
}
