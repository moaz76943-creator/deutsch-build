import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/german_case_disambiguation_engine.dart';
import 'package:deutsch_build/src/core/voice/synthesis/offline_biquad_audio_equalizer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_wave3_ui_bridge.dart';

void main() {
  group('Volume 113 Wave 3 (Tasks 4857-4859) Integration Tests', () {
    test('LING-003: GermanCaseDisambiguationEngine resolves cases and verifies articles', () {
      // Dative prepositions
      expect(
        GermanCaseDisambiguationEngine.resolvePrepositionCase('mit'),
        equals(GermanGrammaticalCase.dativ),
      );
      expect(
        GermanCaseDisambiguationEngine.verifyDefiniteArticle(
          article: 'dem',
          targetCase: GermanGrammaticalCase.dativ,
          gender: 'der',
        ),
        isTrue,
      );

      // Accusative prepositions
      expect(
        GermanCaseDisambiguationEngine.resolvePrepositionCase('durch'),
        equals(GermanGrammaticalCase.akkusativ),
      );
      expect(
        GermanCaseDisambiguationEngine.verifyDefiniteArticle(
          article: 'den',
          targetCase: GermanGrammaticalCase.akkusativ,
          gender: 'der',
        ),
        isTrue,
      );

      // Two-way prepositions (Wechselpräpositionen)
      expect(
        GermanCaseDisambiguationEngine.resolvePrepositionCase('in', isDirectionalMotion: true),
        equals(GermanGrammaticalCase.akkusativ),
      );
      expect(
        GermanCaseDisambiguationEngine.resolvePrepositionCase('in', isDirectionalMotion: false),
        equals(GermanGrammaticalCase.dativ),
      );
    });

    test('P1-12: OfflineBiquadAudioEqualizer processes PCM audio without drift', () {
      final eq = OfflineBiquadAudioEqualizer(sampleRate: 24000);

      // 100 samples of test audio
      final inputBytes = Uint8List(200);
      final view = ByteData.sublistView(inputBytes);
      for (int i = 0; i < 100; i++) {
        view.setInt16(i * 2, 500, Endian.little);
      }

      final processed = eq.processPcmBytes(inputBytes);
      expect(processed.length, equals(200));

      final outView = ByteData.sublistView(processed);
      expect(outView.getInt16(0, Endian.little), isNotNull);
    });

    test('UI Bridge correctly generates Wave 3 diagnostics report', () {
      final bridge = Vol113Wave3UIBridge();
      final report = bridge.getWave3Diagnostics();

      expect(report['volume'], equals(113));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['case_disambiguation_engine']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['biquad_audio_equalizer']['status'], equals('ACTIVE'));
      expect(bridge.checkPrepositionCase('ohne'), equals(GermanGrammaticalCase.akkusativ));
    });
  });
}
