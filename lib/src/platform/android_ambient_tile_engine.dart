/// Ambient lock-screen glanceable card content.
class AmbientGlanceCard {
  final String targetWord;
  final String partOfSpeech;
  final String contextualExampleSentence;
  final String nativeTranslation;
  final int dueCountToday;

  const AmbientGlanceCard({
    required this.targetWord,
    required this.partOfSpeech,
    required this.contextualExampleSentence,
    required this.nativeTranslation,
    required this.dueCountToday,
  });
}

/// Orchestrates Android Quick Settings Tile service and Glance lockscreen micro-widgets.
class AndroidAmbientTileEngine {
  bool _isTileActive = false;

  bool get isTileActive => _isTileActive;

  /// Toggles Android Quick Settings Tile state.
  void setTileActive(bool active) {
    _isTileActive = active;
  }

  /// Builds lightweight glanceable card payload for Android Always-On Display.
  AmbientGlanceCard buildGlanceCard({
    required String word,
    required String pos,
    required String example,
    required String translation,
    required int dueTotal,
  }) {
    return AmbientGlanceCard(
      targetWord: word,
      partOfSpeech: pos,
      contextualExampleSentence: example,
      nativeTranslation: translation,
      dueCountToday: dueTotal,
    );
  }

  /// Formats concise status label for Quick Settings Tile.
  String getTileSubtitle(int dueReviews) {
    if (dueReviews <= 0) return 'Alles erledigt! 🎉';
    return '$dueReviews Vokabeln fällig';
  }
}
