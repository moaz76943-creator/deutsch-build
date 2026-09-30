class AudioPathResolver {
  static const String _baseAssetPath = 'assets/audio';

  /// Resolves the local asset path for a given concept ID and language code.
  ///
  /// Returns null if the conceptId or languageCode is null or empty, allowing
  /// for graceful fallback without application crashes.
  ///
  /// It sanitizes the conceptId to prevent irregular characters or directory
  /// traversal issues.
  String? resolvePath(String? conceptId, String? languageCode) {
    if (conceptId == null || conceptId.trim().isEmpty) return null;
    if (languageCode == null || languageCode.trim().isEmpty) return null;

    final sanitizedConceptId = _sanitize(conceptId);
    if (sanitizedConceptId.isEmpty) return null;

    final sanitizedLanguageCode = _sanitize(languageCode);
    if (sanitizedLanguageCode.isEmpty) return null;

    return '$_baseAssetPath/$sanitizedLanguageCode/$sanitizedConceptId.mp3';
  }

  /// Sanitizes input strings by removing path traversal characters
  /// and potentially harmful irregular characters.
  String _sanitize(String input) {
    // Basic sanitization: allow only alphanumeric characters, dashes, and underscores.
    // Replace anything else with an empty string.
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '').toLowerCase();
  }
}
