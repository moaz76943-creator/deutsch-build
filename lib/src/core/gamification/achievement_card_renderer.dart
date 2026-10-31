class AchievementBadgePayload {
  final String learnerHandle;
  final String targetLanguage;
  final String cefrLevel;
  final int streakDays;
  final int masteredWordsCount;
  final double retentionRate;
  final String achievementTitle;

  const AchievementBadgePayload({
    required this.learnerHandle,
    required this.targetLanguage,
    required this.cefrLevel,
    required this.streakDays,
    required this.masteredWordsCount,
    required this.retentionRate,
    required this.achievementTitle,
  });
}

class AchievementCardRenderer {
  const AchievementCardRenderer();

  /// Renders a high-resolution, shareable SVG card (1200x630 social standard).
  String renderSvgCard(AchievementBadgePayload payload) {
    final retentionPercent = (payload.retentionRate * 100).toStringAsFixed(1);
    final escapedHandle = _xmlEscape(payload.learnerHandle);
    final escapedTitle = _xmlEscape(payload.achievementTitle);

    return '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 630" width="1200" height="630">
  <defs>
    <linearGradient id="bgGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0a0c10"/>
      <stop offset="50%" stop-color="#12161f"/>
      <stop offset="100%" stop-color="#05070a"/>
    </linearGradient>
    <linearGradient id="goldGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#f6d365"/>
      <stop offset="100%" stop-color="#fda085"/>
    </linearGradient>
    <linearGradient id="cyanGrad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#00f2fe"/>
      <stop offset="100%" stop-color="#4facfe"/>
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="blur"/>
      <feComposite in="SourceGraphic" in2="blur" operator="over"/>
    </filter>
  </defs>

  <!-- Background Surface -->
  <rect width="1200" height="630" fill="url(#bgGrad)" rx="24"/>
  <rect x="2" y="2" width="1196" height="626" fill="none" stroke="#252a36" stroke-width="2" rx="22"/>

  <!-- Brand Top Header -->
  <text x="60" y="80" fill="#4facfe" font-family="system-ui, -apple-system, sans-serif" font-size="24" font-weight="800" letter-spacing="2">POLYGLOT SOVEREIGN</text>
  <text x="60" y="115" fill="#8892b0" font-family="system-ui, -apple-system, sans-serif" font-size="16">100-Language Sovereign Core • Zero Telemetry</text>

  <!-- Main Achievement Trophy Title -->
  <text x="60" y="210" fill="url(#goldGrad)" font-family="system-ui, -apple-system, sans-serif" font-size="44" font-weight="900">$escapedTitle</text>
  <text x="60" y="260" fill="#ffffff" font-family="system-ui, -apple-system, sans-serif" font-size="28" font-weight="600">Learner: @$escapedHandle</text>

  <!-- Metrics Grid -->
  <!-- Box 1: CEFR Level -->
  <rect x="60" y="320" width="240" height="180" fill="#141822" rx="16" stroke="#252a36" stroke-width="1.5"/>
  <text x="90" y="370" fill="#8892b0" font-family="system-ui, -apple-system, sans-serif" font-size="18">CEFR Mastery</text>
  <text x="90" y="450" fill="url(#cyanGrad)" font-family="system-ui, -apple-system, sans-serif" font-size="64" font-weight="900">${payload.cefrLevel}</text>

  <!-- Box 2: Streak Days -->
  <rect x="330" y="320" width="240" height="180" fill="#141822" rx="16" stroke="#252a36" stroke-width="1.5"/>
  <text x="360" y="370" fill="#8892b0" font-family="system-ui, -apple-system, sans-serif" font-size="18">Streak Flame</text>
  <text x="360" y="450" fill="url(#goldGrad)" font-family="system-ui, -apple-system, sans-serif" font-size="64" font-weight="900">${payload.streakDays}🔥</text>

  <!-- Box 3: Words Mastered -->
  <rect x="600" y="320" width="260" height="180" fill="#141822" rx="16" stroke="#252a36" stroke-width="1.5"/>
  <text x="630" y="370" fill="#8892b0" font-family="system-ui, -apple-system, sans-serif" font-size="18">Mastered Lexicon</text>
  <text x="630" y="450" fill="#ffffff" font-family="system-ui, -apple-system, sans-serif" font-size="54" font-weight="900">${payload.masteredWordsCount}</text>

  <!-- Box 4: Retention Rate -->
  <rect x="890" y="320" width="250" height="180" fill="#141822" rx="16" stroke="#252a36" stroke-width="1.5"/>
  <text x="920" y="370" fill="#8892b0" font-family="system-ui, -apple-system, sans-serif" font-size="18">FSRS Retention</text>
  <text x="920" y="450" fill="#2ed573" font-family="system-ui, -apple-system, sans-serif" font-size="54" font-weight="900">$retentionPercent%</text>

  <!-- Bottom Verification Footer -->
  <text x="60" y="565" fill="#57606f" font-family="system-ui, -apple-system, sans-serif" font-size="16">Target Language: ${payload.targetLanguage.toUpperCase()} • Authenticated via Local Merkle Tree</text>
</svg>''';
  }

  String _xmlEscape(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
