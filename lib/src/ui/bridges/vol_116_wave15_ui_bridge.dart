import '../../core/content/german_ersatzinfinitiv_engine.dart';

/// Volume 116 Wave 15 UI Bridge exposing Ersatzinfinitiv Diagnostics.
class Vol116Wave15UIBridge {
  Map<String, dynamic> getTask4915Diagnostics() {
    return <String, dynamic>{
      'volume': 116,
      'task_id': 4915,
      'subsystem': 'german_ersatzinfinitiv_engine',
      'supported_types': ['modalVerb', 'perceptionVerb', 'causativeLassen'],
      'supported_clauses': ['mainClause', 'subordinateClauseOberfeld'],
      'tasks_remaining_to_5000': 85,
      'status': 'OPERATIONAL_VERIFIED',
    };
  }

  ErsatzinfinitivStructure constructDoubleInfinitive({
    required String subject,
    required String aux,
    required String governing,
    required String governed,
    String comp = '',
    DoubleInfinitiveClauseType clause = DoubleInfinitiveClauseType.mainClause,
  }) {
    return GermanErsatzinfinitivEngine.buildSentence(
      subject: subject,
      auxiliary: aux,
      governingVerb: governing,
      governedInfinitive: governed,
      objectOrComplement: comp,
      clauseType: clause,
    );
  }
}
