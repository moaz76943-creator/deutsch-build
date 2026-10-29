class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  })  : assert(sourceLocale != '', 'sourceLocale cannot be empty'),
        assert(targetLocale != '', 'targetLocale cannot be empty'),
        assert(semanticVersion != '', 'semanticVersion cannot be empty');

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';

  bool get isReflexive => sourceLocale == targetLocale;
<<<<<<< HEAD

  bool isValidForLearning() =>
      !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty;

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

  String serialize() => uniqueKey;

  static DirectedPairId parse(String serialized) {
    if (serialized.isEmpty) {
      throw const FormatException(
          'Cannot parse empty string into DirectedPairId');
    }
    final parts = serialized.split('_');
    if (parts.length == 3) {
      final source = parts[0];
      final target = parts[1];
      final version = parts[2];
      if (source.isEmpty || target.isEmpty || version.isEmpty) {
        throw FormatException(
            'Invalid DirectedPairId format: empty components in $serialized');
      }
      return DirectedPairId(
        sourceLocale: source,
        targetLocale: target,
        semanticVersion: version,
      );
    } else if (parts.length == 2) {
      // Legacy migration path
      final source = parts[0];
      final target = parts[1];
      if (source.isEmpty || target.isEmpty) {
        throw FormatException(
            'Invalid legacy DirectedPairId format: empty components in $serialized');
      }
      return DirectedPairId(
        sourceLocale: source,
        targetLocale: target,
        semanticVersion: '1.0.0', // Default legacy version
      );
    } else {
      throw FormatException('Invalid DirectedPairId format: $serialized');
    }
  }
=======
  bool isValidForLearning() => !isReflexive && sourceLocale.isNotEmpty && targetLocale.isNotEmpty;
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
}
