import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../lib/ui_v35/widgets/glass_card.dart';
import '../../lib/ui_v35/theme/app_design_system.dart';
import '../../lib/ui_v35/widgets/home_visuals.dart';

void main() {
  testWidgets('premium hero uses verified toolkit and dynamic metrics', (
    tester,
  ) async {
    var continueCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.dark(),
        home: Scaffold(
          body: SingleChildScrollView(
            child: HomeProgressHero(
              levelLabel: 'A2',
              overallProgress: 0.65,
              streak: 12,
              masteredWords: 84,
              totalWords: 100,
              xp: 1280,
              onContinue: () => continueCount++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reference-home-hero')), findsOneWidget);
    expect(find.byType(GlassCard), findsWidgets);
    expect(find.byType(CircularPercentIndicator), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('1280'), findsOneWidget);
    expect(find.text('84'), findsOneWidget);
    expect(find.text('متابعة التعلّم الآن'), findsOneWidget);

    await tester.tap(find.text('متابعة التعلّم الآن'));
    await tester.pumpAndSettle();
    expect(continueCount, 1);
  });

  testWidgets('balanced action deck exposes four focused learning actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.dark(),
        home: Scaffold(
          body: ReferenceHomeActions(
            onDailyLessons: () {},
            onAiConversation: () {},
            onQuickPractice: () {},
            onAssessment: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('daily-lessons-card')), findsOneWidget);
    expect(find.byKey(const Key('ai-conversation-card')), findsOneWidget);
    expect(find.byKey(const Key('quick-practice-card')), findsOneWidget);
    expect(find.byKey(const Key('assessment-card')), findsOneWidget);
    expect(find.text('دروس اليوم'), findsOneWidget);
    expect(find.text('محادثة AI'), findsOneWidget);
    expect(find.text('تدريب سريع'), findsOneWidget);
    expect(find.text('اختبار المستوى'), findsOneWidget);
    expect(find.text('تابع مسار التعلم'), findsOneWidget);
  });

  testWidgets('floating nav exposes five premium destinations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.dark(),
        home: Scaffold(
          bottomNavigationBar: ReferenceFloatingNavigationBar(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('main-navigation-bar')), findsOneWidget);
    expect(find.byType(GlassCard), findsOneWidget);

    for (final label in const [
      'الرئيسية',
      'الدروس',
      'محادثة',
      'التقدم',
      'المزيد',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
