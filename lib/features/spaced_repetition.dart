import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SpacedRepetitionItem {
  final String wordId;
  int stage;
  DateTime nextReviewDate;

  SpacedRepetitionItem({
    required this.wordId,
    this.stage = 1,
    required this.nextReviewDate,
  });

  Map<String, dynamic> toMap() => {
    'wordId': wordId,
    'stage': stage,
    'nextReviewDate': nextReviewDate.toIso8601String(),
  };

  factory SpacedRepetitionItem.fromMap(Map<String, dynamic> map) => SpacedRepetitionItem(
    wordId: map['wordId'] as String,
    stage: map['stage'] as int,
    nextReviewDate: DateTime.parse(map['nextReviewDate'] as String),
  );
}

class SpacedRepetitionEngine {
  static const String _storageKey = 'srs_records';

  static DateTime _calculateNextReview(int stage) {
    final now = DateTime.now();
    switch (stage) {
      case 1:
        return now.add(const Duration(hours: 12));
      case 2:
        return now.add(const Duration(days: 1));
      case 3:
        return now.add(const Duration(days: 3));
      case 4:
        return now.add(const Duration(days: 7));
      case 5:
        return now.add(const Duration(days: 21));
      default:
        return now.add(const Duration(days: 30));
    }
  }

  static Future<void> recordAnswer({required String wordId, required bool correct}) async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);
    Map<String, dynamic> map = rawData != null ? json.decode(rawData) : {};

    SpacedRepetitionItem item;
    if (map.containsKey(wordId)) {
      item = SpacedRepetitionItem.fromMap(Map<String, dynamic>.from(map[wordId]));
      if (correct) {
        item.stage = (item.stage < 5) ? item.stage + 1 : 5;
      } else {
        item.stage = 1;
      }
      item.nextReviewDate = _calculateNextReview(item.stage);
    } else {
      item = SpacedRepetitionItem(
        wordId: wordId,
        stage: correct ? 2 : 1,
        nextReviewDate: _calculateNextReview(correct ? 2 : 1),
      );
    }

    map[wordId] = item.toMap();
    await prefs.setString(_storageKey, json.encode(map));
  }

  static Future<List<String>> getDueWords() async {
    final prefs = await SharedPreferences.getInstance();
    final rawData = prefs.getString(_storageKey);
    if (rawData == null) return [];

    final Map<String, dynamic> map = json.decode(rawData);
    final now = DateTime.now();
    final List<String> dueWords = [];

    map.forEach((key, val) {
      final item = SpacedRepetitionItem.fromMap(Map<String, dynamic>.from(val));
      if (item.nextReviewDate.isBefore(now)) {
        dueWords.add(item.wordId);
      }
    });

    return dueWords;
  }
}
