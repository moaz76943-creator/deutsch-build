import 'dart:math';

/// CEFR Proficiency Level.
enum CefrLevel { A1, A2, B1, B2, C1 }

/// A calibrated diagnostic test item with Rasch difficulty beta.
class DiagnosticItem {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctOption;
  final double difficulty; // Rasch beta: A1 (-2.0) to C1 (+2.0)
  final CefrLevel targetLevel;

  const DiagnosticItem({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.difficulty,
    required this.targetLevel,
  });
}

/// A recorded response during the adaptive session.
class DiagnosticResponse {
  final String itemId;
  final double difficulty;
  final bool isCorrect;

  const DiagnosticResponse({
    required this.itemId,
    required this.difficulty,
    required this.isCorrect,
  });
}

/// Result of the adaptive placement assessment.
class PlacementAssessmentResult {
  final double theta; // Estimated learner ability
  final double standardError; // Standard Error of Measurement (SEM)
  final CefrLevel determinedLevel;
  final int totalQuestionsAnswered;
  final int correctAnswers;
  final bool isConfident;

  const PlacementAssessmentResult({
    required this.theta,
    required this.standardError,
    required this.determinedLevel,
    required this.totalQuestionsAnswered,
    required this.correctAnswers,
    required this.isConfident,
  });

  Map<String, dynamic> toJson() => {
    'theta': theta,
    'standardError': standardError,
    'determinedLevel': determinedLevel.name,
    'totalQuestionsAnswered': totalQuestionsAnswered,
    'correctAnswers': correctAnswers,
    'isConfident': isConfident,
  };
}

/// Adaptive Computerized Placement Test Runner using 1PL Rasch Model.
class PlacementTestRunner {
  final List<DiagnosticItem> itemPool;
  final List<DiagnosticResponse> _responses = [];
  final Set<String> _usedItemIds = {};

  double _currentTheta = 0.0; // Initial prior at B1 threshold
  static const double targetSemThreshold = 0.35;
  static const int minQuestions = 8;
  static const int maxQuestions = 20;

  PlacementTestRunner({required this.itemPool});

  List<DiagnosticResponse> get responses => List.unmodifiable(_responses);
  double get currentTheta => _currentTheta;
  bool get isComplete =>
      _responses.length >= maxQuestions ||
      (_responses.length >= minQuestions && currentSem <= targetSemThreshold);

  /// Default calibrated diagnostic bank spanning A1 to C1.
  static const List<DiagnosticItem> defaultBank = [
    // A1 Items (difficulty: -2.0 to -1.2)
    DiagnosticItem(
      id: 'diag_a1_01',
      questionText: 'Wie heißt du? - Ich ___ Mohammed.',
      options: ['heiße', 'heißt', 'heißen', 'heiß'],
      correctOption: 'heiße',
      difficulty: -2.0,
      targetLevel: CefrLevel.A1,
    ),
    DiagnosticItem(
      id: 'diag_a1_02',
      questionText: 'Das ist ___ Buch. (neutrum)',
      options: ['ein', 'eine', 'einen', 'einem'],
      correctOption: 'ein',
      difficulty: -1.5,
      targetLevel: CefrLevel.A1,
    ),
    // A2 Items (difficulty: -1.0 to -0.2)
    DiagnosticItem(
      id: 'diag_a2_01',
      questionText: 'Gestern ___ ich ins Kino gegangen.',
      options: ['bin', 'habe', 'war', 'hatte'],
      correctOption: 'bin',
      difficulty: -0.8,
      targetLevel: CefrLevel.A2,
    ),
    DiagnosticItem(
      id: 'diag_a2_02',
      questionText: 'Ich helfe ___ Kind. (Dativ)',
      options: ['dem', 'den', 'das', 'des'],
      correctOption: 'dem',
      difficulty: -0.4,
      targetLevel: CefrLevel.A2,
    ),
    // B1 Items (difficulty: 0.0 to +0.8)
    DiagnosticItem(
      id: 'diag_b1_01',
      questionText: 'Wenn ich Zeit hätte, ___ ich Deutsch lernen.',
      options: ['würde', 'werde', 'wäre', 'hätte'],
      correctOption: 'würde',
      difficulty: 0.2,
      targetLevel: CefrLevel.B1,
    ),
    DiagnosticItem(
      id: 'diag_b1_02',
      questionText: 'Er wartet schon lange ___ den Bus.',
      options: ['auf', 'für', 'an', 'über'],
      correctOption: 'auf',
      difficulty: 0.6,
      targetLevel: CefrLevel.B1,
    ),
    // B2 Items (difficulty: +1.0 to +1.6)
    DiagnosticItem(
      id: 'diag_b2_01',
      questionText: 'Die Aufgabe lässt sich nicht einfach ___.',
      options: ['lösen', 'gelöst', 'zu lösen', 'lösbar'],
      correctOption: 'lösen',
      difficulty: 1.2,
      targetLevel: CefrLevel.B2,
    ),
    DiagnosticItem(
      id: 'diag_b2_02',
      questionText: 'Wir müssen eine Entscheidung ___. (FVG)',
      options: ['treffen', 'machen', 'nehmen', 'stellen'],
      correctOption: 'treffen',
      difficulty: 1.5,
      targetLevel: CefrLevel.B2,
    ),
    // C1 Items (difficulty: +1.8 to +2.5)
    DiagnosticItem(
      id: 'diag_c1_01',
      questionText: '___ der widrigen Wetterumstände fand das Spiel statt.',
      options: ['Ungeachtet', 'Infolge', 'Wegen', 'Mittels'],
      correctOption: 'Ungeachtet',
      difficulty: 2.1,
      targetLevel: CefrLevel.C1,
    ),
  ];

