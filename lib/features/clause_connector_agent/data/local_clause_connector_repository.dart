import '../domain/clause_connector_models.dart';
import '../domain/clause_connector_repository.dart';

final class LocalClauseConnectorRepository
    implements ClauseConnectorRepository {
  static const List<ConnectorChallengeItem> _challengeBank =
      <ConnectorChallengeItem>[
    ConnectorChallengeItem(
      id: 'weil_krank',
      firstSentence: 'Ich bleibe zu Hause.',
      secondSentence: 'Ich bin krank.',
      targetConnector: 'weil',
      correctCombinedSentence:
          'Ich bleibe zu Hause, weil ich krank bin.',
      type: ConjunctionType.verbKicker,
      arabicVerbPositionExplanation:
          'weil أداة جملة فرعية؛ الفعل المصرف bin ينتقل إلى نهاية الجملة الفرعية.',
    ),
    ConnectorChallengeItem(
      id: 'denn_krank',
      firstSentence: 'Ich bleibe zu Hause.',
      secondSentence: 'Ich bin krank.',
      targetConnector: 'denn',
      correctCombinedSentence:
          'Ich bleibe zu Hause, denn ich bin krank.',
      type: ConjunctionType.positionZero,
      arabicVerbPositionExplanation:
          'denn تأتي في Position 0 ولا تغيّر ترتيب الجملة الرئيسية؛ الفعل bin يبقى في الموضع الثاني.',
    ),
    ConnectorChallengeItem(
      id: 'obwohl_regen',
      firstSentence: 'Mia geht spazieren.',
      secondSentence: 'Es regnet heute stark.',
      targetConnector: 'obwohl',
      correctCombinedSentence:
          'Mia geht spazieren, obwohl es heute stark regnet.',
      type: ConjunctionType.verbKicker,
      arabicVerbPositionExplanation:
          'obwohl تفتح جملة فرعية؛ الفعل regnet يذهب إلى نهاية الجملة الفرعية.',
    ),
    ConnectorChallengeItem(
      id: 'dass_zeit',
      firstSentence: 'Ich weiß.',
      secondSentence: 'Du hast heute Zeit.',
      targetConnector: 'dass',
      correctCombinedSentence:
          'Ich weiß, dass du heute Zeit hast.',
      type: ConjunctionType.verbKicker,
      arabicVerbPositionExplanation:
          'dass أداة جملة فرعية؛ الفعل المصرف hast يأتي في نهاية الجملة التابعة.',
    ),
    ConnectorChallengeItem(
      id: 'weil_modal',
      firstSentence: 'Ich gehe früh schlafen.',
      secondSentence: 'Ich muss morgen arbeiten.',
      targetConnector: 'weil',
      correctCombinedSentence:
          'Ich gehe früh schlafen, weil ich morgen arbeiten muss.',
      type: ConjunctionType.verbKicker,
      arabicVerbPositionExplanation:
          'مع weil ينتقل الفعل المصرف muss إلى النهاية بعد المصدر arbeiten: arbeiten muss.',
    ),
    ConnectorChallengeItem(
      id: 'denn_modal',
      firstSentence: 'Ich gehe früh schlafen.',
      secondSentence: 'Ich muss morgen arbeiten.',
      targetConnector: 'denn',
      correctCombinedSentence:
          'Ich gehe früh schlafen, denn ich muss morgen arbeiten.',
      type: ConjunctionType.positionZero,
      arabicVerbPositionExplanation:
          'مع denn تبقى الجملة مستقلة نحويًا؛ الفعل muss يبقى في الموضع الثاني، وبعده بقية الجملة.',
    ),
    ConnectorChallengeItem(
      id: 'deshalb_mued',
      firstSentence: 'Ich bin müde.',
      secondSentence: 'Ich gehe früh ins Bett.',
      targetConnector: 'deshalb',
      correctCombinedSentence:
          'Ich bin müde. Deshalb gehe ich früh ins Bett.',
      type: ConjunctionType.adverbialConnector,
      arabicVerbPositionExplanation:
          'deshalb ظرف رابط يحتل الموضع الأول؛ لذلك يأتي الفعل gehe مباشرة بعده في الموضع الثاني ثم الفاعل ich.',
    ),
    ConnectorChallengeItem(
      id: 'trotzdem_regen',
      firstSentence: 'Es regnet stark.',
      secondSentence: 'Wir gehen spazieren.',
      targetConnector: 'trotzdem',
      correctCombinedSentence:
          'Es regnet stark. Trotzdem gehen wir spazieren.',
      type: ConjunctionType.adverbialConnector,
      arabicVerbPositionExplanation:
          'trotzdem ظرف رابط في الموضع الأول؛ الفعل gehen يأتي بعده مباشرة، ثم الفاعل wir.',
    ),
  ];

  @override
  Future<List<ConnectorChallengeItem>> getChallenges({
    ConjunctionType? type,
  }) async {
    final filtered = type == null
        ? _challengeBank
        : _challengeBank.where((item) => item.type == type);
    return List<ConnectorChallengeItem>.unmodifiable(filtered);
  }

  @override
  Future<bool> validateConnection(
    String challengeId,
    String constructedClause,
  ) async {
    final normalizedId = challengeId.trim();
    ConnectorChallengeItem? challenge;
    for (final item in _challengeBank) {
      if (item.id == normalizedId) {
        challenge = item;
        break;
      }
    }
    if (challenge == null) return false;

    return _normalizeClause(constructedClause) ==
        _normalizeClause(challenge.correctCombinedSentence);
  }

  static String _normalizeClause(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\s*,\s*'), ', ')
        .replaceAll(RegExp(r'\s+([;:])\s*'), r'$1 ')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .trim();
  }
}
