import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_bureaucracy/application/bureaucracy_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_bureaucracy/application/city_registration_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_bureaucracy/application/immigration_office_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_bureaucracy/domain/bureaucracy_models.dart';
import 'package:deutsch_bilarabi/features/life_bureaucracy/presentation/life_bureaucracy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CityRegistrationSubAgent', () {
    test('covers Anmeldung, housing confirmation, and certificate requests', () {
      const agent = CityRegistrationSubAgent();

      final intents = agent.guides.map((guide) => guide.intent).toSet();
      expect(
        intents,
        containsAll(<BureaucracyIntent>{
          BureaucracyIntent.registrationAppointment,
          BureaucracyIntent.housingConfirmation,
          BureaucracyIntent.certificateRequest,
        }),
      );

      final corpus = agent.guides
          .expand((guide) => <String>[
                guide.titleDe,
                guide.phraseDe,
                ...guide.documents.map((document) => document.nameDe),
              ])
          .join(' ');
      expect(corpus, contains('Wohnungsgeberbestätigung'));
      expect(corpus, contains('Meldebescheinigung'));
    });

    test('every city guide uses the formal Sie register', () {
      const agent = CityRegistrationSubAgent();

      expect(
        agent.guides.every(
          (guide) => guide.register == BureaucracyRegister.formalSie,
        ),
        isTrue,
      );
    });
  });

  group('ImmigrationOfficeSubAgent', () {
    test('covers residence extension, biometric photo, and status inquiry', () {
      const agent = ImmigrationOfficeSubAgent();

      final intents = agent.guides.map((guide) => guide.intent).toSet();
      expect(
        intents,
        containsAll(<BureaucracyIntent>{
          BureaucracyIntent.residencePermitExtension,
          BureaucracyIntent.biometricPhoto,
          BureaucracyIntent.statusInquiry,
        }),
      );

      final corpus = agent.guides
          .expand((guide) => <String>[
                guide.titleDe,
                guide.phraseDe,
                ...guide.documents.map((document) => document.nameDe),
              ])
          .join(' ');
      expect(corpus, contains('Aufenthaltstitel'));
      expect(corpus.toLowerCase(), contains('biometr'));
    });
  });

  group('BureaucracyMasterOrchestrator', () {
    test('switches categories and searches German and Arabic text', () {
      final orchestrator = BureaucracyMasterOrchestrator();

      expect(
        orchestrator.activeCategory,
        BureaucracyCategory.cityRegistration,
      );

      orchestrator.search('Wohnungsgeberbestätigung');
      expect(
        orchestrator.visibleGuides.single.intent,
        BureaucracyIntent.housingConfirmation,
      );

      orchestrator.setCategory(BureaucracyCategory.immigrationOffice);
      orchestrator.search('الإقامة');
      expect(
        orchestrator.visibleGuides.any(
          (guide) =>
              guide.intent == BureaucracyIntent.residencePermitExtension,
        ),
        isTrue,
      );
    });

    test('panic checklist reports missing documents and readiness', () {
      final orchestrator = BureaucracyMasterOrchestrator();
      final guide = orchestrator.activeGuide;
      expect(guide, isNotNull);

      final first = guide!.documents.first;
      expect(orchestrator.panicChecklist.missingDocuments, isNotEmpty);

      for (final document in guide.documents) {
        orchestrator.setDocumentReady(document.id, true);
      }

      expect(orchestrator.panicChecklist.isReady, isTrue);
      expect(orchestrator.panicChecklist.missingDocuments, isEmpty);

      orchestrator.setDocumentReady(first.id, false);
      expect(orchestrator.panicChecklist.isReady, isFalse);
      expect(orchestrator.panicChecklist.missingDocuments, contains(first));
    });

    test('selects only guides belonging to the active category', () {
      final orchestrator = BureaucracyMasterOrchestrator();
      final immigrationId =
          const ImmigrationOfficeSubAgent().guides.first.id;

      expect(
        () => orchestrator.selectGuide(immigrationId),
        throwsArgumentError,
      );

      orchestrator.setCategory(BureaucracyCategory.immigrationOffice);
      orchestrator.selectGuide(immigrationId);
      expect(orchestrator.activeGuide?.id, immigrationId);
    });
  });

  testWidgets(
      'screen uses glass cards, SafeArea, scrolling, and explicit BiDi text',
      (tester) async {
    final orchestrator = BureaucracyMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: LifeBureaucracyScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final german = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'Bürgeramt & Ausländerbehörde',
      ),
    );
    expect(german.languageCode, 'de');

    final arabic = tester.widget<AppDirectionalText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is AppDirectionalText &&
            widget.text == 'المعاملات الرسمية والدوائر الحكومية',
      ),
    );
    expect(arabic.languageCode, 'ar');
  });
}
