import 'assessment.dart';

enum DiagnosticDimension {
  meaning,
  grammar,
  listening,
  transfer,
  production;

  String get wireName => name;

  static DiagnosticDimension? fromWire(String? raw) {
    final value = raw?.trim().toLowerCase();
    for (final dimension in DiagnosticDimension.values) {
      if (dimension.wireName == value) return dimension;
    }
    return null;
  }
}

enum DiagnosticPlacementBand {
  foundation,
  basic,
  developing,
  strong;

  String get wireName => name;

  static DiagnosticPlacementBand fromWire(String? raw) {
    final value = raw?.trim().toLowerCase();
    for (final band in DiagnosticPlacementBand.values) {
      if (band.wireName == value) return band;
    }
    return DiagnosticPlacementBand.foundation;
  }
}

final class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.question,
    required this.dimension,
    required this.difficultyBand,
  });

  final AssessmentQuestion question;
  final DiagnosticDimension dimension;
  final int difficultyBand;
}

final class DiagnosticResponse {
  const DiagnosticResponse({
    required this.questionId,
    required this.itemId,
    required this.dimension,
    required this.correct,
    required this.hinted,
    required this.skipped,
    this.difficultyBand = 1,
  });

  final String questionId;
  final String itemId;
  final DiagnosticDimension dimension;
  final bool correct;
  final bool hinted;
  final bool skipped;
  final int difficultyBand;

  double get evidenceValue {
    if (skipped || !correct) return 0;
    return hinted ? .7 : 1;
  }
}

final class PlacementDiagnosticResult {
  const PlacementDiagnosticResult({
    required this.answered,
    required this.scoredAnswers,
    required this.cleanCorrect,
    required this.score,
    required this.confidence,
    required this.band,
    required this.dimensionScores,
    required this.weakDimensions,
    required this.reviewItemIds,
  });

  final int answered;
  final int scoredAnswers;
  final int cleanCorrect;
  final double score;
  final double confidence;
  final DiagnosticPlacementBand band;
  final Map<DiagnosticDimension, double> dimensionScores;
  final List<DiagnosticDimension> weakDimensions;
  final List<String> reviewItemIds;

  bool get isCefrCertification => false;

  PlacementDiagnosticRecord toRecord({required DateTime at, String? id}) =>
      PlacementDiagnosticRecord(
        id: id ?? 'placement_${at.microsecondsSinceEpoch}',
        at: at,
        answered: answered,
        scoredAnswers: scoredAnswers,
        score: score,
        confidence: confidence,
        band: band,
        dimensionScores: dimensionScores,
        weakDimensions: weakDimensions,
        reviewItemIds: reviewItemIds,
      );
}

final class PlacementDiagnosticRecord {
  const PlacementDiagnosticRecord({
    required this.id,
    required this.at,
    required this.answered,
    required this.scoredAnswers,
    required this.score,
    required this.confidence,
    required this.band,
    required this.dimensionScores,
    required this.weakDimensions,
    required this.reviewItemIds,
    this.curriculumStartLevel,
    this.recommendedStartTaskOrder = 1,
    this.learningGoal,
  });

