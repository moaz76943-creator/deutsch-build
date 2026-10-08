// Directed Pair Intelligence Contract - Post-V1 Expansion
// Encapsulates direction-specific intelligence between language pairs (A->B != B->A)

class DirectedPairContract {
  final String sourceLanguage;
  final String targetLanguage;
  final bool isPairReady;
  final Map<String, dynamic> pairMetadata;

  const DirectedPairContract({
    required this.sourceLanguage,
    required this.targetLanguage,
    this.isPairReady = false,
    this.pairMetadata = const {},
  });

  String get pairKey => '$sourceLanguage->$targetLanguage';
}
