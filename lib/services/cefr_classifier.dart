import 'package:flutter/material.dart';

enum CefrLevel { a1, a2, b1, b2, c1, c2, unknown }
enum CefrGrouping { beginner, intermediate, advanced, unknown }
enum CefrEvidenceSource { explicitPolicy, certifiedCorpus, inferredDifficulty, none }

class CefrEvidence {
  final CefrEvidenceSource source;
  final double confidence;
  final CefrLevel? explicitLevel;
  final String? languageCode;
  final String? contentId;
  final String? sourceId;
  final String? sourceVersion;
  final String frameworkId;

  const CefrEvidence({
    this.source = CefrEvidenceSource.none,
    this.confidence = 0.0,
    this.explicitLevel,
    this.languageCode,
    this.contentId,
    this.sourceId,
    this.sourceVersion,
    this.frameworkId = 'CEFR',
  });

  /// Metadata completeness only. Independent pack/source verification is external.
  bool get isSufficient =>
      frameworkId == 'CEFR' &&
      (source == CefrEvidenceSource.explicitPolicy ||
          source == CefrEvidenceSource.certifiedCorpus) &&
      confidence.isFinite &&
      confidence >= 0.5 &&
      confidence <= 1.0 &&
      explicitLevel != null &&
      explicitLevel != CefrLevel.unknown &&
      languageCode != null &&
      languageCode!.isNotEmpty &&
      contentId != null &&
      contentId!.isNotEmpty &&
      sourceId != null &&
      sourceId!.isNotEmpty &&
      sourceVersion != null &&
      sourceVersion!.isNotEmpty;
}

class CefrClassifier {
  /// Previous frequency/word-length heuristic cannot justify CEFR across scripts.
  @Deprecated('Use classifyWord with attested CEFR evidence')
  static CefrLevel detectLevel(int frequencyRank, int charLength) =>
      CefrLevel.unknown;

  static int _authority(CefrEvidenceSource value) {
    switch (value) {
      case CefrEvidenceSource.explicitPolicy:
        return 2;
      case CefrEvidenceSource.certifiedCorpus:
        return 1;
      case CefrEvidenceSource.inferredDifficulty:
      case CefrEvidenceSource.none:
        return 0;
    }
  }

  static CefrLevel _classify(
    Iterable<CefrEvidence> evidence, {
    String? languageCode,
    String? contentId,
  }) {
    // Bound even caller-supplied lazy/infinite evidence iterables. The caller
    // must provide compact, admitted per-sense evidence, not an entire corpus.
    const maxEvidenceRecords = 64;
    final eligible = <CefrEvidence>[];
    var visited = 0;
    for (final candidate in evidence) {
      visited++;
      if (visited > maxEvidenceRecords) return CefrLevel.unknown;
      if (candidate.isSufficient) eligible.add(candidate);
    }
    if (eligible.isEmpty) return CefrLevel.unknown;
    final language = languageCode ?? eligible.first.languageCode!;
    final content = contentId ?? eligible.first.contentId!;
    if (eligible.any((e) =>
        e.languageCode != language || e.contentId != content)) {
      return CefrLevel.unknown;
    }
    int maxAuthority = 0;
    final topLevels = <CefrLevel>{};
    for (final e in eligible) {
      final rank = _authority(e.source);
      if (rank > maxAuthority) {
        maxAuthority = rank;
        topLevels.clear();
      }
      if (rank == maxAuthority) topLevels.add(e.explicitLevel!);
    }
    return topLevels.length == 1 ? topLevels.single : CefrLevel.unknown;
  }

  static CefrLevel classifyWord(
    Iterable<CefrEvidence> evidence, {
    String? languageCode,
    String? contentId,
  }) => _classify(
    evidence, languageCode: languageCode, contentId: contentId,
  );

  static CefrLevel classifyExample(
    Iterable<CefrEvidence> evidence, {
    String? languageCode,
    String? contentId,
  }) => _classify(
    evidence, languageCode: languageCode, contentId: contentId,
  );

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

  static String getCode(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1';
      case CefrLevel.a2: return 'A2';
      case CefrLevel.b1: return 'B1';
      case CefrLevel.b2: return 'B2';
      case CefrLevel.c1: return 'C1';
      case CefrLevel.c2: return 'C2';
      case CefrLevel.unknown: return '--';
    }
  }

  static String getLabelAr(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return 'A1 (مبتدئ)';
      case CefrLevel.a2: return 'A2 (أساسي)';
      case CefrLevel.b1: return 'B1 (متوسط)';
      case CefrLevel.b2: return 'B2 (متقدم)';
      case CefrLevel.c1: return 'C1 (احترافي)';
      case CefrLevel.c2: return 'C2 (إتقان تام)';
      case CefrLevel.unknown: return 'عام';
    }
  }

  static String getLabel(CefrLevel level) => getLabelAr(level);

  static Color getLevelColor(CefrLevel level) {
    switch (level) {
      case CefrLevel.a1: return const Color(0xFF10B981);
      case CefrLevel.a2: return const Color(0xFF06B6D4);
      case CefrLevel.b1: return const Color(0xFFF59E0B);
      case CefrLevel.b2: return const Color(0xFFF97316);
      case CefrLevel.c1:
      case CefrLevel.c2: return const Color(0xFFEF4444);
      case CefrLevel.unknown: return const Color(0xFF6B7280);
    }
  }
}
