import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/applications/applications_models.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/applications/applications_notices_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/applications/applications_phrase_bank.dart';
import 'package:deutsch_bilarabi/features/life_jobcenter_employment/applications/applications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phrase bank covers Hauptantrag, housing costs, notice, objection, and delayed payment', () {
    const bank = ApplicationsPhraseBank();
    final topics = bank.phrases.map((phrase) => phrase.topic).toSet();

    expect(
      topics,
      containsAll(<ApplicationsTopic>{
        ApplicationsTopic.hauptantrag,
        ApplicationsTopic.housingCosts,
        ApplicationsTopic.approvalNotice,
        ApplicationsTopic.objection,
        ApplicationsTopic.delayedPayment,
      }),
    );

    final corpus = bank.phrases.map((phrase) => phrase.german).join(' ');
    expect(corpus, contains('Hauptantrag'));
    expect(corpus, contains('Kosten der Unterkunft'));
    expect(corpus, contains('Bewilligungsbescheid'));
    expect(corpus, contains('Widerspruch'));
    expect(corpus, contains('Zahlung'));
  });

  test('objection guidance tells newcomers to check the notice deadline', () {
    const bank = ApplicationsPhraseBank();
    final objection = bank.phrases.where(
      (phrase) => phrase.topic == ApplicationsTopic.objection,
    );

    expect(objection, isNotEmpty);
    expect(
      objection.any(
        (phrase) =>
            phrase.german.contains('Frist') &&
            phrase.german.contains('Bescheid'),
      ),
      isTrue,
    );
  });

  group('ApplicationsNoticesOrchestrator', () {
    test('filters by topic and German or Arabic query', () {
      final orchestrator = ApplicationsNoticesOrchestrator()
        ..setTopic(ApplicationsTopic.housingCosts)
        ..setQuery('السكن');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.topic == ApplicationsTopic.housingCosts,
        ),
        isTrue,
      );

      orchestrator
        ..setTopic(ApplicationsTopic.approvalNotice)
        ..setQuery('Bewilligungsbescheid');

      expect(orchestrator.visiblePhrases, isNotEmpty);
      expect(
        orchestrator.visiblePhrases.every(
          (phrase) => phrase.topic == ApplicationsTopic.approvalNotice,
        ),
        isTrue,
      );
    });

    test('topic switch clears stale search', () {
      final orchestrator = ApplicationsNoticesOrchestrator()
        ..setQuery('Hauptantrag');

      orchestrator.setTopic(ApplicationsTopic.delayedPayment);

      expect(orchestrator.query, isEmpty);
    });
  });

  testWidgets(
    'applications screen uses glass cards, safe scrolling, and explicit BiDi',
    (tester) async {
      final orchestrator = ApplicationsNoticesOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: ApplicationsNoticesScreen(orchestrator: orchestrator),
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
        find.text('Anträge, Bescheide & Widerspruch'),
        findsOneWidget,
      );
      expect(find.textContaining('Hauptantrag'), findsWidgets);
    },
  );
}
