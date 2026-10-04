import 'local_learning_recovery.dart';

final class LocalLearningRecoveryResumeCursor {
  LocalLearningRecoveryResumeCursor({
    required this.pairKey,
    required this.createdAtUtc,
    required Iterable<String> remainingReviewKeys,
  }) : remainingReviewKeys = List<String>.unmodifiable(
          remainingReviewKeys
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .take(8),
        ) {
    if (pairKey.trim().isEmpty) {
      throw ArgumentError.value(pairKey, 'pairKey', 'must not be empty');
    }
  }

  final String pairKey;
  final DateTime createdAtUtc;
  final List<String> remainingReviewKeys;

  Map<String, Object?> toJson() => <String, Object?>{
        'pairKey': pairKey,
        'createdAtUtc': createdAtUtc.toUtc().toIso8601String(),
        'remainingReviewKeys': remainingReviewKeys,
      };

  static LocalLearningRecoveryResumeCursor? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final pairKey = raw['pairKey']?.toString().trim() ?? '';
    final createdAtUtc =
        DateTime.tryParse(raw['createdAtUtc']?.toString() ?? '')?.toUtc();
    final rawKeys = raw['remainingReviewKeys'];
    if (pairKey.isEmpty || createdAtUtc == null || rawKeys is! List) {
      return null;
    }
    final keys = rawKeys
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .take(8)
        .toList(growable: false);
    if (keys.isEmpty) return null;
    return LocalLearningRecoveryResumeCursor(
      pairKey: pairKey,
      createdAtUtc: createdAtUtc,
      remainingReviewKeys: keys,
    );
  }
}

final class LocalLearningRecoverySession {
  const LocalLearningRecoverySession({
    required this.plan,
    required this.resumed,
  });

  final LocalLearningRecoveryPlan plan;
  final bool resumed;
}

final class LocalLearningRecoveryResumePlanner {
  const LocalLearningRecoveryResumePlanner();

  static const Duration resumeTtl = Duration(hours: 24);

  LocalLearningRecoverySession restore({
    required LocalLearningRecoveryPlan plan,
    required LocalLearningRecoveryResumeCursor? cursor,
    required DateTime now,
  }) {
    final at = now.toUtc();
    final validCursor = cursor != null &&
        cursor.pairKey == plan.pairKey &&
        !at.isBefore(cursor.createdAtUtc) &&
        at.difference(cursor.createdAtUtc) <= resumeTtl;

    if (validCursor) {
      final byKey = <String, LocalLearningRecoveryItem>{
        for (final item in plan.items) item.reviewKey: item,
      };
      final remaining = <LocalLearningRecoveryItem>[];
      final seen = <String>{};
      for (final key in cursor.remainingReviewKeys) {
        final item = byKey[key];
        if (item == null || !seen.add(key)) continue;
        remaining.add(item);
      }
      if (remaining.isNotEmpty) {
        return LocalLearningRecoverySession(
          resumed: true,
          plan: LocalLearningRecoveryPlan(
            pairKey: plan.pairKey,
            generatedAtUtc: plan.generatedAtUtc,
            estimatedMinutes: _estimateMinutes(remaining.length),
            items: remaining,
          ),
        );
      }
    }

    return LocalLearningRecoverySession(
      plan: plan,
      resumed: false,
    );
  }

  static int _estimateMinutes(int itemCount) =>
      ((itemCount * 75) / 60).ceil().clamp(5, 10).toInt();
}
