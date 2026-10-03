import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_pets/pet_regulations_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_pets/pets_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_pets/pets_models.dart';
import 'package:deutsch_bilarabi/features/life_pets/pets_screen.dart';
import 'package:deutsch_bilarabi/features/life_pets/vet_clinic_sub_agent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PetsMasterOrchestrator', () {
    test('defaults to veterinary care and filters locally', () {
      final orchestrator = PetsMasterOrchestrator();

      expect(orchestrator.category, PetsCategory.veterinary);
      expect(
        orchestrator.visiblePhrases.any(
          (phrase) => phrase.id == 'vet-appointment',
        ),
        isTrue,
      );

      orchestrator.setQuery('Impfung');

      expect(orchestrator.visiblePhrases, hasLength(1));
      expect(orchestrator.visiblePhrases.single.id, 'vet-vaccinations');
    });

    test('category switching exposes regulation and adoption content', () {
      final orchestrator = PetsMasterOrchestrator();

      orchestrator.setCategory(PetsCategory.regulationsAdoption);

      expect(orchestrator.category, PetsCategory.regulationsAdoption);
      expect(
        orchestrator.visiblePhrases.map((phrase) => phrase.id),
        containsAll(<String>[
          'regulation-dog-tax',
          'regulation-leash',
          'shelter-visit',
          'shelter-adoption',
        ]),
      );
    });

    test('emergency bar provides immediate veterinary scripts', () {
      final orchestrator = PetsMasterOrchestrator();

      expect(
        orchestrator.emergencyScripts,
        contains('Wo ist der nächste tierärztliche Notdienst?'),
      );
      expect(orchestrator.emergencyScripts, hasLength(3));
    });
  });

  test('sub-agents cover veterinary, municipal, and shelter domains', () {
    const veterinary = VetClinicSubAgent();
    const regulations = PetRegulationsSubAgent();

    expect(
      veterinary.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'vet-appointment',
        'vet-symptoms',
        'vet-vaccinations',
        'vet-pet-passport',
      ]),
    );
    expect(
      regulations.phrases.map((phrase) => phrase.id),
      containsAll(<String>[
        'regulation-dog-tax',
        'regulation-leash',
        'shelter-visit',
        'shelter-adoption',
      ]),
    );
  });

  testWidgets(
    'hub uses glass cards, safe scrolling, explicit BiDi, and live controls',
    (tester) async {
      final orchestrator = PetsMasterOrchestrator();

      await tester.pumpWidget(
        MaterialApp(
          home: PetsMasterHub(orchestrator: orchestrator),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.byType(AppGlassCard), findsWidgets);
      expect(
        find.byKey(const ValueKey<String>('pets-emergency-bar')),
        findsOneWidget,
      );

      final directions = tester
          .widgetList<Directionality>(find.byType(Directionality))
          .map((widget) => widget.textDirection)
          .toSet();
      expect(directions, contains(TextDirection.ltr));
      expect(directions, contains(TextDirection.rtl));

      await tester.tap(
        find.byKey(
          const ValueKey<String>('pets-category-regulationsAdoption'),
        ),
      );
      await tester.pump();

      expect(orchestrator.category, PetsCategory.regulationsAdoption);
      expect(
        find.text('Wo und wie melde ich meinen Hund für die Hundesteuer an?'),
        findsOneWidget,
      );
    },
  );
}