  /// Probability of correct answer under Rasch 1PL model.
  static double raschProbability(double theta, double beta) {
    return 1.0 / (1.0 + exp(-(theta - beta)));
  }

  /// Calculates Fisher Information for the current test trajectory.
  double get totalInformation {
    double info = 0.2; // Prior regularization
    for (final r in _responses) {
      final p = raschProbability(_currentTheta, r.difficulty);
      info += p * (1.0 - p);
    }
    return info;
  }

  /// Current Standard Error of Measurement (SEM).
  double get currentSem => 1.0 / sqrt(totalInformation);

  /// Selects next optimal question maximizing Fisher Information (closest difficulty to theta).
  DiagnosticItem? selectNextItem() {
    if (isComplete) return null;

    final available = itemPool.where((i) => !_usedItemIds.contains(i.id)).toList();
    if (available.isEmpty) return null;

    available.sort((a, b) =>
        (a.difficulty - _currentTheta).abs().compareTo((b.difficulty - _currentTheta).abs()));

    return available.first;
  }

  /// Submits an answer and updates latent ability theta using Newton-Raphson update step.
  void submitAnswer(DiagnosticItem item, String selectedOption) {
    final isCorrect = item.correctOption.trim().toLowerCase() == selectedOption.trim().toLowerCase();
    _usedItemIds.add(item.id);
    _responses.add(DiagnosticResponse(
      itemId: item.id,
      difficulty: item.difficulty,
      isCorrect: isCorrect,
    ));

    // Update Theta estimate
    final p = raschProbability(_currentTheta, item.difficulty);
    final score = isCorrect ? 1.0 : 0.0;
    final itemInfo = p * (1.0 - p);
    final delta = (score - p) / (itemInfo + 0.2); // Damped gradient step

    // Bound step to prevent divergence on outliers
    final clampedDelta = delta.clamp(-0.8, 0.8);
    _currentTheta = (_currentTheta + clampedDelta).clamp(-3.0, 3.0);
  }

  /// Evaluates and finalizes assessment result.
  PlacementAssessmentResult finalizeResult() {
    final correctCount = _responses.where((r) => r.isCorrect).length;
    final sem = currentSem;
    final isConfident = sem <= targetSemThreshold || _responses.length >= minQuestions;

    CefrLevel level;
    if (_currentTheta < -1.3) {
      level = CefrLevel.A1;
    } else if (_currentTheta < -0.3) {
      level = CefrLevel.A2;
    } else if (_currentTheta < 0.7) {
      level = CefrLevel.B1;
    } else if (_currentTheta < 1.7) {
      level = CefrLevel.B2;
    } else {
      level = CefrLevel.C1;
    }

    return PlacementAssessmentResult(
      theta: _currentTheta,
      standardError: sem,
      determinedLevel: level,
      totalQuestionsAnswered: _responses.length,
      correctAnswers: correctCount,
      isConfident: isConfident,
    );
  }
}
