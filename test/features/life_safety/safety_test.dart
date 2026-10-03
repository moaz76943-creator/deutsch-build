import 'package:deutsch_bilarabi/design_system/app_glass_card.dart';
import 'package:deutsch_bilarabi/features/life_safety/application/official_reporting_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_safety/application/roadside_assistance_sub_agent.dart';
import 'package:deutsch_bilarabi/features/life_safety/application/safety_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_safety/domain/safety_models.dart';
import 'package:deutsch_bilarabi/features/life_safety/presentation/safety_master_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const roadside = RoadsideAssistanceSubAgent();
  const reporting = OfficialReportingSubAgent();
  const orchestrator = SafetyMasterOrchestrator(
    roadsideAssistance: roadside,
    officialReporting: reporting,
  );

  test('roadside agent covers breakdown, tire, towing and km markers', () {
    expect(
      roadside.items.map((item) => item.topic),
      containsAll(<SafetyTopic>{
        SafetyTopic.breakdown,
        SafetyTopic.flatTire,
        SafetyTopic.towing,
        SafetyTopic.highwayLocation,
      }),
    );
    expect(
      roadside.items.any((item) => item.german.contains('ADAC')),
      isTrue,
    );
    expect(
      roadside.items.any((item) => item.german.contains('Kilometer')),
      isTrue,
    );
  });

  test('official reporting covers Fundbüro, bike theft and insurance claims', () {
    expect(
      reporting.items.map((item) => item.topic),
      containsAll(<SafetyTopic>{
        SafetyTopic.lostItem,
        SafetyTopic.bikeTheft,
        SafetyTopic.insuranceClaim,
      }),
    );
    expect(
      reporting.items.any((item) => item.german.contains('Fundbüro')),
      isTrue,
    );
    expect(
      reporting.items.any((item) => item.german.contains('Fahrrad')),
      isTrue,
    );
  });

  test('orchestrator exposes 112 and 110 panic scripts first-class', () {
    final actions = orchestrator.panicActions;

    expect(actions.length, 2);
    expect(
      actions.map((action) => action.phoneNumber),
      containsAll(<String>['112', '110']),
    );
    expect(actions.every((action) => action.germanScript.isNotEmpty), isTrue);
    expect(actions.every((action) => action.arabicGuide.isNotEmpty), isTrue);
  });

  test('orchestrator switches categories without mixing sub-agents', () {
    final roadsideItems =
        orchestrator.itemsForCategory(SafetyCategory.roadsideAssistance);
    final reportItems =
        orchestrator.itemsForCategory(SafetyCategory.officialReporting);

    expect(roadsideItems, isNotEmpty);
    expect(reportItems, isNotEmpty);
    expect(
      roadsideItems.every(
        (item) => item.category == SafetyCategory.roadsideAssistance,
      ),
      isTrue,
    );
    expect(
      reportItems.every(
        (item) => item.category == SafetyCategory.officialReporting,
      ),
      isTrue,
    );
  });

  test('search matches German, Arabic and tags within an optional category', () {
    final german = orchestrator.search('Abschleppdienst');
    final arabic = orchestrator.search('تأمين');
    final scoped = orchestrator.search(
      'Polizei',
      category: SafetyCategory.officialReporting,
    );

    expect(german.any((item) => item.topic == SafetyTopic.towing), isTrue);
    expect(arabic.any((item) => item.topic == SafetyTopic.insuranceClaim), isTrue);
    expect(scoped, isNotEmpty);
    expect(
      scoped.every(
        (item) => item.category == SafetyCategory.officialReporting,
      ),
      isTrue,
    );
  });

  testWidgets('screen uses glass UI, SafeArea, scroll view and explicit BiDi', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SafetyMasterScreen(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(Directionality), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Pannenhilfe & Notfall'), findsOneWidget);
    expect(find.text('112'), findsOneWidget);
    expect(find.text('110'), findsOneWidget);
  });
}
