class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  }) : assert(sourceLocale != '', 'sourceLocale must not be empty'),
       assert(targetLocale != '', 'targetLocale must not be empty'),
       assert(semanticVersion != '', 'semanticVersion must not be empty');

  factory DirectedPairId.forLearning({
    required String sourceLocale,
    required String targetLocale,
    required String semanticVersion,
  }) {
    if (sourceLocale == targetLocale) {
      throw ArgumentError('sourceLocale and targetLocale must be distinct for learning pairs');
    }
    return DirectedPairId(
      sourceLocale: sourceLocale,
      targetLocale: targetLocale,
      semanticVersion: semanticVersion,
    );
  }

  factory DirectedPairId.parse(String legacyId) {
    final parts = legacyId.split('_');
    if (parts.length < 3) {
      throw FormatException('Invalid legacy DirectedPairId string: $legacyId');
    }
    // E.g. en_de_1.0.0
    // If semantic version has underscores, they would be split.
    // Usually it's locale_locale_version, so the first two are locales, the rest is version.
    final sourceLocale = parts[0];
    final targetLocale = parts[1];
    final semanticVersion = parts.skip(2).join('_');

    return DirectedPairId(
      sourceLocale: sourceLocale,
      targetLocale: targetLocale,
      semanticVersion: semanticVersion,
    );
  }

  factory DirectedPairId.fromMap(Map<String, dynamic> map) {
    return DirectedPairId(
      sourceLocale: map['sourceLocale'] as String,
      targetLocale: map['targetLocale'] as String,
      semanticVersion: map['semanticVersion'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sourceLocale': sourceLocale,
      'targetLocale': targetLocale,
      'semanticVersion': semanticVersion,
    };
  }

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';
  bool get isReflexive => sourceLocale == targetLocale;
  bool isValidForLearning() => !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DirectedPairId &&
        other.sourceLocale == sourceLocale &&
        other.targetLocale == targetLocale &&
        other.semanticVersion == semanticVersion;
  }

  @override
  int get hashCode => Object.hash(sourceLocale, targetLocale, semanticVersion);
}
