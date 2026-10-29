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
  bool isValidForLearning() => !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty && semanticVersion.isNotEmpty;

  factory DirectedPairId.fromJson(Map<String, dynamic> json) {
    return DirectedPairId(
      sourceLocale: json['sourceLocale'] as String,
      targetLocale: json['targetLocale'] as String,
      semanticVersion: json['semanticVersion'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceLocale': sourceLocale,
      'targetLocale': targetLocale,
      'semanticVersion': semanticVersion,
    };
  }

  factory DirectedPairId.fromLegacyString(String value) {
    final parts = value.split('_');
    if (parts.length >= 3) {
      return DirectedPairId(
        sourceLocale: parts[0],
        targetLocale: parts[1],
        semanticVersion: parts.sublist(2).join('_'),
      );
    } else if (parts.length == 2) {
      return DirectedPairId(
        sourceLocale: parts[0],
        targetLocale: parts[1],
        semanticVersion: '1.0.0', // default version if missing
      );
    } else {
      throw FormatException('Invalid legacy DirectedPairId string: $value');
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectedPairId &&
          runtimeType == other.runtimeType &&
          sourceLocale == other.sourceLocale &&
          targetLocale == other.targetLocale &&
          semanticVersion == other.semanticVersion;

  @override
  int get hashCode => Object.hash(sourceLocale, targetLocale, semanticVersion);

  @override
  String toString() => uniqueKey;
}
