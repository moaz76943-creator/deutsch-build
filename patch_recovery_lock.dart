import 'dart:io';

void main() {
  final file = File('lib/services/user_vault_security_service.dart');
  var content = file.readAsStringSync();

  // Add _isRecovering and _checkRecoveryLock
  if (!content.contains('bool _isRecovering = false;')) {
    content = content.replaceFirst(
      'Future<LegacyProgressMigrationResult>? _migration;',
      'Future<LegacyProgressMigrationResult>? _migration;\n  bool _isRecovering = false;\n\n  void _checkRecoveryLock() {\n    if (_isRecovering) {\n      throw StateError(\'Vault is currently locked for recovery\');\n    }\n  }'
    );
  }

  // add _checkRecoveryLock() to methods
  final methodsToLock = [
    'Future<void> putRecord(String id, Uint8List plaintext) async {\n',
    'Future<void> deleteRecord(String id) async {\n',
    'Future<SrsReviewSchedule> gradeOperationalSrs({\n    required String lexemeId,\n    required String languageCode,\n    required int grade,\n    DateTime? reviewedAt,\n  }) async {\n',
    'Future<void> incrementOperationalSrs({\n    required String lexemeId,\n    required String languageCode,\n    required String status,\n  }) async {\n',
    'Future<void> putOperationalBookmark({\n    required String bookmarkId,\n    required String languageCode,\n    required Map<String, dynamic> data,\n  }) async {\n',
    'Future<void> deleteOperationalBookmark({\n    required String bookmarkId,\n    required String languageCode,\n  }) async {\n',
  ];

  for (final method in methodsToLock) {
    if (content.contains(method)) {
      content = content.replaceFirst(method, method + '    _checkRecoveryLock();\n');
    } else {
      print('Could not find: $method');
    }
  }

  // patch restoreOperationalSnapshot
  final restoreStart = 'Future<Map<String, int>> restoreOperationalSnapshot({\n    required List<Map<String, Object?>> srs,\n    required List<Map<String, dynamic>> bookmarks,\n    required bool Function(\n            Map<String, Object?> local, Map<String, Object?> incoming)\n        incomingWins,\n  }) async {\n';

  if (content.contains(restoreStart)) {
    content = content.replaceFirst(
      restoreStart,
      restoreStart + '    _checkRecoveryLock();\n    _isRecovering = true;\n    try {\n'
    );
    // find the return block for restoreOperationalSnapshot
    final returnBlock = '      return {\n        \'inserted\': inserted,\n        \'updated\': updated,\n        \'unchanged\': unchanged,\n        \'bookmarksInserted\': bookmarkInserted,\n        \'bookmarksUpdated\': bookmarkUpdated,\n      };\n    });';
    if (content.contains(returnBlock)) {
      content = content.replaceFirst(
        returnBlock,
        returnBlock + '\n    } finally {\n      _isRecovering = false;\n    }'
      );
    } else {
      print('Could not find return block of restoreOperationalSnapshot');
    }
  } else {
    print('Could not find restoreOperationalSnapshot');
  }

  // _activateArchivedSnapshot shouldn't be publicly called concurrent, but let's lock it too just in case.
  final activateStart = 'Future<void> _activateArchivedSnapshot() async {\n';
  if (content.contains(activateStart)) {
    content = content.replaceFirst(activateStart, activateStart + '    _checkRecoveryLock();\n    _isRecovering = true;\n    try {\n');
    final activateEnd = '      await _writeEncrypted(\n          txn,\n          _operationalReadyId,\n          Uint8List.fromList(utf8.encode(jsonEncode(\n              {\'format\': \'operational-progress-v1\', \'origin\': \'migrated\'}))));\n    });\n  }';
    if (content.contains(activateEnd)) {
        content = content.replaceFirst(activateEnd, activateEnd + '\n    } finally {\n      _isRecovering = false;\n    }');
    } else {
        print('Could not find activate end');
    }
  }

  // migrateLegacyProgressDatabase
  final migrateStart = 'Future<LegacyProgressMigrationResult> _migrateLegacyProgressDatabase() async {\n';
  if (content.contains(migrateStart)) {
    content = content.replaceFirst(migrateStart, migrateStart + '    _checkRecoveryLock();\n    _isRecovering = true;\n    try {\n');
    final migrateEnd = '    await oldFile.rename(backup.path);\n    return LegacyProgressMigrationResult(\n      migrated: true,\n      tableRowCounts: Map<String, int>.unmodifiable(counts),\n    );\n  }';
    if (content.contains(migrateEnd)) {
        content = content.replaceFirst(migrateEnd, migrateEnd + '\n    } finally {\n      _isRecovering = false;\n    }');
    } else {
        print('Could not find migrate end');
    }
  }

  file.writeAsStringSync(content);
}
