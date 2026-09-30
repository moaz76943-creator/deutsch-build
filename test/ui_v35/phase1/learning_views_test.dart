import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:deutsch_bilarabi/ui_v35/phase1/learning_view_models.dart';
import 'package:deutsch_bilarabi/ui_v35/phase1/learning_views.dart';

void main() {
  testWidgets('Today Home renders mock daily progress', (tester) async {
    const model = TodayHomeViewModel(
      title: 'اليوم',
      dueCount: 3,
      dailyGoal: 10,
      completedToday: 2,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: TodayHomeView(model: model)),
        ),
      ),
    );

    expect(find.byKey(const Key('phase1-today-home')), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.textContaining('3'), findsWidgets);
  });

  testWidgets('Study Card keeps Arabic source RTL and German target LTR',
      (tester) async {
    const model = StudyCardViewModel(
      sourceText: 'أنا أتعلم الألمانية.',
      targetText: 'Ich lerne Deutsch.',
      prompt: 'ترجم الجملة',
      progress: 0.4,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StudyCardView(model: model)),
      ),
    );

    final source = tester.widget<Text>(
      find.byKey(const Key('phase1-study-source')),
    );
    final target = tester.widget<Text>(
      find.byKey(const Key('phase1-study-target')),
    );

    expect(source.data, model.sourceText);
    expect(source.textDirection, TextDirection.rtl);
    expect(target.data, model.targetText);
    expect(target.textDirection, TextDirection.ltr);
  });

  testWidgets('Review Queue renders mock items from neutral view models',
      (tester) async {
    const model = ReviewQueueViewModel(
      items: <ReviewQueueItemViewModel>[
        ReviewQueueItemViewModel(
          id: 'review-1',
          sourceText: 'مرحبا',
          targetText: 'Hallo',
          dueLabel: 'الآن',
        ),
        ReviewQueueItemViewModel(
          id: 'review-2',
          sourceText: 'شكراً',
          targetText: 'Danke',
          dueLabel: 'اليوم',
        ),
      ],
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ReviewQueueView(model: model)),
      ),
    );

    expect(find.byKey(const Key('phase1-review-queue')), findsOneWidget);
    expect(find.text('Hallo'), findsOneWidget);
    expect(find.text('Danke'), findsOneWidget);
  });
}
