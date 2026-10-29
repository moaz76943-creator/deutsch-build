import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }
<<<<<<< HEAD

enum CefrGroup { beginner, intermediate, advanced, unknown }

enum EvidenceSource {
  explicitPolicy,
  verifiedSource,
  inferredDifficulty,
  unsupported,
}

class ClassificationResult {
  const ClassificationResult({
    required this.level,
    required this.source,
    required this.confidence,
  });

  final CefrLevel level;
  final EvidenceSource source;
  final double confidence;
}

class LexicalEvidence {
  const LexicalEvidence({
    required this.languageCode,
    this.explicitLevel,
    this.sourceLevelMap = const {},
  });

  final String languageCode;
  final CefrLevel? explicitLevel;
  final Map<String, CefrLevel> sourceLevelMap;
}

class ExampleEvidence {
  const ExampleEvidence({
    required this.languageCode,
    this.explicitLevel,
    this.sourceLevelMap = const {},
    this.wordsLevels = const [],
  });

  final String languageCode;
  final CefrLevel? explicitLevel;
  final Map<String, CefrLevel> sourceLevelMap;
  final List<CefrLevel> wordsLevels;
}

class CefrClassifier {
  /// تحديد المستوى بناءً على ترتيب الشيوع وطول الكلمة لأي لغة
  /// (Deprecated: No longer supported due to inaccuracy. Always returns unknown)
  static CefrLevel detectLevel(int frequencyRank, int charLength) {
    return CefrLevel.unknown;
  }

  static ClassificationResult classifyWord(LexicalEvidence evidence) {
    if (evidence.explicitLevel != null &&
        evidence.explicitLevel != CefrLevel.unknown) {
      return ClassificationResult(
        level: evidence.explicitLevel!,
        source: EvidenceSource.explicitPolicy,
        confidence: 1.0,
      );
    }

    if (evidence.sourceLevelMap.isNotEmpty) {
      // Find the highest confidence based on agreement, or fallback deterministically
      final levels = evidence.sourceLevelMap.values
          .where((l) => l != CefrLevel.unknown)
          .toList();
      if (levels.isEmpty) {
        return const ClassificationResult(
          level: CefrLevel.unknown,
          source: EvidenceSource.unsupported,
          confidence: 0.0,
        );
      }

      // Resolve conflicts by picking the highest level among sources to be safe (or most frequent, etc)
      // Let's take the maximum level (which is deterministic).
      CefrLevel highestLevel = levels.first;
      for (var l in levels) {
        if (l.index > highestLevel.index) {
          highestLevel = l;
        }
      }

      return ClassificationResult(
        level: highestLevel,
        source: EvidenceSource.verifiedSource,
        confidence: 0.8,
      );
    }

    return const ClassificationResult(
      level: CefrLevel.unknown,
      source: EvidenceSource.unsupported,
      confidence: 0.0,
    );
  }

