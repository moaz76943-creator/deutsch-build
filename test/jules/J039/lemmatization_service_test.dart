import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/lemmatization_service.dart';
import 'package:deutsch_bilarabi/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LemmatizationService Tests', () {
    late LemmatizationService service;

    setUp(() async {
      service = LemmatizationService();
      // Ensure the DB is initialized and seeded before tests
      await DatabaseService.instance.contentDb;
    });

    test('resolveLemma returns exact match from lemma', () async {
      final results = await service.resolveLemma('Wasser', 'de');
      expect(results.length, 1);
      expect(results.first.lemma, 'Wasser');
      expect(results.first.languageCode, 'de');
    });

    test('resolveLemma resolves from plural', () async {
      final results = await service.resolveLemma('Bücher', 'de');
      expect(results.length, 1);
      expect(results.first.lemma, 'Buch');
    });

    test('resolveLemma returns empty for unknown word', () async {
      final results = await service.resolveLemma('UnknownWord', 'de');
      expect(results.isEmpty, true);
    });
  });
}
