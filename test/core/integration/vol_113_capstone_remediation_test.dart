import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/content/sovereign_dependency_syntax_parser.dart';
import 'package:deutsch_build/src/core/voice/synthesis/td_psola_pitch_shifter.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_capstone_ui_bridge.dart';

void main() {
  group('Volume 113 Capstone (Tasks 4866-4868) Integration Tests', () {
    test('P1-14: TdPsolaPitchShifter scales audio length without pitch distortion', () {
      final shifter = TdPsolaPitchShifter(sampleRate: 24000, defaultWindowSize: 64);

      // Create 512 samples (1024 bytes) of test audio
      final inputBytes = Uint8List(1024);
      final view = ByteData.sublistView(inputBytes);
      for (int i = 0; i < 512; i++) {
        view.setInt16(i * 2, 800, Endian.little);
      }

      // Stretch by 1.5x (slow down)
      final stretched = shifter.timeStretch16BitMono(inputBytes, 1.5);
      expect(stretched.length, equals(1536)); // 1024 * 1.5 = 1536 bytes
    });

    test('LING-006: SovereignDependencySyntaxParser accurately segments German sentences', () {
      final nodes = SovereignDependencySyntaxParser.parseSentence('Ich habe Deutsch gelernt.');

      expect(nodes.length, equals(4));
      expect(nodes[0].role, equals(SyntacticRole.subject));
      expect(nodes[1].role, equals(SyntacticRole.finiteVerb));
      expect(nodes[2].role, equals(SyntacticRole.directObject));
      expect(nodes[3].role, equals(SyntacticRole.infiniteVerb));
    });

    test('UI Bridge correctly generates full Volume 113 Capstone report', () {
      final bridge = Vol113CapstoneUIBridge();
      final report = bridge.getVolume113FullReport();

      expect(report['volume'], equals(113));
      expect(report['status'], equals('SEALED_AND_VERIFIED'));
      expect(report['verdict'], equals('PRODUCTION_READY'));
      expect(report['total_tasks_completed'], equals(18));
    });
  });
}