  static ClassificationResult classifyExample(ExampleEvidence evidence) {
    if (evidence.explicitLevel != null &&
        evidence.explicitLevel != CefrLevel.unknown) {
      return ClassificationResult(
        level: evidence.explicitLevel!,
        source: EvidenceSource.explicitPolicy,
        confidence: 1.0,
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
        return ClassificationResult(
          level: highestLevel,
          source: EvidenceSource.verifiedSource,
          confidence: 0.8,
        );
      }
    }

    // Infer difficulty from words levels
    final validWordLevels =
        evidence.wordsLevels.where((l) => l != CefrLevel.unknown).toList();
    if (validWordLevels.isNotEmpty) {
      CefrLevel maxLevel = validWordLevels.first;
      for (var l in validWordLevels) {
        if (l.index > maxLevel.index) {
          maxLevel = l;
        }
      }

      // Bump level for examples if we have complex words, but cap at C2
      int nextIndex = maxLevel.index + 1;
      if (nextIndex > CefrLevel.c2.index) {
        nextIndex = CefrLevel.c2.index;
      }

      return ClassificationResult(
        level: CefrLevel.values[nextIndex],
        source: EvidenceSource.inferredDifficulty,
        confidence: 0.6,
      );
    }

    return const ClassificationResult(
      level: CefrLevel.unknown,
      source: EvidenceSource.unsupported,
      confidence: 0.0,
    );
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

  static CefrClassification classifyLexicalEntry(
      LexicalEntryEvidence evidence) {
    if (evidence.sourceProvidedCefr != null &&
        evidence.sourceProvidedCefr != CefrLevel.unknown) {
      return CefrClassification(
        level: evidence.sourceProvidedCefr!,
        grouping: getGrouping(evidence.sourceProvidedCefr!),
        method: CefrClassificationMethod.explicit,
        confidence: CefrEvidenceConfidence.high,
        details: 'Explicit source metadata',
      );
    }

    if (evidence.frequencyRank == null) {
      return const CefrClassification(
        level: CefrLevel.unknown,
        grouping: CefrGrouping.unknown,
        method: CefrClassificationMethod.inferred,
        confidence: CefrEvidenceConfidence.none,
        details: 'Insufficient evidence',
      );
    }

    // Language-specific profiles for inferred level based on frequency and traits
    final lang = evidence.languageId.toLowerCase();
    CefrLevel inferred;
    CefrEvidenceConfidence conf = CefrEvidenceConfidence.medium;

    // Very basic mapping for fallback, treating languages differently.
    int rank = evidence.frequencyRank!;
    bool compound = evidence.isCompound ?? false;

    if (lang == 'de') {
      if (rank <= 500) {
        inferred = CefrLevel.a1;
      } else if (rank <= 2000)
        inferred = CefrLevel.a2;
      else if (rank <= 4000)
        inferred = CefrLevel.b1;
      else if (rank <= 8000)
        inferred = CefrLevel.b2;
      else
        inferred = CefrLevel.c1;

      if (compound && inferred == CefrLevel.a1) {
        inferred = CefrLevel.a2; // Compounds are generally harder
      }
    } else if (lang == 'ar') {
      if (rank <= 600) {
        inferred = CefrLevel.a1;
      } else if (rank <= 2500)
        inferred = CefrLevel.a2;
      else if (rank <= 5000)
        inferred = CefrLevel.b1;
      else if (rank <= 10000)
        inferred = CefrLevel.b2;
      else
        inferred = CefrLevel.c1;
    } else {
      // Generic fallback
      if (rank <= 1000) {
        inferred = CefrLevel.a1;
      } else if (rank <= 3000)
        inferred = CefrLevel.a2;
      else if (rank <= 6000)
        inferred = CefrLevel.b1;
      else if (rank <= 10000)
        inferred = CefrLevel.b2;
      else
        inferred = CefrLevel.c1;
      conf = CefrEvidenceConfidence.low;
    }

    // If length is extremely long but rank is high, could bump difficulty
    if (evidence.charLength != null && evidence.charLength! > 15) {
      if (inferred == CefrLevel.a1) {
        inferred = CefrLevel.a2;
      } else if (inferred == CefrLevel.a2) inferred = CefrLevel.b1;
    }

    return CefrClassification(
      level: inferred,
      grouping: getGrouping(inferred),
      method: CefrClassificationMethod.inferred,
      confidence: conf,
      details: 'Inferred from frequency profile',
    );
  }

  static CefrClassification classifyLearningExample(
      LearningExampleEvidence evidence) {
    if (evidence.sourceProvidedCefr != null &&
        evidence.sourceProvidedCefr != CefrLevel.unknown) {
      return CefrClassification(
        level: evidence.sourceProvidedCefr!,
        grouping: getGrouping(evidence.sourceProvidedCefr!),
        method: CefrClassificationMethod.explicit,
        confidence: CefrEvidenceConfidence.high,
        details: 'Explicit source metadata',
      );
    }

    if (evidence.wordCount == null && evidence.maxWordFrequencyRank == null) {
      return const CefrClassification(
        level: CefrLevel.unknown,
        grouping: CefrGrouping.unknown,
        method: CefrClassificationMethod.inferred,
        confidence: CefrEvidenceConfidence.none,
        details: 'Insufficient evidence',
      );
    }

    CefrLevel inferred = CefrLevel.unknown;

    // Determine complexity based on word count and max frequency rank
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
      grouping: getGrouping(inferred),
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
=======

class CefrClassifier {
  /// تحديد المستوى بناءً على ترتيب الشيوع وطول الكلمة لأي لغة
  CefrLevel detectLevel(int frequencyRank, int charLength) {
    if (frequencyRank <= 500 && charLength <= 6) return CefrLevel.a1;
    if (frequencyRank <= 1500) return CefrLevel.a2;
    if (frequencyRank <= 3500) return CefrLevel.b1;
    if (frequencyRank <= 6000) return CefrLevel.b2;
    return CefrLevel.c1;
  }

  /// التسمية المعيارية الدولية الصالحة لجميع اللغات الـ 100
  String getCode(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1';
      case CefrLevel.a2: return 'A2';
      case CefrLevel.b1: return 'B1';
      case CefrLevel.b2: return 'B2';
      case CefrLevel.c1: return 'C1';
      case CefrLevel.c2: return 'C2';
      default: return '--';
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    }
  }

  /// وصف المستوى باللغة العربية
  String getLabelAr(CefrLevel level) {
    switch (level) {
<<<<<<< HEAD
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
=======
      case CefrLevel.a1: return 'A1 (مبتدئ)';
      case CefrLevel.a2: return 'A2 (أساسي)';
      case CefrLevel.b1: return 'B1 (متوسط)';
      case CefrLevel.b2: return 'B2 (متقدم)';
      case CefrLevel.c1: return 'C1 (احترافي)';
      case CefrLevel.c2: return 'C2 (إتقان تام)';
      default: return 'عام';
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    }
  }

  /// التوافق العكسي
  String getLabel(CefrLevel level) => getLabelAr(level);

  /// ألوان التمييز البصري لكل مستوى
  Color getLevelColor(CefrLevel level) {
    switch (level) {
<<<<<<< HEAD
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
=======
      case CefrLevel.a1: return const Color(0xFF10B981); // زمردي
      case CefrLevel.a2: return const Color(0xFF06B6D4); // سماوي
      case CefrLevel.b1: return const Color(0xFFF59E0B); // كهرماني
      case CefrLevel.b2: return const Color(0xFFF97316); // برتقالي
      case CefrLevel.c1:
      case CefrLevel.c2: return const Color(0xFFEF4444); // أحمر
      default: return const Color(0xFF6B7280);
>>>>>>> origin/staging/v2-full-platform-1792367411258400957
    }
  }
}
