import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_build/src/features/exercises/presentation/widgets/session_progress_hud.dart';

void main() {
  group('SessionProgressHUD Widget Tests', () {
    test('SessionHudState calculates progress ratio and mastery tier correctly', () {
      const state = SessionHudState(
        currentIndex: 4,
        totalCount: 10,
        correctCount: 4,
        streak: 3,
        bktMasteryProbability: 0.88,
      );

      expect(state.progressRatio, equals(0.5));
      expect(state.masteryLabel, contains('متقن'));
      expect(state.masteryColor, equals(Colors.green));
    });

    testWidgets('renders progress counter and calls onExitRequested', (tester) async {
      bool exitCalled = false;
      const state = SessionHudState(
        currentIndex: 2,
        totalCount: 5,
        streak: 2,
        bktMasteryProbability: 0.65,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SessionProgressHUD(
              state: state,
              onExitRequested: () {
                exitCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('3/5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // streak
      expect(find.textContaining('متمكن'), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(exitCalled, isTrue);
    });
  });
}
