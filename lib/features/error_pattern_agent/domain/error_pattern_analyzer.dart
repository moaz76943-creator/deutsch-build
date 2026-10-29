import 'error_pattern_models.dart';

final class ErrorPatternAnalyzer {
  const ErrorPatternAnalyzer();

  static const Set<String> _genderArticles = <String>{'der', 'die', 'das'};
  static const Set<String> _caseArticles = <String>{
    'der', 'die', 'das', 'den', 'dem', 'des',
    'ein', 'eine', 'einen', 'einem', 'einer', 'eines',
    'kein', 'keine', 'keinen', 'keinem', 'keiner', 'keines',
  };

  ErrorPatternType? classify(LearningFailureSignal signal) {
    if (signal.explicitType != null) return signal.explicitType;
    final tag = _normalize(signal.skillTag);
    final expected = _normalize(signal.expected);
    final actual = _normalize(signal.actual);

    if (_containsAny(tag, const <String>{
      'word_order', 'wordorder', 'sentence_reorder', 'reorder', 'v2',
    })) {
      return ErrorPatternType.wordOrderDrift;
    }
    if (_containsAny(tag, const <String>{
      'case', 'akkusativ', 'accusative', 'dativ', 'dative',
      'genitiv', 'genitive', 'nominativ', 'nominative',
    })) {
      return ErrorPatternType.caseMismatch;
    }
    if (_containsAny(tag, const <String>{
      'gender', 'article_gender', 'noun_gender',
    })) {
      return ErrorPatternType.genderConfusion;
    }

    if (_genderArticles.contains(expected) &&
        _genderArticles.contains(actual) &&
        expected != actual) {
      return ErrorPatternType.genderConfusion;
    }
    if (_caseArticles.contains(expected) &&
        _caseArticles.contains(actual) &&
        expected != actual) {
      return ErrorPatternType.caseMismatch;
    }
    if (signal.source == ErrorEventSource.grammar &&
        _sameWordsDifferentOrder(expected, actual)) {
      return ErrorPatternType.wordOrderDrift;
    }
    return null;
  }

  ErrorLogEntry? entryFromSignal(LearningFailureSignal signal) {
    final type = classify(signal);
    if (type == null) return null;
    return ErrorLogEntry(
      id: 'diag_${signal.occurredAt.toUtc().microsecondsSinceEpoch}_${type.name}',
      type: type,
      focus: _bounded(signal.focus, 160),
      expected: _bounded(signal.expected, 240),
      actual: _bounded(signal.actual, 240),
      source: signal.source,
      timestamp: signal.occurredAt.toUtc(),
    );
  }

  BlindSpotReport buildReport(
    Iterable<ErrorLogEntry> entries, {
    DateTime? now,
  }) {
    final safeNow = (now ?? DateTime.now()).toUtc();
    final all = entries.toList(growable: false);
    if (all.isEmpty) {
      return BlindSpotReport(
        generatedAt: safeNow,
        totalErrors: 0,
        topBlindSpots: const <BlindSpotDiagnostic>[],
      );
    }

    final byType = <ErrorPatternType, List<ErrorLogEntry>>{};
    for (final entry in all) {
      byType.putIfAbsent(entry.type, () => <ErrorLogEntry>[]).add(entry);
    }

    final diagnostics = <BlindSpotDiagnostic>[];
    for (final pair in byType.entries) {
      final group = pair.value
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final count = group.length;
      final frequency = count / all.length;
      final focus = _topFocus(group);
      diagnostics.add(
        BlindSpotDiagnostic(
          type: pair.key,
          count: count,
          frequency: frequency,
          severity: _severity(count, frequency),
          focus: focus,
          recommendationAr: recommendationFor(pair.key),
          commonActual: group.first.actual,
          expectedExample: group.first.expected,
        ),
      );
    }

    diagnostics.sort((a, b) {
      final countOrder = b.count.compareTo(a.count);
      if (countOrder != 0) return countOrder;
      final frequencyOrder = b.frequency.compareTo(a.frequency);
      if (frequencyOrder != 0) return frequencyOrder;
      return a.type.index.compareTo(b.type.index);
    });

    return BlindSpotReport(
      generatedAt: safeNow,
      totalErrors: all.length,
      topBlindSpots: List<BlindSpotDiagnostic>.unmodifiable(
        diagnostics.take(3),
      ),
    );
  }

  String recommendationFor(ErrorPatternType type) => switch (type) {
        ErrorPatternType.genderConfusion =>
          'راجع الاسم دائماً مع أداة تعريفه، ثم اختبر der/die/das في جمل قصيرة قبل الانتقال لكلمة جديدة.',
        ErrorPatternType.caseMismatch =>
          'حدّد وظيفة الاسم أولاً، ثم طبّق أداة الحالة: Nominativ أو Akkusativ أو Dativ قبل اختيار النهاية.',
        ErrorPatternType.wordOrderDrift =>
          'ابنِ الجملة على قاعدة الفعل في الموقع الثاني، وحدد موضع الفعل المنفصل أو المصدر قبل إضافة التفاصيل.',
      };

  DiagnosticSeverity _severity(int count, double frequency) {
    if (count >= 5 && frequency >= 0.35) return DiagnosticSeverity.high;
    if (count >= 3 || frequency >= 0.25) return DiagnosticSeverity.moderate;
    return DiagnosticSeverity.low;
  }

  String _topFocus(List<ErrorLogEntry> entries) {
    final counts = <String, int>{};
    for (final entry in entries) {
      final focus = entry.focus.trim();
      if (focus.isEmpty) continue;
      counts.update(focus, (value) => value + 1, ifAbsent: () => 1);
    }
    if (counts.isEmpty) return 'قاعدة عامة';
    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final countOrder = b.value.compareTo(a.value);
        return countOrder != 0 ? countOrder : a.key.compareTo(b.key);
      });
    return ranked.first.key;
  }

  bool _sameWordsDifferentOrder(String expected, String actual) {
    final expectedParts =
        expected.split(' ').where((x) => x.isNotEmpty).toList();
    final actualParts =
        actual.split(' ').where((x) => x.isNotEmpty).toList();
    if (expectedParts.length < 2 || expectedParts.length != actualParts.length) {
      return false;
    }
    if (expectedParts.join(' ') == actualParts.join(' ')) return false;
    expectedParts.sort();
    actualParts.sort();
    return expectedParts.join('\u0000') == actualParts.join('\u0000');
  }

  bool _containsAny(String value, Set<String> needles) =>
      needles.any(value.contains);

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _bounded(String value, int max) {
    final normalized = value.trim();
    return normalized.length <= max
        ? normalized
        : normalized.substring(0, max);
  }
}
