import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'vocabulary_provider.dart';
import '../services/crash_loop_guard.dart';
import '../services/database_integrity_service.dart';

/// The public catalog supplies metadata, not proof that a pack has been mounted
/// into the content database. Never use its is_active field as install status.
const languagePackManifestUrl =
    'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/manifest.json';
const _packBaseUrl =
    'https://raw.githubusercontent.com/moaz76943-creator/-offline-packs-store/main/packs/';
const _activeKey = 'language_manager.active_code.v1';
const _manifestCacheKey = 'language_manager.manifest.v1';

final languagePackStorageProvider = Provider<LanguagePackStorage>((ref) {
  return LanguagePackStorage();
});

final activeLanguageProvider =
    StateNotifierProvider<ActiveLanguageNotifier, ActiveLanguageState>((ref) {
  final notifier =
      ActiveLanguageNotifier(ref, ref.watch(languagePackStorageProvider));
  return notifier;
});

/// Content readers should watch this provider when querying language-specific
/// data. It updates immediately after a successful language switch.
final activeLanguageCodeProvider = Provider<String>((ref) {
  return ref.watch(
    activeLanguageProvider.select((state) => state.activeLanguageCode),
  );
});

class LanguagePackMetadata {
  const LanguagePackMetadata({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.sizeBytes,
    required this.packFile,
    required this.sha256Hex,
    required this.isAvailable,
  });

  final String code;
  final String name;
  final String nativeName;
  final int? sizeBytes;
  final String? packFile;
  final String? sha256Hex;
  final bool isAvailable;

  static final _safeCode = RegExp(r'^[a-z]{2,3}(-[a-z0-9]{2,8})?$');
  static final _safeFilename = RegExp(r'^[A-Za-z0-9_-]+\.pack\.gz$');
  static final _safeDigest = RegExp(r'^[a-fA-F0-9]{64}$');

  bool get canDownload =>
      code != 'de' &&
      isAvailable &&
      sizeBytes != null &&
      sizeBytes! > 0 &&
      packFile != null &&
      _safeFilename.hasMatch(packFile!) &&
      sha256Hex != null &&
      _safeDigest.hasMatch(sha256Hex!);

  static LanguagePackMetadata? fromManifest(Object? raw) {
    if (raw is! Map) return null;
    final code = (raw['code'] as String?)?.toLowerCase().trim();
    if (code == null || !_safeCode.hasMatch(code)) return null;

    final size = raw['size_bytes'];
    final native = raw['native_name'];
    final english = raw['name'];
    return LanguagePackMetadata(
      code: code,
      name: english is String && english.trim().isNotEmpty
          ? english.trim()
          : code.toUpperCase(),
      nativeName: native is String && native.trim().isNotEmpty
          ? native.trim()
          : (english is String ? english : code.toUpperCase()),
      sizeBytes: size is int && size > 0 ? size : null,
      packFile: raw['pack_file'] is String ? raw['pack_file'] as String : null,
      sha256Hex: raw['sha256'] is String ? raw['sha256'] as String : null,
      isAvailable: raw['is_active'] == true,
    );
  }

  static List<LanguagePackMetadata> parseManifest(String rawManifest) {
    final document = jsonDecode(rawManifest);
    if (document is! Map || document['languages'] is! List) {
      throw const FormatException('Invalid language pack manifest.');
    }
    final deduplicated = <String, LanguagePackMetadata>{};
    for (final item in document['languages'] as List) {
      final pack = fromManifest(item);
      if (pack != null) deduplicated[pack.code] = pack;
    }
    if (deduplicated.isEmpty) {
      throw const FormatException('Language manifest is empty.');
    }
    return List.unmodifiable(deduplicated.values);
  }
}

class ActiveLanguageState {
  ActiveLanguageState({
    required this.activeLanguageCode,
    required List<LanguagePackMetadata> remotePacks,
    required Set<String> installedCodes,
    required Map<String, double> downloadProgress,
    required Set<String> downloadingCodes,
    Set<String> quarantinedCodes = const <String>{},
    required this.isLoadingCatalog,
    this.errorMessage,
  })  : remotePacks = List.unmodifiable(remotePacks),
        installedCodes = Set.unmodifiable(installedCodes),
        downloadProgress = Map.unmodifiable(downloadProgress),
        downloadingCodes = Set.unmodifiable(downloadingCodes),
        quarantinedCodes = Set.unmodifiable(quarantinedCodes);

