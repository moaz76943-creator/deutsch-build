import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/dentist_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/dentist_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_dentist_clinic/dentist_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const orchestrator = DentistMasterOrchestrator();

  test('master covers checkup cleaning and appointments', () {
    expect(orchestrator.categories, DentistCategory.values);
    expect(orchestrator.itemsFor(DentistCategory.checkup), isNotEmpty);
    expect(orchestrator.itemsFor(DentistCategory.cleaning), isNotEmpty);
    expect(orchestrator.itemsFor(DentistCategory.appointment), isNotEmpty);
  });

  test('search is bilingual', () {
    expect(orchestrator.search('Kontrolle'), isNotEmpty);
    expect(orchestrator.search('تنظيف'), isNotEmpty);
  });

  testWidgets('master hub is safe, scrollable and glass based', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DentistMasterHub(orchestrator: DentistMasterOrchestrator()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Zahnarztpraxis'), findsOneWidget);
    expect(find.textContaining('keine zahnärztliche Beratung'), findsOneWidget);
  });
}
