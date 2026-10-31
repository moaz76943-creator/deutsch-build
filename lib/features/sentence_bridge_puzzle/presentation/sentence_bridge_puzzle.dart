import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../data/database.dart';

class SentenceBridgePuzzleWidget extends StatefulWidget {
  final SentenceBridgeDatabase database;

  const SentenceBridgePuzzleWidget({super.key, required this.database});

  @override
  State<SentenceBridgePuzzleWidget> createState() =>
      _SentenceBridgePuzzleWidgetState();
}

class _SentenceBridgePuzzleWidgetState
    extends State<SentenceBridgePuzzleWidget> {
  PuzzleItem? _currentPuzzle;
  List<String> _scrambledWords = [];
  List<String> _assembledWords = [];
  bool _isLoading = true;
  String? _feedbackMessage;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _loadRandomPuzzle();
  }

  Future<void> _loadRandomPuzzle() async {
    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final puzzles = await widget.database.getRandomPuzzles(1);
    if (puzzles.isNotEmpty) {
      final item = PuzzleItem.fromMap(puzzles.first);
      setState(() {
        _currentPuzzle = item;
        _scrambledWords = item.scrambledWords;
        _assembledWords = [];
        _isLoading = false;
        _startTime = DateTime.now();
      });
    } else {
      setState(() {
        _isLoading = false;
        _feedbackMessage = "No puzzles available.";
      });
    }
  }

  void _onWordTapped(String word, bool isFromAssembled) {
    setState(() {
      if (isFromAssembled) {
        _assembledWords.remove(word);
        _scrambledWords.add(word);
      } else {
        _scrambledWords.remove(word);
        _assembledWords.add(word);
      }
    });
  }

  Future<void> _checkAnswer() async {
    if (_currentPuzzle == null || _startTime == null) return;

    final originalSentence = _currentPuzzle!.germanSentence
        .replaceAll(RegExp(r'[^\wäöüßÄÖÜ\s]'), '')
        .trim();
    final assembledSentence = _assembledWords.join(' ').trim();

    final isCorrect =
        originalSentence.toLowerCase() == assembledSentence.toLowerCase();

    final timeTakenMs = DateTime.now().difference(_startTime!).inMilliseconds;

    final attempt = PuzzleAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      puzzleId: _currentPuzzle!.id,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
      timeTakenMs: timeTakenMs,
    );

    await widget.database.recordAttempt(attempt.toMap());

    setState(() {
      if (isCorrect) {
        _feedbackMessage = "Correct!";
      } else {
        _feedbackMessage = "Incorrect. Try again!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentPuzzle == null) {
      return Center(child: Text(_feedbackMessage ?? "Unknown error"));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Translate this sentence:",
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _currentPuzzle!.arabicSentence,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _assembledWords
                  .map((word) => _buildWordChip(word, true))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _scrambledWords
                .map((word) => _buildWordChip(word, false))
                .toList(),
          ),
          const Spacer(),
          if (_feedbackMessage != null) ...[
            Text(
              _feedbackMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    _feedbackMessage == "Correct!" ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _scrambledWords.isEmpty ? _checkAnswer : null,
                child: const Text('Check'),
              ),
              if (_feedbackMessage == "Correct!")
                ElevatedButton(
                  onPressed: _loadRandomPuzzle,
                  child: const Text('Next Puzzle'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(String word, bool isFromAssembled) {
    return ActionChip(
      label: Text(word),
      onPressed: () => _onWordTapped(word, isFromAssembled),
      backgroundColor: isFromAssembled
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.secondaryContainer,
    );
  }
}
