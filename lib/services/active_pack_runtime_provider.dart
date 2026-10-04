import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart'
    show Database, DatabaseFactory, OpenDatabaseOptions;
import 'package:sqflite_sqlcipher/sqflite.dart' as sqlcipher;

import '../features/srs/corpus_sqlite_contract.dart';
import '../features/srs/corpus_sqlite_migrator.dart';
import '../features/srs/corpus_sqlite_repository.dart';
import '../language/language_pack.dart';
import '../language/german/german_word_family_repository.dart';
import 'grammar_hub_service.dart';
import 'pack_grammar_hub_repository.dart';
import 'pack_german_word_family_repository.dart';
import 'pack_manager_service.dart';
import 'pack_database_key_store.dart';
import 'pack_database_security.dart';

enum RuntimeContentOrigin { activePack, embeddedFallback }

final class RuntimePackState {
  const RuntimePackState({
    required this.origin,
    this.activePackId,
    this.fallbackReason,
  });

  const RuntimePackState.embeddedFallback({
    this.activePackId,
    this.fallbackReason,
  }) : origin = RuntimeContentOrigin.embeddedFallback;

  final RuntimeContentOrigin origin;
  final String? activePackId;
  final String? fallbackReason;

  bool get isActivePack => origin == RuntimeContentOrigin.activePack;
}

final class RuntimePackResolution {
  const RuntimePackResolution({
    required this.languagePack,
    required this.grammarHubService,
    required this.state,
    this.wordFamilyRepository = const EmptyGermanWordFamilyRepository(),
    this.corpusRepository,
    Database? corpusDatabase,
  }) : _corpusDatabase = corpusDatabase;

  final LanguagePack languagePack;
  final GrammarHubRepository grammarHubService;
  final GermanWordFamilyRepository wordFamilyRepository;
  final RuntimePackState state;

  /// Indexed SQLite corpus. Null means no admitted local corpus is active.
  final IndexedSrsCorpusRepository? corpusRepository;
  final Database? _corpusDatabase;

  bool get hasIndexedCorpus => corpusRepository != null;

  Future<void> closeCorpus() async {
    final database = _corpusDatabase;
    if (database != null) {
      await database.close();
    }
  }
}

/// Admission boundary for authenticity/integrity decisions before the SQLite
/// database is trusted.
abstract interface class RuntimePackAdmissionGate {
  Future<void> verify({
    required InstalledLanguagePack pack,
    required String sqlitePath,
  });
}

final class RegisteredRuntimePackAdmissionGate
    implements RuntimePackAdmissionGate {
  const RegisteredRuntimePackAdmissionGate();

  @override
  Future<void> verify({
    required InstalledLanguagePack pack,
    required String sqlitePath,
  }) async {
    if (sqlitePath.trim().isEmpty) {
      throw const RuntimePackAdmissionException('pack_sqlite_missing');
    }
    if (pack.contractVersion.trim().isEmpty) {
      throw const RuntimePackAdmissionException('pack_contract_missing');
    }
    if (!pack.hasSignedProvenance) {
      throw const RuntimePackAdmissionException('pack_provenance_missing');
    }
    if (!pack.databaseEncrypted) {
      throw const RuntimePackAdmissionException('pack_database_unencrypted');
    }
  }
}

final class RuntimePackAdmissionException implements Exception {
  const RuntimePackAdmissionException(this.code);

  final String code;

  @override
  String toString() => 'RuntimePackAdmissionException($code)';
}

/// Resolves an admitted language pack to indexed local SQLite.
///
/// The signed/encrypted pack database remains immutable. Its legacy lexicon is
/// migrated in bounded pages into a derived indexed SRS database. Production
/// callers read content through [corpusRepository]; no full lexicon is
/// materialized into Dart objects here.
final class ActivePackRuntimeProvider {
  ActivePackRuntimeProvider({
    required this.packManager,
    required LanguagePack languagePack,
    required this.embeddedGrammar,
    this.databaseFactory,
    PackDatabaseKeyStore? databaseKeyStore,
    PackDatabaseOpener? databaseOpener,
    this.admissionGate = const RegisteredRuntimePackAdmissionGate(),
  })  : embeddedLanguagePack = languagePack,
        _databaseKeyStore =
            databaseKeyStore ?? const UnavailablePackDatabaseKeyStore(),
        _databaseOpener = databaseOpener ??
            (databaseFactory == null
                ? const SqlCipherPackDatabaseSecurity()
                : FactoryBackedPackDatabaseOpener(databaseFactory));

  static const String derivedCorpusFilePrefix = 'srs-corpus-v1-';

  final PackManagerService packManager;
  final LanguagePack embeddedLanguagePack;
  final GrammarHubRepository embeddedGrammar;
  final DatabaseFactory? databaseFactory;
  final PackDatabaseKeyStore _databaseKeyStore;
  final PackDatabaseOpener _databaseOpener;
  final RuntimePackAdmissionGate admissionGate;

