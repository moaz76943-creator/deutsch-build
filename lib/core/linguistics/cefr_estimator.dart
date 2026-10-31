enum CefrLevel {
  a1,
  a2,
  b1,
  b2,
  c1,
  c2;

  String get label => name.toUpperCase();

  String get arabicDescription => switch (this) {
    CefrLevel.a1 => 'المستوى التأسيسي الأول (A1 - مبتدئ)',
    CefrLevel.a2 => 'المستوى التأسيسي الثاني (A2 - أساسي)',
    CefrLevel.b1 => 'المستوى المتوسط الأول (B1 - مستقل)',
    CefrLevel.b2 => 'المستوى المتوسط المتقدم (B2 - كفء)',
    CefrLevel.c1 => 'المستوى المتقدم (C1 - متقن)',
    CefrLevel.c2 => 'المستوى الإتقاني العالي (C2 - طلاقة تامة)',
  };
}

class CefrEstimationResult {
  final String word;
  final CefrLevel estimatedLevel;
  final int confidenceScore; // 0 - 100
  final String rationale;

  const CefrEstimationResult({
    required this.word,
    required this.estimatedLevel,
    required this.confidenceScore,
    required this.rationale,
  });
}

/// مقدر ومصنف مستويات الإطار الأوروبي المشترك للغات (CEFR Classification) - Study 02
/// يحلل الكلمة وفق الطول الصرفي، اللواحق الاشتقاقية، ومستوى التعقيد التركيبي.
class CefrEstimator {
  static const Set<String> _a1Vocabulary = {
    'hallo', 'danke', 'bitte', 'ja', 'nein', 'haus', 'buch', 'tag', 'nacht',
    'guten', 'morgen', 'abend', 'mann', 'frau', 'kind', 'wasser', 'brot',
    'apfel', 'essen', 'trinken', 'gehen', 'kommen', 'sehen', 'hören',
    'sprechen', 'lernen', 'schreiben', 'lesen', 'haben', 'sein', 'gut',
    'groß', 'klein', 'schön', 'eins', 'zwei', 'drei', 'uhr', 'zeit',
  };

  static const Set<String> _a2Vocabulary = {
    'reise', 'urlaub', 'arbeit', 'wetter', 'termin', 'arzt', 'krank',
    'gesund', 'einkaufen', 'bezahlen', 'flughafen', 'bahnhof', 'karte',
    'fahrkarte', 'wohnung', 'miete', 'zimmer', 'schlüssel', 'beruf',
    'kollege', 'ausbildung', 'schule', 'unterricht', 'prüfen', 'feiern',
    'verstehen', 'erklären', 'gefallen', 'passen', 'helfen', 'danken',
  };

  static const Set<String> _b1Vocabulary = {
    'erfahrung', 'meinung', 'entscheidung', 'erfolg', 'zukunft', 'umwelt',
    'klima', 'gesellschaft', 'beziehung', 'streit', 'lösung', 'vertrag',
    'vorschlag', 'ausdruck', 'hoffen', 'erwarten', 'überzeugen', 'vergleichen',
    'teilnehmen', 'organisieren', 'beschweren', 'begründen', 'wichtig',
  };

  static const Set<String> _advancedSuffixesC1C2 = {
    'barkeit', 'widrig', 'gemäß', 'haltig', 'losigkeit', 'haftigkeit',
    'ierung', 'isierung', 'ifikation',
  };

  static const Set<String> _intermediateSuffixesB1B2 = {
    'schaft', 'keit', 'heit', 'ung', 'tum', 'ling', 'nis', 'tät',
  };

  /// تقدير مستوى المفردة الألمانية وفق المعايير اللغوية
  static CefrEstimationResult estimateLevel(String word) {
    final lower = word.trim().toLowerCase();

    // 1. مطابقة المعاجم الأساسية المحكمة
    if (_a1Vocabulary.contains(lower)) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.a1,
        confidenceScore: 95,
        rationale: 'مفردة حيوية من معجم النجاة الأساسي لمستوى A1.',
      );
    }

    if (_a2Vocabulary.contains(lower)) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.a2,
        confidenceScore: 90,
        rationale: 'مفردة تواصلية يومية من معجم المستوى A2.',
      );
    }

    if (_b1Vocabulary.contains(lower)) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.b1,
        confidenceScore: 90,
        rationale: 'مفردة تفاعلية للتعبير عن الرأي والخبرات في مستوى B1.',
      );
    }

    // 2. تحليل اللواحق الصرفية المشتقة
    for (final suffix in _advancedSuffixesC1C2) {
      if (lower.endsWith(suffix)) {
        return CefrEstimationResult(
          word: word,
          estimatedLevel: CefrLevel.c1,
          confidenceScore: 85,
          rationale: 'تحتوي على لاحقة تجريد وتخصيص أكاديمية متقدمة (-$suffix).',
        );
      }
    }

    for (final suffix in _intermediateSuffixesB1B2) {
      if (lower.endsWith(suffix)) {
        final level = lower.length > 12 ? CefrLevel.b2 : CefrLevel.b1;
        return CefrEstimationResult(
          word: word,
          estimatedLevel: level,
          confidenceScore: 80,
          rationale: 'اسم مشتق بواسطة لاحقة صرفية قياسية (-$suffix).',
        );
      }
    }

    // 3. تحليل الطول الصرفي والمقاطع
    if (lower.length <= 5) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.a1,
        confidenceScore: 70,
        rationale: 'مفردة قصيرة وبسيطة التكوين الصرفي.',
      );
    }

    if (lower.length <= 8) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.a2,
        confidenceScore: 75,
        rationale: 'مفردة متوسطة الطول ملائمة للمرحلة التأسيسية A2.',
      );
    }

    if (lower.length <= 14) {
      return CefrEstimationResult(
        word: word,
        estimatedLevel: CefrLevel.b1,
        confidenceScore: 75,
        rationale: 'مفردة متعددة المقاطع تتطلب مهارات المستوى B1.',
      );
    }

    return CefrEstimationResult(
      word: word,
      estimatedLevel: CefrLevel.b2,
      confidenceScore: 70,
      rationale: 'مفردة مركبة طويلة مناسبة للمستوى B2 فما فوق.',
    );
  }
}
