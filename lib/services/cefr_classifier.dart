import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }

enum CefrGrouping { beginner, intermediate, advanced, unknown }

enum CefrEvidenceSource {
  explicitPolicy,
  certifiedCorpus,
  inferredDifficulty,
  none,
}

class CefrEvidence {
  const CefrEvidence({
    this.source = CefrEvidenceSource.none,
    this.confidence = 0.0,
    this.explicitLevel,
  });

  final CefrEvidenceSource source;
  final double confidence;
  final CefrLevel? explicitLevel;

  bool get isSufficient =>
      source != CefrEvidenceSource.none && confidence >= 0.5 && explicitLevel != null;
}

class CefrClassifier {
  /// تحديد المستوى بناءً على ترتيب الشيوع وطول الكلمة لأي لغة
  /// Deprecated: Uses unsupported heuristics. Use classifyWord or classifyExample instead.
  @Deprecated('Use classifyWord instead')
  static CefrLevel detectLevel(int frequencyRank, int charLength) {
    return CefrLevel.unknown;
  }

  static int _getSourceWeight(CefrEvidenceSource source) {
    switch (source) {
      case CefrEvidenceSource.explicitPolicy: return 3;
      case CefrEvidenceSource.certifiedCorpus: return 2;
      case CefrEvidenceSource.inferredDifficulty: return 1;
      case CefrEvidenceSource.none: return 0;
    }
  }

  static CefrEvidence? _resolveConflict(Iterable<CefrEvidence> evidenceList) {
    CefrEvidence? bestEvidence;
    bool isAmbiguous = false;

    for (final evidence in evidenceList) {
      if (!evidence.isSufficient) continue;

      if (bestEvidence == null) {
        bestEvidence = evidence;
        continue;
      }

      final currentWeight = _getSourceWeight(evidence.source);
      final bestWeight = _getSourceWeight(bestEvidence.source);

      if (currentWeight > bestWeight) {
        bestEvidence = evidence;
        isAmbiguous = false;
      } else if (currentWeight == bestWeight) {
        if (evidence.confidence > bestEvidence.confidence) {
          bestEvidence = evidence;
          isAmbiguous = false;
        } else if (evidence.confidence == bestEvidence.confidence && evidence.explicitLevel != bestEvidence.explicitLevel) {
          isAmbiguous = true;
        }
      }
    }

    if (isAmbiguous) return null;
    return bestEvidence;
  }

  /// Classify a single word based on linguistic evidence.
  static CefrLevel classifyWord(Iterable<CefrEvidence> evidenceList) {
    if (evidenceList.isEmpty) return CefrLevel.unknown;

    final best = _resolveConflict(evidenceList);
    if (best != null && best.isSufficient) {
      return best.explicitLevel!;
    }
    return CefrLevel.unknown;
  }

  /// Classify an example sentence or phrase based on linguistic evidence.
  /// Example complexity might require higher confidence or explicit policy.
  static CefrLevel classifyExample(Iterable<CefrEvidence> evidenceList) {
    if (evidenceList.isEmpty) return CefrLevel.unknown;

    final best = _resolveConflict(evidenceList);

    if (best != null && best.isSufficient) {
      if (best.source == CefrEvidenceSource.inferredDifficulty) {
        // Inferred difficulty is less reliable for examples than words.
        if (best.confidence < 0.8) return CefrLevel.unknown;
      }
      return best.explicitLevel!;
    }
    return CefrLevel.unknown;
  }

  /// Groups a CEFR level into a broader category.
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
      default:
        return CefrGrouping.unknown;
    }
  }

  /// التسمية المعيارية الدولية الصالحة لجميع اللغات الـ 100
  static String getCode(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1';
      case CefrLevel.a2: return 'A2';
      case CefrLevel.b1: return 'B1';
      case CefrLevel.b2: return 'B2';
      case CefrLevel.c1: return 'C1';
      case CefrLevel.c2: return 'C2';
      default: return '--';
    }
  }

  /// وصف المستوى باللغة العربية
  static String getLabelAr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1 (مبتدئ)';
      case CefrLevel.a2: return 'A2 (أساسي)';
      case CefrLevel.b1: return 'B1 (متوسط)';
      case CefrLevel.b2: return 'B2 (متقدم)';
      case CefrLevel.c1: return 'C1 (احترافي)';
      case CefrLevel.c2: return 'C2 (إتقان تام)';
      default: return 'عام';
    }
  }

  /// التوافق العكسي
  static String getLabel(CefrLevel level) => getLabelAr(level);

  /// ألوان التمييز البصري لكل مستوى
  static Color getLevelColor(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return const Color(0xFF10B981); // زمردي
      case CefrLevel.a2: return const Color(0xFF06B6D4); // سماوي
      case CefrLevel.b1: return const Color(0xFFF59E0B); // كهرماني
      case CefrLevel.b2: return const Color(0xFFF97316); // برتقالي
      case CefrLevel.c1:
      case CefrLevel.c2: return const Color(0xFFEF4444); // أحمر
      default: return const Color(0xFF6B7280);
    }
  }
}