  Future<RuntimePackResolution> resolve() async {
    final activeId = packManager.activePackId;
    if (activeId == null) {
      return _fallback('no_active_pack');
    }

    final installed = packManager.installedFor(activeId);
    if (installed == null) {
      return _fallback('active_pack_not_registered', activeId);
    }
    if (installed.languageCode.toLowerCase() !=
        embeddedLanguagePack.languageCode.toLowerCase()) {
      return _fallback('active_pack_language_mismatch', activeId);
    }

    final sqlitePath = p.join(
      packManager.rootDirectory.path,
      'packs',
      activeId,
      'content',
      'content.sqlite',
    );

    Database? source;
    Database? corpusDatabase;
    try {
      await admissionGate.verify(
        pack: installed,
        sqlitePath: sqlitePath,
      );
      if (!await _databaseExists(sqlitePath)) {
        throw const RuntimePackAdmissionException('pack_sqlite_missing');
      }

      final databaseKey = await _databaseKeyStore.readKey();
      if (databaseKey == null || databaseKey.trim().isEmpty) {
        throw const RuntimePackAdmissionException(
          'pack_database_key_missing',
        );
      }

      source = await _databaseOpener.openReadOnly(
        sqlitePath,
        password: databaseKey,
      );
      final expectedCardinality = await _validateMetadata(
        source,
        installed,
      );

      final prepared = await _openOrBuildCorpus(
        source: source,
        installed: installed,
        databaseKey: databaseKey,
        expectedCardinality: expectedCardinality,
      );
      corpusDatabase = prepared.database;

      await source.close();
      source = null;

      return RuntimePackResolution(
        languagePack: embeddedLanguagePack,
        grammarHubService: PackGrammarHubRepository(
          databasePath: sqlitePath,
          packId: activeId,
          fallback: embeddedGrammar,
          databaseOpener: _databaseOpener,
          databasePassword: databaseKey,
        ),
        wordFamilyRepository: PackGermanWordFamilyRepository(
          databasePath: sqlitePath,
          databaseOpener: _databaseOpener,
          databasePassword: databaseKey,
        ),
        corpusRepository: prepared.repository,
        corpusDatabase: corpusDatabase,
        state: RuntimePackState(
          origin: RuntimeContentOrigin.activePack,
          activePackId: activeId,
        ),
      );
    } on RuntimePackAdmissionException catch (error) {
      if (corpusDatabase != null) {
        await corpusDatabase.close();
      }
      return _fallback(error.code, activeId);
    } on Object {
      if (corpusDatabase != null) {
        await corpusDatabase.close();
      }
      return _fallback('active_pack_runtime_invalid', activeId);
    } finally {
      if (source != null) {
        try {
          await source.close();
        } on Object {
          // Cleanup must not replace the original failure reason.
        }
      }
    }
  }

  Future<_PreparedCorpus> _openOrBuildCorpus({
    required Database source,
    required InstalledLanguagePack installed,
    required String databaseKey,
    required SrsCorpusCardinality expectedCardinality,
  }) async {
    final runtimeDirectory = Directory(
      p.join(
        packManager.rootDirectory.path,
        'packs',
        installed.id,
        'runtime',
      ),
    );
    await runtimeDirectory.create(recursive: true);

    final contentIdentity = installed.contentSha256.toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(contentIdentity)) {
      throw const RuntimePackAdmissionException(
        'pack_content_sha256_invalid',
      );
    }
    final finalFile = File(
      p.join(
        runtimeDirectory.path,
        '$derivedCorpusFilePrefix$contentIdentity.sqlite',
      ),
    );
    final buildingFile = File(finalFile.path + '.building');

    if (await buildingFile.exists()) {
      await buildingFile.delete();
    }

    if (await finalFile.exists()) {
      final existing = await _tryOpenVerifiedCorpus(
        path: finalFile.path,
        databaseKey: databaseKey,
        expectedCardinality: expectedCardinality,
        sourceContentSha256: contentIdentity,
      );
      if (existing != null) {
        return existing;
      }
      await finalFile.delete();
    }

