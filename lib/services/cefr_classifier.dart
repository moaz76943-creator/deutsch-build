import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }

enum CefrGroup { beginner, intermediate, advanced, unknown }

enum CefrClassificationMethod { explicit, inferred }

enum CefrEvidenceConfidence { high, medium, low, none }

sealed class LinguisticEvidence {
  const LinguisticEvidence({
    required this.languageId,
    this.sourceProvidedCefr,
  });

  final String languageId;
  final CefrLevel? sourceProvidedCefr;
}

final class LexicalEntryEvidence extends LinguisticEvidence {
  const LexicalEntryEvidence({
    required super.languageId,
    super.sourceProvidedCefr,
    this.frequencyRank,
    this.charLength,
    this.isCompound,
  });

  final int? frequencyRank;
  final int? charLength;
  final bool? isCompound;
}

final class LearningExampleEvidence extends LinguisticEvidence {
  const LearningExampleEvidence({
    required super.languageId,
    super.sourceProvidedCefr,
    this.wordCount,
    this.maxWordFrequencyRank,
    this.clauseCount,
  });

  final int? wordCount;
  final int? maxWordFrequencyRank;
  final int? clauseCount;
}

class CefrClassification {
  const CefrClassification({
    required this.level,
    required this.grouping,
    required this.method,
    required this.confidence,
    this.details,
  });

  final CefrLevel level;
  final CefrGroup grouping;
  final CefrClassificationMethod method;
  final CefrEvidenceConfidence confidence;
  final String? details;
}

class LexicalEvidence {
  const LexicalEvidence({
    required this.languageCode,
    this.explicitLevel,
    this.sourceLevelMap = const {},
    this.frequencyRank,
    this.charLength,
    this.isCompound,
  });

  final String languageCode;
  final CefrLevel? explicitLevel;
  final Map<String, CefrLevel> sourceLevelMap;
  final int? frequencyRank;
  final int? charLength;
  final bool? isCompound;
}

class ExampleEvidence {
  const ExampleEvidence({
    required this.languageCode,
    this.explicitLevel,
    this.sourceLevelMap = const {},
    this.wordsLevels = const [],
    this.wordCount,
    this.clauseCount,
    this.maxWordFrequencyRank,
  });

  final String languageCode;
  final CefrLevel? explicitLevel;
  final Map<String, CefrLevel> sourceLevelMap;
  final List<CefrLevel> wordsLevels;
  final int? wordCount;
  final int? clauseCount;
  final int? maxWordFrequencyRank;
}

class CefrClassifier {
  /// تحديد المستوى بناءً على ترتيب الشيوع وطول الكلمة لأي لغة
  /// (Deprecated: No longer supported due to inaccuracy. Always returns unknown)
  static CefrLevel detectLevel(int frequencyRank, int charLength) {
    return CefrLevel.unknown;
  }

