class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  });

  /// Provides a controlled migration path for legacy string-based pair IDs.
  factory DirectedPairId.fromString(String legacyId, {String defaultVersion = '1.0.0'}) {
    final parts = legacyId.split('_');
    if (parts.length == 3) {
      return DirectedPairId(
        sourceLocale: parts[0],
        targetLocale: parts[1],
        semanticVersion: parts[2],
      );
    } else if (parts.length == 2) {
      return DirectedPairId(
        sourceLocale: parts[0],
        targetLocale: parts[1],
        semanticVersion: defaultVersion,
      );
    }
    return DirectedPairId(
      sourceLocale: 'unknown',
      targetLocale: 'unknown',
      semanticVersion: defaultVersion,
    );
  }

  factory DirectedPairId.fromJson(Map<String, dynamic> json) {
    return DirectedPairId(
      sourceLocale: json['sourceLocale'] as String? ?? 'unknown',
      targetLocale: json['targetLocale'] as String? ?? 'unknown',
      semanticVersion: json['semanticVersion'] as String? ?? '1.0.0',
    );
  }

  Map<String, dynamic> toJson() => {
        'sourceLocale': sourceLocale,
        'targetLocale': targetLocale,
        'semanticVersion': semanticVersion,
      };

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';

  bool get isReflexive => sourceLocale == targetLocale;

  bool isValidForLearning() =>
      !isReflexive && hasValidLocales;

  bool get hasValidLocales {
    final localeRegex = RegExp(r'^[a-z]{2,3}(_[A-Z]{2,3})?$');
    return localeRegex.hasMatch(sourceLocale) && localeRegex.hasMatch(targetLocale);
  }

  bool get hasValidVersion {
    final versionRegex = RegExp(r'^\d+\.\d+\.\d+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$');
    return versionRegex.hasMatch(semanticVersion);
  }

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
