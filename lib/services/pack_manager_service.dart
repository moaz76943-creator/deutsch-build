import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'pack_checksum.dart';
import 'pack_manifest.dart';
import 'pack_database_key_store.dart';
import 'pack_database_security.dart';
import 'preferences_service.dart';

export 'pack_checksum.dart';
export 'pack_manifest.dart';

enum PackLifecycleStage {
  idle,
  downloading,
  verifying,
  extracting,
  installed,
  deleting,
  failed,
}

class PackOperationState {
  const PackOperationState({
    required this.stage,
    this.progress = 0,
    this.message,
  });

  const PackOperationState.idle()
      : stage = PackLifecycleStage.idle,
        progress = 0,
        message = null;

  final PackLifecycleStage stage;
  final double progress;
  final String? message;

  bool get isBusy =>
      stage == PackLifecycleStage.downloading ||
      stage == PackLifecycleStage.verifying ||
      stage == PackLifecycleStage.extracting ||
      stage == PackLifecycleStage.deleting;
}

class PackIntegrityException implements Exception {
  const PackIntegrityException(this.message);

  final String message;

  @override
  String toString() => 'PackIntegrityException: $message';
}

abstract interface class PackDownloader {
  Future<int> download(
    Uri source,
    File destination, {
    required int expectedBytes,
    required ValueChanged<double> onProgress,
  });
}

class HttpPackDownloader implements PackDownloader {
  HttpPackDownloader({http.Client? client})
      : _client = client ?? http.Client(),
        _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<int> download(
    Uri source,
    File destination, {
    required int expectedBytes,
    required ValueChanged<double> onProgress,
  }) async {
    if (source.scheme != 'https') {
      throw const FormatException('Only HTTPS pack downloads are allowed.');
    }

    await destination.parent.create(recursive: true);
    final response = await _client.send(http.Request('GET', source));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Pack download failed with HTTP ${response.statusCode}.',
        uri: source,
      );
    }

    final sink = destination.openWrite();
    var received = 0;
    try {
      await for (final chunk in response.stream) {
        received += chunk.length;
        if (received > expectedBytes) {
          throw const PackIntegrityException(
            'Downloaded pack exceeds manifest archive size.',
          );
        }
        sink.add(chunk);
        final progress = expectedBytes == 0
            ? 0.0
            : (received / expectedBytes).clamp(0, 1).toDouble();
        onProgress(progress);
      }
      await sink.flush();
    } finally {
      await sink.close();
    }
    return received;
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}

abstract interface class PackArchiveExtractor {
  Future<void> extract(
    File archiveFile,
    Directory destination,
    LanguagePackDescriptor descriptor,
  );
}

/// Language-neutral pack bundle:
/// gzip(JSON({packId, version, contractVersion, files:[{path, contentBase64}]})).
class JsonGzipPackExtractor implements PackArchiveExtractor {
  const JsonGzipPackExtractor();

  static const String supportedFormat = 'json-gzip-v1';

  @override
  Future<void> extract(
    File archiveFile,
    Directory destination,
    LanguagePackDescriptor descriptor,
  ) async {
    final compressed = await archiveFile.readAsBytes();
    final decodedBytes = <int>[];
    final envelopeLimit = (descriptor.installedSizeBytes * 2 + 1024 * 1024)
        .clamp(1024 * 1024, 128 * 1024 * 1024)
        .toInt();
    try {
      final decoder = gzip.decoder.startChunkedConversion(
        _BoundedByteSink(decodedBytes, envelopeLimit),
      );
      decoder.add(compressed);
      decoder.close();
    } on PackIntegrityException {
      rethrow;
    } on Object {
      throw const PackIntegrityException('Pack gzip payload is invalid.');
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(decodedBytes));
    } on Object {
      throw const PackIntegrityException('Pack JSON payload is invalid.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const PackIntegrityException('Pack payload must be a JSON object.');
    }

    if (decoded['packId'] != descriptor.id ||
        decoded['version'] != descriptor.version ||
        decoded['contractVersion'] != descriptor.contractVersion) {
      throw const PackIntegrityException(
        'Pack payload identity does not match its manifest.',
      );
    }

    final files = decoded['files'];
    if (files is! List || files.isEmpty || files.length > 256) {
      throw const PackIntegrityException(
        'Pack files must contain between 1 and 256 entries.',
      );
    }

    await destination.create(recursive: true);
    final root = p.normalize(destination.absolute.path);
    final seenPaths = <String>{};
    var expandedBytes = 0;

    for (final rawFile in files) {
      if (rawFile is! Map) {
        throw const PackIntegrityException('Invalid pack file entry.');
      }
      final file = rawFile.cast<String, dynamic>();
      final safePath = _safeRelativePath((file['path'] ?? '').toString());
      if (!seenPaths.add(safePath)) {
        throw PackIntegrityException('Duplicate pack file: $safePath');
      }

      late final List<int> content;
      try {
        content = base64Decode((file['contentBase64'] ?? '').toString());
      } on Object {
        throw PackIntegrityException(
          'Invalid base64 content for pack file: $safePath',
        );
      }

      expandedBytes += content.length;
      if (expandedBytes > descriptor.installedSizeBytes) {
        throw const PackIntegrityException(
          'Expanded pack exceeds manifest installed size.',
        );
      }

      final outputPath = p.normalize(p.join(root, safePath));
      if (!p.isWithin(root, outputPath)) {
        throw const PackIntegrityException(
          'Pack file attempts to escape its destination.',
        );
      }
      final output = File(outputPath);
      await output.parent.create(recursive: true);
      await output.writeAsBytes(content, flush: true);
    }

    if (expandedBytes != descriptor.installedSizeBytes) {
      throw PackIntegrityException(
        'Expanded size mismatch: expected '
        '${descriptor.installedSizeBytes}, got $expandedBytes.',
      );
    }
  }

