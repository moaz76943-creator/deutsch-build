import 'dart:collection';
import 'dart:convert';
import 'polyglot_unified_core.dart';

/// حالة التكرار المتباعد (SM-2) لوحدة تعليمية واحدة (بدون أي بيانات شخصية)
class SrsReviewCardState {
  final String unitId;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReviewAt;
  final int totalReviews;
  final int lapseCount;

  const SrsReviewCardState({
    required this.unitId,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.easeFactor = 2.5,
    required this.nextReviewAt,
    this.totalReviews = 0,
    this.lapseCount = 0,
  });

  bool isDue(DateTime now) => !nextReviewAt.isAfter(now);

  SrsReviewCardState copyWith({
    int? repetitions,
    int? intervalDays,
    double? easeFactor,
    DateTime? nextReviewAt,
    int? totalReviews,
    int? lapseCount,
  }) {
    return SrsReviewCardState(
      unitId: unitId,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      totalReviews: totalReviews ?? this.totalReviews,
      lapseCount: lapseCount ?? this.lapseCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'easeFactor': easeFactor,
        'nextReviewAt': nextReviewAt.toUtc().toIso8601String(),
        'totalReviews': totalReviews,
        'lapseCount': lapseCount,
      };

  factory SrsReviewCardState.fromJson(Map<String, dynamic> json) {
    return SrsReviewCardState(
      unitId: json['unitId'] as String,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String).toUtc(),
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      lapseCount: (json['lapseCount'] as num?)?.toInt() ?? 0,
    );
  }
}

/// محرك التكرار المتباعد الموحد (Offline-First SM-2 Scheduler)
/// يعمل على كافة الوحدات في PolyglotUnifiedRegistry دون الحاجة لأي اتصال أو PII.
class PolyglotSrsScheduler {
  final Map<String, SrsReviewCardState> _cards = {};

  /// تسجيل مراجعة جديدة بجودة من 0 (نسيان تام) إلى 5 (إتقان فوري)
  SrsReviewCardState recordReview(
    String unitId,
    int quality, {
    DateTime? now,
  }) {
    final clampedQuality = quality.clamp(0, 5);
    final timestamp = (now ?? DateTime.now()).toUtc();
    final current = _cards[unitId] ??
        SrsReviewCardState(
          unitId: unitId,
          nextReviewAt: timestamp,
        );

    int nextReps = current.repetitions;
    int nextInterval = current.intervalDays;
    int nextLapses = current.lapseCount;

    if (clampedQuality < 3) {
      nextReps = 0;
      nextInterval = 1;
      nextLapses += 1;
    } else {
      if (nextReps == 0) {
        nextInterval = 1;
      } else if (nextReps == 1) {
        nextInterval = 6;
      } else {
        nextInterval = (current.intervalDays * current.easeFactor).round();
      }
      nextReps += 1;
    }

    final deltaEase =
        0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02);
    final nextEase = (current.easeFactor + deltaEase).clamp(1.3, 3.0);

    final updated = current.copyWith(
      repetitions: nextReps,
      intervalDays: nextInterval,
      easeFactor: nextEase,
      nextReviewAt: timestamp.add(Duration(days: nextInterval)),
      totalReviews: current.totalReviews + 1,
      lapseCount: nextLapses,
    );

    _cards[unitId] = updated;
    return updated;
  }

  /// استرجاع قائمة الوحدات المستحقة للمراجعة الآن
  List<PolyglotLearningUnit> getDueUnits(
    PolyglotUnifiedRegistry registry, {
    String? languageCode,
    DateTime? now,
    int limit = 20,
  }) {
    final checkTime = (now ?? DateTime.now()).toUtc();
    final candidates = registry.queryUnits(languageCode: languageCode);
    final due = <PolyglotLearningUnit>[];

    for (final unit in candidates) {
      final state = _cards[unit.id];
      if (state == null || state.isDue(checkTime)) {
        due.add(unit);
        if (due.length >= limit) break;
      }
    }
    return UnmodifiableListView(due);
  }

  /// تصدير حالة التكرار المتباعد بصيغة JSON للتخزين المحلي المشفر
  String exportProgressJson() {
    final payload = {
      'schemaVersion': 1,
      'zeroPii': true,
      'cards': _cards.values.map((c) => c.toJson()).toList(growable: false),
    };
    return jsonEncode(payload);
  }

  /// استيراد حالة التكرار المتباعد من التخزين المحلي مع حماية ضد تلف السجلات
  int importProgressJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) return 0;
      final cardsList = decoded['cards'];
      if (cardsList is! List) return 0;

      var imported = 0;
      for (final item in cardsList) {
        if (item is Map<String, dynamic> && item['unitId'] is String) {
          final card = SrsReviewCardState.fromJson(item);
          _cards[card.unitId] = card;
          imported++;
        }
      }
      return imported;
    } catch (_) {
      return 0;
    }
  }

  SrsReviewCardState? stateOf(String unitId) => _cards[unitId];
  int get trackedCardCount => _cards.length;
}

/// محمل حزم اللغات والمحتوى الديناميكي من JSON دون الحاجة لكتابة كود Dart لكل درس
class PolyglotJsonPackLoader {
  static CefrProficiencyLevel _parseLevel(String? raw) {
    switch ((raw ?? 'b1').toLowerCase()) {
      case 'a1':
        return CefrProficiencyLevel.a1;
      case 'a2':
        return CefrProficiencyLevel.a2;
      case 'b1':
        return CefrProficiencyLevel.b1;
      case 'b2':
        return CefrProficiencyLevel.b2;
      case 'c1':
        return CefrProficiencyLevel.c1;
      case 'c2':
        return CefrProficiencyLevel.c2;
      default:
        return CefrProficiencyLevel.b1;
    }
  }

  /// تحميل حزمة لغة + وحداتها مباشرة داخل PolyglotUnifiedRegistry
  static int loadIntoRegistry(
    PolyglotUnifiedRegistry registry,
    String rawJsonPack,
  ) {
    final decoded = jsonDecode(rawJsonPack);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Polyglot JSON pack root object');
    }

    final langJson = decoded['language'];
    if (langJson is Map<String, dynamic>) {
      registry.registerLanguage(LanguageDescriptor(
        isoCode: langJson['isoCode'] as String,
        nativeName: langJson['nativeName'] as String,
        arabicName: langJson['arabicName'] as String,
        isRightToLeft: (langJson['isRightToLeft'] as bool?) ?? false,
      ));
    }

    final rawUnits = decoded['units'];
    if (rawUnits is! List) return 0;

    final parsedUnits = <PolyglotLearningUnit>[];
    for (final u in rawUnits) {
      if (u is! Map<String, dynamic>) continue;
      parsedUnits.add(PolyglotLearningUnit(
        id: u['id'] as String,
        languageCode: (u['languageCode'] as String?) ?? 'de',
        level: _parseLevel(u['level'] as String?),
        domainId: (u['domainId'] as String?) ?? 'general',
        categoryId: (u['categoryId'] as String?) ?? 'general',
        title: u['title'] as String,
        targetExpression: u['targetExpression'] as String,
        contextualSentence: u['contextualSentence'] as String,
        commonPitfall: (u['commonPitfall'] as String?) ?? '—',
        arabicExplanation: u['arabicExplanation'] as String,
        tags: (u['tags'] as List?)?.cast<String>() ?? const [],
      ));
    }

    registry.registerUnits(parsedUnits);
    return parsedUnits.length;
  }
}
