import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/german_morphological_lemmatizer.dart';
import 'package:deutsch_build/src/core/voice/synthesis/low_bitrate_frame_packetizer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_113_wave5_ui_bridge.dart';

void main() {
  group('Volume 113 Wave 5 (Tasks 4863-4865) Integration Tests', () {
    test('LING-005: GermanMorphologicalLemmatizer resolves irregular and regular verbs', () {
      // Irregular verbs
      expect(GermanMorphologicalLemmatizer.lemmatize('ging').lemma, equals('gehen'));
      expect(GermanMorphologicalLemmatizer.lemmatize('gesprochen').lemma, equals('sprechen'));
      expect(GermanMorphologicalLemmatizer.lemmatize('hatte').lemma, equals('haben'));

      // Regular Partizip II
      expect(GermanMorphologicalLemmatizer.lemmatize('gekauft').lemma, equals('kaufen'));
      expect(GermanMorphologicalLemmatizer.lemmatize('gelernt').lemma, equals('lernen'));

      // Regular present
      expect(GermanMorphologicalLemmatizer.lemmatize('lernst').lemma, equals('lernen'));
      expect(GermanMorphologicalLemmatizer.lemmatize('kauft').lemma, equals('kaufen'));
    });

    test('P1-13: VoiceJitterBuffer handles packet reordering and performs PLC on loss', () {
      final buffer = VoiceJitterBuffer(maxBufferFrames: 4);

      final p0 = VoiceFramePacket(sequenceNumber: 0, timestampMs: 0, payload: Uint8List.fromList([1, 2]));
      final p2 = VoiceFramePacket(sequenceNumber: 2, timestampMs: 40, payload: Uint8List.fromList([5, 6]));

      // Receive p0, then p2 (p1 is missing)
      buffer.pushPacket(p0);
      buffer.pushPacket(p2);

      // Frame 0 received cleanly
      final f0 = buffer.pullNextOrderedFrame(defaultFrameBytes: 2);
      expect(f0, equals([1, 2]));

      // Frame 1 was lost: should execute PLC (silence packet)
      final f1 = buffer.pullNextOrderedFrame(defaultFrameBytes: 2);
      expect(f1, equals([0, 0]));
      expect(buffer.concealedCount, equals(1));

      // Frame 2 received cleanly from jitter queue
      final f2 = buffer.pullNextOrderedFrame(defaultFrameBytes: 2);
      expect(f2, equals([5, 6]));
    });

    test('UI Bridge correctly generates Wave 5 diagnostics report', () {
      final bridge = Vol113Wave5UIBridge();
      final report = bridge.getWave5Diagnostics();

      expect(report['volume'], equals(113));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['morphological_lemmatizer']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['voice_jitter_buffer']['status'], equals('ACTIVE'));
      expect(bridge.extractLemma('gegangen'), equals('gehen'));
    });
  });
}
