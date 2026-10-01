import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../lib/models/grammar.dart';
import '../../../lib/ui_v35/pages/grammar_hub_page.dart';
import '../../../lib/ui_v35/pages/grammar_topic_detail_page.dart';

void main() {
  group('Grammar Hub UI', () {
    testWidgets('GrammarHubPage renders tabs and topics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GrammarHubPage()));

      expect(find.text('مركز القواعد'), findsOneWidget);
      expect(find.text('A1'), findsWidgets);
      expect(find.text('A2'), findsWidgets);
      expect(find.text('C2'), findsWidgets);

      // Wait for TabBarView to settle
      await tester.pumpAndSettle();

      // There should be at least one A1 topic rendered initially
      expect(find.text('Personalpronomen'), findsWidgets);
      expect(find.text('الضمائر الشخصية'), findsWidgets);
    });

    testWidgets('Tapping a topic navigates to details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GrammarHubPage()));

      await tester.pumpAndSettle();

      final topicCard = find.text('Personalpronomen').first;
      expect(topicCard, findsOneWidget);

      await tester.tap(topicCard);
      await tester.pumpAndSettle();

      expect(find.byType(GrammarTopicDetailPage), findsOneWidget);
      expect(find.text('الضمائر في حالة الرفع (Nominativ)'), findsOneWidget);
    });

    testWidgets('Mini check interaction works', (WidgetTester tester) async {
      const topic = GrammarTopic(
        id: 'test',
        level: 'A1',
        titleDe: 'Test',
        titleAr: 'Test Ar',
        summaryAr: 'Sum',
        miniChecks: [
          MiniCheckQuestion(
            id: 'q1',
            questionText: 'Test Question',
            options: ['A', 'B', 'C'],
            correctAnswerIndex: 1,
            explanationAr: 'Explanation Text',
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(home: GrammarTopicDetailPage(topic: topic)),
      );

      expect(find.text('Test Question'), findsOneWidget);
      expect(find.text('Explanation Text'), findsNothing);

      // Tap wrong answer
      await tester.tap(find.text('A'));
      await tester.pump();

      // Explanation should now be visible
      expect(find.text('Explanation Text'), findsOneWidget);
    });
  });
}
