import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/core/gamification/widgets/cognitive_skill_tree_widget.dart';

void main() {
  group('CognitiveSkillTreeWidget Tests', () {
    testWidgets('Renders skill nodes with respective mastery states and handles taps', (tester) async {
      CognitiveSkillNode? tappedNode;
      final nodes = [
        const CognitiveSkillNode(id: 'node_01', title: 'أساسيات النطق', iconCode: 'mic', bktMastery: 0.95), // Mastered
        const CognitiveSkillNode(id: 'node_02', title: 'الأفعال الشاذة', iconCode: 'book', bktMastery: 0.45), // In Progress
        const CognitiveSkillNode(id: 'node_03', title: 'حالات الداتيف', iconCode: 'lock', bktMastery: 0.05), // Locked
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CognitiveSkillTreeWidget(
              nodes: nodes,
              onNodeSelected: (n) => tappedNode = n,
            ),
          ),
        ),
      );

      expect(find.text('أساسيات النطق'), findsOneWidget);
      expect(find.text('الأفعال الشاذة'), findsOneWidget);
      expect(find.text('حالات الداتيف'), findsOneWidget);

      // Tap active node
      await tester.tap(find.text('الأفعال الشاذة'));
      expect(tappedNode?.id, equals('node_02'));
    });
  });
}
