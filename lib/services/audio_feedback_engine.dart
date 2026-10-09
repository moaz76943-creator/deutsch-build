class AudioFeedbackEngine {
  static double getPitchForArticle(String article) {
    switch (article.toLowerCase().trim()) {
      case 'der':
        return 0.9; // طبقة نبرة أعمق للمذكر
      case 'die':
        return 1.15; // طبقة نبرة أعلى للمؤنث
      case 'das':
      default:
        return 1.0; // نبرة قياسية
    }
  }

  static double getRecommendedSpeed({required bool isSlowMode}) {
    return isSlowMode ? 0.75 : 1.0;
  }
}
