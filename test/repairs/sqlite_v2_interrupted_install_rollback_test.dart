import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Local synthetic bytes only; no shipped pack material is created or edited.
void main() {
  late Directory tmp;
  late File installed;
  late File backup;
  late List<int> trusted;
  late String expectedDigest;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('sqlite-v2-rollback-');
    installed = File('${tmp.path}/de.sqlite');
    backup = File('${installed.path}.bak');
    trusted = utf8.encode('verified synthetic bundled file bytes');
    expectedDigest = sha256.convert(trusted).toString();
  });

  tearDown(() => tmp.delete(recursive: true));

  test('restore a verified last-known-good backup after interrupted rename',
      () async {
    await backup.writeAsBytes(trusted, flush: true);
    expect(
      await DatabaseService.recoverVerifiedBundledBackup(
        installed, expectedDigest,
      ),
      isTrue,
    );
    expect(await installed.readAsBytes(), trusted);
    expect(await backup.exists(), isFalse);
  });

  test('corrupt replacement cannot supersede a verified backup', () async {
    await installed.writeAsString('corrupt target', flush: true);
    await backup.writeAsBytes(trusted, flush: true);
    expect(
      await DatabaseService.recoverVerifiedBundledBackup(
        installed, expectedDigest,
      ),
      isTrue,
    );
    expect(await installed.readAsBytes(), trusted);
  });

  test('unverified backup never replaces the installed file', () async {
    await installed.writeAsString('existing bytes', flush: true);
    await backup.writeAsString('untrusted bytes', flush: true);
    expect(
      await DatabaseService.recoverVerifiedBundledBackup(
        installed, expectedDigest,
      ),
      isFalse,
    );
    expect(await installed.readAsString(), 'existing bytes');
    expect(await backup.exists(), isTrue);
  });

  test('recovery is idempotent with a valid installed file', () async {
    await installed.writeAsBytes(trusted, flush: true);
    await backup.writeAsBytes(trusted, flush: true);
    expect(
      await DatabaseService.recoverVerifiedBundledBackup(
        installed, expectedDigest,
      ),
      isFalse,
    );
    expect(await installed.readAsBytes(), trusted);
  });
}
