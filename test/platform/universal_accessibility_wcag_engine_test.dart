import 'package:test/test.dart';
import '../../lib/src/platform/universal_accessibility_wcag_engine.dart';

void main() {
  group('UniversalAccessibilityWcagEngine Unit Tests (N087)', () {
    final engine = UniversalAccessibilityWcagEngine();

    test('Validates pure black on white contrast ratio (21:1) passing WCAG AAA', () {
      final ratio = engine.calculateContrastRatio(1.0, 0.0);
      expect(ratio, closeTo(21.0, 0.1));
      expect(engine.satisfiesWcagAaa(ratio), isTrue);
    });

    test('Rejects low contrast ratio failing WCAG AAA standard (< 7:1)', () {
      final ratio = engine.calculateContrastRatio(0.4, 0.2);
      expect(ratio, lessThan(7.0));
      expect(engine.satisfiesWcagAaa(ratio), isFalse);
    });

    test('Builds well-formed screen reader semantic string', () {
      final label = engine.buildAccessibleLabel(
        role: 'Schaltfläche',
        actionDescription: 'Audioaufnahme starten',
        stateHint: 'Doppeltippen zum Aktivieren',
      );

      expect(label, contains('Schaltfläche: Audioaufnahme starten.'));
      expect(label, contains('Doppeltippen zum Aktivieren.'));
    });
  });
}
