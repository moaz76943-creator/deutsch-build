/// Stable, version-independent identity for one language.
///
/// Runtime source/user selection is deliberately not part of this value.
/// Equality is anchored to [languageId]; presentation/locale metadata may
/// evolve without changing the stable language identity used by consumers.
final class LanguageIdentity {
  final String languageId;
  final String displayName;
  final String primaryLocale;

  LanguageIdentity({
    required this.languageId,
    required this.displayName,
    required this.primaryLocale,
  }) {
    _requireNonEmpty(languageId, 'languageId');
    _requireNonEmpty(displayName, 'displayName');
    _requireNonEmpty(primaryLocale, 'primaryLocale');
  }

  Map<String, String> toMap() => <String, String>{
        'languageId': languageId,
        'displayName': displayName,
        'primaryLocale': primaryLocale,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanguageIdentity && other.languageId == languageId;

  @override
  int get hashCode => languageId.hashCode;

  static void _requireNonEmpty(String value, String field) {
    if (value.trim().isEmpty) {
      throw ArgumentError.value(value, field, 'must not be empty');
    }
  }
}
