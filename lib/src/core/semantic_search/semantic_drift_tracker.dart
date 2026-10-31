/// Type of semantic evolutionary shift.
enum DriftType {
  amelioration, // Meaning became more positive
  pejoration, // Meaning became more negative
  broadening, // Meaning generalized to wider domain
  narrowing, // Meaning specialized
  slangColloquialShift, // Shifted from formal to contemporary slang
}

/// Historical and contemporary semantic profile for a shifting word.
class SemanticDriftRecord {
  final String word;
  final String archaicMeaning;
  final String contemporaryMeaning;
  final DriftType driftType;
  final String registerGuidance;

  const SemanticDriftRecord({
    required this.word,
    required this.archaicMeaning,
    required this.contemporaryMeaning,
    required this.driftType,
    required this.registerGuidance,
  });
}

/// Tracks diachronic shifts to prevent learners from applying outdated or inappropriate senses.
class SemanticDriftTracker {
  static const Map<String, SemanticDriftRecord> _records = {
    'toll': SemanticDriftRecord(
      word: 'toll',
      archaicMeaning: 'Mad, crazy, frantic (historical root in tollwütig / rabies).',
      contemporaryMeaning: 'Great, fantastic, wonderful.',
      driftType: DriftType.amelioration,
      registerGuidance: 'Safe for all modern casual and professional positive praise.',
    ),
    'geil': SemanticDriftRecord(
      word: 'geil',
      archaicMeaning: 'Luxuriant, lush, over-fertile vegetation.',
      contemporaryMeaning: 'Extremely cool / awesome (slang), or sexually aroused.',
      driftType: DriftType.slangColloquialShift,
      registerGuidance: 'Use only among close friends; strictly avoid in professional/formal environments.',
    ),
    'furchtbar': SemanticDriftRecord(
      word: 'furchtbar',
      archaicMeaning: 'Causing dread and awe-inspiring terror.',
      contemporaryMeaning: 'Terrible / awful, or used as an intensifier (furchtbar nett = terribly nice).',
      driftType: DriftType.broadening,
      registerGuidance: 'Commonly used in daily colloquial speech as a modifier.',
    ),
  };

  /// Checks if a word has undergone significant semantic drift.
  SemanticDriftRecord? auditDrift(String word) {
    return _records[word.trim().toLowerCase()];
  }

  /// Evaluates safety of using a drifting word in a specific target formality.
  bool isAppropriateForRegister(String word, {required bool isFormalContext}) {
    final record = auditDrift(word);
    if (record == null) return true;
    if (isFormalContext && record.driftType == DriftType.slangColloquialShift) {
      return false;
    }
    return true;
  }
}