  factory ActiveLanguageState.initial() => ActiveLanguageState(
        activeLanguageCode: 'de',
        remotePacks: const [],
        installedCodes: const {'de'},
        downloadProgress: const {},
        downloadingCodes: const {},
        isLoadingCatalog: true,
      );

  final String activeLanguageCode;
  final List<LanguagePackMetadata> remotePacks;
  final Set<String> installedCodes;
  final Map<String, double> downloadProgress;
  final Set<String> downloadingCodes;
  final Set<String> quarantinedCodes;
  final bool isLoadingCatalog;
  final String? errorMessage;

  bool isInstalled(String code) =>
      !quarantinedCodes.contains(code) &&
      (code == 'de' || installedCodes.contains(code));
  bool isDownloading(String code) => downloadingCodes.contains(code);

  /// Keep installed packs visible even when the network catalog is unavailable.
  List<LanguagePackMetadata> get visiblePacks {
    final entries = <String, LanguagePackMetadata>{
      for (final pack in remotePacks) pack.code: pack,
    };
    entries.putIfAbsent(
      'de',
      () => const LanguagePackMetadata(
        code: 'de',
        name: 'German',
        nativeName: 'Deutsch',
        sizeBytes: null,
        packFile: null,
        sha256Hex: null,
        isAvailable: true,
      ),
    );
    for (final code in installedCodes) {
      entries.putIfAbsent(
        code,
        () => LanguagePackMetadata(
          code: code,
          name: code.toUpperCase(),
          nativeName: code.toUpperCase(),
          sizeBytes: null,
          packFile: null,
          sha256Hex: null,
          isAvailable: false,
        ),
      );
    }
    final packs = entries.values.toList();
    packs.sort((a, b) {
      if (a.code == 'de') return -1;
      if (b.code == 'de') return 1;
      return a.nativeName.toLowerCase().compareTo(b.nativeName.toLowerCase());
    });
    return packs;
  }

  ActiveLanguageState copyWith({
    String? activeLanguageCode,
    List<LanguagePackMetadata>? remotePacks,
    Set<String>? installedCodes,
    Map<String, double>? downloadProgress,
    Set<String>? downloadingCodes,
    Set<String>? quarantinedCodes,
    bool? isLoadingCatalog,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActiveLanguageState(
      activeLanguageCode: activeLanguageCode ?? this.activeLanguageCode,
      remotePacks: remotePacks ?? this.remotePacks,
      installedCodes: installedCodes ?? this.installedCodes,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      downloadingCodes: downloadingCodes ?? this.downloadingCodes,
      quarantinedCodes: quarantinedCodes ?? this.quarantinedCodes,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Isolated pack archive storage. This does not claim to import database rows;
/// that integration belongs to the parallel database/downloader track.
class LanguagePackStorage {
  Future<Directory> get _directory async {
    final support = await getApplicationSupportDirectory();
    return Directory(support.path + '/language_packs');
  }

  Future<File> _packFile(String code) async {
    if (!LanguagePackMetadata._safeCode.hasMatch(code) || code == 'de') {
      throw ArgumentError.value(code, 'code', 'Invalid downloadable code');
    }
    return File((await _directory).path + '/' + code + '.pack.gz');
  }

  Future<String> fetchManifest() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final request = await client
          .getUrl(Uri.parse(languagePackManifestUrl))
          .timeout(const Duration(seconds: 15));
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Catalog HTTP status: ' + response.statusCode.toString());
      }
      final bytes = BytesBuilder(copy: false);
      var count = 0;
      await for (final chunk in response.timeout(const Duration(seconds: 30))) {
        count += chunk.length;
        if (count > 1024 * 1024) {
          throw const FormatException('Catalog exceeds the maximum size.');
        }
        bytes.add(chunk);
      }
      return utf8.decode(bytes.takeBytes());
    } finally {
      client.close(force: true);
    }
  }

  Future<Set<String>> findInstalled(List<LanguagePackMetadata> packs) async {
    final installed = <String>{'de'};
    for (final pack in packs) {
      if (pack.code == 'de' || pack.sizeBytes == null) continue;
      final file = await _packFile(pack.code);
      if (await file.exists() &&
          await file.length() == pack.sizeBytes &&
          pack.sha256Hex != null &&
          LanguagePackMetadata._safeDigest.hasMatch(pack.sha256Hex!) &&
          await _fileDigest(file.path) == pack.sha256Hex!.toLowerCase()) {
        installed.add(pack.code);
      }
    }
    return installed;
  }

  Future<void> download(
    LanguagePackMetadata pack, {
    required void Function(double progress) onProgress,
  }) async {
    if (!pack.canDownload) throw StateError('Pack is not downloadable.');
    final directory = await _directory;
    await directory.create(recursive: true);
    final target = await _packFile(pack.code);
    final expectedHash = pack.sha256Hex!.toLowerCase();

    // Re-verify a cached file before considering it a successful download.
    if (await target.exists()) {
      if (await target.length() == pack.sizeBytes &&
          await _fileDigest(target.path) == expectedHash) {
        onProgress(1);
        return;
      }
    }

    final temporary = File(target.path + '.partial');
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 12);
    try {
      final uri = Uri.parse(_packBaseUrl + pack.packFile!);
      final request = await client.getUrl(uri).timeout(const Duration(seconds: 15));
      final response = await request.close().timeout(const Duration(seconds: 15));
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Pack HTTP status: ' + response.statusCode.toString());
      }

      final writer = temporary.openWrite(mode: FileMode.writeOnly);
      var received = 0;
      try {
        await for (final chunk in response.timeout(const Duration(seconds: 30))) {
          received += chunk.length;
          if (received > pack.sizeBytes!) {
            throw const FormatException('Pack is larger than its manifest size.');
          }
          writer.add(chunk);
          onProgress((received / pack.sizeBytes!).clamp(0.0, 1.0));
        }
        await writer.flush();
      } finally {
        await writer.close();
      }
      if (received != pack.sizeBytes) {
        throw const FormatException('Pack size does not match the manifest.');
      }
      if (await _fileDigest(temporary.path) != expectedHash) {
        throw const FormatException('Pack checksum verification failed.');
      }
      if (await target.exists()) await target.delete();
      await temporary.rename(target.path);
      onProgress(1);
    } finally {
      client.close(force: true);
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<void> delete(String code) async {
    final file = await _packFile(code);
    if (!await file.exists()) {
      throw StateError('No managed archive exists for ' + code);
    }
    await file.delete();
  }

  Future<String> _fileDigest(String path) async {
    // Stream hashing off the UI isolate: no full-pack in-memory buffer.
    return Isolate.run(
      () async => (await sha256.bind(File(path).openRead()).first).toString(),
    );
  }
}

class ActiveLanguageNotifier extends StateNotifier<ActiveLanguageState> {
  ActiveLanguageNotifier(this._ref, this._storage)
      : super(ActiveLanguageState.initial()) {
    DatabaseIntegrityService.instance.quarantined.addListener(_onQuarantine);
    _onQuarantine();
  }

