enum ReviewFacetType {
  meaningRecall,
  gender,
  plural,
  caseForm,
  spelling,
  listening,
  pronunciation,
  verbValency,
  prepositionCase,
  separablePrefix,
  auxiliary,
  collocation,
  production,
  unknown;

  String get wireName => switch (this) {
        ReviewFacetType.meaningRecall => 'meaning_recall',
        ReviewFacetType.caseForm => 'case_form',
        ReviewFacetType.verbValency => 'verb_valency',
        ReviewFacetType.prepositionCase => 'preposition_case',
        ReviewFacetType.separablePrefix => 'separable_prefix',
        _ => name,
      };

  static ReviewFacetType fromWire(String? raw) {
    final value = raw?.trim().toLowerCase();
    if (value == null || value.isEmpty) {
      return ReviewFacetType.meaningRecall;
    }
    for (final facet in ReviewFacetType.values) {
      if (facet != ReviewFacetType.unknown && facet.wireName == value) {
        return facet;
      }
    }
    return ReviewFacetType.unknown;
  }
}

final class ReviewFacetKey {
  const ReviewFacetKey({
    required this.conceptId,
    this.facetType = ReviewFacetType.meaningRecall,
    this.variantKey,
  });

  static const String _prefix = '@facet::';

  final String conceptId;
  final ReviewFacetType facetType;
  final String? variantKey;

  String? get normalizedVariantKey => normalizeVariant(variantKey);

  bool get isValid {
    final id = conceptId.trim();
    final variant = normalizedVariantKey;
    return id.isNotEmpty &&
        id.length <= 160 &&
        facetType != ReviewFacetType.unknown &&
        (variant == null || variant.length <= 80);
  }

  bool get isLegacyMeaningKey =>
      facetType == ReviewFacetType.meaningRecall &&
      normalizedVariantKey == null;

  String get storageKey {
    final id = conceptId.trim();
    if (facetType == ReviewFacetType.meaningRecall &&
        normalizedVariantKey == null) {
      return id;
    }
    return '$_prefix'
        '${Uri.encodeComponent(id)}::'
        '${facetType.wireName}::'
        '${Uri.encodeComponent(normalizedVariantKey ?? '')}';
  }

  static ReviewFacetKey fromStorageKey(String raw) {
    final value = raw.trim();
    if (!value.startsWith(_prefix)) {
      return ReviewFacetKey(conceptId: value);
    }

    final payload = value.substring(_prefix.length);
    final parts = payload.split('::');
    if (parts.length != 3) {
      return const ReviewFacetKey(
        conceptId: '',
        facetType: ReviewFacetType.unknown,
      );
    }

    try {
      return ReviewFacetKey(
        conceptId: Uri.decodeComponent(parts[0]),
        facetType: ReviewFacetType.fromWire(parts[1]),
        variantKey: normalizeVariant(Uri.decodeComponent(parts[2])),
      );
    } on FormatException {
      return const ReviewFacetKey(
        conceptId: '',
        facetType: ReviewFacetType.unknown,
      );
    }
  }

  static String? normalizeVariant(String? raw) {
    final value = raw?.trim();
    return value == null || value.isEmpty ? null : value;
  }
}
