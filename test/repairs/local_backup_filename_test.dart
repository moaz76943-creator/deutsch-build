import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/screens/backup_restore_screen.dart';

void main() {
  group('Local backup filename admission', () {
    test('accepts the actual exported backup filename', () {
      expect(isLocalBackupFilename('deutsch_backup_1792512345678.json'), isTrue);
      expect(isLocalBackupFilename('deutsch_backup_0.json'), isTrue);
    });

    test('rejects unrelated and misleading files', () {
      for (final name in [
        'other.json',
        'deutsch_backup_notes.json',
        'deutsch_backup_.json',
        'prefix_deutsch_backup_1792512345678.json',
        'deutsch_backup_1792512345678.json.bak',
        'deutsch_backup_1792512345678.JSON',
        'deutsch_backup_1792512345678.json/other.json',
        '../deutsch_backup_1792512345678.json',
        '/data/user/0/com.deutsch_backup_app/other.json',
      ]) {
        expect(isLocalBackupFilename(name), isFalse, reason: name);
      }
    });

    test('does not select arbitrary JSON files from directory containing backup prefix', () {
      const parent = '/data/user/0/com.deutsch_backup_app/app_flutter/';
      expect(isLocalBackupFilename('${parent}notes.json'), isFalse);
      expect(isLocalBackupFilename('${parent}other.json'), isFalse);
    });
  });
}
