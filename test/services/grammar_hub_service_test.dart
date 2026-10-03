import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:deutsch_bilarabi/services/grammar_hub_service.dart';

void main() {
  late GrammarHubService service;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    service = GrammarHubService(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
  });

  tearDown(() async {
    await service.close();
  });

  test('should initialize and seed data correctly', () async {
    final topics = await service.getTopicsByLevel('A1');
    expect(topics.isNotEmpty, isTrue);
    expect(topics.first.titleDe, equals('Nominativ'));

    final quizzes = await service.getQuizzesForTopic(topics.first.id);
    expect(quizzes.isNotEmpty, isTrue);
    expect(quizzes.first.question, contains('Welcher Artikel'));
  });

  test('should return correct topics by level', () async {
    final a1Topics = await service.getTopicsByLevel('A1');
    expect(a1Topics.length, greaterThanOrEqualTo(2));
    expect(a1Topics.first.level, equals('A1'));
    expect(a1Topics.first.id, equals('a1_nominativ'));

    final b2Topics = await service.getTopicsByLevel('B2');
    expect(b2Topics.length, equals(1));
    expect(b2Topics.first.level, equals('B2'));
  });

  test('should expose canonical rule details for the microscope', () async {
    final rules = await service.getRulesForTopic('a1_pronouns');
    expect(rules, isNotEmpty);
    expect(rules.first.topicId, equals('a1_pronouns'));
    expect(rules.first.table, isNotEmpty);
    expect(rules.first.examples, isNotEmpty);
  });

  test('should save topic mastery correctly', () async {
    final initialTopic = await service.getTopicDetail('a1_nominativ');
    expect(initialTopic?.isMastered, isFalse);

    await service.saveTopicMastery('a1_nominativ', true);

    final masteredTopic = await service.getTopicDetail('a1_nominativ');
    expect(masteredTopic?.isMastered, isTrue);
  });
}
