class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  static final RegExp _localeRegex = RegExp(r'^[a-z]{2,3}(_[A-Z]{2})?$');
  static final RegExp _versionRegex = RegExp(r'^\d+\.\d+\.\d+$');

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  })  : assert(sourceLocale != '', 'sourceLocale cannot be empty'),
        assert(targetLocale != '', 'targetLocale cannot be empty'),
        assert(semanticVersion != '', 'semanticVersion cannot be empty');

  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';

  bool get isReflexive => sourceLocale == targetLocale;

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

  static DirectedPairId fromString(String serialized) {
    if (serialized.isEmpty) {
      throw const FormatException(
          'Cannot parse empty string into DirectedPairId');
    }

    // Attempt to split. Since locales might contain underscores (e.g. en_US),
    // and semanticVersion does not contain underscores, we can parse safely.
    // Legacy migration: source_target (e.g. ar_fr)
    // New format: source_target_version (e.g. ar_fr_1.0.0, or en_US_es_ES_1.0.0)

    String source;
    String target;
    String version;

    final parts = serialized.split('_');

    // Check if the last part is a semantic version
    if (parts.length >= 3 && _versionRegex.hasMatch(parts.last)) {
      version = parts.last;

      // Now we have the remaining parts for locales.
      final remaining = parts.sublist(0, parts.length - 1);
      if (remaining.length == 2) {
        source = remaining[0];
        target = remaining[1];
      } else if (remaining.length == 3) {
        // e.g. en_US and es, or en and es_ES
        // we can test which one matches the regex
        if (_localeRegex.hasMatch('${remaining[0]}_${remaining[1]}') &&
            _localeRegex.hasMatch(remaining[2])) {
          source = '${remaining[0]}_${remaining[1]}';
          target = remaining[2];
        } else if (_localeRegex.hasMatch(remaining[0]) &&
            _localeRegex.hasMatch('${remaining[1]}_${remaining[2]}')) {
          source = remaining[0];
          target = '${remaining[1]}_${remaining[2]}';
        } else {
          throw FormatException(
              'Invalid locales in DirectedPairId: $serialized');
        }
      } else if (remaining.length == 4) {
        source = '${remaining[0]}_${remaining[1]}';
        target = '${remaining[2]}_${remaining[3]}';
      } else {
        throw FormatException('Invalid DirectedPairId format: $serialized');
      }
    } else if (parts.length == 2) {
      // Legacy migration path
      source = parts[0];
      target = parts[1];
      version = '1.0.0'; // Default legacy version
    } else {
      throw FormatException('Invalid DirectedPairId format: $serialized');
    }

    if (source.isEmpty || target.isEmpty || version.isEmpty) {
      throw FormatException(
          'Invalid DirectedPairId format: empty components in $serialized');
    }

    if (!_localeRegex.hasMatch(source)) {
      throw FormatException('Invalid source locale: $source');
    }
    if (!_localeRegex.hasMatch(target)) {
      throw FormatException('Invalid target locale: $target');
    }
    if (!_versionRegex.hasMatch(version)) {
      throw FormatException('Invalid semantic version: $version');
    }

    return DirectedPairId(
      sourceLocale: source,
      targetLocale: target,
      semanticVersion: version,
    );
  }
}