  void _onQuarantine() {
    if (!mounted) return;
    final codes =
        DatabaseIntegrityService.instance.quarantined.value.keys.toSet();
    final changed = codes.length != state.quarantinedCodes.length ||
        !codes.containsAll(state.quarantinedCodes);
    final selected = codes.contains(state.activeLanguageCode)
        ? 'de'
        : state.activeLanguageCode;
    final switched = selected != state.activeLanguageCode;
    if (!changed && !switched) return;
    state = state.copyWith(
      quarantinedCodes: codes,
      activeLanguageCode: selected,
    );
    _ref.invalidate(vocabularyListProvider);
  }

  @override
  void dispose() {
    DatabaseIntegrityService.instance.quarantined.removeListener(_onQuarantine);
    super.dispose();
  }

  final Ref _ref;
  final LanguagePackStorage _storage;

  Future<void>? _localInitialization;
  String? _savedActive;

  /// Heavy pack verification and network access are activated by user action.
  Future<void> initialize({bool refreshRemoteCatalog = true}) async {
    await (_localInitialization ??= _restoreLocalState());
    if (!mounted || !refreshRemoteCatalog) return;
    await refreshCatalog();
    if (!mounted) return;
    final savedActive = _savedActive;
    if (savedActive != null && state.isInstalled(savedActive) &&
        state.activeLanguageCode != savedActive) {
      state = state.copyWith(activeLanguageCode: savedActive);
      _ref.invalidate(vocabularyListProvider);
    }
  }

