import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v35/theme/app_design_system.dart';
import '../../lib/ui_v35/widgets/home_visuals.dart';

void main() {
  testWidgets('reference hero renders exact A2 visual specification', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ReferenceHomeHero(
              greeting: 'Hallo Salim! 👋',
              levelLabel: 'A2',
              progress: 0.65,
              streak: 37,
              points: 1280,
              certificates: 24,
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('reference-home-hero')), findsOneWidget);
    expect(find.text('Hallo Salim! 👋'), findsOneWidget);
    expect(find.text('A2'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('37'), findsOneWidget);
    expect(find.text('1280'), findsOneWidget);
    expect(find.text('24'), findsOneWidget);
    expect(find.text('يوم متتالي'), findsOneWidget);
    expect(find.text('نقطة'), findsOneWidget);
    expect(find.text('شهادة صغيرة'), findsOneWidget);
  });

  testWidgets('reference action deck exposes four exact learning actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
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

    expect(find.byKey(const Key('daily-lessons-card')), findsOneWidget);
    expect(find.byKey(const Key('ai-conversation-card')), findsOneWidget);
    expect(find.byKey(const Key('quick-practice-card')), findsOneWidget);
    expect(find.byKey(const Key('assessment-card')), findsOneWidget);
    expect(find.text('دروس اليوم'), findsOneWidget);
    expect(find.text('محادثة بالذكاء الاصطناعي'), findsOneWidget);
    expect(find.text('التدريب السريع'), findsOneWidget);
    expect(find.text('15 دقيقة'), findsOneWidget);
    expect(find.text('الاختبارات'), findsOneWidget);
    expect(find.text('اختبر مستواك'), findsOneWidget);
  });

  testWidgets('floating nav exposes five reference destinations', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: Scaffold(
          bottomNavigationBar: ReferenceFloatingNavigationBar(
            selectedIndex: 0,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('main-navigation-bar')), findsOneWidget);
    for (final label in const ['الرئيسية', 'الدروس', 'محادثة', 'التقدم', 'المزيد']) {
      expect(find.text(label), findsOneWidget);
    }
  });
}
