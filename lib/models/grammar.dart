import 'package:flutter/foundation.dart';

@immutable
class GrammarTopic {
  final String id;
  final String level; // A1, A2, B1, B2, C1, C2
  final String titleDe;
  final String titleAr;
  final String summaryAr;
  final List<GrammarRule> rules;
  final List<MiniCheckQuestion> miniChecks;

  const GrammarTopic({
    required this.id,
    required this.level,
    required this.titleDe,
    required this.titleAr,
    required this.summaryAr,
    this.rules = const [],
    this.miniChecks = const [],
  });

  GrammarTopic copyWith({
    String? id,
    String? level,
    String? titleDe,
    String? titleAr,
    String? summaryAr,
    List<GrammarRule>? rules,
    List<MiniCheckQuestion>? miniChecks,
  }) {
    return GrammarTopic(
      id: id ?? this.id,
      level: level ?? this.level,
      titleDe: titleDe ?? this.titleDe,
      titleAr: titleAr ?? this.titleAr,
      summaryAr: summaryAr ?? this.summaryAr,
      rules: rules ?? this.rules,
      miniChecks: miniChecks ?? this.miniChecks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrammarTopic &&
        other.id == id &&
        other.level == level &&
        other.titleDe == titleDe &&
        other.titleAr == titleAr &&
        other.summaryAr == summaryAr &&
        listEquals(other.rules, rules) &&
        listEquals(other.miniChecks, miniChecks);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        level.hashCode ^
        titleDe.hashCode ^
        titleAr.hashCode ^
        summaryAr.hashCode ^
        Object.hashAll(rules) ^
        Object.hashAll(miniChecks);
  }
}

@immutable
class GrammarRule {
  final String id;
  final String title;
  final String explanationAr;
  final List<GrammarExample> examples;
  // Syntax tables can be represented as List of rows (List of columns)
  final List<List<String>> table;

  const GrammarRule({
    required this.id,
    required this.title,
    required this.explanationAr,
    this.examples = const [],
    this.table = const [],
  });

  GrammarRule copyWith({
    String? id,
    String? title,
    String? explanationAr,
    List<GrammarExample>? examples,
    List<List<String>>? table,
  }) {
    return GrammarRule(
      id: id ?? this.id,
      title: title ?? this.title,
      explanationAr: explanationAr ?? this.explanationAr,
      examples: examples ?? this.examples,
      table: table ?? this.table,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrammarRule &&
        other.id == id &&
        other.title == title &&
        other.explanationAr == explanationAr &&
        listEquals(other.examples, examples) &&
        _tableEquals(other.table, table);
  }

  bool _tableEquals(List<List<String>> a, List<List<String>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        explanationAr.hashCode ^
        Object.hashAll(examples) ^
        _tableHashCode();
  }

  int _tableHashCode() {
    int hash = 0;
    for (var row in table) {
      hash ^= Object.hashAll(row);
    }
    return hash;
  }
}

@immutable
class GrammarExample {
  final String german;
  final String arabic;

  const GrammarExample({required this.german, required this.arabic});

  GrammarExample copyWith({String? german, String? arabic}) {
    return GrammarExample(
      german: german ?? this.german,
      arabic: arabic ?? this.arabic,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GrammarExample &&
        other.german == german &&
        other.arabic == arabic;
  }

  @override
  int get hashCode => german.hashCode ^ arabic.hashCode;
}

@immutable
class MiniCheckQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanationAr;

  const MiniCheckQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanationAr,
  });

  MiniCheckQuestion copyWith({
    String? id,
    String? questionText,
    List<String>? options,
    int? correctAnswerIndex,
    String? explanationAr,
  }) {
    return MiniCheckQuestion(
      id: id ?? this.id,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      explanationAr: explanationAr ?? this.explanationAr,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MiniCheckQuestion &&
        other.id == id &&
        other.questionText == questionText &&
        listEquals(other.options, options) &&
        other.correctAnswerIndex == correctAnswerIndex &&
        other.explanationAr == explanationAr;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        questionText.hashCode ^
        Object.hashAll(options) ^
        correctAnswerIndex.hashCode ^
        explanationAr.hashCode;
  }
}
