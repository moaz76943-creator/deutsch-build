import 'package:flutter/foundation.dart';

@immutable
class VerbChallengeAttempt {
  final String id;
  final String infinitive;
  final String person;
  final bool isCorrect;
  final DateTime timestamp;
  final Duration timeTaken;

  const VerbChallengeAttempt({
    required this.id,
    required this.infinitive,
    required this.person,
    required this.isCorrect,
    required this.timestamp,
    required this.timeTaken,
  });

  VerbChallengeAttempt copyWith({
    String? id,
    String? infinitive,
    String? person,
    bool? isCorrect,
    DateTime? timestamp,
    Duration? timeTaken,
  }) {
    return VerbChallengeAttempt(
      id: id ?? this.id,
      infinitive: infinitive ?? this.infinitive,
      person: person ?? this.person,
      isCorrect: isCorrect ?? this.isCorrect,
      timestamp: timestamp ?? this.timestamp,
      timeTaken: timeTaken ?? this.timeTaken,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'infinitive': infinitive,
      'person': person,
      'isCorrect': isCorrect ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'timeTaken': timeTaken.inMilliseconds,
    };
  }

  factory VerbChallengeAttempt.fromMap(Map<String, dynamic> map) {
    return VerbChallengeAttempt(
      id: map['id'] as String,
      infinitive: map['infinitive'] as String,
      person: map['person'] as String,
      isCorrect: (map['isCorrect'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      timeTaken: Duration(milliseconds: map['timeTaken'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerbChallengeAttempt &&
        other.id == id &&
        other.infinitive == infinitive &&
        other.person == person &&
        other.isCorrect == isCorrect &&
        other.timestamp == timestamp &&
        other.timeTaken == timeTaken;
  }

  @override
  int get hashCode {
    return Object.hash(id, infinitive, person, isCorrect, timestamp, timeTaken);
  }
}
