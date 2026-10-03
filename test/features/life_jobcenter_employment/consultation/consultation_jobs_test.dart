import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/consultation/consultation_jobs_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/consultation/consultation_models.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/consultation/consultation_phrase_bank.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/consultation/consultation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phrase bank covers adviser, skills, course funding, applications, and travel costs', () {
    const bank = ConsultationPhraseBank();
    final topics = bank.phrases.map((phrase) => phrase.topic).toSet();

    expect(
      topics,
      containsAll(<ConsultationTopic>{
        ConsultationTopic.adviserMeeting,
        ConsultationTopic.skillsProfile,
        ConsultationTopic.courseFunding,
        ConsultationTopic.applications,
        ConsultationTopic.travelCosts,
      }),
    );

    final corpus = bank.phrases.map((phrase) => phrase.german).join(' ');
    expect(corpus, contains('Sachbearbeiter'));
    expect(corpus, contains('Integrationskurs'));
    expect(corpus, contains('Sprachkurs'));
    expect(corpus, contains('Bewerbungen'));
    expect(corpus, contains('Fahrtkosten'));
  });

  test('course funding language asks for eligibility instead of promising approval', () {
    const bank = ConsultationPhraseBank();
    final funding = bank.phrases.where(
      (phrase) => phrase.topic == ConsultationTopic.courseFunding,
    );

    expect(funding, isNotEmpty);
    expect(
      funding.every(
        (phrase) =>
            phrase.german.contains('kann') ||
            phrase.german.contains('möglich') ||
            phrase.german.contains('Voraussetzungen'),
      ),
      isTrue,
    );
  });

  group('ConsultationJobsOrchestrator', () {
    test('filters by active topic and German or Arabic search', () {
      final orchestrator = ConsultationJobsOrchestrator()
        ..setTopic(ConsultationTopic.skillsProfile)
        ..setQuery('خبرة');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.topic == ConsultationTopic.skillsProfile,
        ),
        isTrue,
      );

      orchestrator
        ..setTopic(ConsultationTopic.travelCosts)
        ..setQuery('Fahrtkosten');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.topic == ConsultationTopic.travelCosts,
        ),
        isTrue,
      );
    });

    test('topic switch clears stale query', () {
      final orchestrator = ConsultationJobsOrchestrator()
        ..setQuery('Sachbearbeiter');

      orchestrator.setTopic(ConsultationTopic.applications);

      expect(orchestrator.query, isEmpty);
    });
  });

  testWidgets(
    'consultation screen uses glass cards, safe scrolling, and explicit BiDi',
    (tester) async {
      final orchestrator = ConsultationJobsOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: ConsultationJobsScreen(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.rtl));
      expect(directions, contains(TextDirection.ltr));

      expect(
        find.text('Beratung, Jobsuche & Förderung'),
        findsOneWidget,
      );
      expect(find.textContaining('Sachbearbeiter'), findsWidgets);
    },
  );
}
