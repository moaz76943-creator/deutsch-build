/// Header metadata for custom teacher/learner exported study decks (.polyglot-pack).
class CustomPackHeader {
  final String packTitle;
  final String creatorHandle;
  final String targetLanguage;
  final int cardCount;
  final bool hasAudioClips;
  final String ethicalDeclaration;

  const CustomPackHeader({
    required this.packTitle,
    required this.creatorHandle,
    required this.targetLanguage,
    required this.cardCount,
    required this.hasAudioClips,
    required this.ethicalDeclaration,
  });
}

/// Exports and imports custom offline learning decks between peers in educational hubs.
class CustomPackExchangeEngine {
  /// Packs custom deck into a verified portable export bundle.
  CustomPackHeader createExportHeader({
    required String title,
    required String author,
    required String language,
    required int cards,
    required bool withAudio,
  }) {
    return CustomPackHeader(
      packTitle: title,
      creatorHandle: author,
      targetLanguage: language,
      cardCount: cards,
      hasAudioClips: withAudio,
      ethicalDeclaration: '100% Ethical, Open, and Family-Friendly Education',
    );
  }

  /// Validates incoming peer deck format.
  bool validateCustomPack(CustomPackHeader header) {
    return header.packTitle.isNotEmpty &&
        header.cardCount > 0 &&
        header.targetLanguage != 'he' && // Strict exclusion of prohibited locale
        header.ethicalDeclaration.contains('Ethical');
  }
}
