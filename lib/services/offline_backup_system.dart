import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineBackupSystem {
  static const List<String> _targetDatabases = [
    'heatmap.db',
    'user_vocabulary.db',
    'milestones.db',
    'reverse_quiz.db',
  ];

  Future<void> exportDatabases(String backupDirectoryPath) async {
    final dbPath = await getDatabasesPath();
    final backupDir = Directory(backupDirectoryPath);

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    for (final dbName in _targetDatabases) {
      final sourceFile = File(join(dbPath, dbName));
      if (await sourceFile.exists()) {
        final destFile = File(join(backupDirectoryPath, dbName));
        await sourceFile.copy(destFile.path);
      }
      final walFile = File(join(dbPath, '$dbName-wal'));
      if (await walFile.exists()) {
        final destWal = File(join(backupDirectoryPath, '$dbName-wal'));
        await walFile.copy(destWal.path);
      }
      final shmFile = File(join(dbPath, '$dbName-shm'));
      if (await shmFile.exists()) {
        final destShm = File(join(backupDirectoryPath, '$dbName-shm'));
        await shmFile.copy(destShm.path);
      }
    }
  }

  Future<void> restoreDatabases(String backupDirectoryPath) async {
    final dbPath = await getDatabasesPath();
    final backupDir = Directory(backupDirectoryPath);

    if (!await backupDir.exists()) {
      throw FileSystemException(
        'Backup directory does not exist',
        backupDirectoryPath,
      );
    }

    final databasesDir = Directory(dbPath);
    if (!await databasesDir.exists()) {
      await databasesDir.create(recursive: true);
    }

    for (final dbName in _targetDatabases) {
      final sourceFile = File(join(backupDirectoryPath, dbName));
      if (await sourceFile.exists()) {
        // Delete existing auxiliary files before restoring main db to prevent corruption
        final existingWal = File(join(dbPath, '$dbName-wal'));
        if (await existingWal.exists()) {
          await existingWal.delete();
        }
        final existingShm = File(join(dbPath, '$dbName-shm'));
        if (await existingShm.exists()) {
          await existingShm.delete();
        }

        final destFile = File(join(dbPath, dbName));
        await sourceFile.copy(destFile.path);
      }

      final sourceWal = File(join(backupDirectoryPath, '$dbName-wal'));
      if (await sourceWal.exists()) {
        final destWal = File(join(dbPath, '$dbName-wal'));
        await sourceWal.copy(destWal.path);
      }
      final sourceShm = File(join(backupDirectoryPath, '$dbName-shm'));
      if (await sourceShm.exists()) {
        final destShm = File(join(dbPath, '$dbName-shm'));
        await sourceShm.copy(destShm.path);
      }
    }
  }
}
