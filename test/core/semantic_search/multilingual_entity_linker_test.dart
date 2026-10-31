import 'package:test/test.dart';
import '../../lib/src/core/semantic_search/multilingual_entity_linker.dart';

void main() {
  group('MultilingualEntityLinker Unit Tests (N048)', () {
    final linker = MultilingualEntityLinker();

    test('Identifies and links German landmark mention in passage', () {
      const sentence = 'Gestern haben wir das Brandenburger Tor in Berlin besucht.';
      final mentions = linker.linkEntities(sentence);

      expect(mentions.length, equals(1));
      expect(mentions.first.surfaceText, equals('Brandenburger Tor'));
      expect(mentions.first.linkedEntity.entityId, equals('ent_brandenburger_tor'));
      expect(mentions.first.linkedEntity.category, equals('landmark'));
    });

    test('Links Arabic localized entity aliases', () {
      const sentence = 'قرأنا قصيدة رائعة للشاعر غوته اليوم.';
      final mentions = linker.linkEntities(sentence);

      expect(mentions.length, equals(1));
      expect(mentions.first.surfaceText, equals('غوته'));
      expect(mentions.first.linkedEntity.entityId, equals('ent_goethe'));
    });

    test('Returns empty list when no recognized entities are present', () {
      final mentions = linker.linkEntities('Wir trinken heute frischen Kaffee.');
      expect(mentions, isEmpty);
    });
  });
}