  static String _safeRelativePath(String rawPath) {
    final normalized = p.posix.normalize(rawPath.replaceAll('\\', '/'));
    if (normalized.isEmpty ||
        normalized == '.' ||
        normalized == '..' ||
        normalized.startsWith('../') ||
        p.posix.isAbsolute(normalized) ||
        normalized.length > 240) {
      throw const PackIntegrityException('Unsafe pack file path.');
    }
    return p.joinAll(p.posix.split(normalized));
  }
}

final class _BoundedByteSink implements ChunkedConversionSink<List<int>> {
  _BoundedByteSink(this.target, this.maxBytes);

  final List<int> target;
  final int maxBytes;
  int _received = 0;

  @override
  void add(List<int> chunk) {
    _received += chunk.length;
    if (_received > maxBytes) {
      throw const PackIntegrityException(
        'Expanded gzip envelope exceeds safety limit.',
      );
    }
    target.addAll(chunk);
  }

  @override
  void close() {}
}

final class _ManifestAcceptance {
  const _ManifestAcceptance({
    required this.revision,
    required this.signature,
    required this.keyId,
  });

  const _ManifestAcceptance.empty()
      : revision = 0,
        signature = '',
        keyId = '';

  final int revision;
  final String signature;
  final String keyId;
}

class PackManagerService extends ChangeNotifier {
  PackManagerService(
    this._prefs, {
    required this.rootDirectory,
    PackManifestVerifier? manifestVerifier,
    PackDatabaseKeyStore databaseKeyStore =
        const UnavailablePackDatabaseKeyStore(),
    PackDatabaseCipher databaseCipher = const UnavailablePackDatabaseCipher(),
    PackDownloader? downloader,
    PackArchiveExtractor extractor = const JsonGzipPackExtractor(),
    DateTime Function()? clock,
  })  : _manifestVerifier =
            manifestVerifier ?? const RejectingPackManifestVerifier(),
        _databaseKeyStore = databaseKeyStore,
        _databaseCipher = databaseCipher,
        _downloader = downloader ?? HttpPackDownloader(),
        _extractor = extractor,
        _clock = clock ?? DateTime.now {
    _loadInstalledRegistry();
  }

  static const String installedRegistryKey = 'offline_pack_registry_v1';
  static const String activePackKey = 'offline_active_pack_v1';
  static const String manifestRevisionKey = 'offline_manifest_revision_v1';
  static const String manifestAcceptanceKey = 'offline_manifest_acceptance_v2';

  final PreferencesService _prefs;
  final Directory rootDirectory;
  final PackManifestVerifier _manifestVerifier;
  final PackDatabaseKeyStore _databaseKeyStore;
  final PackDatabaseCipher _databaseCipher;
  final PackDownloader _downloader;
  final PackArchiveExtractor _extractor;
  final DateTime Function() _clock;

  PackManifest _manifest = PackManifest.empty();
  final Map<String, InstalledLanguagePack> _installed =
      <String, InstalledLanguagePack>{};
  final Map<String, PackOperationState> _operations =
      <String, PackOperationState>{};
  String? _activePackId;

