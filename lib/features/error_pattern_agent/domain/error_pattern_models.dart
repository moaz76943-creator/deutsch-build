enum ErrorPatternType {
  genderConfusion,
  caseMismatch,
  wordOrderDrift;

  String get wireName => switch (this) {
        ErrorPatternType.genderConfusion => 'gender_confusion',
        ErrorPatternType.caseMismatch => 'case_mismatch',
        ErrorPatternType.wordOrderDrift => 'word_order_drift',
      };

  String get labelAr => switch (this) {
        ErrorPatternType.genderConfusion => 'التباس جنس الاسم وأداة التعريف',
        ErrorPatternType.caseMismatch => 'عدم تطابق الحالة الإعرابية',
        ErrorPatternType.wordOrderDrift => 'انحراف ترتيب الكلمات',
      };

  static ErrorPatternType? fromWireName(String? value) => switch (value) {
        'gender_confusion' => ErrorPatternType.genderConfusion,
        'case_mismatch' => ErrorPatternType.caseMismatch,
        'word_order_drift' => ErrorPatternType.wordOrderDrift,
        _ => null,
      };
}

enum DiagnosticSeverity {
  low('للمراقبة'),
  moderate('متكرر'),
  high('متكرر بوضوح');

  const DiagnosticSeverity(this.labelAr);
  final String labelAr;
}

enum ErrorEventSource { flashcard, grammar }

final class LearningFailureSignal {
  const LearningFailureSignal({
    required this.source,
    required this.skillTag,
    required this.expected,
    required this.actual,
    required this.focus,
    required this.occurredAt,
    this.explicitType,
  });

  final ErrorEventSource source;
  final String skillTag;
  final String expected;
  final String actual;
  final String focus;
  final DateTime occurredAt;
  final ErrorPatternType? explicitType;
}

final class ErrorLogEntry {
  const ErrorLogEntry({
    required this.id,
    required this.type,
    required this.focus,
    required this.expected,
    required this.actual,
    required this.source,
    required this.timestamp,
  });

  final String id;
  final ErrorPatternType type;
  final String focus;
  final String expected;
  final String actual;
  final ErrorEventSource source;
  final DateTime timestamp;

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'type': type.wireName,
        'focus': focus,
        'expected': expected,
        'actual': actual,
        'source': source.name,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  static ErrorLogEntry? fromJson(Map<String, Object?> json) {
    final type = ErrorPatternType.fromWireName(json['type']?.toString());
    final timestamp = DateTime.tryParse(json['timestamp']?.toString() ?? '');
    if (type == null || timestamp == null) return null;
    final source = switch (json['source']?.toString()) {
      'grammar' => ErrorEventSource.grammar,
      'flashcard' => ErrorEventSource.flashcard,
      _ => null,
    };
    if (source == null) return null;
    final id = _bounded(json['id']?.toString() ?? '', 160);
    if (id.isEmpty) return null;
    return ErrorLogEntry(
      id: id,
      type: type,
      focus: _bounded(json['focus']?.toString() ?? '', 160),
      expected: _bounded(json['expected']?.toString() ?? '', 240),
      actual: _bounded(json['actual']?.toString() ?? '', 240),
      source: source,
      timestamp: timestamp.toUtc(),
    );
  }

  static String _bounded(String value, int max) {
    final normalized = value.trim();
    if (normalized.length <= max) return normalized;
    return normalized.substring(0, max);
  }
}

final class BlindSpotDiagnostic {
  const BlindSpotDiagnostic({
    required this.type,
    required this.count,
    required this.frequency,
    required this.severity,
    required this.focus,
    required this.recommendationAr,
    required this.commonActual,
    required this.expectedExample,
  });

  final ErrorPatternType type;
  final int count;
  final double frequency;
  final DiagnosticSeverity severity;
  final String focus;
  final String recommendationAr;
  final String commonActual;
  final String expectedExample;
}

final class BlindSpotReport {
  const BlindSpotReport({
    required this.generatedAt,
    required this.totalErrors,
    required this.topBlindSpots,
  });

  final DateTime generatedAt;
  final int totalErrors;
  final List<BlindSpotDiagnostic> topBlindSpots;

  bool get isEmpty => topBlindSpots.isEmpty;
}