  final String id;
  final DateTime at;
  final int answered;
  final int scoredAnswers;
  final double score;
  final double confidence;
  final DiagnosticPlacementBand band;
  final Map<DiagnosticDimension, double> dimensionScores;
  final List<DiagnosticDimension> weakDimensions;
  final List<String> reviewItemIds;
  final String? curriculumStartLevel;
  final int recommendedStartTaskOrder;
  final String? learningGoal;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'at': at.toIso8601String(),
        'answered': answered,
        'scoredAnswers': scoredAnswers,
        'score': score,
        'confidence': confidence,
        'band': band.wireName,
        'dimensionScores': <String, double>{
          for (final entry in dimensionScores.entries)
            entry.key.wireName: entry.value,
        },
        'weakDimensions': weakDimensions
            .map((dimension) => dimension.wireName)
            .toList(growable: false),
        'reviewItemIds': reviewItemIds.take(20).toList(growable: false),
        if (curriculumStartLevel != null)
          'curriculumStartLevel': curriculumStartLevel,
        'recommendedStartTaskOrder':
            recommendedStartTaskOrder.clamp(1, 50),
        if (learningGoal != null) 'learningGoal': learningGoal,
      };

  factory PlacementDiagnosticRecord.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    var at = DateTime.tryParse(json['at']?.toString() ?? '') ?? now;
    if (at.isBefore(DateTime(2000)) ||
        at.isAfter(now.add(const Duration(days: 1)))) {
      at = now;
    }

    final scores = <DiagnosticDimension, double>{};
    final rawScores = json['dimensionScores'];
    if (rawScores is Map) {
      for (final entry in rawScores.entries) {
        final dimension = DiagnosticDimension.fromWire(entry.key.toString());
        final raw = entry.value;
        if (dimension == null || raw is! num) continue;
        scores[dimension] = raw.toDouble().clamp(0.0, 1.0).toDouble();
      }
    }

    final weak = <DiagnosticDimension>[];
    final rawWeak = json['weakDimensions'];
    if (rawWeak is List) {
      for (final raw in rawWeak.take(DiagnosticDimension.values.length)) {
        final dimension = DiagnosticDimension.fromWire(raw?.toString());
        if (dimension != null && !weak.contains(dimension)) weak.add(dimension);
      }
    }

    final reviewIds = <String>[];
    final rawReviewIds = json['reviewItemIds'];
    if (rawReviewIds is List) {
      for (final raw in rawReviewIds.take(20)) {
        final value = raw?.toString().trim() ?? '';
        if (value.isNotEmpty &&
            value.length <= 160 &&
            !reviewIds.contains(value)) {
          reviewIds.add(value);
        }
      }
    }

    final rawId = json['id']?.toString().trim() ?? '';
    return PlacementDiagnosticRecord(
      id: rawId.length > 160 ? rawId.substring(0, 160) : rawId,
      at: at,
      answered: _boundedInt(json['answered'], 0, 20),
      scoredAnswers: _boundedInt(json['scoredAnswers'], 0, 20),
      score: _boundedDouble(json['score'], 0, 100),
      confidence: _boundedDouble(json['confidence'], 0, 1),
      band: DiagnosticPlacementBand.fromWire(json['band']?.toString()),
      dimensionScores: Map<DiagnosticDimension, double>.unmodifiable(scores),
      weakDimensions: List<DiagnosticDimension>.unmodifiable(weak),
      reviewItemIds: List<String>.unmodifiable(reviewIds),
      curriculumStartLevel: _placementLevel(
        json['curriculumStartLevel']?.toString(),
      ),
      recommendedStartTaskOrder:
          _boundedInt(json['recommendedStartTaskOrder'], 1, 50),
      learningGoal: _learningGoal(json['learningGoal']?.toString()),
    );
  }


  static String? _placementLevel(String? raw) {
    final value = raw?.trim().toUpperCase();
    return const <String>{'A1', 'A2', 'B1', 'B2'}.contains(value)
        ? value
        : null;
  }

  static String? _learningGoal(String? raw) {
    final value = raw?.trim();
    return const <String>{
      'general',
      'dailyLife',
      'work',
      'studyExam',
      'travel',
    }.contains(value)
        ? value
        : null;
  }

  static int _boundedInt(Object? raw, int min, int max) {
    final value =
        raw is num ? raw.toInt() : int.tryParse(raw?.toString() ?? '');
    return (value ?? min).clamp(min, max).toInt();
  }

  static double _boundedDouble(Object? raw, double min, double max) {
    final value =
        raw is num ? raw.toDouble() : double.tryParse(raw?.toString() ?? '');
    return (value ?? min).clamp(min, max).toDouble();
  }
}
