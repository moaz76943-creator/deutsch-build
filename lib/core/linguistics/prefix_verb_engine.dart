enum PrefixCategory { separable, inseparable, dual }

class PrefixAnalysisResult {
  final String fullVerb;
  final String prefix;
  final String stem;
  final PrefixCategory category;
  final bool isSeparatedInMainClause;
  final String partizip2Example;
  final String zuInfinitivExample;

  const PrefixAnalysisResult({
    required this.fullVerb,
    required this.prefix,
    required this.stem,
    required this.category,
    required this.isSeparatedInMainClause,
    required this.partizip2Example,
    required this.zuInfinitivExample,
  });
}

/// Offline linguistic engine governing German separable and inseparable verbal prefixes.
class PrefixVerbEngine {
  // البادئات غير القابلة للانفصال قطيعاً (لا تأخذ ge- في الماضي، ولا تنفصل)
  static const Set<String> _inseparablePrefixes = {
    'be', 'ge', 'er', 'ver', 'zer', 'ent', 'emp', 'miss'
  };

  // البادئات الشائعة القابلة للانفصال (منبورة، وتدرج ge و zu في الوسط)
  static const Set<String> _separablePrefixes = {
    'ab', 'an', 'auf', 'aus', 'ein', 'mit', 'nach', 'vor', 'weg', 'zu', 'zurück'
  };

  /// تحليل البادئة وسلوكها النحوي والتصريفي
  PrefixAnalysisResult analyze(String verb) {
    final v = verb.toLowerCase().trim();

    // 1. فحص البادئات غير القابلة للانفصال
    for (final p in _inseparablePrefixes) {
      if (v.startsWith(p) && v.length > p.length + 2) {
        final stem = v.substring(p.length);
        return PrefixAnalysisResult(
          fullVerb: verb,
          prefix: p,
          stem: stem,
          category: PrefixCategory.inseparable,
          isSeparatedInMainClause: false,
          partizip2Example: '$p$stem' 't', // لا تأخذ ge- (verstanden)
          zuInfinitivExample: 'zu $v',     // zu تسبق الفعل كاملاً
        );
      }
    }

    // 2. فحص البادئات القابلة للانفصال
    for (final p in _separablePrefixes) {
      if (v.startsWith(p) && v.length > p.length + 2) {
        final stem = v.substring(p.length);
        return PrefixAnalysisResult(
          fullVerb: verb,
          prefix: p,
          stem: stem,
          category: PrefixCategory.separable,
          isSeparatedInMainClause: true,
          partizip2Example: '${p}ge$stem' 't', // ge في الوسط (auf-ge-standen)
          zuInfinitivExample: '${p}zu$stem',   // zu في الوسط (auf-zu-stehen)
        );
      }
    }

    return PrefixAnalysisResult(
      fullVerb: verb,
      prefix: '',
      stem: v,
      category: PrefixCategory.inseparable,
      isSeparatedInMainClause: false,
      partizip2Example: 'ge$v' 't',
      zuInfinitivExample: 'zu $v',
    );
  }

  /// صياغة جملة رئيسية مع انفصال البادئة إلى آخر الجملة (Satzklammer)
  String constructMainClausePresent({
    required String subject,
    required String verb,
    required String conjugatedStem,
    required String mittelfeldObjects,
  }) {
    final res = analyze(verb);
    if (res.category == PrefixCategory.separable) {
      return '$subject $conjugatedStem $mittelfeldObjects ${res.prefix}.';
    }
    return '$subject $conjugatedStem $mittelfeldObjects.';
  }
}
