class DirectedPairId {
  final String sourceLocale;
  final String targetLocale;
  final String semanticVersion;

  const DirectedPairId({
    required this.sourceLocale,
    required this.targetLocale,
    required this.semanticVersion,
  });

  // Keep the persisted legacy key shape. No migration of existing identities.
  String get uniqueKey => '${sourceLocale}_${targetLocale}_$semanticVersion';
  bool get isReflexive => sourceLocale == targetLocale;

  static final RegExp _localeSyntax =
      RegExp(r'^[a-z]{2,3}(?:-[A-Za-z0-9]{2,8})*$');

  /// Syntax alone does not establish canonical registration or content readiness.
  bool isValidForLearning() =>
      sourceLocale.length <= 64 &&
      targetLocale.length <= 64 &&
      semanticVersion.isNotEmpty &&
      semanticVersion.length <= 64 &&
      _localeSyntax.hasMatch(sourceLocale) &&
      _localeSyntax.hasMatch(targetLocale) &&
      semanticVersion.trim().isNotEmpty &&
      !semanticVersion.contains('_') &&
      !isReflexive;

  factory DirectedPairId.fromJson(Map<String, dynamic> json) {
    final source = json['sourceLocale'];
    final target = json['targetLocale'];
    final version = json['semanticVersion'];
    if (source is! String || target is! String || version is! String) {
      throw const FormatException('Invalid directed pair JSON');
    }
    final pair = DirectedPairId(
      sourceLocale: source, targetLocale: target, semanticVersion: version,
    );
    if (!pair.isValidForLearning()) {
      throw const FormatException('Invalid directed pair identity');
    }
    return pair;
  }

  Map<String, String> toJson() => <String, String>{
    'sourceLocale': sourceLocale,
    'targetLocale': targetLocale,
    'semanticVersion': semanticVersion,
  };

  /// An absent historical version must be supplied by a trusted migration.
  /// Underscored locale IDs are ambiguous; never guess their meaning.
  factory DirectedPairId.fromLegacyString(
    String value, {
    String? missingVersion,
  }) {
    final parts = value.split('_');
    if (parts.length != 3 && parts.length != 2) {
      throw const FormatException('Ambiguous legacy pair identifier');
    }
    final version = parts.length == 3 ? parts[2] : missingVersion;
    if (version == null) {
      throw const FormatException('Missing legacy semantic version');
    }
    return DirectedPairId.fromJson(<String, dynamic>{
      'sourceLocale': parts[0],
      'targetLocale': parts[1],
      'semanticVersion': version,
    });
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DirectedPairId &&
          sourceLocale == other.sourceLocale &&
          targetLocale == other.targetLocale &&
          semanticVersion == other.semanticVersion);

  @override
  int get hashCode => Object.hash(sourceLocale, targetLocale, semanticVersion);

  @override
  String toString() => uniqueKey;
}
