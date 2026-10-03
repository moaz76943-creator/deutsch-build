import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_health/application/hausarzt_agent.dart';
import 'package:deutsch_bilarabi/features/life_health/application/health_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_health/application/pharmacy_agent.dart';
import 'package:deutsch_bilarabi/features/life_health/domain/health_models.dart';
import 'package:deutsch_bilarabi/features/life_health/presentation/health_master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const pharmacy = PharmacyAgent();
  const hausarzt = HausarztAgent();
  const orchestrator = HealthMasterOrchestrator(
    pharmacy: pharmacy,
    hausarzt: hausarzt,
  );

  test('pharmacy agent covers prescription, dosage and active ingredients', () {
    expect(
      pharmacy.items.map((item) => item.topic),
      containsAll(<HealthTopic>[
        HealthTopic.prescription,
        HealthTopic.dosage,
        HealthTopic.activeIngredient,
        HealthTopic.commonRemedy,
      ]),
    );
    expect(
      pharmacy.items.any((item) => item.german.contains('Rezept')),
      isTrue,
    );
    expect(
      pharmacy.items.any((item) => item.german.contains('Wirkstoff')),
      isTrue,
    );
  });

  test('Hausarzt agent covers appointments, symptoms and AU notes', () {
    expect(
      hausarzt.items.map((item) => item.topic),
      containsAll(<HealthTopic>[
        HealthTopic.appointment,
        HealthTopic.symptom,
        HealthTopic.sickLeaveNote,
      ]),
    );
    expect(
      hausarzt.items.any((item) => item.german.contains('Termin')),
      isTrue,
    );
    expect(
      hausarzt.items.any((item) => item.german.contains('Arbeitsunfähigkeit')),
      isTrue,
    );
  });

  test('orchestrator searches symptom language across both sub-agents', () {
    final results = orchestrator.searchSymptoms('Kopfschmerzen');

    expect(results, isNotEmpty);
    expect(
      results.any((item) => item.service == HealthService.pharmacy),
      isTrue,
    );
    expect(
      results.any((item) => item.service == HealthService.hausarzt),
      isTrue,
    );
  });

  test('orchestrator filters learning content by CEFR band', () {
    final b2 = orchestrator.filterByLevel(HealthLevel.b2);

    expect(b2, isNotEmpty);
    expect(b2.every((item) => item.level == HealthLevel.b2), isTrue);
  });

  test('emergency quick actions are explicit and separate from diagnosis', () {
    final actions = orchestrator.emergencyActions;

    expect(actions, isNotEmpty);
    expect(actions.any((action) => action.phoneNumber == '112'), isTrue);
    expect(
      actions.any((action) => action.german.contains('Notfall')),
      isTrue,
    );
    expect(
      actions.every((action) => action.isEmergency),
      isTrue,
    );
  });

  test('search can be constrained to a learning level', () {
    final results = orchestrator.searchSymptoms(
      'Schmerzen',
      level: HealthLevel.a1a2,
    );

    expect(results, isNotEmpty);
    expect(
      results.every((item) => item.level == HealthLevel.a1a2),
      isTrue,
    );
  });

  testWidgets('screen uses glass surfaces and explicit BiDi text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HealthMasterScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Apotheke & Hausarzt'), findsOneWidget);
  });
}
