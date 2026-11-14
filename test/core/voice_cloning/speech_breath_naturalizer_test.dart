import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/voice_cloning/speech_breath_naturalizer.dart';

void main() {
  test('Inserts natural micro-breaths before subordinate conjunctions and periods', () {
    const naturalizer = SpeechBreathNaturalizer();
    final processed = naturalizer.naturalizeScript('Ich freue mich, weil wir heute Deutsch lernen. Wie geht es dir?');
    expect(processed, contains('[breath:soft:120ms] weil'));
    expect(processed, contains('[pause:220ms]'));
  });
}
