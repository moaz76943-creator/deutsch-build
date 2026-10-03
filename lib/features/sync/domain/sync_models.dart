enum SyncStatus { offline, syncing, upToDate, conflictDetected }

enum SyncConflictResolutionStrategy {
  lastWriteWinsProtectHigherStreak,
  mergeProgress,
  keepLocal,
  keepRemote,
}

final class SyncSrsRecord {
  const SyncSrsRecord({
    required this.key,
    required this.updatedAtUtc,
    required this.dueAtUtc,
    required this.repetitions,
    required this.lapses,
    required this.successes,
    required this.failures,
    this.intervalDays = 0,
    this.difficulty = 1.3,
    this.stabilityDays = 0,
    this.lastReviewedAtUtc,
  });

  final String key;
  final DateTime updatedAtUtc;
  final DateTime dueAtUtc;
  final int repetitions;
  final int intervalDays;
  final int lapses;
  final int successes;
  final int failures;
  final double difficulty;
  final double stabilityDays;
  final DateTime? lastReviewedAtUtc;

  Map<String, Object?> toJson() => <String, Object?>{
        'key': key,
        'updatedAtUtc': updatedAtUtc.toUtc().toIso8601String(),
        'dueAtUtc': dueAtUtc.toUtc().toIso8601String(),
        'repetitions': repetitions,
        'intervalDays': intervalDays,
        'lapses': lapses,
        'successes': successes,
        'failures': failures,
        'difficulty': difficulty,
        'stabilityDays': stabilityDays,
        if (lastReviewedAtUtc != null)
          'lastReviewedAtUtc': lastReviewedAtUtc!.toUtc().toIso8601String(),
      };

  factory SyncSrsRecord.fromJson(Map<String, Object?> json) {
    final lastRaw = json['lastReviewedAtUtc'];
    DateTime? lastReviewed;
    if (lastRaw is String) {
      lastReviewed = DateTime.tryParse(lastRaw)?.toUtc();
    }
    return SyncSrsRecord(
      key: _requiredText(json['key'], 'key'),
      updatedAtUtc: _requiredUtc(json['updatedAtUtc'], 'updatedAtUtc'),
      dueAtUtc: _requiredUtc(json['dueAtUtc'], 'dueAtUtc'),
      repetitions: _boundedInt(json['repetitions'], 0, 10000),
      intervalDays: _boundedInt(json['intervalDays'], 0, 3650),
      lapses: _boundedInt(json['lapses'], 0, 10000),
      successes: _boundedInt(json['successes'], 0, 100000),
      failures: _boundedInt(json['failures'], 0, 100000),
      difficulty: _boundedDouble(json['difficulty'], .5, 2.5, 1.3),
      stabilityDays: _boundedDouble(
        json['stabilityDays'],
        0,
        3650,
        0,
      ),
      lastReviewedAtUtc: lastReviewed,
    );
  }
}

final class SyncProgressSnapshot {
  SyncProgressSnapshot({
    required this.revision,
    required DateTime updatedAtUtc,
    required int currentStreak,
    required int longestStreak,
    required int totalXp,
    required Map<String, SyncSrsRecord> srs,
    required Set<String> achievementIds,
  })  : updatedAtUtc = updatedAtUtc.toUtc(),
        currentStreak = currentStreak.clamp(0, 10000).toInt(),
        longestStreak = longestStreak.clamp(0, 10000).toInt(),
        totalXp = totalXp.clamp(0, 100000000).toInt(),
        srs = Map<String, SyncSrsRecord>.unmodifiable(srs),
        achievementIds = Set<String>.unmodifiable(achievementIds) {
    if (revision.trim().isEmpty || revision.length > 160) {
      throw ArgumentError.value(revision, 'revision', 'invalid revision');
    }
    if (this.longestStreak < this.currentStreak) {
      throw ArgumentError('longestStreak cannot be below currentStreak');
    }
  }

  final String revision;
  final DateTime updatedAtUtc;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final Map<String, SyncSrsRecord> srs;
  final Set<String> achievementIds;

  SyncProgressSnapshot copyWith({
    String? revision,
    DateTime? updatedAtUtc,
    int? currentStreak,
    int? longestStreak,
    int? totalXp,
    Map<String, SyncSrsRecord>? srs,
    Set<String>? achievementIds,
  }) {
    return SyncProgressSnapshot(
      revision: revision ?? this.revision,
      updatedAtUtc: updatedAtUtc ?? this.updatedAtUtc,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalXp: totalXp ?? this.totalXp,
      srs: srs ?? this.srs,
      achievementIds: achievementIds ?? this.achievementIds,
    );
  }

