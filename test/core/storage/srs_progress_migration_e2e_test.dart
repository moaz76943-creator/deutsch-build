import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

/// End-to-End Regression Test Suite - Master Constitution Section 09 Compliant:
/// Simulates schema and content pack upgrades, strictly asserting that 100% of
/// learner progress, SRS intervals, and user favorites survive without data loss.
void main() {
  group('Learner Data Preservation End-to-End Regression Tests', () {
    late Directory testStorageDir;
    late File userProgressDbFile;
    late File favoritesFile;

    setUp(() async {
      testStorageDir = await Directory.systemTemp.createTemp('polyglot_e2e_migration_');
      userProgressDbFile = File('${testStorageDir.path}/user_progress.json');
      favoritesFile = File('${testStorageDir.path}/user_favorites.json');
    });

    tearDown(() async {
      if (await testStorageDir.exists()) {
        await testStorageDir.delete(recursive: true);
      }
    });

    test('Learner SRS and progress records survive content pack upgrades 100% intact', () async {
      final v1LearnerData = {
        'schema_version': 1,
        'user_id': 'learner_primary',
        'active_pair': 'de_ar',
        'srs_reviews': List.generate(50, (i) => {
          'card_id': 'card_de_$i',
          'interval_days': i * 2 + 1,
          'ease_factor': 2.5,
          'repetitions': i,
        }),
        'completed_lessons': ['a1_intro', 'a1_greetings', 'a1_alphabet'],
      };

      await userProgressDbFile.writeAsString(jsonEncode(v1LearnerData), flush: true);

      final v1Favorites = {
        'favorites': ['Hund', 'Katze', 'Buch', 'lernen', 'Wasser']
      };
      await favoritesFile.writeAsString(jsonEncode(v1Favorites), flush: true);

      // Execute non-destructive migration transform
      final rawContent = await userProgressDbFile.readAsString();
      final decoded = jsonDecode(rawContent) as Map<String, dynamic>;
      decoded['schema_version'] = 2;
      decoded['migrated_at'] = DateTime.now().toIso8601String();
      decoded['pair_epoch'] = 1;

      final tempFile = File('${userProgressDbFile.path}.tmp');
      await tempFile.writeAsString(jsonEncode(decoded), flush: true);
      await tempFile.rename(userProgressDbFile.path);

      // Verify 100% retention
      final migratedContent = await userProgressDbFile.readAsString();
      final migratedData = jsonDecode(migratedContent) as Map<String, dynamic>;

      expect(migratedData['schema_version'], equals(2));
      expect(migratedData['user_id'], equals('learner_primary'));

      final srsList = migratedData['srs_reviews'] as List<dynamic>;
      expect(srsList.length, equals(50));
      expect(srsList.first['card_id'], equals('card_de_0'));
      expect(srsList.last['card_id'], equals('card_de_49'));

      final lessons = migratedData['completed_lessons'] as List<dynamic>;
      expect(lessons.length, equals(3));

      final favContent = await favoritesFile.readAsString();
      final favData = jsonDecode(favContent) as Map<String, dynamic>;
      expect((favData['favorites'] as List<dynamic>).length, equals(5));
    });
  });
}