  PackManifest get manifest => _manifest;
  List<LanguagePackDescriptor> get availablePacks => _manifest.packs;
  List<InstalledLanguagePack> get installedPacks =>
      List.unmodifiable(_installed.values);
  String? get activePackId => _activePackId;
  int get totalStorageBytes => _installed.values.fold<int>(
        0,
        (total, pack) => total + pack.storageBytes,
      );

  InstalledLanguagePack? installedFor(String packId) => _installed[packId];

  PackOperationState operationFor(String packId) =>
      _operations[packId] ?? const PackOperationState.idle();

  Future<PackManifest> loadManifestJson(String rawJson) async {
    final parsed = await _manifestVerifier.verifyAndParse(rawJson);
    final acceptance = _readManifestAcceptance();
    final legacyRevision = _prefs.getInt(manifestRevisionKey) ?? 0;
    final acceptedRevision = acceptance.revision > legacyRevision
        ? acceptance.revision
        : legacyRevision;
    if (parsed.manifestRevision < acceptedRevision) {
      throw StateError(
        'Manifest rollback rejected: ' +
            parsed.manifestRevision.toString() +
            ' < ' +
            acceptedRevision.toString() +
            '.',
      );
    }
    if (parsed.manifestRevision == acceptance.revision &&
        acceptance.signature.isNotEmpty &&
        (parsed.signature != acceptance.signature ||
            parsed.keyId != acceptance.keyId)) {
      throw StateError(
        'Manifest replay conflict: revision was already accepted with '
        'different signed content.',
      );
    }
    if (parsed.manifestRevision > acceptance.revision ||
        acceptance.signature.isEmpty) {
      final state = jsonEncode(<String, Object>{
        'revision': parsed.manifestRevision,
        'signature': parsed.signature,
        'keyId': parsed.keyId,
      });
      if (!await _prefs.writeText(manifestAcceptanceKey, state)) {
        throw StateError('Manifest acceptance state could not be persisted.');
      }
      await _prefs.setInt(manifestRevisionKey, parsed.manifestRevision);
    }
    _manifest = parsed;
    notifyListeners();
    return parsed;
  }

