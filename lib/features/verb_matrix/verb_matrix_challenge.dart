import 'package:flutter/material.dart';

import '../../models/verb_conjugation.dart';
import '../../services/verb_index.dart';
import 'data/database.dart';
import 'domain/models.dart';

class VerbMatrixChallengePage extends StatefulWidget {
  final VerbIndex verbIndex;
  final VerbMatrixDatabase database;

  const VerbMatrixChallengePage({
    super.key,
    required this.verbIndex,
    required this.database,
  });

  @override
  State<VerbMatrixChallengePage> createState() =>
      _VerbMatrixChallengePageState();
}

class _VerbMatrixChallengePageState extends State<VerbMatrixChallengePage> {
  String? _selectedInfinitive;
  List<VerbConjugation> _currentVerbs = [];
  final Map<String, String?> _userAnswers = {}; // person -> form
  DateTime? _startTime;
  bool _isSubmitted = false;

  final List<String> _pronouns = [
    'ich',
    'du',
    'er/sie/es',
    'wir',
    'ihr',
    'sie/Sie',
  ];

  // A mapping to simplify pronouns from the data model to the UI display
  String _normalizePronoun(String person) {
    if (person == 'ich' ||
        person == 'du' ||
        person == 'wir' ||
        person == 'ihr') {
      return person;
    } else if (person == 'er' || person == 'sie (هي)' || person == 'es') {
      return 'er/sie/es';
    } else if (person == 'sie (هم)' || person == 'Sie') {
      return 'sie/Sie';
    }
    return person; // Fallback
  }

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    final infinitives = widget.verbIndex.infinitives.toList();
    if (infinitives.isEmpty) return;

    // Pick a random verb for the challenge
    infinitives.shuffle();
    _selectedInfinitive = infinitives.first;
    _currentVerbs = widget.verbIndex.rowsFor(_selectedInfinitive!);
    _userAnswers.clear();
    _isSubmitted = false;
    _startTime = DateTime.now();
    setState(() {});
  }

  Future<void> _submitAnswers() async {
    setState(() {
      _isSubmitted = true;
    });

    final timeTaken = DateTime.now().difference(_startTime!);

    // Record attempts
    for (final verb in _currentVerbs) {
      final normalizedPronoun = _normalizePronoun(verb.person);
      final userAnswer = _userAnswers[normalizedPronoun];

      // Skip if we already recorded for this normalized pronoun in this round
      // to avoid duplicates for er/sie/es

      if (userAnswer != null) {
        final isCorrect = userAnswer == verb.form;
        final attempt = VerbChallengeAttempt(
          id: 'attempt_${DateTime.now().millisecondsSinceEpoch}_${verb.person}',
          infinitive: verb.infinitive,
          person: verb.person,
          isCorrect: isCorrect,
          timestamp: DateTime.now(),
          timeTaken: timeTaken,
        );

        await widget.database.recordAttempt(attempt.toMap());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedInfinitive == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Filter out verbs to just get one representative for each pronoun group
    final representativeVerbs = <String, VerbConjugation>{};
    for (final verb in _currentVerbs) {
      representativeVerbs[_normalizePronoun(verb.person)] = verb;
    }

    // Get all possible forms for draggable items, specifically one for each pronoun slot
    final forms = representativeVerbs.values.map((v) => v.form).toList()
      ..shuffle();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحدي تصريف الأفعال'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startNewRound,
            tooltip: 'تحدي جديد',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'صرف الفعل: $_selectedInfinitive',
              style: Theme.of(context).textTheme.headlineSmall,
              textDirection: TextDirection.ltr,
            ),
            if (_currentVerbs.isNotEmpty)
              Text(
                _currentVerbs.first.arabic,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 24),

            // The Drop Targets (Matrix)
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: _pronouns.map((pronoun) {
                  final expectedVerb = representativeVerbs[pronoun];
                  final isAnswered = _userAnswers[pronoun] != null;

                  bool? isCorrect;
                  if (_isSubmitted && isAnswered && expectedVerb != null) {
                    isCorrect = _userAnswers[pronoun] == expectedVerb.form;
                  }

                  return DragTarget<String>(
                    onAcceptWithDetails: (details) {
                      if (!_isSubmitted) {
                        setState(() {
                          _userAnswers[pronoun] = details.data;
                        });
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      Color bgColor =
                          Theme.of(context).colorScheme.surfaceContainerHighest;
                      if (candidateData.isNotEmpty) {
                        bgColor =
                            Theme.of(context).colorScheme.primaryContainer;
                      } else if (isCorrect == true) {
                        bgColor = const Color(0xFF0D9488)
                            .withValues(alpha: 0.3); // Deep Teal for success
                      } else if (isCorrect == false) {
                        bgColor = const Color(0xFFE11D48)
                            .withValues(alpha: 0.3); // Soft Crimson for error
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCorrect == false
                                ? const Color(0xFFE11D48)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(14),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                pronoun,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  _userAnswers[pronoun] ?? '...',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: isAnswered
                                        ? null
                                        : Theme.of(context).disabledColor,
                                  ),
                                  textDirection: TextDirection.ltr,
                                ),
                              ),
                            ),
                            if (isCorrect == false && expectedVerb != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Tooltip(
                                  message: 'الصحيح: ${expectedVerb.form}',
                                  child: const Icon(
                                    Icons.help_outline,
                                    color: Color(0xFFE11D48),
                                    size: 20,
                                  ),
                                ),
                              ),
                            if (isAnswered && !_isSubmitted)
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _userAnswers.remove(pronoun);
                                  });
                                },
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),

            // The Draggable Items
            if (!_isSubmitted) ...[
              const Divider(),
              const Text('اسحب التصريف الصحيح إلى الضمير المناسب'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: () {
                  // Count remaining occurrences for each form
                  final formCounts = <String, int>{};
                  for (final form in forms) {
                    formCounts[form] = (formCounts[form] ?? 0) + 1;
                  }

                  // Subtract forms that are already placed
                  for (final answer in _userAnswers.values) {
                    if (answer != null && formCounts.containsKey(answer)) {
                      formCounts[answer] = formCounts[answer]! - 1;
                    }
                  }

                  final availableForms = <String>[];
                  for (final entry in formCounts.entries) {
                    for (var i = 0; i < entry.value; i++) {
                      availableForms.add(entry.key);
                    }
                  }

                  availableForms.shuffle();

                  return availableForms.map((form) {
                    return Draggable<String>(
                      data: form,
                      feedback: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            form,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      childWhenDragging: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          form,
                          style: TextStyle(
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(form, style: const TextStyle(fontSize: 18)),
                      ),
                    );
                  }).toList();
                }(),
              ),
            ],

            const SizedBox(height: 24),

            if (_isSubmitted)
              ElevatedButton.icon(
                onPressed: _startNewRound,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('التالي'),
              )
            else
              ElevatedButton(
                onPressed: _userAnswers.length == _pronouns.length
                    ? _submitAnswers
                    : null,
                child: const Text('تحقق من الإجابات'),
              ),
          ],
        ),
      ),
    );
  }
}
