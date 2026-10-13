/// A read-only local analytics facade. Never synthesize learning progress.
///
/// The runtime currently exposes only an in-memory review journal. Its values
/// are NOT durable committed SRS facts. Until the database owner wires an
/// atomic committed-event source, report an explicit empty/unknown result
/// rather than awarding badges or inventing mastered cards.
class LocalLearningAnalytics {
  static Future<Map<String, dynamic>> generate30DayReport() async {
    return {
      'mastered_cards': 0,
      'active_domains': 0,
      'learning_trend': 'insufficient_evidence',
      'consistency_score': 0,
    };
  }

  static Future<String?> checkNewBadge() async {
    return null;
  }
}
