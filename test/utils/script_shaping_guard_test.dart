import 'package:deutsch_bilarabi/utils/script_shaping_guard.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects Indic, Thai, Khmer, Tibetan and Georgian Unicode', () {
    const values = [0x0915, 0x0E01, 0x1780, 0x0F40, 0x10D0];
    final text = String.fromCharCodes(values);
    expect(ScriptShapingGuard.scriptsIn(text), [
      'Devanagari', 'Thai', 'Khmer', 'Tibetan', 'Georgian'
    ]);
    expect(ScriptShapingGuard.scriptOf(0x1C90), 'Georgian');
    expect(ScriptShapingGuard.scriptsIn('Berlin 123'), isEmpty);
  });

  test('maintains style and existing fallbacks on Android 8-10', () {
    const base = TextStyle(fontSize: 18, fontFamily: 'Chosen',
      fontFamilyFallback: ['Existing']);
    final style = ScriptShapingGuard.styleFor(
      String.fromCharCodes([0x0915, 0x0E01]),
      base: base, androidSdkInt: 28);
    expect(style.fontFamily, 'Chosen');
    expect(style.fontSize, 18);
    expect(style.fontFamilyFallback, [
      'Existing', 'Noto Sans Devanagari', 'Noto Sans Thai', 'sans-serif'
    ]);
    expect(ScriptShapingGuard.styleFor('Hello', base: base), same(base));
  });

  test('distinguishes actual U+FFFD from complex shaped text', () {
    expect(ScriptShapingGuard.containsReplacementCharacter(
      String.fromCharCode(0x0F40)), isFalse);
    expect(ScriptShapingGuard.containsReplacementCharacter(
      String.fromCharCode(0xFFFD)), isTrue);
  });
}
