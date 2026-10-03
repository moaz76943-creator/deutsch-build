enum ErrorCategory {
  genderConfusion,
  caseMismatch,
  wordOrderDrift,
  prepositionError,
}

final class ErrorLogEntry {
  ErrorLogEntry({
    required this.id,
    required this.category,
    required this.item,
    required this.context,
    required DateTime timestamp,
  }) : timestamp = timestamp.toUtc() {
    final normalizedId = id.trim();
    final normalizedItem = item.trim();
    if (normalizedId.isEmpty || normalizedId.length > 160) {
      throw ArgumentError.value(id, 'id', 'invalid error id');
    }
    if (normalizedItem.isEmpty || normalizedItem.length > 240) {
      throw ArgumentError.value(item, 'item', 'invalid error item');
    }
    if (context.length > 500) {
      throw ArgumentError.value(context, 'context', 'context too long');
    }
  }

  final String id;
  final ErrorCategory category;
  final String item;
  final String context;
  final DateTime timestamp;
}

final class BlindSpotSummary {
  const BlindSpotSummary({
    required this.topCategory,
    required this.frequencyPercentage,
    required this.adviceAr,
  });

  final ErrorCategory topCategory;
  final double frequencyPercentage;
  final String adviceAr;
}
