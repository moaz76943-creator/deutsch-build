/// CEFR competency domain according to Council of Europe.
enum CefrDomain { reception, production, interaction, mediation }

/// CEFR Can-Do statement definition.
class CefrCanDoStatement {
  final String code;
  final String cefrLevel; // A1, A2, B1, B2, C1, C2
  final CefrDomain domain;
  final String descriptor;
  final int requiredLexicalBreadth;

  const CefrCanDoStatement({
    required this.code,
    required this.cefrLevel,
    required this.domain,
    required this.descriptor,
    required this.requiredLexicalBreadth,
  });
}

/// Evaluates communicative readiness against official CEFR functional benchmarks.
class CefrMilestoneEvaluator {
  static const List<CefrCanDoStatement> _milestones = [
    CefrCanDoStatement(
      code: 'A1_INT_01',
      cefrLevel: 'A1',
      domain: CefrDomain.interaction,
      descriptor: 'Can interact in a simple way provided the other person is prepared to repeat or rephrase.',
      requiredLexicalBreadth: 400,
    ),
    CefrCanDoStatement(
      code: 'A2_PROD_01',
      cefrLevel: 'A2',
      domain: CefrDomain.production,
      descriptor: 'Can use a series of phrases and sentences to describe in simple terms family, living conditions, and educational background.',
      requiredLexicalBreadth: 1200,
    ),
    CefrCanDoStatement(
      code: 'B1_MED_01',
      cefrLevel: 'B1',
      domain: CefrDomain.mediation,
      descriptor: 'Can convey information given in clear texts on familiar matters of everyday life.',
      requiredLexicalBreadth: 2500,
    ),
    CefrCanDoStatement(
      code: 'B2_INT_01',
      cefrLevel: 'B2',
      domain: CefrDomain.interaction,
      descriptor: 'Can interact with a degree of fluency and spontaneity that makes regular interaction with native speakers quite possible.',
      requiredLexicalBreadth: 4500,
    ),
  ];

  /// Audits whether learner stats meet requirements for a specific Can-Do milestone.
  Map<String, dynamic> evaluateReadiness({
    required String milestoneCode,
    required int activeVocabularySize,
    required double communicativeAccuracy,
  }) {
    final milestone = _milestones.firstWhere(
      (m) => m.code == milestoneCode,
      orElse: () => throw ArgumentError('Unknown milestone code: $milestoneCode'),
    );

    final vocabRatio = (activeVocabularySize / milestone.requiredLexicalBreadth).clamp(0.0, 1.0);
    final isCertified = vocabRatio >= 0.90 && communicativeAccuracy >= 0.75;

    return {
      'code': milestone.code,
      'cefrLevel': milestone.cefrLevel,
      'domain': milestone.domain.name,
      'isCertified': isCertified,
      'vocabularyFulfillment': double.parse((vocabRatio * 100).toStringAsFixed(1)),
      'accuracyScore': communicativeAccuracy,
      'descriptor': milestone.descriptor,
    };
  }
}
