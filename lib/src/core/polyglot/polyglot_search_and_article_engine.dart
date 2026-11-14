import 'dart:collection';
import 'polyglot_unified_core.dart';

/// تصنيف أداة التعريف الألمانية مع التمييز البصري المريح لشاشات AMOLED
enum GermanArticleGender {
  masculine('der', 0xFF4DA6FF, 'مذكر'),
  feminine('die', 0xFFFF6B81, 'مؤنث'),
  neuter('das', 0xFF5CE6A0, 'محايد'),
  plural('die (Pl.)', 0xFFB88CFF, 'جمع'),
  none('—', 0xFFEDEDED, 'بدون أداة');

  final String article;
  final int amoledSafeHexColor;
  final String arabicLabel;
  const GermanArticleGender(this.article, this.amoledSafeHexColor, this.arabicLabel);
}

/// نتيجة بحث مرتبة بالصلة مع إبراز أداة التعريف إن وُجدت
class PolyglotSearchHit {
  final PolyglotLearningUnit unit;
  final double relevanceScore;
  final GermanArticleGender detectedGender;

  const PolyglotSearchHit({
    required this.unit,
    required this.relevanceScore,
    required this.detectedGender,
  });
}

/// محرك البحث السريع دون اتصال (Umlaut-Tolerant & Arabic-Diacritic-Normalized)
/// مصمم للعمل بسلاسة 144Hz على الهواتف دون أي استهلاك للشبكة.
class PolyglotOfflineSearchEngine {
  /// تطبيع النص الألماني والعربي لتجاهل الهمزات والتشكيل واختلافات Umlaut / ß
  static String normalizeForSearch(String raw) {
    var s = raw.trim().toLowerCase();
    // German Umlaut & Eszett normalization (handles both ae/a and ß/ss)
    s = s
        .replaceAll('ä', 'a')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ß', 'ss')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('ç', 'c')
        .replaceAll('ñ', 'n')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g')
        .replaceAll('ı', 'i');
    // Arabic Alef & Ta-Marbuta & Diacritics normalization
    s = s
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي');
    return s;
  }

  /// استنتاج أداة التعريف اللونية تلقائياً من التعبير المستهدف
  static GermanArticleGender detectGermanArticle(String expression) {
    final trimmed = expression.trim().toLowerCase();
    if (trimmed.startsWith('der ')) return GermanArticleGender.masculine;
    if (trimmed.startsWith('das ')) return GermanArticleGender.neuter;
    if (trimmed.startsWith('die ')) {
      if (trimmed.contains('(pl') || trimmed.endsWith('en') || trimmed.endsWith('er')) {
        return GermanArticleGender.plural;
      }
      return GermanArticleGender.feminine;
    }
    return GermanArticleGender.none;
  }

  /// بحث فوري مرتب حسب التطابق الدقيق والجزئي (O(N) خفيف جداً لأكثر من 5,000 وحدة)
  static List<PolyglotSearchHit> search(
    PolyglotUnifiedRegistry registry,
    String query, {
    String? languageCode,
    CefrProficiencyLevel? level,
    int limit = 25,
  }) {
    final normQuery = normalizeForSearch(query);
    if (normQuery.isEmpty) {
      return UnmodifiableListView(
        registry
            .queryUnits(languageCode: languageCode, level: level)
            .take(limit)
            .map((u) => PolyglotSearchHit(
                  unit: u,
                  relevanceScore: 1.0,
                  detectedGender: detectGermanArticle(u.targetExpression),
                ))
            .toList(growable: false),
      );
    }

    final tokens = normQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final hits = <PolyglotSearchHit>[];

    for (final unit in registry.queryUnits(languageCode: languageCode, level: level)) {
      final normTarget = normalizeForSearch(unit.targetExpression);
      final normTitle = normalizeForSearch(unit.title);
      final normSentence = normalizeForSearch(unit.contextualSentence);
      final normArabic = normalizeForSearch(unit.arabicExplanation);

      double score = 0.0;
      if (normTarget.contains(normQuery)) score += 5.0;
      if (normTitle.contains(normQuery)) score += 3.5;
      if (normSentence.contains(normQuery)) score += 2.0;
      if (normArabic.contains(normQuery)) score += 2.0;

      for (final tok in tokens) {
        if (normTarget.contains(tok)) score += 1.5;
        if (normSentence.contains(tok)) score += 0.8;
        if (normArabic.contains(tok)) score += 0.8;
      }

      if (score > 0) {
        hits.add(PolyglotSearchHit(
          unit: unit,
          relevanceScore: score,
          detectedGender: detectGermanArticle(unit.targetExpression),
        ));
      }
    }

    hits.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return UnmodifiableListView(hits.take(limit));
  }
}
