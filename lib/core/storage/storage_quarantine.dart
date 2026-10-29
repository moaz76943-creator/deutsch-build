import 'dart:io';

class QuarantinedData {
  final String id;
  final String rawJson;
  final String diagnosticReason;
  final int timestampEpoch;

  const QuarantinedData({
    required this.id,
    required this.rawJson,
    required this.diagnosticReason,
    required this.timestampEpoch,
  });
}

class StorageQuarantine {
  final List<QuarantinedData> _quarantine = [];
  static const int maxQuarantinedFiles = 5;

  void isolateCorruptData({
    required String id,
    required String rawJson,
    required String reason,
  }) {
    _quarantine.add(QuarantinedData(
      id: id,
      rawJson: rawJson,
      diagnosticReason: reason,
      timestampEpoch: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<void> isolateCorruptFile(File corruptFile, String reason, String quarantineDir) async {
    final quarantineDirFile = Directory(quarantineDir);
    if (!await quarantineDirFile.exists()) {
      await quarantineDirFile.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = corruptFile.uri.pathSegments.last;
    final newPath = '$quarantineDir/quarantine_${timestamp}_$fileName';

    await corruptFile.rename(newPath);

    // Enforce bounded retention based on disk content
    await _enforceRetention(quarantineDirFile);
  }

  Future<void> _enforceRetention(Directory quarantineDir) async {
    if (!await quarantineDir.exists()) return;

    final files = await quarantineDir.list().toList();
    final quarantinedFiles = files.whereType<File>().toList();

    if (quarantinedFiles.length > maxQuarantinedFiles) {
      // Sort oldest first based on modified time
      final fileStats = await Future.wait(
        quarantinedFiles.map((f) async {
          final stat = await f.stat();
          return MapEntry(f, stat.modified);
        })
      );

      fileStats.sort((a, b) => a.value.compareTo(b.value));

      final diff = fileStats.length - maxQuarantinedFiles;
      final toRemove = fileStats.sublist(0, diff);

      for (var entry in toRemove) {
        if (await entry.key.exists()) {
          await entry.key.delete();
        }
      }
    }
  }

  Future<List<File>> getIsolatedFiles(String quarantineDir) async {
    final dir = Directory(quarantineDir);
    if (!await dir.exists()) return [];
    final files = await dir.list().where((e) => e is File).cast<File>().toList();
    return files;
  }

  List<QuarantinedData> get isolatedItems => List.unmodifiable(_quarantine);

  void clearResolved(String id) {
    _quarantine.removeWhere((item) => item.id == id);
  }
}