    Database? target;
    try {
      target = await _openWritableDerivedDatabase(
        path: buildingFile.path,
        databaseKey: databaseKey,
      );
      final report = await const SrsCorpusSqliteMigrator().migrate(
        source: source,
        target: target,
        expectedCardinality: expectedCardinality,
        sourceContentSha256: contentIdentity,
      );
      if (!report.matches(expectedCardinality)) {
        throw const RuntimePackAdmissionException(
          'srs_corpus_migration_incomplete',
        );
      }
      await target.close();
      target = null;

      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await buildingFile.rename(finalFile.path);

      final prepared = await _tryOpenVerifiedCorpus(
        path: finalFile.path,
        databaseKey: databaseKey,
        expectedCardinality: expectedCardinality,
        sourceContentSha256: contentIdentity,
      );
      if (prepared == null) {
        throw const RuntimePackAdmissionException(
          'srs_corpus_verification_failed',
        );
      }
      return prepared;
    } on RuntimePackAdmissionException {
      rethrow;
    } on Object {
      throw const RuntimePackAdmissionException(
        'srs_corpus_migration_failed',
      );
    } finally {
      if (target != null) {
        try {
          await target.close();
        } on Object {
          // Cleanup boundary only.
        }
      }
      if (await buildingFile.exists()) {
        await buildingFile.delete();
      }
    }
  }

  Future<_PreparedCorpus?> _tryOpenVerifiedCorpus({
    required String path,
    required String databaseKey,
    required SrsCorpusCardinality expectedCardinality,
    required String sourceContentSha256,
  }) async {
    Database? database;
    try {
      database = await _openDerivedReadOnly(
        path: path,
        databaseKey: databaseKey,
      );
      final repository = await IndexedSrsCorpusRepository.open(
        database,
        expectedCardinality: expectedCardinality,
        sourceContentSha256: sourceContentSha256,
      );
      return _PreparedCorpus(
        database: database,
        repository: repository,
      );
    } on Object {
      if (database != null) {
        try {
          await database.close();
        } on Object {
          // Invalid derived corpus is discarded by the caller.
        }
      }
      return null;
    }
  }

  Future<Database> _openWritableDerivedDatabase({
    required String path,
    required String databaseKey,
  }) {
    final factory = databaseFactory;
    if (factory != null) {
      return factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          singleInstance: false,
        ),
      );
    }
    return sqlcipher.openDatabase(
      path,
      password: databaseKey,
      singleInstance: false,
    );
  }

  Future<Database> _openDerivedReadOnly({
    required String path,
    required String databaseKey,
  }) {
    final factory = databaseFactory;
    if (factory != null) {
      return factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          readOnly: true,
          singleInstance: false,
        ),
      );
    }
    return sqlcipher.openDatabase(
      path,
      password: databaseKey,
      readOnly: true,
      singleInstance: false,
    );
  }

  Future<bool> _databaseExists(String path) {
    final factory = databaseFactory;
    return factory == null
        ? sqflite.databaseExists(path)
        : factory.databaseExists(path);
  }

  Future<SrsCorpusCardinality> _validateMetadata(
    Database database,
    InstalledLanguagePack installed,
  ) async {
    if (!await _hasTable(database, 'metadata') ||
        !await _hasTable(database, 'lexicon')) {
      throw const RuntimePackAdmissionException('pack_schema_missing');
    }

    final rows = await database.query('metadata', limit: 64);
    final metadata = <String, String>{
      for (final row in rows)
        if (row['key'] != null && row['value'] != null)
          row['key'].toString(): row['value'].toString(),
    };

    if (metadata['packId'] != installed.id ||
        metadata['languageCode']?.toLowerCase() !=
            installed.languageCode.toLowerCase() ||
        metadata['version'] != installed.version ||
        metadata['contractVersion'] != installed.contractVersion) {
      throw const RuntimePackAdmissionException(
        'pack_metadata_mismatch',
      );
    }

    final contentRows = _requiredMetadataInt(
      metadata,
      'contentRows',
      allowZero: false,
    );
    final verbRows = _requiredMetadataInt(
      metadata,
      'verbRows',
      allowZero: true,
    );

    final countRows = await database.rawQuery(
      'SELECT COUNT(*) AS count FROM lexicon',
    );
    final rawCount =
        countRows.length == 1 ? countRows.single['count'] : null;
    final actualContentRows = rawCount is int
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '');
    if (actualContentRows != contentRows) {
      throw const RuntimePackAdmissionException(
        'pack_content_cardinality_mismatch',
      );
    }

    return SrsCorpusCardinality(
      contentRows: contentRows,
      verbRows: verbRows,
    );
  }

  int _requiredMetadataInt(
    Map<String, String> metadata,
    String key, {
    required bool allowZero,
  }) {
    final value = int.tryParse(metadata[key] ?? '');
    final minimum = allowZero ? 0 : 1;
    if (value == null || value < minimum) {
      throw const RuntimePackAdmissionException(
        'pack_cardinality_metadata_invalid',
      );
    }
    return value;
  }

  Future<bool> _hasTable(Database database, String name) async {
    final rows = await database.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      <Object?>['table', name],
    );
    return rows.isNotEmpty;
  }

  RuntimePackResolution _fallback(
    String reason, [
    String? attemptedPackId,
  ]) =>
      RuntimePackResolution(
        languagePack: embeddedLanguagePack,
        grammarHubService: embeddedGrammar,
        state: RuntimePackState.embeddedFallback(
          activePackId: attemptedPackId,
          fallbackReason: reason,
        ),
      );
}

final class _PreparedCorpus {
  const _PreparedCorpus({
    required this.database,
    required this.repository,
  });

  final Database database;
  final IndexedSrsCorpusRepository repository;
}