  static CefrGroup getGroup(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
      case CefrLevel.a2:
        return CefrGroup.beginner;
      case CefrLevel.b1:
      case CefrLevel.b2:
        return CefrGroup.intermediate;
      case CefrLevel.c1:
      case CefrLevel.c2:
        return CefrGroup.advanced;
      case CefrLevel.unknown:
        return CefrGroup.unknown;
    }
  }

  static CefrClassification classifyWord(LexicalEvidence evidence) {
    if (evidence.explicitLevel != null &&
        evidence.explicitLevel != CefrLevel.unknown) {
      return CefrClassification(
        level: evidence.explicitLevel!,
        grouping: getGroup(evidence.explicitLevel!),
        method: CefrClassificationMethod.explicit,
        confidence: CefrEvidenceConfidence.high,
        details: 'Explicit source metadata',
      );
    }

    if (evidence.sourceLevelMap.isNotEmpty) {
      final levels = evidence.sourceLevelMap.values
          .where((l) => l != CefrLevel.unknown)
          .toList();
      if (levels.isNotEmpty) {
        CefrLevel highestLevel = levels.first;
        for (var l in levels) {
          if (l.index > highestLevel.index) {
            highestLevel = l;
          }
        }
        return CefrClassification(
          level: highestLevel,
          grouping: getGroup(highestLevel),
          method: CefrClassificationMethod.explicit,
          confidence: CefrEvidenceConfidence.high,
          details: 'Verified multi-source metadata',
        );
      }
    }

    if (evidence.frequencyRank == null) {
      return const CefrClassification(
        level: CefrLevel.unknown,
        grouping: CefrGroup.unknown,
        method: CefrClassificationMethod.inferred,
        confidence: CefrEvidenceConfidence.none,
        details: 'Insufficient evidence',
      );
    }

    final lang = evidence.languageCode.toLowerCase();
    CefrLevel inferred;
    CefrEvidenceConfidence conf = CefrEvidenceConfidence.medium;

    int? rank = evidence.frequencyRank;
    bool compound = evidence.isCompound ?? false;

    if (lang == 'de') {
      if (rank! <= 500) {
        inferred = CefrLevel.a1;
      } else if (rank <= 2000) {
        inferred = CefrLevel.a2;
      } else if (rank <= 4000) {
        inferred = CefrLevel.b1;
      } else if (rank <= 8000) {
        inferred = CefrLevel.b2;
      } else {
        inferred = CefrLevel.c1;
      }

      if (compound && inferred == CefrLevel.a1) {
        inferred = CefrLevel.a2;
      }
    } else if (lang == 'ar') {
      if (rank! <= 600) {
        inferred = CefrLevel.a1;
      } else if (rank <= 2500) {
        inferred = CefrLevel.a2;
      } else if (rank <= 5000) {
        inferred = CefrLevel.b1;
      } else if (rank <= 10000) {
        inferred = CefrLevel.b2;
      } else {
        inferred = CefrLevel.c1;
      }
    } else {
      if (rank! <= 1000) {
        inferred = CefrLevel.a1;
      } else if (rank <= 3000) {
        inferred = CefrLevel.a2;
      } else if (rank <= 6000) {
        inferred = CefrLevel.b1;
      } else if (rank <= 10000) {
        inferred = CefrLevel.b2;
      } else {
        inferred = CefrLevel.c1;
      }
      conf = CefrEvidenceConfidence.low;
    }

    if (evidence.charLength != null && evidence.charLength! > 15) {
      if (inferred == CefrLevel.a1) {
        inferred = CefrLevel.a2;
      } else if (inferred == CefrLevel.a2) {
        inferred = CefrLevel.b1;
      }
    }

    return CefrClassification(
      level: inferred,
      grouping: getGroup(inferred),
      method: CefrClassificationMethod.inferred,
      confidence: conf,
      details: 'Inferred from frequency profile',
    );
  }

  static CefrClassification classifyExample(ExampleEvidence evidence) {
    if (evidence.explicitLevel != null &&
        evidence.explicitLevel != CefrLevel.unknown) {
      return CefrClassification(
        level: evidence.explicitLevel!,
        grouping: getGroup(evidence.explicitLevel!),
        method: CefrClassificationMethod.explicit,
        confidence: CefrEvidenceConfidence.high,
        details: 'Explicit source metadata',
      );
    }

    if (evidence.sourceLevelMap.isNotEmpty) {
      final levels = evidence.sourceLevelMap.values
          .where((l) => l != CefrLevel.unknown)
          .toList();
      if (levels.isNotEmpty) {
        CefrLevel highestLevel = levels.first;
        for (var l in levels) {
          if (l.index > highestLevel.index) {
            highestLevel = l;
          }
        }
        return CefrClassification(
          level: highestLevel,
          grouping: getGroup(highestLevel),
          method: CefrClassificationMethod.explicit,
          confidence: CefrEvidenceConfidence.high,
          details: 'Verified multi-source metadata',
        );
      }
    }

    final validWordLevels =
        evidence.wordsLevels.where((l) => l != CefrLevel.unknown).toList();
    if (validWordLevels.isNotEmpty) {
      CefrLevel maxLevel = validWordLevels.first;
      for (var l in validWordLevels) {
        if (l.index > maxLevel.index) {
          maxLevel = l;
        }
      }

      int nextIndex = maxLevel.index + 1;
      if (nextIndex > CefrLevel.c2.index) {
        nextIndex = CefrLevel.c2.index;
      }

      return CefrClassification(
        level: CefrLevel.values[nextIndex],
        grouping: getGroup(CefrLevel.values[nextIndex]),
        method: CefrClassificationMethod.inferred,
        confidence: CefrEvidenceConfidence.medium,
        details: 'Inferred from words levels',
      );
    }

    if (evidence.wordCount == null || evidence.maxWordFrequencyRank == null) {
      return const CefrClassification(
        level: CefrLevel.unknown,
        grouping: CefrGroup.unknown,
        method: CefrClassificationMethod.inferred,
        confidence: CefrEvidenceConfidence.none,
        details: 'Insufficient evidence',
      );
    }

    CefrLevel inferred = CefrLevel.unknown;

    int wc = evidence.wordCount ?? 0;
    int clauses = evidence.clauseCount ?? 1;
    int maxRank = evidence.maxWordFrequencyRank ?? 1000;

    if (maxRank <= 500 && wc <= 5 && clauses == 1) {
      inferred = CefrLevel.a1;
    } else if (maxRank <= 2000 && wc <= 10 && clauses <= 2) {
      inferred = CefrLevel.a2;
    } else if (maxRank <= 5000 && wc <= 15) {
      inferred = CefrLevel.b1;
    } else if (maxRank <= 10000) {
      inferred = CefrLevel.b2;
    } else {
      inferred = CefrLevel.c1;
    }

    return CefrClassification(
      level: inferred,
      grouping: getGroup(inferred),
      method: CefrClassificationMethod.inferred,
      confidence: CefrEvidenceConfidence.medium,
      details: 'Inferred from example complexity',
    );
  }

  /// التسمية المعيارية الدولية الصالحة لجميع اللغات الـ 100
  static String getCode(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return 'A1';
      case CefrLevel.a2:
        return 'A2';
      case CefrLevel.b1:
        return 'B1';
      case CefrLevel.b2:
        return 'B2';
      case CefrLevel.c1:
        return 'C1';
      case CefrLevel.c2:
        return 'C2';
      default:
        return '--';
    }
  }

  /// وصف المستوى باللغة العربية
  static String getLabelAr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return 'A1 (مبتدئ)';
      case CefrLevel.a2:
        return 'A2 (أساسي)';
      case CefrLevel.b1:
        return 'B1 (متوسط)';
      case CefrLevel.b2:
        return 'B2 (متقدم)';
      case CefrLevel.c1:
        return 'C1 (احترافي)';
      case CefrLevel.c2:
        return 'C2 (إتقان تام)';
      default:
        return 'عام';
    }
  }

  /// التوافق العكسي
  static String getLabel(CefrLevel level) => getLabelAr(level);

  /// ألوان التمييز البصري لكل مستوى
  static Color getLevelColor(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
        return const Color(0xFF10B981); // زمردي
      case CefrLevel.a2:
        return const Color(0xFF06B6D4); // سماوي
      case CefrLevel.b1:
        return const Color(0xFFF59E0B); // كهرماني
      case CefrLevel.b2:
        return const Color(0xFFF97316); // برتقالي
      case CefrLevel.c1:
      case CefrLevel.c2:
        return const Color(0xFFEF4444); // أحمر
      default:
        return const Color(0xFF6B7280);
    }
  }
}
