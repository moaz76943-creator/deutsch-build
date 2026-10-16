// SRS Facets and Review Key Definitions
enum ReviewFacetType {
  meaningRecall,
  recognition,
  production,
  listening,
  spelling,
  grammar,
  collocation;

  String get wireName => name;

  static ReviewFacetType fromWire(String? wire) {
    if (wire == null || wire.isEmpty) return ReviewFacetType.meaningRecall;
    for (final v in ReviewFacetType.values) {
      if (v.name.toLowerCase() == wire.toLowerCase() ||
          v.wireName.toLowerCase() == wire.toLowerCase()) {
        return v;
      }
    }
    return ReviewFacetType.meaningRecall;
  }
}

class ReviewFacetKey {
  final String conceptId;
  final String variantKey;
  final ReviewFacetType facetType;
  final String contentId;

  const ReviewFacetKey({
    String? conceptId,
    String? variantKey,
    String? contentId,
    ReviewFacetType? facetType,
  })  : conceptId = conceptId ?? '',
        variantKey = variantKey ?? '',
        contentId = contentId ?? '',
        facetType = facetType ?? ReviewFacetType.meaningRecall;

  String get storageKey {
    final id = conceptId.isNotEmpty ? conceptId : contentId;
    final variant = variantKey.isNotEmpty ? ':$variantKey' : '';
    return '$id:${facetType.wireName}$variant';
  }

  bool get isValid => conceptId.isNotEmpty || contentId.isNotEmpty;

  bool get isLegacyMeaningKey => facetType == ReviewFacetType.meaningRecall;

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
