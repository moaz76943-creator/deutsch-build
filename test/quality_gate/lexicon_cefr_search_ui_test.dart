import 'package:deutsch_bilarabi/features/lexicon_search/application/lexicon_search_notifier.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/data/offline_lexicon_search_repository.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_models.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/domain/lexicon_repositories.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/presentation/quick_search_modal.dart';
import 'package:deutsch_bilarabi/features/lexicon_search/presentation/widgets/lexicon_result_card.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_contract.dart';
import 'package:deutsch_bilarabi/features/srs/corpus_sqlite_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search maps real CEFR from indexed corpus and filters by level', () async {
    final fixture = await _openCorpus();
    addTearDown(fixture.database.close);

    final repository = OfflineLexiconSearchRepository(
      corpusRepository: fixture.repository,
    );

    final a1 = await repository.search(
      const LexiconSearchQuery(
        filters: LexiconSearchFilters(cefrLevels: <String>{'A1'}),
      ),
    );
    expect(a1.map((item) => item.wordId).toList(), <String>['a1.house']);
    expect(a1.single.cefrLevel, 'A1');

    final a2 = await repository.search(
      const LexiconSearchQuery(text: 'Zug'),
    );
    expect(a2.single.wordId, 'a2.train');
    expect(a2.single.cefrLevel, 'A2');

    final b2 = await repository.byId('b2.decision');
    expect(b2?.cefrLevel, 'B2');

    final unsupported = await repository.search(
      const LexiconSearchQuery(
        filters: LexiconSearchFilters(cefrLevels: <String>{'C1'}),
      ),
    );
    expect(unsupported, isEmpty);
  });

  test('unknown CEFR stays repository data and is not fabricated as a badge', () async {
    final fixture = await _openCorpus();
    addTearDown(fixture.database.close);

    final repository = OfflineLexiconSearchRepository(
      corpusRepository: fixture.repository,
    );
    final item = await repository.byId('unknown.misc');

    expect(item, isNotNull);
    expect(item!.cefrLevel, 'unknown');
    expect(item.hasCefrLevel, isFalse);
  });

  testWidgets('result card renders repository CEFR badge without fake fallback',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LexiconResultCard(
            item: const SearchResultItem(
              wordId: 'a1.house',
              germanWord: 'Haus',
              arabicMeaning: 'بيت',
              cefrLevel: 'A1',
              article: LexiconArticle.das,
            ),
            isBookmarked: false,
            onBookmarkToggle: _noop,
          ),
        ),
      ),
    );

    expect(find.text('A1'), findsOneWidget);
    expect(find.text('—'), findsNothing);
  });

  testWidgets('CEFR filter UI exposes only runtime-supported A1-B2 levels',
      (tester) async {
    final notifier = LexiconSearchNotifier(
      searchRepository: _EmptySearchRepository(),
      bookmarkRepository: _EmptyBookmarkRepository(),
      debounceDuration: Duration.zero,
    );
    addTearDown(notifier.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickSearchModal(notifier: notifier),
        ),
      ),
    );
    await tester.pump();

    for (final level in const <String>['A1', 'A2', 'B1', 'B2']) {
      expect(find.text(level), findsOneWidget);
    }
    expect(find.text('C1'), findsNothing);
    expect(find.text('C2'), findsNothing);
  });
}

void _noop() {}

final class _CorpusFixture {
  const _CorpusFixture({
    required this.database,
    required this.repository,
  });

  final Database database;
  final IndexedSrsCorpusRepository repository;
}

Future<_CorpusFixture> _openCorpus() async {
  sqfliteFfiInit();
  final database = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(singleInstance: false),
  );

  for (final statement in SrsCorpusContract.createSchemaStatements) {
    await database.execute(statement);
  }
  for (final statement in SrsCorpusContract.createIndexStatements) {
    await database.execute(statement);
  }

  const sha = 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc';
  final rows = <Map<String, Object?>>[
    <String, Object?>{
      'id': 'a1.house',
      'german': 'Haus',
      'arabic': 'بيت',
      'sentence': 'Das Haus ist groß.',
      'sentence_ar': 'البيت كبير.',
      'topic': 'home',
      'skill': 'vocabulary',
      'cefr': 'A1',
      'article': 'das',
      'plural': 'Häuser',
    },
    <String, Object?>{
      'id': 'a2.train',
      'german': 'Zug',
      'arabic': 'قطار',
      'sentence': 'Der Zug kommt.',
      'sentence_ar': 'القطار يصل.',
      'topic': 'travel',
      'skill': 'vocabulary',
      'cefr': 'A2',
      'article': 'der',
      'plural': 'Züge',
    },
    <String, Object?>{
      'id': 'b2.decision',
      'german': 'Entscheidung',
      'arabic': 'قرار',
      'sentence': 'Das ist eine Entscheidung.',
      'sentence_ar': 'هذا قرار.',
      'topic': 'daily',
      'skill': 'vocabulary',
      'cefr': 'B2',
      'article': 'die',
      'plural': 'Entscheidungen',
    },
    <String, Object?>{
      'id': 'unknown.misc',
      'german': 'Beispiel',
      'arabic': 'مثال',
      'sentence': '',
      'sentence_ar': '',
      'topic': 'general',
      'skill': 'vocabulary',
      'cefr': 'unknown',
      'article': 'das',
      'plural': 'Beispiele',
    },
  ];

  for (final row in rows) {
    await database.insert(SrsCorpusContract.contentTable, row);
  }

  final metadata = <String, String>{
    SrsCorpusContract.metadataSchemaVersionKey:
        SrsCorpusContract.schemaVersion.toString(),
    SrsCorpusContract.metadataStateKey: 'ready',
    SrsCorpusContract.metadataContentRowsKey: rows.length.toString(),
    SrsCorpusContract.metadataVerbRowsKey: '0',
    SrsCorpusContract.metadataSourceContentSha256Key: sha,
  };
  for (final entry in metadata.entries) {
    await database.insert(
      SrsCorpusContract.metadataTable,
      <String, Object?>{'key': entry.key, 'value': entry.value},
    );
  }

  final repository = await IndexedSrsCorpusRepository.open(
    database,
    expectedCardinality: SrsCorpusCardinality(
      contentRows: rows.length,
      verbRows: 0,
    ),
    sourceContentSha256: sha,
  );
  return _CorpusFixture(database: database, repository: repository);
}

final class _EmptySearchRepository implements LexiconSearchRepository {
  @override
  Future<SearchResultItem?> byId(String wordId) async => null;

  @override
  Future<List<SearchResultItem>> search(LexiconSearchQuery query) async =>
      const <SearchResultItem>[];
}

final class _EmptyBookmarkRepository implements BookmarkRepository {
  @override
  Future<List<UserBookmark>> loadBookmarks() async => const <UserBookmark>[];

  @override
  Future<Map<String, WordPersonalNote>> loadNotes() async =>
      const <String, WordPersonalNote>{};

  @override
  Future<void> removeBookmark(String wordId) async {}

  @override
  Future<void> removeNote(String wordId) async {}

  @override
  Future<void> saveBookmark(UserBookmark bookmark) async {}

  @override
  Future<void> saveNote(WordPersonalNote note) async {}
}
