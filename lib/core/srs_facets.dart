// SRS Facets and Review Key Definitions
enum ReviewFacetType {
  meaningRecall,
  recognition,
  production,
  listening,
  spelling,
  grammar,
  collocation,
  gender,
  plural,
  caseForm,
  verbValency,
  prepositionCase,
  separablePrefix,
  auxiliary,
  pronunciation,
  unknown;

  String get wireName => switch (this) {
        ReviewFacetType.caseForm => 'case_form',
        ReviewFacetType.verbValency => 'verb_valency',
        ReviewFacetType.prepositionCase => 'preposition_case',
        ReviewFacetType.separablePrefix => 'separable_prefix',
        _ => name,
      };

  static ReviewFacetType fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ReviewFacetType.meaningRecall;
    for (final v in ReviewFacetType.values) {
      if (v.name.toLowerCase() ==
              wire.trim().replaceAll('_', '').toLowerCase() ||
          v.wireName.toLowerCase() == wire.trim().toLowerCase()) {
        return v;
      }
    }
    return ReviewFacetType.unknown;
  }
}

class ReviewFacetKey {
  final String conceptId;
  final String variantKey;
  final ReviewFacetType facetType;
  final String contentId;
  final String? _storedKey;

  const ReviewFacetKey({
    String? conceptId,
    String? variantKey,
    String? contentId,
    ReviewFacetType? facetType,
  })  : conceptId = conceptId ?? '',
        variantKey = variantKey ?? '',
        contentId = contentId ?? '',
        facetType = facetType ?? ReviewFacetType.meaningRecall,
        _storedKey = null;

  const ReviewFacetKey._stored(
      {required this.conceptId,
      required this.variantKey,
      required this.facetType,
      required String storedKey})
      : contentId = '',
        _storedKey = storedKey;

  String get normalizedVariantKey => normalizeVariant(variantKey);

  String get storageKey {
    final stored = _storedKey;
    if (stored != null) return stored;
    final id = conceptId.isNotEmpty ? conceptId : contentId;
    final variant = variantKey.isNotEmpty ? ':$variantKey' : '';
    return '$id:${facetType.wireName}$variant';
  }

  bool get isValid =>
      facetType != ReviewFacetType.unknown &&
      (conceptId.isNotEmpty || contentId.isNotEmpty);

  /// Read old encoded keys and the current colon format without rewriting bytes.
  static ReviewFacetKey fromStorageKey(String raw) {
    ReviewFacetKey parsed(String id, ReviewFacetType facet, String variant) =>
        ReviewFacetKey._stored(
            conceptId: id,
            facetType: facet,
            variantKey: variant,
            storedKey: raw);
    if (raw.startsWith('@facet::')) {
      final parts = raw.substring(8).split('::');
      if (parts.length == 3) {
        try {
          return parsed(
              Uri.decodeComponent(parts[0]),
              ReviewFacetType.fromWire(parts[1]),
              Uri.decodeComponent(parts[2]));
        } on FormatException {
          /* Preserve malformed input as an invalid key. */
        } on ArgumentError {/* Invalid URL encoding is not a valid identity. */}
      }
      return parsed('', ReviewFacetType.unknown, '');
    }
    final parts = raw.split(':');
    if (parts.skip(1).any((part) => part == 'unknown')) {
      return parsed('', ReviewFacetType.unknown, '');
    }
    final markers = <int>[];
    for (var i = 1; i < parts.length; i++) {
      if (ReviewFacetType.fromWire(parts[i]) != ReviewFacetType.unknown &&
          parts[i].isNotEmpty) markers.add(i);
    }
    if (markers.length == 1) {
      final index = markers.single;
      return parsed(
          parts.take(index).join(':'),
          ReviewFacetType.fromWire(parts[index]),
          parts.skip(index + 1).join(':'));
    }
    if (markers.length > 1) return parsed('', ReviewFacetType.unknown, '');
    return parsed(raw, ReviewFacetType.meaningRecall, '');
  }

  bool get isLegacyMeaningKey =>
      facetType == ReviewFacetType.meaningRecall &&
      normalizedVariantKey.isEmpty;

  static String normalizeVariant([String? variant = '']) =>
      variant?.trim().toLowerCase() ?? '';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewFacetKey &&
          runtimeType == other.runtimeType &&
          conceptId == other.conceptId &&
          variantKey == other.variantKey &&
          facetType == other.facetType &&
          contentId == other.contentId;

  @override
  int get hashCode =>
      conceptId.hashCode ^
      variantKey.hashCode ^
      facetType.hashCode ^
      contentId.hashCode;

  @override
  String toString() => storageKey;
}
