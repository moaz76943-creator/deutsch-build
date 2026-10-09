import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum ReviewRating { again, hard, good, easy }

class SrsItemState {
  final String wordId;
  final int repetitions;
  final int intervalDays;
  final double easeFactor;
  final DateTime nextReviewDate;

  SrsItemState({
    required this.wordId,
    required this.repetitions,
    required this.intervalDays,
    required this.easeFactor,
    required this.nextReviewDate,
  });

  Map<String, dynamic> toMap() => {
    'wordId': wordId,
    'repetitions': repetitions,
    'intervalDays': intervalDays,
    'easeFactor': easeFactor,
    'nextReviewDate': nextReviewDate.toIso8601String(),
  };

  factory SrsItemState.fromMap(Map<String, dynamic> map) => SrsItemState(
    wordId: map['wordId'] as String,
    repetitions: (map['repetitions'] as num).toInt(),
    intervalDays: (map['intervalDays'] as num).toInt(),
    easeFactor: (map['easeFactor'] as num).toDouble(),
    nextReviewDate: DateTime.parse(map['nextReviewDate'] as String),
  );

  factory SrsItemState.initial(String wordId) => SrsItemState(
    wordId: wordId,
    repetitions: 0,
    intervalDays: 0,
    easeFactor: 2.5,
    nextReviewDate: DateTime.now(),
  );
}

class SrsEngine {
  static const String _prefix = 'srs_state_';

  /// استرجاع حالة الكلمة الحالية من الذاكرة المحلية
  static Future<SrsItemState> getItemState(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$wordId');
    if (raw == null) return SrsItemState.initial(wordId);
    try {
      return SrsItemState.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return SrsItemState.initial(wordId);
    }
  }

  /// حساب الجدولة الجديدة وحفظها محلياً
  static Future<SrsItemState> processReview(String wordId, ReviewRating rating) async {
    final current = await getItemState(wordId);
    int reps = current.repetitions;
    int interval = current.intervalDays;
    double ease = current.easeFactor;

    switch (rating) {
      case ReviewRating.again:
        reps = 0;
        interval = 0;
        ease = (ease - 0.2).clamp(1.3, 3.0);
        break;
      case ReviewRating.hard:
        reps += 1;
        interval = (interval == 0) ? 1 : (interval * 1.2).round();
        ease = (ease - 0.15).clamp(1.3, 3.0);
        break;
      case ReviewRating.good:
        reps += 1;
        if (reps == 1) {
          interval = 1;
        } else if (reps == 2) {
          interval = 6;
        } else {
          interval = (interval * ease).round();
        }
        break;
      case ReviewRating.easy:
        reps += 1;
        if (reps == 1) {
          interval = 4;
        } else if (reps == 2) {
          interval = 10;
        } else {
          interval = (interval * ease * 1.3).round();
        }
        ease = (ease + 0.15).clamp(1.3, 3.0);
        break;
    }

    final nextDate = DateTime.now().add(Duration(days: interval));
    final updated = SrsItemState(
      wordId: wordId,
      repetitions: reps,
      intervalDays: interval,
      easeFactor: ease,
      nextReviewDate: nextDate,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$wordId', jsonEncode(updated.toMap()));
    return updated;
  }
}
