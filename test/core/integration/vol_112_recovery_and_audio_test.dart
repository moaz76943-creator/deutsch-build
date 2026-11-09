import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/storage/sqlite_crash_recovery_journal_manager.dart';
import 'package:deutsch_build/src/core/voice/synthesis/fixed_capacity_audio_ring_buffer.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_ui_bridge.dart';

void main() {
  group('Volume 112 (Tasks 4833-4835) Durability & Audio Test Suite', () {
    test('DATA-003: SQLite Crash Recovery Journal records and replays reliably', () async {
      final manager = SQLiteCrashRecoveryJournalManager();

      manager.appendJournal(
        entityKey: 'lesson_vocab_101',
        operation: 'INSERT',
        payload: Uint8List.fromList([10, 20, 30, 40]),
        checksumSha256: 'a1b2c3d4e5f6',
      );

      manager.appendJournal(
        entityKey: 'lesson_vocab_102',
        operation: 'UPDATE',
        payload: Uint8List.fromList([50, 60]),
        checksumSha256: 'b2c3d4e5f6a1',
      );

      expect(manager.pendingJournalCount, equals(2));
      expect(manager.lastCommittedSequence, equals(0));

      final replayed = await manager.performCrashRecoveryReplay();
      expect(replayed, equals(2));
      expect(manager.pendingJournalCount, equals(0));
      expect(manager.lastCommittedSequence, equals(2));
    });

    test('P1-09: FixedCapacityAudioRingBuffer enforces bounded buffer and FIFO sequencing', () {
      final ring = FixedCapacityAudioRingBuffer(capacityBytes: 16);

      expect(ring.capacityBytes, equals(16));
      expect(ring.availableBytes, equals(0));
      expect(ring.remainingSpace, equals(16));

      final chunk1 = Uint8List.fromList([1, 2, 3, 4, 5]);
      final written1 = ring.writePcmFrames(chunk1);
      expect(written1, equals(5));
      expect(ring.availableBytes, equals(5));

      final readChunk = ring.readPcmFrames(3);
      expect(readChunk, equals([1, 2, 3]));
      expect(ring.availableBytes, equals(2));

      // Overfill test
      final largeChunk = Uint8List.fromList(List.generate(20, (i) => i));
      final writtenLarge = ring.writePcmFrames(largeChunk);
      expect(writtenLarge, equals(14)); // capacity 16 - 2 existing = 14
      expect(ring.isFull, isTrue);

      ring.clear();
      expect(ring.isEmpty, isTrue);
    });

    test('UI Bridge correctly generates Volume 112 diagnostics report', () {
      final bridge = Vol112UIBridge();
      final report = bridge.getVolume112Diagnostics();

      expect(report['volume'], equals(112));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['crash_recovery_journal']['status'], equals('OPERATIONAL'));
      expect(report['subsystems']['fixed_capacity_audio_ring_buffer']['status'], equals('LOW_LATENCY_ACTIVE'));
    });
  });
}
