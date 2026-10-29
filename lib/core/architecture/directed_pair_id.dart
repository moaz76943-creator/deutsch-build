class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  });

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';
  bool get isReflexive => sourceLocale == targetLocale;
  bool isValidForLearning() => !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty;
}