  Future<InstalledLanguagePack> install(
    LanguagePackDescriptor descriptor,
  ) async {
    _assertDescriptorAdmitted(descriptor);
    _assertNotBusy(descriptor.id);
    await rootDirectory.create(recursive: true);

    final downloadDir = Directory(p.join(rootDirectory.path, '.downloads'));
    final stagingRoot = Directory(p.join(rootDirectory.path, '.staging'));
    await downloadDir.create(recursive: true);
    await stagingRoot.create(recursive: true);

    final stamp = _clock().toUtc().microsecondsSinceEpoch;
    final archiveFile = File(
      p.join(downloadDir.path, '${descriptor.id}_$stamp.pack.gz'),
    );
    final staging = Directory(
      p.join(stagingRoot.path, '${descriptor.id}_$stamp'),
    );

    try {
      _setOperation(
        descriptor.id,
        const PackOperationState(
          stage: PackLifecycleStage.downloading,
          progress: 0,
        ),
      );
      final downloaded = await _downloader.download(
        descriptor.archiveUrl,
        archiveFile,
        expectedBytes: descriptor.archiveSizeBytes,
        onProgress: (progress) => _setOperation(
          descriptor.id,
          PackOperationState(
            stage: PackLifecycleStage.downloading,
            progress: progress,
          ),
        ),
      );
      if (downloaded != descriptor.archiveSizeBytes) {
        throw PackIntegrityException(
          'Archive size mismatch: expected '
          '${descriptor.archiveSizeBytes}, got $downloaded.',
        );
      }

      _setOperation(
        descriptor.id,
        const PackOperationState(
          stage: PackLifecycleStage.verifying,
          progress: 1,
        ),
      );
      final checksum = PackChecksum.sha256Hex(await archiveFile.readAsBytes());
      if (checksum.toLowerCase() != descriptor.sha256.toLowerCase()) {
        throw const PackIntegrityException(
          'SHA-256 checksum verification failed.',
        );
      }

      _setOperation(
        descriptor.id,
        const PackOperationState(
          stage: PackLifecycleStage.extracting,
          progress: 1,
        ),
      );
      await staging.create(recursive: true);
      await _extractor.extract(archiveFile, staging, descriptor);
      final sqliteFile = File(
        p.join(staging.path, 'content', 'content.sqlite'),
      );
      if (!await sqliteFile.exists()) {
        throw const PackIntegrityException(
          'Pack is missing required content/content.sqlite.',
        );
      }
      final contentChecksum = PackChecksum.sha256Hex(
        await sqliteFile.readAsBytes(),
      );
      if (contentChecksum.toLowerCase() !=
          descriptor.contentSha256.toLowerCase()) {
        throw const PackIntegrityException(
          'Content SQLite SHA-256 verification failed.',
        );
      }
      final plaintextStorageBytes = await _directorySize(staging);
      if (plaintextStorageBytes != descriptor.installedSizeBytes) {
        throw PackIntegrityException(
          'Installed size mismatch: expected ' +
              descriptor.installedSizeBytes.toString() +
              ', got ' +
              plaintextStorageBytes.toString() +
              '.',
        );
      }

      final databaseKey = await _databaseKeyStore.getOrCreateKey();
      await _databaseCipher.encryptPlaintextInPlace(
        sqliteFile,
        password: databaseKey,
      );
      final storageBytes = await _directorySize(staging);

      final destination = _packDirectory(descriptor.id);
      await _replaceAtomically(staging, destination);

      final installed = InstalledLanguagePack(
        id: descriptor.id,
        languageCode: descriptor.languageCode,
        displayName: descriptor.displayName,
        version: descriptor.version,
        contractVersion: descriptor.contractVersion,
        sha256: descriptor.sha256,
        contentSha256: descriptor.contentSha256,
        storageBytes: storageBytes,
        installedAt: _clock().toUtc(),
        manifestRevision: _manifest.manifestRevision,
        manifestKeyId: _manifest.keyId,
        manifestSignature: _manifest.signature,
        databaseEncrypted: true,
      );
      _installed[descriptor.id] = installed;
      await _persistInstalledRegistry();

      if (_activePackId == null) {
        await _persistActivePack(descriptor.id);
      }

      _setOperation(
        descriptor.id,
        const PackOperationState(
          stage: PackLifecycleStage.installed,
          progress: 1,
        ),
      );
      return installed;
    } on Object catch (error) {
      _setOperation(
        descriptor.id,
        PackOperationState(
          stage: PackLifecycleStage.failed,
          message: error.toString(),
        ),
      );
      rethrow;
    } finally {
      if (await archiveFile.exists()) {
        await archiveFile.delete();
      }
      if (await staging.exists()) {
        await staging.delete(recursive: true);
      }
    }
  }

  Future<InstalledLanguagePack> reinstall(LanguagePackDescriptor descriptor) =>
      install(descriptor);

