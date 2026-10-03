/// Stable learner-addressable content coordinate.
///
/// This key is deliberately independent from semantic identity. The same
/// semantic concept in two languages does not automatically share learner
/// progress, and equal local IDs in different language/namespace coordinates
/// remain distinct.
final class LearnerContentKey {
  static const String legacyGermanNamespace = 'legacy-german-canonical';

  final String languageId;
  final String contentNamespaceId;
  final String localItemId;

  LearnerContentKey({
    required this.languageId,
    required this.contentNamespaceId,
    required this.localItemId,
  }) {
    _requireNonEmpty(languageId, 'languageId');
    _requireNonEmpty(contentNamespaceId, 'contentNamespaceId');
    _requireNonEmpty(localItemId, 'localItemId');
  }

  factory LearnerContentKey.germanLegacy(String localItemId) =>
      LearnerContentKey(
        languageId: 'de',
        contentNamespaceId: legacyGermanNamespace,
        localItemId: localItemId,
      );

  Map<String, String> toMap() => <String, String>{
        'languageId': languageId,
        'contentNamespaceId': contentNamespaceId,
        'localItemId': localItemId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearnerContentKey &&
          other.languageId == languageId &&
          other.contentNamespaceId == contentNamespaceId &&
          other.localItemId == localItemId;

  @override
  int get hashCode => Object.hash(languageId, contentNamespaceId, localItemId);

  @override
  String toString() => '$languageId/$contentNamespaceId/$localItemId';
}

void _requireNonEmpty(String value, String field) {
  if (value.trim().isEmpty) {
    throw ArgumentError.value(value, field, 'must not be empty');
  }
}
