import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/optician_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/optician_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/optician_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orchestrator = OpticianMasterOrchestrator();

  test('master covers exam measurements and glasses ordering', () {
    expect(orchestrator.categories, OpticianCategory.values);
    expect(orchestrator.itemsFor(OpticianCategory.visionExam), isNotEmpty);
    expect(orchestrator.itemsFor(OpticianCategory.lensMeasurements), isNotEmpty);
    expect(orchestrator.itemsFor(OpticianCategory.glassesOrder), isNotEmpty);
  });

  test('search works in German and Arabic', () {
    expect(orchestrator.search('Sehtest'), isNotEmpty);
    expect(orchestrator.search('عدسات'), isNotEmpty);
  });

  testWidgets('master hub uses glass UI, SafeArea and BiDi', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: OpticianMasterHub(orchestrator: OpticianMasterOrchestrator()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Optiker & Brille'), findsOneWidget);
    expect(find.textContaining('تدريب لغوي'), findsOneWidget);
  });
}
