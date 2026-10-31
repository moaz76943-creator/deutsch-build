import 'package:flutter/foundation.dart';

import '../domain/clause_connector_models.dart';
import '../domain/clause_connector_repository.dart';

final class ClauseConnectorNotifier extends ChangeNotifier {
  ClauseConnectorNotifier(
    this._repository, {
    this.typeFilter,
  });

  static const String verbFinalPosition = 'verb-final';
  static const String verbSecondPosition = 'verb-second';
  static const String inversionVerbSecondPosition = 'inversion-verb-second';

  static const List<String> _connectorPool = <String>[
    'weil',
    'denn',
    'obwohl',
    'dass',
    'deshalb',
    'trotzdem',
  ];

  final ClauseConnectorRepository _repository;
  final ConjunctionType? typeFilter;

  List<ConnectorChallengeItem> _challenges =
      const <ConnectorChallengeItem>[];
  ConnectorChallengeItem? _currentChallenge;
  List<String> _options = const <String>[];
  bool? _isCorrect;
  String? _feedbackExplanation;
  int _currentIndex = -1;
  bool _isBusy = false;

  ConnectorChallengeItem? get currentChallenge => _currentChallenge;

  List<String> get options => _options;

  bool? get isCorrect => _isCorrect;

  String? get feedbackExplanation => _feedbackExplanation;

  bool get isBusy => _isBusy;

  Future<void> nextChallenge() async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      if (_challenges.isEmpty) {
        _challenges = await _repository.getChallenges(type: typeFilter);
      }
      if (_challenges.isEmpty) {
        _currentChallenge = null;
        _options = const <String>[];
        _isCorrect = null;
        _feedbackExplanation =
            'لا توجد تحديات متاحة لهذا النوع حالياً.';
        return;
      }

      _currentIndex = (_currentIndex + 1) % _challenges.length;
      _currentChallenge = _challenges[_currentIndex];
      _options = _buildConnectorOptions(
        _currentChallenge!.targetConnector,
      );
      _isCorrect = null;
      _feedbackExplanation = null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> submitConnector(
    String connector,
    String verbPosition,
  ) async {
    if (_isBusy) return;
    final challenge = _currentChallenge;
    if (challenge == null) return;

    final submittedConnector = connector.trim().toLowerCase();
    final submittedPosition = verbPosition.trim().toLowerCase();
    final expectedPosition = _expectedVerbPosition(challenge.type);
    final connectorCorrect =
        submittedConnector == challenge.targetConnector.toLowerCase();
    final positionCorrect = submittedPosition == expectedPosition;

    _isBusy = true;
    notifyListeners();
    try {
      final candidate = challenge.correctCombinedSentence.replaceFirst(
        challenge.targetConnector,
        submittedConnector,
      );
      final repositoryValid = await _repository.validateConnection(
        challenge.id,
        candidate,
      );

      _isCorrect =
          connectorCorrect && positionCorrect && repositoryValid;
      _feedbackExplanation = _buildFeedback(
        challenge: challenge,
        connectorCorrect: connectorCorrect,
        positionCorrect: positionCorrect,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  static String expectedVerbPositionFor(ConjunctionType type) =>
      _expectedVerbPosition(type);

  static String _expectedVerbPosition(ConjunctionType type) {
    return switch (type) {
      ConjunctionType.positionZero => verbSecondPosition,
      ConjunctionType.verbKicker => verbFinalPosition,
      ConjunctionType.adverbialConnector =>
        inversionVerbSecondPosition,
    };
  }

  List<String> _buildConnectorOptions(String target) {
    final normalizedTarget = target.trim().toLowerCase();
    final values = <String>[normalizedTarget];
    for (final connector in _connectorPool) {
      if (connector == normalizedTarget) continue;
      values.add(connector);
      if (values.length == 4) break;
    }

    final shift = normalizedTarget.codeUnits.fold<int>(
          0,
          (sum, value) => sum + value,
        ) %
        values.length;
    return List<String>.unmodifiable(
      <String>[
        ...values.skip(shift),
        ...values.take(shift),
      ],
    );
  }

  String _buildFeedback({
    required ConnectorChallengeItem challenge,
    required bool connectorCorrect,
    required bool positionCorrect,
  }) {
    if (connectorCorrect && positionCorrect) {
      return challenge.arabicVerbPositionExplanation;
    }

    if (!connectorCorrect && !positionCorrect) {
      return 'الأداة الصحيحة هي ${challenge.targetConnector}. '
          '${challenge.arabicVerbPositionExplanation}';
    }
    if (!connectorCorrect) {
      return 'اختيار موقع الفعل مناسب، لكن الأداة المستهدفة هنا هي '
          '${challenge.targetConnector}.';
    }
    return challenge.arabicVerbPositionExplanation;
  }
}
