import 'package:flutter/foundation.dart';

import '../domain/story_models.dart';
import '../domain/story_repository.dart';

final class StoryReaderState {
  const StoryReaderState({
    this.story,
    this.paragraphIndex = 0,
    this.revealedWord,
    this.showParagraphTranslation = false,
    this.answers = const <String, String>{},
    this.answerCorrectness = const <String, bool>{},
    this.isLoading = false,
    this.errorMessage,
  });

  final StoryItem? story;
  final int paragraphIndex;
  final StoryInteractiveWord? revealedWord;
  final bool showParagraphTranslation;
  final Map<String, String> answers;
  final Map<String, bool> answerCorrectness;
  final bool isLoading;
  final String? errorMessage;

  StoryParagraph? get currentParagraph {
    final value = story;
    if (value == null || paragraphIndex >= value.paragraphs.length) return null;
    return value.paragraphs[paragraphIndex];
  }

  bool get isLastParagraph {
    final value = story;
    return value != null && paragraphIndex == value.paragraphs.length - 1;
  }
}

class StoryReaderNotifier extends ChangeNotifier {
  StoryReaderNotifier({required StoryRepository repository})
      : _repository = repository;

  final StoryRepository _repository;
  StoryReaderState _state = const StoryReaderState();

  StoryReaderState get state => _state;

  double get completionFraction {
    final story = _state.story;
    if (story == null) return 0;
    final paragraphUnits = _state.paragraphIndex + 1;
    final completedUnits = paragraphUnits + _state.answers.length;
    final totalUnits = story.paragraphs.length + story.questions.length;
    return (completedUnits / totalUnits).clamp(0.0, 1.0).toDouble();
  }

  int get comprehensionScorePercent {
    final story = _state.story;
    if (story == null || story.questions.isEmpty) return 0;
    final correct = _state.answerCorrectness.values.where((value) => value).length;
    return ((correct / story.questions.length) * 100).round();
  }

  bool get comprehensionComplete {
    final story = _state.story;
    return story != null && _state.answers.length == story.questions.length;
  }

  Future<void> loadStory(String storyId) async {
    if (_state.isLoading) return;
    _setState(const StoryReaderState(isLoading: true));
    try {
      final story = await _repository.getStory(storyId);
      if (story == null) {
        _setState(
          const StoryReaderState(errorMessage: 'القصة المطلوبة غير موجودة.'),
        );
        return;
      }
      _setState(StoryReaderState(story: story));
    } catch (error) {
      _setState(StoryReaderState(errorMessage: error.toString()));
    }
  }

  void nextParagraph() {
    final story = _state.story;
    if (story == null || _state.paragraphIndex >= story.paragraphs.length - 1) {
      return;
    }
    _setState(
      StoryReaderState(
        story: story,
        paragraphIndex: _state.paragraphIndex + 1,
        answers: _state.answers,
        answerCorrectness: _state.answerCorrectness,
      ),
    );
  }

  void previousParagraph() {
    final story = _state.story;
    if (story == null || _state.paragraphIndex <= 0) return;
    _setState(
      StoryReaderState(
        story: story,
        paragraphIndex: _state.paragraphIndex - 1,
        answers: _state.answers,
        answerCorrectness: _state.answerCorrectness,
      ),
    );
  }

  void toggleWordMeaning(String wordId) {
    final paragraph = _state.currentParagraph;
    if (paragraph == null) return;
    final word = paragraph.wordById(wordId);
    if (word == null) return;
    final sameWord = _state.revealedWord?.id == word.id;
    _setState(
      StoryReaderState(
        story: _state.story,
        paragraphIndex: _state.paragraphIndex,
        revealedWord: sameWord ? null : word,
        showParagraphTranslation: _state.showParagraphTranslation,
        answers: _state.answers,
        answerCorrectness: _state.answerCorrectness,
      ),
    );
  }

  void toggleParagraphTranslation() {
    if (_state.currentParagraph == null) return;
    _setState(
      StoryReaderState(
        story: _state.story,
        paragraphIndex: _state.paragraphIndex,
        revealedWord: _state.revealedWord,
        showParagraphTranslation: !_state.showParagraphTranslation,
        answers: _state.answers,
        answerCorrectness: _state.answerCorrectness,
      ),
    );
  }

  void answerQuestion(String questionId, String optionId) {
    final story = _state.story;
    if (story == null) return;
    StoryComprehensionQuestion? question;
    for (final candidate in story.questions) {
      if (candidate.id == questionId) {
        question = candidate;
        break;
      }
    }
    if (question == null ||
        !question.options.any((option) => option.id == optionId)) {
      return;
    }

    _setState(
      StoryReaderState(
        story: story,
        paragraphIndex: _state.paragraphIndex,
        revealedWord: _state.revealedWord,
        showParagraphTranslation: _state.showParagraphTranslation,
        answers: Map<String, String>.unmodifiable(
          <String, String>{..._state.answers, questionId: optionId},
        ),
        answerCorrectness: Map<String, bool>.unmodifiable(
          <String, bool>{
            ..._state.answerCorrectness,
            questionId: question.isCorrect(optionId),
          },
        ),
      ),
    );
  }

  void _setState(StoryReaderState value) {
    _state = value;
    notifyListeners();
  }
}
