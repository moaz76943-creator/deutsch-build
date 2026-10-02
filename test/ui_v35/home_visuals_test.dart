import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v35/theme/app_design_system.dart';
import '../../lib/ui_v35/widgets/home_visuals.dart';

void main() {
  testWidgets('home hero exposes real learner progress metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: const Scaffold(
          body: HomeProgressHero(
            levelLabel: 'A2',
            overallProgress: 0.65,
            streak: 37,
            masteredWords: 1280,
            totalWords: 14813,
            xp: 1280,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('home-progress-hero')), findsOneWidget);
    expect(find.byKey(const Key('home-level-badge')), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    expect(find.text('37'), findsOneWidget);
    expect(find.text('1280/14813'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
  });

  testWidgets('learning track renders four progress cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: const Scaffold(
          body: LearningTrackGrid(
            skillScores: <String, double>{
              'recall': 0.8,
              'listening': 0.6,
              'production': 0.4,
              'transfer': 0.2,
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('learning-track-grid')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNWidgets(4));
    expect(find.text('التعرّف'), findsOneWidget);
    expect(find.text('الاستماع'), findsOneWidget);
    expect(find.text('الإنتاج'), findsOneWidget);
    expect(find.text('النقل'), findsOneWidget);
  });
}
