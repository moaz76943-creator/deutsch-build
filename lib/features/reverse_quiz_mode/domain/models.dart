class ReverseQuizItem {
  final String id;
  final String conceptId;
  final String german;
  final String arabic;

  const ReverseQuizItem({
    required this.id,
    required this.conceptId,
    required this.german,
    required this.arabic,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conceptId': conceptId,
      'german': german,
      'arabic': arabic,
    };
  }

  factory ReverseQuizItem.fromMap(Map<String, dynamic> map) {
    return ReverseQuizItem(
      id: map['id'] as String,
      conceptId: map['conceptId'] as String,
      german: map['german'] as String,
      arabic: map['arabic'] as String,
    );
  }
}

class ReverseQuizAttempt {
  final String id;
  final String cardId;
  final bool isCorrect;
  final DateTime timestamp;

  const ReverseQuizAttempt({
    required this.id,
    required this.cardId,
    required this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cardId': cardId,
      'isCorrect': isCorrect ? 1 : 0,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory ReverseQuizAttempt.fromMap(Map<String, dynamic> map) {
    return ReverseQuizAttempt(
      id: map['id'] as String,
      cardId: map['cardId'] as String,
      isCorrect: (map['isCorrect'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