  Future<void> deletePack(String packId) async {
    _assertPackId(packId);
    _assertNotBusy(packId);
    _setOperation(
      packId,
      const PackOperationState(stage: PackLifecycleStage.deleting),
    );
    try {
      final directory = _packDirectory(packId);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
      _installed.remove(packId);
      await _persistInstalledRegistry();
      if (_activePackId == packId) {
        _activePackId = null;
        if (!await _prefs.deleteValue(activePackKey)) {
          throw StateError('Active pack registration could not be cleared.');
        }
      }
      _setOperation(packId, const PackOperationState.idle());
    } on Object catch (error) {
      _setOperation(
        packId,
        PackOperationState(
          stage: PackLifecycleStage.failed,
          message: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> setActivePack(String packId) async {
    _assertPackId(packId);
    final installed = _installed[packId];
    if (installed == null) {
      throw StateError('Cannot activate a pack that is not installed.');
    }
    if (!installed.hasSignedProvenance) {
      throw StateError('Cannot activate a pack without signed provenance.');
    }
    if (!installed.databaseEncrypted) {
      throw StateError('Cannot activate an unencrypted pack.');
    }
    await _persistActivePack(packId);
    notifyListeners();
  }

  Future<int> storageBytesFor(String packId) async {
    _assertPackId(packId);
    return _directorySize(_packDirectory(packId));
  }

  Future<void> refreshStorage() async {
    var changed = false;
    final stale = <String>[];

    for (final entry in _installed.entries.toList(growable: false)) {
      final directory = _packDirectory(entry.key);
      if (!await directory.exists()) {
        stale.add(entry.key);
        continue;
      }
      final bytes = await _directorySize(directory);
      if (bytes != entry.value.storageBytes) {
        _installed[entry.key] = entry.value.copyWith(storageBytes: bytes);
        changed = true;
      }
    }

    for (final id in stale) {
      _installed.remove(id);
      changed = true;
    }
    if (_activePackId != null && !_installed.containsKey(_activePackId)) {
      _activePackId = null;
      await _prefs.deleteValue(activePackKey);
      changed = true;
    }

    if (changed) {
      await _persistInstalledRegistry();
      notifyListeners();
    }
  }

  Directory _packDirectory(String packId) =>
      Directory(p.join(rootDirectory.path, 'packs', packId));

  void _loadInstalledRegistry() {
    final raw = _prefs.readTextList(installedRegistryKey) ?? const <String>[];
    for (final entry in raw) {
      try {
        final decoded = jsonDecode(entry);
        if (decoded is! Map) continue;
        final installed = InstalledLanguagePack.fromJson(
          decoded.cast<String, dynamic>(),
        );
        _installed[installed.id] = installed;
      } on Object {
        // Corrupt local registration is ignored rather than trusted.
      }
    }
    final active = _prefs.readText(activePackKey);
    _activePackId =
        active != null && _installed.containsKey(active) ? active : null;
  }

  Future<void> _persistInstalledRegistry() async {
    final rows = _installed.values
        .map((pack) => jsonEncode(pack.toJson()))
        .toList(growable: false);
    if (!await _prefs.writeTextList(installedRegistryKey, rows)) {
      throw StateError('Installed pack registry could not be persisted.');
    }
  }

  Future<void> _persistActivePack(String packId) async {
    if (!await _prefs.writeText(activePackKey, packId)) {
      throw StateError('Active pack registration could not be persisted.');
    }
    _activePackId = packId;
  }

  Future<void> _replaceAtomically(
    Directory staging,
    Directory destination,
  ) async {
    await destination.parent.create(recursive: true);
    final backup = Directory('${destination.path}.backup');
    if (await backup.exists()) {
      await backup.delete(recursive: true);
    }

    var movedExisting = false;
    if (await destination.exists()) {
      await destination.rename(backup.path);
      movedExisting = true;
    }

    try {
      await staging.rename(destination.path);
      if (movedExisting && await backup.exists()) {
        await backup.delete(recursive: true);
      }
    } on Object {
      if (await destination.exists()) {
        await destination.delete(recursive: true);
      }
      if (movedExisting && await backup.exists()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
  }

  Future<int> _directorySize(Directory directory) async {
    if (!await directory.exists()) return 0;
    var total = 0;
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }

  _ManifestAcceptance _readManifestAcceptance() {
    final raw = _prefs.readText(manifestAcceptanceKey);
    if (raw == null || raw.isEmpty) return const _ManifestAcceptance.empty();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw StateError('Manifest acceptance state is corrupt.');
      }
      final map = decoded.cast<String, dynamic>();
      final revision = (map['revision'] as num?)?.toInt() ?? 0;
      final signature = (map['signature'] ?? '').toString();
      final keyId = (map['keyId'] ?? '').toString();
      if (revision <= 0 || signature.isEmpty || keyId.isEmpty) {
        throw StateError('Manifest acceptance state is corrupt.');
      }
      return _ManifestAcceptance(
        revision: revision,
        signature: signature,
        keyId: keyId,
      );
    } on StateError {
      rethrow;
    } on Object {
      throw StateError('Manifest acceptance state is corrupt.');
    }
  }

  void _assertDescriptorAdmitted(LanguagePackDescriptor descriptor) {
    final admitted = _manifest.packById(descriptor.id);
    if (admitted == null || !admitted.sameAs(descriptor)) {
      throw const PackIntegrityException(
        'Pack descriptor is not admitted by the verified manifest.',
      );
    }
  }

  void _setOperation(String packId, PackOperationState state) {
    _operations[packId] = state;
    notifyListeners();
  }

  void _assertNotBusy(String packId) {
    if (operationFor(packId).isBusy) {
      throw StateError('Pack operation already in progress: $packId');
    }
  }

  static void _assertPackId(String packId) {
    if (!RegExp(r'^[a-z0-9][a-z0-9._-]{1,63}$').hasMatch(packId)) {
      throw ArgumentError.value(packId, 'packId', 'Invalid pack id.');
    }
  }

  @override
  void dispose() {
    final downloader = _downloader;
    if (downloader is HttpPackDownloader) {
      downloader.dispose();
    }
    super.dispose();
  }
}
