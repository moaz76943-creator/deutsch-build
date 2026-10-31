import 'package:test/test.dart';
import 'package:deutsch_build/src/core/platform/universal_accessibility_engine.dart';

void main() {
  group('UniversalAccessibilityEngine Tests', () {
    const engine = UniversalAccessibilityEngine();

    test('Generates detailed semantic voiceover label for front and back flashcard states', () {
      final frontLabel = engine.generateFlashcardSemanticLabel(
        frontTerm: 'das Buch',
        backMeaning: 'the book',
        partOfSpeech: 'Substantiv, neutral',
        phoneticIpa: 'buːx',
        isFlipped: false,
      );

      expect(frontLabel, contains('Vokabelkarte Vorderseite: das Buch'));
      expect(frontLabel, contains('Doppeltippen zum Umdrehen'));

      final backLabel = engine.generateFlashcardSemanticLabel(
        frontTerm: 'das Buch',
        backMeaning: 'the book',
        partOfSpeech: 'Substantiv, neutral',
        phoneticIpa: 'buːx',
        isFlipped: true,
      );

      expect(backLabel, contains('Vokabelkarte Rückseite'));
      expect(backLabel, contains('the book'));
    });

    test('Bypasses 3D card physics when reduce motion is enabled for vestibular safety', () {
      const standardSettings = AccessibilitySettings(reduceMotionEnabled: false);
      const safeSettings = AccessibilitySettings(reduceMotionEnabled: true);

      expect(engine.shouldBypassMotionAnimations(standardSettings), isFalse);
      expect(engine.shouldBypassMotionAnimations(safeSettings), isTrue);
    });

    test('Verifies WCAG 2.1 AAA compliance when standards are fully satisfied', () {
      final isCompliant = engine.verifyWcagAaaCompliance(
        contrastRatio: 15.5, // Pure OLED black vs amber text
        maxSupportedFontScale: 2.0, // 200% scaling
        hasSemanticTreeLabels: true,
      );

      expect(isCompliant, isTrue);
    });
  });
}
