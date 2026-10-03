import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../language/language_pack.dart';
import '../language/german/german_word_family_repository.dart';
import '../language/runtime_language_pack.dart';
import '../models/content.dart';
import '../models/verb_conjugation.dart';
import 'grammar_hub_service.dart';
import 'pack_grammar_hub_repository.dart';
import 'pack_german_word_family_repository.dart';
import 'pack_manager_service.dart';
import 'pack_database_key_store.dart';
import 'pack_database_security.dart';
import 'verb_index.dart';

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
  });

  final LanguagePack languagePack;
  final GrammarHubRepository grammarHubService;
  final GermanWordFamilyRepository wordFamilyRepository;
  final RuntimePackState state;
}

/// Admission boundary for authenticity/integrity decisions before the SQLite
/// database is trusted. Phase 6 can attach Ed25519 verification here without
/// changing runtime composition.
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

/// Resolves the active installed pack into a LanguagePack content override.
/// Any admission, schema, metadata, or SQLite failure returns the embedded
/// language pack unchanged as the last-known-good runtime.
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

  static const int maxRuntimeLexiconRows = 100000;
  static const int maxAcceptedForms = 32;
  static const int maxTextLength = 4000;

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

    Database? db;
    try {
      await admissionGate.verify(pack: installed, sqlitePath: sqlitePath);
      if (!await _databaseExists(sqlitePath)) {
        throw const RuntimePackAdmissionException('pack_sqlite_missing');
      }
      final databaseKey = await _databaseKeyStore.readKey();
      if (databaseKey == null) {
        throw const RuntimePackAdmissionException('pack_database_key_missing');
      }
      db = await _databaseOpener.openReadOnly(
        sqlitePath,
        password: databaseKey,
      );
      await _validateMetadata(db, installed);
      final loaded = await _loadContent(db);
      if (loaded.corpus.isEmpty) {
        throw const RuntimePackAdmissionException('pack_corpus_empty');
      }

      final verbIndex = VerbIndex.fromRows(
        textNormalizer: embeddedLanguagePack.textNormalizer,
        rows: loaded.verbRows,
      );
      final activeLanguagePack = RuntimeLanguagePack(
        base: embeddedLanguagePack,
        runtimeContentPack: RuntimeLanguageContentPack(
          items: loaded.corpus,
          verbIndex: verbIndex,
        ),
      );

      await db.close();
      db = null;

      return RuntimePackResolution(
        languagePack: activeLanguagePack,
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
        state: RuntimePackState(
          origin: RuntimeContentOrigin.activePack,
          activePackId: activeId,
        ),
      );
    } on RuntimePackAdmissionException catch (error) {
      return _fallback(error.code, activeId);
    } on Object {
      return _fallback('active_pack_runtime_invalid', activeId);
    } finally {
      if (db != null) {
        try {
          await db.close();
        } on Object {
          // Best-effort cleanup must not replace the original failure reason.
        }
      }
    }
  }

  Future<bool> _databaseExists(String path) {
    final factory = databaseFactory;
    return factory == null
        ? databaseExists(path)
        : factory.databaseExists(path);
  }

  Future<void> _validateMetadata(
    Database db,
    InstalledLanguagePack installed,
  ) async {
    if (!await _hasTable(db, 'metadata') || !await _hasTable(db, 'lexicon')) {
      throw const RuntimePackAdmissionException('pack_schema_missing');
    }

    final rows = await db.query('metadata', limit: 64);
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
      throw const RuntimePackAdmissionException('pack_metadata_mismatch');
    }
  }

  Future<_LoadedPackContent> _loadContent(Database db) async {
    final rows = await db.query(
      'lexicon',
      columns: const <String>['id', 'surface', 'part_of_speech', 'fields_json'],
      orderBy: 'id ASC',
      limit: maxRuntimeLexiconRows + 1,
    );
    if (rows.length > maxRuntimeLexiconRows) {
      throw const RuntimePackAdmissionException('pack_lexicon_too_large');
    }

    final ids = <String>{};
    final corpus = <ContentItem>[];
    final verbRows = <VerbConjugation>[];

    for (final row in rows) {
      final id = _boundedRequired(row['id'], 'id', maxLength: 160);
      if (!ids.add(id)) {
        throw const RuntimePackAdmissionException('pack_duplicate_content_id');
      }
      final source = _boundedRequired(
        row['surface'],
        'surface',
        maxLength: maxTextLength,
      );
      final fields = _decodeFields(row['fields_json']);
      final translation = _firstString(
          fields,
          const <String>[
            'translation',
            'translationText',
            'arabic',
          ],
          required: true);

      corpus.add(
        ContentItem(
          id: id,
          german: source,
          arabic: translation,
          sentence: _firstString(fields, const <String>['example', 'sentence']),
          sentenceAr: _firstString(fields, const <String>[
            'exampleTranslation',
            'sentenceAr',
          ]),
          topic: _firstString(
              fields,
              const <String>[
                'topic',
              ],
              fallback: 'pack'),
          skill: _firstString(
              fields,
              const <String>[
                'skill',
              ],
              fallback: 'recall'),
          article: _firstString(fields, const <String>[
            'article',
            'grammaticalMarker',
          ]),
          plural: _firstString(fields, const <String>['plural']),
          accepted: _acceptedForms(fields['accepted']),
        ),
      );

      final partOfSpeech = row['part_of_speech']?.toString().toLowerCase();
      if (partOfSpeech == 'verb') {
        verbRows.addAll(
          _verbRows(
            fields['verbRows'],
            fallbackInfinitive: source,
            fallbackTranslation: translation,
          ),
        );
      }
    }

    return _LoadedPackContent(
      corpus: List<ContentItem>.unmodifiable(corpus),
      verbRows: List<VerbConjugation>.unmodifiable(verbRows),
    );
  }

  Map<String, dynamic> _decodeFields(Object? raw) {
    if (raw is! String || raw.length > 256 * 1024) {
      throw const RuntimePackAdmissionException('pack_fields_invalid');
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        throw const RuntimePackAdmissionException('pack_fields_invalid');
      }
      return Map<String, dynamic>.from(decoded);
    } on RuntimePackAdmissionException {
      rethrow;
    } on Object {
      throw const RuntimePackAdmissionException('pack_fields_invalid');
    }
  }

  String _firstString(
    Map<String, dynamic> fields,
    List<String> keys, {
    bool required = false,
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = fields[key];
      if (value is String) {
        final clean = value.trim();
        if (clean.isNotEmpty && clean.length <= maxTextLength) {
          return clean;
        }
      }
    }
    if (required) {
      throw const RuntimePackAdmissionException(
        'pack_required_translation_missing',
      );
    }
    return fallback;
  }

  List<String> _acceptedForms(Object? raw) {
    if (raw is! List) return const <String>[];
    return raw
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty && value.length <= 200)
        .take(maxAcceptedForms)
        .toList(growable: false);
  }

  List<VerbConjugation> _verbRows(
    Object? raw, {
    required String fallbackInfinitive,
    required String fallbackTranslation,
  }) {
    if (raw is! List) return const <VerbConjugation>[];
    if (raw.length > 128) {
      throw const RuntimePackAdmissionException('pack_verb_rows_too_large');
    }
    return raw.map((entry) {
      if (entry is! Map) {
        throw const RuntimePackAdmissionException('pack_verb_row_invalid');
      }
      final row = Map<String, dynamic>.from(entry);
      return VerbConjugation(
        infinitive: _mapString(
          row,
          'infinitive',
          fallback: fallbackInfinitive,
        ),
        arabic: _mapString(row, 'arabic', fallback: fallbackTranslation),
        group: _mapString(row, 'group', fallback: 'pack'),
        person: _mapString(row, 'person', required: true),
        personAr: _mapString(row, 'personAr'),
        form: _mapString(row, 'form', required: true),
        past: _mapString(row, 'past'),
        pastArabic: _mapString(row, 'pastArabic'),
        example: _mapString(row, 'example'),
        exampleAr: _mapString(row, 'exampleAr'),
        pastExample: _mapString(row, 'pastExample'),
        pastExampleAr: _mapString(row, 'pastExampleAr'),
      );
    }).toList(growable: false);
  }

  String _mapString(
    Map<String, dynamic> map,
    String key, {
    bool required = false,
    String fallback = '',
  }) {
    final raw = map[key];
    if (raw is String) {
      final clean = raw.trim();
      if (clean.isNotEmpty && clean.length <= maxTextLength) {
        return clean;
      }
    }
    if (required) {
      throw const RuntimePackAdmissionException('pack_verb_row_invalid');
    }
    return fallback;
  }

  String _boundedRequired(Object? raw, String field, {required int maxLength}) {
    if (raw is! String) {
      throw RuntimePackAdmissionException('pack_' + field + '_invalid');
    }
    final value = raw.trim();
    if (value.isEmpty || value.length > maxLength) {
      throw RuntimePackAdmissionException('pack_' + field + '_invalid');
    }
    return value;
  }

  Future<bool> _hasTable(Database db, String name) async {
    final rows = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type = ? AND name = ?',
      <Object?>['table', name],
    );
    return rows.isNotEmpty;
  }

  RuntimePackResolution _fallback(String reason, [String? attemptedPackId]) =>
      RuntimePackResolution(
        languagePack: embeddedLanguagePack,
        grammarHubService: embeddedGrammar,
        state: RuntimePackState.embeddedFallback(
          activePackId: attemptedPackId,
          fallbackReason: reason,
        ),
      );
}

final class _LoadedPackContent {
  const _LoadedPackContent({required this.corpus, required this.verbRows});

  final List<ContentItem> corpus;
  final List<VerbConjugation> verbRows;
}
