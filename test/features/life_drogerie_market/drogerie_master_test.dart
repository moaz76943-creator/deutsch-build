import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/drogerie_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/drogerie_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/drogerie_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orchestrator = DrogerieMasterOrchestrator();

  test('master covers cleaning personal care and loyalty', () {
    expect(orchestrator.categories, DrogerieCategory.values);
    expect(orchestrator.itemsFor(DrogerieCategory.householdCleaning), isNotEmpty);
    expect(orchestrator.itemsFor(DrogerieCategory.personalCare), isNotEmpty);
    expect(orchestrator.itemsFor(DrogerieCategory.loyalty), isNotEmpty);
  });

  test('bilingual search finds store language', () {
    expect(orchestrator.search('Waschmittel'), isNotEmpty);
    expect(orchestrator.search('نقاط'), isNotEmpty);
  });

  testWidgets('master hub uses design system and explicit BiDi', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DrogerieMasterHub(orchestrator: DrogerieMasterOrchestrator()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Drogeriemarkt'), findsOneWidget);
    expect(find.textContaining('dm / ROSSMANN'), findsOneWidget);
  });
}
