import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }

enum CefrGroup { beginner, intermediate, advanced, unknown }

enum CefrGrouping { beginner, intermediate, advanced, unknown }

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

final class CefrClassification {
  const CefrClassification({
    required this.level,
    required this.grouping,
    required this.method,
    required this.confidence,
    this.details,
  });

  final CefrLevel level;
  final CefrGrouping grouping;
  final CefrClassificationMethod method;
  final CefrEvidenceConfidence confidence;
  final String? details;
}

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

  static CefrGrouping getGrouping(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1:
      case CefrLevel.a2:
        return CefrGrouping.beginner;
      case CefrLevel.b1:
      case CefrLevel.b2:
        return CefrGrouping.intermediate;
      case CefrLevel.c1:
      case CefrLevel.c2:
        return CefrGrouping.advanced;
      case CefrLevel.unknown:
        return CefrGrouping.unknown;
    }
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

    return const CefrClassification(
      level: CefrLevel.unknown,
      grouping: CefrGrouping.unknown,
      method: CefrClassificationMethod.inferred,
      confidence: CefrEvidenceConfidence.none,
      details: 'Insufficient evidence',
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

    return const CefrClassification(
      level: CefrLevel.unknown,
      grouping: CefrGrouping.unknown,
      method: CefrClassificationMethod.inferred,
      confidence: CefrEvidenceConfidence.none,
      details: 'Insufficient evidence',
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