  Map<String, Object?> toJson() {
    final achievements = achievementIds.toList(growable: false)..sort();
    return <String, Object?>{
      'revision': revision,
      'updatedAtUtc': updatedAtUtc.toIso8601String(),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalXp': totalXp,
      'srs': <String, Object?>{
        for (final entry in srs.entries) entry.key: entry.value.toJson(),
      },
      'achievementIds': achievements,
    };
  }

  factory SyncProgressSnapshot.fromJson(Map<String, Object?> json) {
    final rawSrs = json['srs'];
    final parsedSrs = <String, SyncSrsRecord>{};
    if (rawSrs is Map) {
      for (final entry in rawSrs.entries) {
        if (entry.key is! String || entry.value is! Map) continue;
        final value = <String, Object?>{
          for (final child in (entry.value as Map).entries)
            if (child.key is String) (child.key as String): child.value,
        };
        try {
          parsedSrs[entry.key as String] = SyncSrsRecord.fromJson(value);
        } on FormatException {
          continue;
        } on ArgumentError {
          continue;
        }
      }
    }

    final rawAchievements = json['achievementIds'];
    final achievements = <String>{};
    if (rawAchievements is List) {
      for (final value in rawAchievements.whereType<String>()) {
        final normalized = value.trim();
        if (normalized.isNotEmpty && normalized.length <= 120) {
          achievements.add(normalized);
        }
      }
    }

    final current = _boundedInt(json['currentStreak'], 0, 10000);
    final longest = _boundedInt(json['longestStreak'], current, 10000);
    return SyncProgressSnapshot(
      revision: _requiredText(json['revision'], 'revision'),
      updatedAtUtc: _requiredUtc(json['updatedAtUtc'], 'updatedAtUtc'),
      currentStreak: current,
      longestStreak: longest,
      totalXp: _boundedInt(json['totalXp'], 0, 100000000),
      srs: parsedSrs,
      achievementIds: achievements,
    );
  }
}

final class SyncQueueItem {
  SyncQueueItem({
    required this.id,
    required this.entityKey,
    required DateTime updatedAtUtc,
    required Map<String, Object?> payload,
  })  : updatedAtUtc = updatedAtUtc.toUtc(),
        payload = Map<String, Object?>.unmodifiable(payload) {
    if (id.trim().isEmpty || id.length > 160) {
      throw ArgumentError.value(id, 'id', 'invalid mutation id');
    }
    if (entityKey.trim().isEmpty || entityKey.length > 200) {
      throw ArgumentError.value(entityKey, 'entityKey', 'invalid entity key');
    }
  }

  final String id;
  final String entityKey;
  final DateTime updatedAtUtc;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'entityKey': entityKey,
        'updatedAtUtc': updatedAtUtc.toIso8601String(),
        'payload': payload,
      };

  factory SyncQueueItem.fromJson(Map<String, Object?> json) {
    final rawPayload = json['payload'];
    final payload = <String, Object?>{};
    if (rawPayload is Map) {
      for (final entry in rawPayload.entries) {
        if (entry.key is String) {
          payload[entry.key as String] = entry.value;
        }
      }
    }
    return SyncQueueItem(
      id: _requiredText(json['id'], 'id'),
      entityKey: _requiredText(json['entityKey'], 'entityKey'),
      updatedAtUtc: _requiredUtc(json['updatedAtUtc'], 'updatedAtUtc'),
      payload: payload,
    );
  }
}

final class SyncConflict {
  const SyncConflict({
    required this.local,
    required this.remote,
  });

  final SyncProgressSnapshot local;
  final SyncProgressSnapshot remote;
}

final class CloudPushResult {
  const CloudPushResult._({
    required this.applied,
    this.snapshot,
    this.conflict,
  });

  factory CloudPushResult.applied(SyncProgressSnapshot snapshot) =>
      CloudPushResult._(applied: true, snapshot: snapshot);

  factory CloudPushResult.conflict(SyncProgressSnapshot remote) =>
      CloudPushResult._(applied: false, conflict: remote);

  final bool applied;
  final SyncProgressSnapshot? snapshot;
  final SyncProgressSnapshot? conflict;
}

String _requiredText(Object? value, String field) {
  if (value is! String) throw FormatException('missing $field');
  final normalized = value.trim();
  if (normalized.isEmpty) throw FormatException('empty $field');
  return normalized;
}

DateTime _requiredUtc(Object? value, String field) {
  if (value is! String) throw FormatException('missing $field');
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('invalid $field');
  return parsed.toUtc();
}

int _boundedInt(Object? value, int min, int max) {
  final parsed = value is num ? value.toInt() : int.tryParse('$value');
  final safe = parsed ?? min;
  return safe.clamp(min, max).toInt();
}

double _boundedDouble(
  Object? value,
  double min,
  double max,
  double fallback,
) {
  final parsed = value is num ? value.toDouble() : double.tryParse('$value');
  if (parsed == null || !parsed.isFinite) return fallback;
  return parsed.clamp(min, max).toDouble();
}
