import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/core/database/wikidata_sense_resolver.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  group('WikidataSenseResolver SQLite v2 Tests', () {
    late Database db;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await WikidataSenseResolver.createSchema(db);

      // بذر بيانات تجريبية: كلمة Schloss الألمانية ذات المعنيين المشتركين (Homonyms)
      // 1. مفهوم قصر (Palace) = Q16560
      // 2. مفهوم قفل (Lock) = Q80113

      // إدخال لكسيمة الألمانية لـ Schloss
      await db.insert('wikidata_lexemes', {
        'lexeme_id': 'L_DE_SCHLOSS',
        'language_code': 'de',
        'lemma': 'Schloss',
        'lexical_category': 'noun',
      });

      // إدخال معاني Schloss
      await db.insert('wikidata_senses', {
        'sense_id': 'S_DE_SCHLOSS_1',
        'lexeme_id': 'L_DE_SCHLOSS',
        'concept_qid': 'Q16560', // قصر
        'gloss_ar': 'قصر أو قلعة فخمة',
      });

      await db.insert('wikidata_senses', {
        'sense_id': 'S_DE_SCHLOSS_2',
        'lexeme_id': 'L_DE_SCHLOSS',
        'concept_qid': 'Q80113', // قفل
        'gloss_ar': 'قفل ومزلاج للباب',
      });

      // إدخال لكسيمات اللغة الهدف (العربية ar) المقابلة للمفاهيم
      await db.insert('wikidata_lexemes', {
        'lexeme_id': 'L_AR_QASR',
        'language_code': 'ar',
        'lemma': 'قصر',
        'lexical_category': 'noun',
      });

      await db.insert('wikidata_senses', {
        'sense_id': 'S_AR_QASR_1',
        'lexeme_id': 'L_AR_QASR',
        'concept_qid': 'Q16560',
        'gloss_ar': 'قصر',
      });

      await db.insert('wikidata_lexemes', {
        'lexeme_id': 'L_AR_QUFL',
        'language_code': 'ar',
        'lemma': 'قفل',
        'lexical_category': 'noun',
      });

      await db.insert('wikidata_senses', {
        'sense_id': 'S_AR_QUFL_1',
        'lexeme_id': 'L_AR_QUFL',
        'concept_qid': 'Q80113',
        'gloss_ar': 'قفل',
      });
    });

    tearDown(() async {
      await db.close();
    });

    test('1. استرجاع المعاني الخالية من اللبس لكلمة Schloss في العربية', () async {
      final glosses = await resolveExactSenses(db, 'Schloss', 'ar');

      expect(glosses, hasLength(2));
      expect(glosses, contains('قصر'));
      expect(glosses, contains('قفل'));
    });

    test('2. استرجاع التفاصيل الدلالية المربوطة بمعرف المفهوم concept_qid', () async {
      final details = await WikidataSenseResolver.resolveSenseDetails(db, 'Schloss', 'ar');

      expect(details, hasLength(2));
      final qids = details.map((d) => d['concept_qid']).toSet();
      expect(qids, containsAll(['Q16560', 'Q80113']));
    });

    test('3. إرجاع قائمة فارغة عند الاستعلام عن كلمة غير موجودة', () async {
      final nonExistent = await resolveExactSenses(db, 'UnbekanntesWort', 'ar');
      expect(nonExistent, isEmpty);
    });
  });
}
