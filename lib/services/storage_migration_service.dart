import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'database_lifecycle_contract.dart';
import 'storage_maintenance_service.dart';

typedef PackStorageDirectoryProvider = Future<Directory> Function();
typedef ExternalPackDirectoryProvider = Future<List<Directory>?> Function();

class PackStorageLocation {
  const PackStorageLocation({
    required this.directory,
    required this.isExternal,
    required this.isRemovable,
  });

  final Directory directory;
  final bool isExternal;
  final bool isRemovable;
}

/// App-specific Android getExternalFilesDirs roots (via path_provider).
/// No shared-storage permissions are needed; the primary emulated directory
/// is not mistaken for a removable SD card.
///
/// Files are streamed to a temporary sibling, checked twice by SHA-256, then
/// atomically renamed before the source is deleted. Failures keep the source.
class StorageMigrationService {
  StorageMigrationService({
    PackStorageDirectoryProvider? internalDirectory,
    ExternalPackDirectoryProvider? externalDirectories,
    FreeDiskSpaceProbe? freeSpaceProbe,
    DatabaseCloserCallback? closeContentDb,
    bool? androidPlatform,
  })  : _internalDirectory = internalDirectory ?? _defaultInternalDirectory,
        _externalDirectories =
            externalDirectories ?? getExternalStorageDirectories,
        _freeSpaceProbe = freeSpaceProbe,
        _androidPlatform = androidPlatform ?? Platform.isAndroid,
        _closeContentDb = closeContentDb ?? _missingDatabaseCloser;

  final PackStorageDirectoryProvider _internalDirectory;
  final ExternalPackDirectoryProvider _externalDirectories;
  final FreeDiskSpaceProbe? _freeSpaceProbe;
  final DatabaseCloserCallback _closeContentDb;

  static Future<void> _missingDatabaseCloser(String languageCode) async {
    throw StateError('A database close callback is required to move an open SQLite pack');
  }
  final bool _androidPlatform;

  static final RegExp _filename = RegExp(
    r'^[a-z]{2,3}(?:-[a-z0-9]{2,8})*\.(?:sqlite|pack\.gz)$',
  );

  static Future<Directory> _defaultInternalDirectory() async {
    final support = await getApplicationSupportDirectory();
    return Directory(path.join(support.path, 'packs'));
  }

  static String _validatedName(String filename) {
    if (!_filename.hasMatch(filename)) {
      throw ArgumentError.value(filename, 'filename', 'Invalid pack filename');
    }
    return filename;
  }

  Future<List<PackStorageLocation>> availableLocations() async {
    final internal = await _internalDirectory();
    final roots = <PackStorageLocation>[
      PackStorageLocation(
        directory: internal.absolute,
        isExternal: false,
        isRemovable: false,
      ),
    ];
    if (_androidPlatform) {
      final external = await _externalDirectories() ?? <Directory>[];
      final seen = <String>{internal.absolute.path};
      for (var index = 0; index < external.length; index++) {
        // path_provider returns Android getExternalFilesDirs(null), which are
        // app-specific locations. Never promote a symlink to a trusted root:
        // a redirected pack directory could leave that sandbox.
        final root = external[index].absolute;
        if (await FileSystemEntity.type(root.path, followLinks: false) ==
            FileSystemEntityType.link) {
          continue;
        }
        final directory =
            Directory(path.join(root.path, 'deutsch_packs')).absolute;
        if (await FileSystemEntity.type(directory.path, followLinks: false) ==
            FileSystemEntityType.link) {
          continue;
        }
        if (!seen.add(directory.path)) continue;
        roots.add(PackStorageLocation(
          directory: directory,
          isExternal: true,
          isRemovable: index > 0,
        ));
      }
    }
    return List<PackStorageLocation>.unmodifiable(roots);
  }

  /// Resolves pre-existing packs without a destructive path registry.
  Future<String?> resolvePackPath(String filename) async {
    final name = _validatedName(filename);
    // Most packs remain internal: do not query Android SD mounts for them.
    final internal = await _internalDirectory();
    final preferred = File(path.join(internal.path, name));
    if (await FileSystemEntity.type(preferred.path, followLinks: false) ==
        FileSystemEntityType.file) {
      return preferred.path;
    }
    for (final location in await availableLocations()) {
      if (!location.isExternal) continue;
      final candidate = File(path.join(location.directory.path, name));
      if (await FileSystemEntity.type(candidate.path, followLinks: false) ==
          FileSystemEntityType.file) {
        return candidate.path;
      }
    }
    return null;
  }

  Future<File> migratePack(
    String filename, {
    required PackStorageLocation destination,
  }) async {
    final name = _validatedName(filename);
    final locations = await availableLocations();
    if (!locations.any((item) =>
        item.directory.absolute.path == destination.directory.absolute.path &&
        item.isExternal == destination.isExternal)) {
      throw ArgumentError('Destination is not an app-specific pack directory');
    }
    final sourcePath = await resolvePackPath(name);
    if (sourcePath == null) throw StateError('Pack $name is not installed');
    final source = File(sourcePath);
    final targetDir = destination.directory.absolute;
    if (await FileSystemEntity.type(targetDir.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw StateError('External pack directory cannot be a symbolic link');
    }
    final target = File(path.join(targetDir.path, name));
    if (source.absolute.path == target.absolute.path) return source;

    if (name.endsWith('.sqlite')) {
      await _closeContentDb(name.substring(0, name.length - '.sqlite'.length));
    }

    final expectedHash = await _sha256(source);
    final sourceInfo = await source.stat();
    final alreadyExists = await target.exists();
    if (alreadyExists) {
      if (await FileSystemEntity.type(target.path, followLinks: false) !=
          FileSystemEntityType.file) {
        throw StateError('Destination is not a regular pack file');
      }
      if (await _sha256(target) != expectedHash) {
        throw StateError('Destination pack differs; refusing overwrite');
      }
    } else {
      final available = await StorageMaintenanceService(
        packDirectory: targetDir,
        freeDiskSpaceProbe: _freeSpaceProbe,
      ).getAvailableDiskSpaceBytes();
      if (available == null || available < sourceInfo.size) {
        throw StateError('Destination capacity unavailable or insufficient');
      }
    }

    await targetDir.create(recursive: true);
    final staging = File(target.path + '.migrating');
    if (await FileSystemEntity.type(staging.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Another pack migration is staged');
    }
    if (!alreadyExists) {
      try {
        final sink = staging.openWrite();
        try {
          await sink.addStream(source.openRead());
          await sink.flush();
        } finally {
          await sink.close();
        }
        if (await _sha256(staging) != expectedHash ||
            await _sha256(source) != expectedHash) {
          throw StateError('SHA-256 verification failed during migration');
        }
        final current = await source.stat();
        if (sourceInfo.size != current.size ||
            sourceInfo.modified != current.modified) {
          throw StateError('Source pack changed during migration');
        }
        await staging.rename(target.path);
      } finally {
        if (await staging.exists()) await staging.delete();
      }
    }

    // On deletion failure both verified copies remain intact; the resolver
    // continues to prefer the original until its removal succeeds.
    if (await _sha256(source) != expectedHash) {
      throw StateError('Source pack changed before deletion');
    }
    await source.delete();
    return target;
  }

  static Future<String> _sha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();
}
