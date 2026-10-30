import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/android_glance_widget_engine.dart';

void main() {
  group('AndroidGlanceWidgetEngine Tests', () {
    const engine = AndroidGlanceWidgetEngine();

    final testPayload = GlanceWidgetPayload(
      headlineWord: 'die Sehnsucht',
      partOfSpeech: 'Substantiv, feminin',
      phoneticIpa: 'ˈzeːnˌzʊxt',
      translation: 'longing / yearning',
      exampleSentence: 'Sie hatte große Sehnsucht nach der Heimat.',
      streakDays: 28,
      quizOptions: const [
        GlanceQuizOption(text: 'happiness', isCorrect: false),
        GlanceQuizOption(text: 'longing', isCorrect: true),
        GlanceQuizOption(text: 'curiosity', isCorrect: false),
      ],
    );

    test('Renders compact 2x2 widget markup omitting long sentences for small space', () {
      final xml = engine.renderWidgetMarkup(testPayload, WidgetLayoutSize.compact2x2);

      expect(xml, contains('<WordSection word="die Sehnsucht"'));
      expect(xml, isNot(contains('<Example sentence=')));
      expect(xml, isNot(contains('<InteractiveQuiz')));
    });

    test('Renders expanded 4x4 layout with interactive on-screen quiz buttons', () {
      final xml = engine.renderWidgetMarkup(testPayload, WidgetLayoutSize.expanded4x4);

      expect(xml, contains('<InteractiveQuiz title="Schnelltest">'));
      expect(xml, contains('<QuizButton index="1" label="longing" />'));
    });

    test('Evaluates in-widget quiz tap instantly and returns correct verification', () {
      final isCorrectAnswer = engine.evaluateInWidgetQuizTap(testPayload, 1);
      final isWrongAnswer = engine.evaluateInWidgetQuizTap(testPayload, 0);

      expect(isCorrectAnswer, isTrue);
      expect(isWrongAnswer, isFalse);
    });
  });
}
