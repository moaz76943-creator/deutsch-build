import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../packs/pack_models.dart';

final class FileSystemModularPackStorage implements LocalPackCatalog {
  FileSystemModularPackStorage({
    required this.rootDirectory,
  });

  static const int maxTextBytes = 16 * 1024 * 1024;
  static const int maxBinaryBytes = 64 * 1024 * 1024;

  final Directory rootDirectory;

  Directory get packsDirectory =>
      Directory(p.join(rootDirectory.path, 'packs'));

  Directory get stagingDirectory =>
      Directory(p.join(rootDirectory.path, '.staging'));

  Future<void> initialize() async {
    await packsDirectory.create(recursive: true);
    await stagingDirectory.create(recursive: true);
  }

  Future<Directory> prepareStaging(PackPairRequest request) async {
    final pairKey = request.pairKey;
    await initialize();
    final stamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final directory = Directory(
      p.join(
        stagingDirectory.path,
        '${request.storageKey}_$stamp',
      ),
    );
    await directory.create(recursive: true);
    await File(p.join(directory.path, '.pair'))
        .writeAsString(pairKey, flush: true);
    return directory;
  }

  Future<void> commitStaged(
    PackPairRequest request,
    Directory staging,
  ) async {
    final pairKey = request.pairKey;
    await initialize();

    final stagingRoot = p.normalize(stagingDirectory.absolute.path);
    final candidate = p.normalize(staging.absolute.path);
    if (!p.isWithin(stagingRoot, candidate)) {
      throw ArgumentError.value(
        staging.path,
        'staging',
        'must be created under the storage staging root',
      );
    }

    final pairMarker = File(p.join(staging.path, '.pair'));
    if (!await pairMarker.exists()) {
      throw StateError('pack_staging_pair_marker_missing');
    }
    final stagedPair = (await pairMarker.readAsString()).trim();
    if (stagedPair != pairKey) {
      throw StateError('pack_staging_pair_mismatch');
    }

    final jsonContent =
        File(p.join(staging.path, 'content', 'pack.json'));
    final sqliteContent =
        File(p.join(staging.path, 'content', 'content.sqlite'));
    final hasJson = await jsonContent.exists();
    final hasSqlite = await sqliteContent.exists();
    if (!hasJson && !hasSqlite) {
      throw StateError('pack_content_missing');
    }

    final destination = _packDirectory(request);
    if (await destination.exists()) {
      throw StateError('pack_already_installed');
    }

    await File(p.join(staging.path, '.ready'))
        .writeAsString(pairKey, flush: true);
    await staging.rename(destination.path);
  }

  @override
  Future<LocalPackHandle?> find(PackPairRequest request) async {
    final pairKey = request.pairKey;
    final directory = _packDirectory(request);
    if (!await directory.exists()) return null;

    final ready = File(p.join(directory.path, '.ready'));
    if (!await ready.exists()) return null;
    final readyPair = (await ready.readAsString()).trim();
    if (readyPair != pairKey) return null;

    final jsonContent =
        File(p.join(directory.path, 'content', 'pack.json'));
    final sqliteContent =
        File(p.join(directory.path, 'content', 'content.sqlite'));
    final hasJson = await jsonContent.exists();
    final hasSqlite = await sqliteContent.exists();
    if (!hasJson && !hasSqlite) return null;

    return LocalPackHandle(
      pairKey: pairKey,
      rootPath: directory.path,
      reader: _FileSystemLocalPackReader(directory),
      hasJsonContent: hasJson,
      hasSqliteContent: hasSqlite,
    );
  }

  Directory _packDirectory(PackPairRequest request) =>
      Directory(p.join(packsDirectory.path, request.storageKey));
}

final class _FileSystemLocalPackReader implements LocalPackReader {
  const _FileSystemLocalPackReader(this.root);

  final Directory root;

  @override
  Future<String> readText(String relativePath) async {
    final file = _resolveFile(relativePath);
    final length = await file.length();
    if (length > FileSystemModularPackStorage.maxTextBytes) {
      throw StateError('pack_text_payload_too_large');
    }
    final bytes = await file.readAsBytes();
    try {
      return utf8.decode(bytes);
    } on FormatException {
      throw StateError('pack_text_payload_not_utf8');
    }
  }

  @override
  Future<List<int>> readBytes(String relativePath) async {
    final file = _resolveFile(relativePath);
    final length = await file.length();
    if (length > FileSystemModularPackStorage.maxBinaryBytes) {
      throw StateError('pack_binary_payload_too_large');
    }
    return List<int>.unmodifiable(await file.readAsBytes());
  }

  @override
  Future<List<String>> listAssets() async {
    final assets = Directory(p.join(root.path, 'assets'));
    if (!await assets.exists()) {
      return const <String>[];
    }

    final rootPath = p.normalize(root.absolute.path);
    final result = <String>[];
    await for (final entity in assets.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;
      final absolute = p.normalize(entity.absolute.path);
      if (!p.isWithin(rootPath, absolute)) continue;
      result.add(
        p.posix.normalize(
          p.relative(absolute, from: rootPath).replaceAll('\\', '/'),
        ),
      );
    }
    result.sort();
    return List<String>.unmodifiable(result);
  }

  File _resolveFile(String relativePath) {
    final safe = _safeRelativePath(relativePath);
    final rootPath = p.normalize(root.absolute.path);
    final resolved = p.normalize(p.join(rootPath, safe));
    if (!p.isWithin(rootPath, resolved)) {
      throw ArgumentError.value(
        relativePath,
        'relativePath',
        'must stay inside the pack root',
      );
    }
    final file = File(resolved);
    if (!file.existsSync()) {
      throw StateError('pack_file_missing');
    }
    return file;
  }

  static String _safeRelativePath(String rawPath) {
    final normalized =
        p.posix.normalize(rawPath.trim().replaceAll('\\', '/'));
    if (normalized.isEmpty ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../') ||
        p.posix.isAbsolute(normalized) ||
        normalized.length > 240) {
      throw ArgumentError.value(
        rawPath,
        'relativePath',
        'must be a safe relative pack path',
      );
    }
    return p.joinAll(p.posix.split(normalized));
  }
}
