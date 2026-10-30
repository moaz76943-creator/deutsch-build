import 'package:test/test.dart';
import '../../lib/src/platform/font_homogeneity_engine.dart';

void main() {
  group('FontHomogeneityEngine Unit Tests (N093)', () {
    final engine = FontHomogeneityEngine();

    test('Maps Arabic and Syriac scripts to sovereign Noto typography', () {
      expect(engine.resolveFontFamily('arabic'), equals('NotoNaskhArabic'));
      expect(engine.resolveFontFamily('syriac'), equals('NotoSansSyriac'));
      expect(engine.resolveFontFamily('latin'), equals('NotoSans'));
    });

    test('Validates layout height and detects viewport clipping when container is too small', () {
      final reportSafe = engine.auditLayout(
        text: 'مرحبا بكم في عالم اللغات',
        scriptType: 'arabic',
        containerHeightPx: 40.0,
        fontSizePx: 18.0, // 18 * 1.6 = 28.8px (Safe in 40px)
      );
      expect(reportSafe.hasViewportClipping, isFalse);
      expect(reportSafe.activeFontFamily, equals('NotoNaskhArabic'));

      final reportClipped = engine.auditLayout(
        text: 'Text',
        scriptType: 'latin',
        containerHeightPx: 15.0,
        fontSizePx: 20.0, // 20 * 1.3 = 26px (> 15px)
      );
      expect(reportClipped.hasViewportClipping, isTrue);
    });
  });
}
