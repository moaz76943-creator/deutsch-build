import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_culture/application/adult_education_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_culture/application/culture_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_culture/application/public_library_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_culture/domain/culture_models.dart';
import 'package:deutsch_bilarabi/features/life_culture/presentation/life_culture_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PublicLibrarySubAgent', () {
    test('covers card, loans, Onleihe, and study-room etiquette', () {
      const agent = PublicLibrarySubAgent();

      final intents = agent.guides.map((guide) => guide.intent).toSet();
      expect(
        intents,
        containsAll(<CultureIntent>{
          CultureIntent.libraryCardIssuance,
          CultureIntent.libraryCardRenewal,
          CultureIntent.loanExtension,
          CultureIntent.digitalMediaOnleihe,
          CultureIntent.studyRoomEtiquette,
        }),
      );

      final corpus = agent.guides
          .expand((guide) => <String>[
                guide.titleDe,
                guide.phraseDe,
                guide.noteAr,
              ])
          .join(' ');

      expect(corpus, contains('Bibliotheksausweis'));
      expect(corpus, contains('Leihfrist'));
      expect(corpus, contains('Onleihe'));
      expect(corpus, contains('Lernraum'));
    });

    test('exposes a dedicated quick card-renewal guide', () {
      const agent = PublicLibrarySubAgent();

      expect(
        agent.quickCardRenewalGuide.intent,
        CultureIntent.libraryCardRenewal,
      );
      expect(
        agent.quickCardRenewalGuide.phraseDe,
        contains('Bibliotheksausweis'),
      );
    });
  });

  group('AdultEducationSubAgent', () {
    test('covers VHS registration, schedule, materials, and attendance certificate', () {
      const agent = AdultEducationSubAgent();

      final intents = agent.guides.map((guide) => guide.intent).toSet();
      expect(
        intents,
        containsAll(<CultureIntent>{
          CultureIntent.vhsCourseRegistration,
          CultureIntent.scheduleInquiry,
          CultureIntent.materialsInquiry,
          CultureIntent.attendanceCertificate,
        }),
      );

      final corpus = agent.guides
          .expand((guide) => <String>[guide.titleDe, guide.phraseDe])
          .join(' ');

      expect(corpus, contains('Volkshochschule'));
      expect(corpus, contains('Unterrichtsmaterialien'));
      expect(corpus, contains('Teilnahmebescheinigung'));
    });
  });

  group('CultureMasterOrchestrator', () {
    test('switches domains and searches German and Arabic content', () {
      final orchestrator = CultureMasterOrchestrator();

      expect(orchestrator.activeDomain, CultureDomain.publicLibrary);

      orchestrator.search('Onleihe');
      expect(
        orchestrator.visibleGuides.single.intent,
        CultureIntent.digitalMediaOnleihe,
      );

      orchestrator.setDomain(CultureDomain.adultEducation);
      orchestrator.search('شهادة الحضور');
      expect(
        orchestrator.visibleGuides.single.intent,
        CultureIntent.attendanceCertificate,
      );
    });

    test('quick renewal opens the library renewal guide from any domain', () {
      final orchestrator = CultureMasterOrchestrator()
        ..setDomain(CultureDomain.adultEducation)
        ..search('Kurs');

      orchestrator.openQuickCardRenewal();

      expect(orchestrator.activeDomain, CultureDomain.publicLibrary);
      expect(orchestrator.query, isEmpty);
      expect(
        orchestrator.activeGuide?.intent,
        CultureIntent.libraryCardRenewal,
      );
    });

    test('rejects selecting a guide outside the active domain', () {
      final orchestrator = CultureMasterOrchestrator();
      final vhsId = const AdultEducationSubAgent().guides.first.id;

      expect(() => orchestrator.selectGuide(vhsId), throwsArgumentError);
    });
  });

  testWidgets(
      'screen uses glass cards, SafeArea, scrolling, quick renewal, and explicit BiDi text',
      (tester) async {
    final orchestrator = CultureMasterOrchestrator()
      ..setDomain(CultureDomain.adultEducation);

    await tester.pumpWidget(
      MaterialApp(
        home: LifeCultureScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'Stadtbibliothek & Volkshochschule',
      ),
    );
    expect(german.languageCode, 'de');

    final arabic = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'المكتبة العامة والتعليم المستمر للكبار',
      ),
    );
    expect(arabic.languageCode, 'ar');

    await tester.tap(find.byKey(const ValueKey('culture-quick-renewal')));
    await tester.pump();

    expect(orchestrator.activeDomain, CultureDomain.publicLibrary);
    expect(
      orchestrator.activeGuide?.intent,
      CultureIntent.libraryCardRenewal,
    );
  });
}
