import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_diagnostic_repository.dart';
import 'package:deutsch_bilarabi/features/error_pattern_agent/domain/error_pattern_models.dart';
import 'package:deutsch_bilarabi/features/grammar/application/grammar_drill_notifier.dart';
import 'package:deutsch_bilarabi/features/grammar/domain/grammar_drill_models.dart';
import 'package:flutter_test/flutter_test.dart';

final class _CapturingSink implements ErrorDiagnosticSink {
  final List<LearningFailureSignal> signals = <LearningFailureSignal>[];

  @override
  Future<void> recordFailure(LearningFailureSignal signal) async {
    signals.add(signal);
  }
}

void main() {
  test('case drill emits a case-tagged diagnostic signal on failure', () async {
    final sink = _CapturingSink();
    final notifier = GrammarDrillNotifier(
      const <GrammarDrill>[
        CaseSelectionDrill(
          id: 'case-1',
          level: GrammarLevel.a1,
          titleAr: 'Akkusativ',
          instructionAr: 'اختر الأداة',
          reinforcementAr: 'راجع الحالة',
          targetCase: GrammarCase.accusative,
          sentenceBefore: 'Ich sehe',
          noun: 'Mann',
          sentenceAfter: '.',
          options: <String>['der', 'den'],
          expectedArticle: 'den',
          explanationAr: 'المفعول به المذكر يأخذ den.',
        ),
      ],
      errorDiagnosticSink: sink,
    );

    notifier.setAnswer('der');
    notifier.checkAnswer();
    await Future<void>.delayed(Duration.zero);

    expect(sink.signals, hasLength(1));
    expect(sink.signals.single.source, ErrorEventSource.grammar);
    expect(sink.signals.single.skillTag, 'case_accusative');
    expect(sink.signals.single.expected, 'den');
    expect(sink.signals.single.actual, 'der');
    expect(sink.signals.single.focus, 'Mann');
  });

  test('sentence reorder emits normalized word-order evidence', () async {
    final sink = _CapturingSink();
    final notifier = GrammarDrillNotifier(
      const <GrammarDrill>[
        SentenceReorderExercise(
          id: 'order-1',
          level: GrammarLevel.a1,
          titleAr: 'V2',
          instructionAr: 'رتب',
          reinforcementAr: 'الفعل ثانياً',
          translationAr: 'أنا أذهب اليوم',
          tokens: <GrammarToken>[
            GrammarToken(id: 'today', text: 'Heute'),
            GrammarToken(id: 'go', text: 'gehe'),
            GrammarToken(id: 'i', text: 'ich'),
          ],
          correctTokenIds: <String>['today', 'go', 'i'],
        ),
      ],
      errorDiagnosticSink: sink,
    );

    notifier.addSentenceToken('today');
    notifier.addSentenceToken('i');
    notifier.addSentenceToken('go');
    notifier.checkAnswer();
    await Future<void>.delayed(Duration.zero);

    expect(sink.signals, hasLength(1));
    expect(sink.signals.single.skillTag, 'sentence_reorder');
    expect(sink.signals.single.expected, 'Heute gehe ich');
    expect(sink.signals.single.actual, 'Heute ich gehe');
  });
}
