import 'package:test/test.dart';
import 'package:deutsch_build/src/core/gamification/achievement_card_renderer.dart';

void main() {
  group('AchievementCardRenderer Tests', () {
    const renderer = AchievementCardRenderer();

    final testPayload = AchievementBadgePayload(
      learnerHandle: 'polyglot_pioneer',
      targetLanguage: 'de',
      cefrLevel: 'B2',
      streakDays: 45,
      masteredWordsCount: 1850,
      retentionRate: 0.942,
      achievementTitle: 'B2 Fluency Milestone Master',
    );

    test('Renders valid SVG document with balanced root tag', () {
      final svg = renderer.renderSvgCard(testPayload);

      expect(svg.startsWith('<svg'), isTrue);
      expect(svg.endsWith('</svg>'), isTrue);
      expect(svg, contains('viewBox="0 0 1200 630"'));
    });

    test('Injects all learner stats and formatted percentage into vector tree', () {
      final svg = renderer.renderSvgCard(testPayload);

      expect(svg, contains('B2 Fluency Milestone Master'));
      expect(svg, contains('@polyglot_pioneer'));
      expect(svg, contains('45🔥'));
      expect(svg, contains('1850'));
      expect(svg, contains('94.2%'));
      expect(svg, contains('DE'));
    });

    test('Escapes XML characters correctly to prevent malformed SVG', () {
      const maliciousPayload = AchievementBadgePayload(
        learnerHandle: 'test<script>&"hack"',
        targetLanguage: 'fr',
        cefrLevel: 'A1',
        streakDays: 5,
        masteredWordsCount: 100,
        retentionRate: 0.85,
        achievementTitle: 'Tom & Jerry > Cat',
      );

      final svg = renderer.renderSvgCard(maliciousPayload);
      expect(svg, contains('&amp;'));
      expect(svg, contains('&lt;script&gt;'));
      expect(svg, isNot(contains('<script>')));
    });
  });
}
