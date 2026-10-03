import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_career/career_content.dart';
import 'package:deutsch_bilarabi/features/life_career/career_models.dart';
import 'package:deutsch_bilarabi/features/life_career/career_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_career/career_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CareerMasterOrchestrator', () {
    test('moves through application, interview and follow-up stages', () {
      final orchestrator = CareerMasterOrchestrator();

      expect(orchestrator.stage, CareerStage.application);
      expect(
        orchestrator.visibleItems.every(
          (item) => item.stage == CareerStage.application,
        ),
        isTrue,
      );

      orchestrator.setStage(CareerStage.interview);
      expect(orchestrator.stage, CareerStage.interview);
      expect(
        orchestrator.visibleItems.every(
          (item) => item.stage == CareerStage.interview,
        ),
        isTrue,
      );

      orchestrator.setStage(CareerStage.followUp);
      expect(orchestrator.stage, CareerStage.followUp);
      expect(
        orchestrator.visibleItems.every(
          (item) => item.stage == CareerStage.followUp,
        ),
        isTrue,
      );
    });

    test('searches German and Arabic career phrases case-insensitively', () {
      final orchestrator = CareerMasterOrchestrator();

      orchestrator.setQuery('LEBENSLAUF');
      expect(orchestrator.visibleItems, isNotEmpty);
      expect(
        orchestrator.visibleItems.any(
          (item) => item.german.toLowerCase().contains('lebenslauf'),
        ),
        isTrue,
      );

      orchestrator.setQuery('ساعات العمل');
      expect(
        orchestrator.visibleItems.any(
          (item) => item.arabic.contains('ساعات العمل'),
        ),
        isTrue,
      );
    });

    test('urgent prep keeps only short interview-ready phrases', () {
      final orchestrator = CareerMasterOrchestrator();

      expect(orchestrator.urgentPrep, isNotEmpty);
      expect(
        orchestrator.urgentPrep.every(
          (item) => item.stage == CareerStage.interview && item.urgent,
        ),
        isTrue,
      );
    });
  });

  test('sub-agents expose the required professional content', () {
    expect(
      ApplicationDocsSubAgent.items.any(
        (item) => item.topic == CareerTopic.cv &&
            item.german.contains('Lebenslauf'),
      ),
      isTrue,
    );
    expect(
      ApplicationDocsSubAgent.items.any(
        (item) => item.topic == CareerTopic.coverLetter &&
            item.german.contains('Sehr geehrte'),
      ),
      isTrue,
    );
    expect(
      ApplicationDocsSubAgent.items.any(
        (item) => item.topic == CareerTopic.openPosition,
      ),
      isTrue,
    );
    expect(
      JobInterviewSubAgent.items.any(
        (item) => item.topic == CareerTopic.selfIntroduction,
      ),
      isTrue,
    );
    expect(
      JobInterviewSubAgent.items.any(
        (item) => item.topic == CareerTopic.workingHours,
      ),
      isTrue,
    );
    expect(
      JobInterviewSubAgent.items.any(
        (item) => item.topic == CareerTopic.teamStructure,
      ),
      isTrue,
    );
  });

  testWidgets(
    'CareerHubScreen uses glass cards, scrolling, stage controls and explicit BiDi text',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CareerHubScreen()),
        ),
      );

      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);
      expect(find.byKey(const ValueKey('career-search-field')), findsOneWidget);
      expect(find.byKey(const ValueKey('career-urgent-prep')), findsOneWidget);
      expect(find.text('Bewerbung & Karriere'), findsOneWidget);
      expect(find.text('التقديم والمسار المهني'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('career-stage-interview')));
      await tester.pump();
      expect(find.text('Vorstellungsgespräch'), findsWidgets);

      await tester.enterText(
        find.byKey(const ValueKey('career-search-field')),
        'Arbeitszeiten',
      );
      await tester.pump();
      expect(find.textContaining('Arbeitszeiten'), findsWidgets);
    },
  );
}