  Future<void> _restoreLocalState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedActive = prefs.getString(_activeKey);
      _savedActive = savedActive;
      final cachedManifest = prefs.getString(_manifestCacheKey);
      if (cachedManifest != null && mounted) {
        final cachedPacks = LanguagePackMetadata.parseManifest(cachedManifest);
        await CrashLoopGuard.waitForIntegrityWindow();
        final installed = await _storage.findInstalled(cachedPacks);
        if (mounted) {
          state = state.copyWith(
            remotePacks: cachedPacks,
            installedCodes: {...installed, 'de'},
            activeLanguageCode:
                savedActive != null && installed.contains(savedActive)
                    ? savedActive
                    : 'de',
          );
        }
      }
    } catch (_) {
      // Without a verified installed pack, German remains the safe fallback.
    } finally {
      if (mounted) state = state.copyWith(isLoadingCatalog: false);
    }
  }

  Future<void> refreshCatalog() async {
    if (!mounted) return;
    state = state.copyWith(isLoadingCatalog: true, clearError: true);
    try {
      final raw = await _storage.fetchManifest();
      final packs = LanguagePackMetadata.parseManifest(raw);
      await CrashLoopGuard.waitForIntegrityWindow();
      final found = await _storage.findInstalled(packs);
      if (!mounted) return;
      final existing = {...state.installedCodes, ...found, 'de'};
      state = state.copyWith(
        remotePacks: packs,
        installedCodes: existing,
        isLoadingCatalog: false,
      );
      // Cache is best-effort and must not invalidate a verified catalog.
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_manifestCacheKey, raw);
      } catch (_) {}
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          isLoadingCatalog: false,
          errorMessage: 'تعذر تحديث الكتالوج. عرض البيانات المخزنة إن وجدت.',
        );
      }
    }
  }

  /// Called by the future pack installer after it has verified/mounted packs.
  /// German is always built-in, regardless of the supplied list.
  void updateInstalledList(List<String> codes) {
    final installed = <String>{
      'de',
      for (final code in codes)
        if (LanguagePackMetadata._safeCode.hasMatch(code)) code,
    };
    final active = installed.contains(state.activeLanguageCode)
        ? state.activeLanguageCode
        : 'de';
    final changed = active != state.activeLanguageCode;
    state = state.copyWith(
      installedCodes: installed,
      activeLanguageCode: active,
    );
    if (changed) _ref.invalidate(vocabularyListProvider);
  }

  /// Update external catalog metadata after manifest verification.
  void updateRemoteCatalog(List<LanguagePackMetadata> packs) {
    state = state.copyWith(remotePacks: packs, clearError: true);
  }

  Future<void> selectLanguage(String langCode) async {
    if (state.isDownloading(langCode)) {
      throw StateError('Wait until the download finishes.');
    }
    if (!state.isInstalled(langCode)) {
      throw StateError('Download and verify the pack before using it.');
    }
    if (langCode == state.activeLanguageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, langCode);
    if (!mounted) return;
    state = state.copyWith(activeLanguageCode: langCode, clearError: true);
    _ref.invalidate(vocabularyListProvider);
  }

  Future<void> downloadPack(String langCode) async {
    if (state.isInstalled(langCode) || state.isDownloading(langCode)) return;
    LanguagePackMetadata? pack;
    for (final item in state.remotePacks) {
      if (item.code == langCode) {
        pack = item;
        break;
      }
    }
    if (pack == null || !pack.canDownload) {
      throw StateError('No verified manifest entry for this language.');
    }
    state = state.copyWith(
      downloadingCodes: {...state.downloadingCodes, langCode},
      downloadProgress: {...state.downloadProgress, langCode: 0},
      clearError: true,
    );
    try {
      await _storage.download(pack, onProgress: (progress) {
        if (mounted) {
          state = state.copyWith(
            downloadProgress: {...state.downloadProgress, langCode: progress},
          );
        }
      });
      if (!mounted) return;
      state = state.copyWith(
        installedCodes: {...state.installedCodes, langCode},
      );
    } catch (error) {
      if (mounted) {
        state = state.copyWith(
          errorMessage: 'فشل تنزيل الحزمة أو التحقق منها: ' + error.toString(),
        );
      }
      rethrow;
    } finally {
      if (mounted) {
        final progress = {...state.downloadProgress}..remove(langCode);
        state = state.copyWith(
          downloadingCodes: {...state.downloadingCodes}..remove(langCode),
          downloadProgress: progress,
        );
      }
    }
  }

  Future<void> deletePack(String langCode) async {
    if (langCode == 'de') throw StateError('The built-in German pack is protected.');
    if (langCode == state.activeLanguageCode) {
      throw StateError('Switch to another language before deleting this pack.');
    }
    if (state.isDownloading(langCode)) {
      throw StateError('Cannot delete a pack while downloading it.');
    }
    await _storage.delete(langCode);
    if (!mounted) return;
    state = state.copyWith(
      installedCodes: {...state.installedCodes}..remove(langCode),
      clearError: true,
    );
  }
}
