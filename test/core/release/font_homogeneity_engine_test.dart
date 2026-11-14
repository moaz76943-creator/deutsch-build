import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/release/font_homogeneity_engine.dart';

void main() {
  group('FontHomogeneityEngine Tests', () {
    const engine = FontHomogeneityEngine();

    test('Calculates heightened line multiplier for Arabic script to prevent diacritic clipping', () {
      final latinHeight = engine.calculateSafeLineHeightDp(16.0, ScriptType.latin);
      final arabicHeight = engine.calculateSafeLineHeightDp(16.0, ScriptType.arabicBidi);

      expect(arabicHeight, greaterThan(latinHeight));
      expect(arabicHeight, equals(16.0 * 1.60)); // 25.6 DP
    });

    test('Verifies text fit across compact small phone viewport (320dp width)', () {
      const compactScreen = ViewportSpec(
        deviceLabel: 'Small Android Phone',
        widthDp: 320.0,
        heightDp: 640.0,
        devicePixelRatio: 2.0,
      );

      final shortTextFits = engine.willTextFitViewport(
        text: 'Guten Tag!',
        fontSize: 16.0,
        viewport: compactScreen,
      );

      final longTextOverflows = engine.willTextFitViewport(
        text: 'Dies ist ein extrem langer deutscher Beispielsatz, der auf einem sehr kleinen Display nicht in zwei Zeilen passt.',
        fontSize: 18.0,
        viewport: compactScreen,
        maxLines: 2,
      );

      expect(shortTextFits, isTrue);
      expect(longTextOverflows, isFalse); // Correctly detects truncation risk
    });
  });
}
