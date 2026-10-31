/// A phonetic indexing record matching a word with its IPA transcript and audio timestamp.
class PhoneticIndexRecord {
  final String lemma;
  final String ipaTranscription;
  final double audioStartSeconds;
  final double audioEndSeconds;
  final String primaryStressSyllable;

  const PhoneticIndexRecord({
    required this.lemma,
    required this.ipaTranscription,
    required this.audioStartSeconds,
    required this.audioEndSeconds,
    required this.primaryStressSyllable,
  });
}

/// Builds sub-millisecond phonetic lookups and IPA alignment anchors for offline audio packs.
class OfflinePhoneticIndexBuilder {
  final Map<String, PhoneticIndexRecord> _index = {};

  int get indexedCount => _index.length;

  /// Inserts a phonetic transcript mapping.
  void registerRecord(PhoneticIndexRecord record) {
    _index[record.lemma.toLowerCase()] = record;
  }

  /// Finds IPA transcript and audio timestamp offset for a target word.
  PhoneticIndexRecord? resolvePhonetics(String word) {
    return _index[word.trim().toLowerCase()];
  }
}
