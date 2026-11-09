import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:deutsch_build/src/core/storage/sqlite_migration_rollback_engine.dart';
import 'package:deutsch_build/src/core/voice/synthesis/pcm_adaptive_sample_rate_converter.dart';
import 'package:deutsch_build/src/ui/bridges/vol_112_wave3_ui_bridge.dart';

void main() {
  group('Volume 112 Wave 3 (Tasks 4839-4841) Integration Tests', () {
    test('DATA-004: Migration Engine upgrades successfully and rolls back cleanly on error', () async {
      final engine = SQLiteMigrationRollbackEngine();

      engine.registerMigration(MigrationStep(
        version: 1,
        description: 'Create lessons table',
        upgradeSql: ['CREATE TABLE lessons (id TEXT PRIMARY KEY, title TEXT);'],
        rollbackSql: ['DROP TABLE IF EXISTS lessons;'],
      ));

      engine.registerMigration(MigrationStep(
        version: 2,
        description: 'Faulty migration test',
        upgradeSql: ['SYNTAX_ERROR_TRIGGER'],
        rollbackSql: ['DROP TABLE IF EXISTS faulty;'],
      ));

      // Migrate to v1 should succeed
      await engine.migrateTo(1);
      expect(engine.currentVersion, equals(1));

      // Migrate to v2 should fail and trigger rollback
      expect(
        () => engine.migrateTo(2),
        throwsA(isA<MigrationExecutionException>()),
      );
      expect(engine.currentVersion, equals(1));
      expect(engine.auditTrail.any((entry) => entry.contains('ROLLBACK_v2')), isTrue);
    });

    test('P1-10: PcmAdaptiveSampleRateConverter converts 16kHz to 24kHz with accurate size', () {
      final converter = PcmAdaptiveSampleRateConverter(
        sourceSampleRate: 16000,
        targetSampleRate: 24000,
      );

      // Create 100 samples (200 bytes) of 16-bit audio
      final inputBytes = Uint8List(200);
      final view = ByteData.sublistView(inputBytes);
      for (int i = 0; i < 100; i++) {
        view.setInt16(i * 2, 1000, Endian.little);
      }

      final resampled = converter.resample16BitMono(inputBytes);
      // 100 samples * (24000/16000) = 150 samples -> 300 bytes
      expect(resampled.length, equals(300));

      final outView = ByteData.sublistView(resampled);
      expect(outView.getInt16(0, Endian.little), equals(1000));
    });

    test('UI Bridge correctly generates Wave 3 diagnostics report', () {
      final bridge = Vol112Wave3UIBridge();
      final report = bridge.getWave3Diagnostics();

      expect(report['volume'], equals(112));
      expect(report['verdict'], equals('PRODUCTION_VERIFIED'));
      expect(report['subsystems']['migration_engine']['status'], equals('HEALTHY'));
      expect(report['subsystems']['pcm_resampler']['status'], equals('OPERATIONAL'));
    });
  });
}
