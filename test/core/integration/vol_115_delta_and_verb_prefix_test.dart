import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/content/binary_delta_patch_applier.dart';
import 'package:deutsch_build/src/core/content/german_separable_verb_recombiner.dart';
import 'package:deutsch_build/src/ui/bridges/vol_115_wave3_ui_bridge.dart';

void main() {
  group('Volume 115 Wave 3 (Tasks 4887-4889) Integration Tests', () {
    test('ARCH-013: BinaryDeltaPatchApplier applies copy and insert stream correctly', () {
      final base = Uint8List.fromList(utf8.encode('Hello World'));

      // Target will be "Hello Sovereign World!"
      final targetStr = 'Hello Sovereign World!';
      final targetHash = sha256.convert(utf8.encode(targetStr)).toString();

      final instructions = [
        DeltaInstruction.copy(offset: 0, length: 6), // "Hello "
        DeltaInstruction.insert(data: Uint8List.fromList(utf8.encode('Sovereign '))),
        DeltaInstruction.copy(offset: 6, length: 5), // "World"
        DeltaInstruction.insert(data: Uint8List.fromList(utf8.encode('!'))),
      ];

      final patchedBytes = BinaryDeltaPatchApplier.applyPatch(
        baseBytes: base,
        instructions: instructions,
        expectedTargetSha256: targetHash,
      );

      expect(utf8.decode(patchedBytes), equals(targetStr));
    });

    test('LING-012: GermanSeparableVerbRecombiner identifies prefixes and builds infinitives', () {
      final sentence = 'Ich stehe jeden Tag frueh auf.';
      final analysis = GermanSeparableVerbRecombiner.analyzeSentence(sentence);

      expect(analysis, isNotNull);
      expect(analysis!.isSeparated, isTrue);
      expect(analysis.separatedPrefix, equals('auf'));
      expect(analysis.canonicalInfinitive, equals('aufstehen'));

      final nonSeparable = GermanSeparableVerbRecombiner.analyzeSentence('Ich lerne heute Deutsch.');
      expect(nonSeparable, isNull);
    });

    test('UI Bridge correctly generates Wave 3 diagnostics report', () {
      final bridge = Vol115Wave3UIBridge();
      final report = bridge.getWave3Diagnostics();

      expect(report['volume'], equals(115));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['binary_delta_patch_applier']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['separable_verb_recombiner']['status'], equals('ACTIVE'));
    });
  });
}
