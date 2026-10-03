import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_hardware_store_diy/hardware_store_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_hardware_store_diy/hardware_store_master_orchestrator.dart';
import 'package:deutsch_bilarabi/features/life_hardware_store_diy/hardware_store_models.dart';
import 'package:deutsch_bilarabi/features/life_hardware_store_diy/hardware_store_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('master orchestrator combines tools/materials and cutting/rental agents', () {
    final orchestrator = HardwareStoreMasterOrchestrator();

    expect(orchestrator.section, HardwareStoreSection.toolsMaterials);
    expect(
      orchestrator.visiblePhrases.map((item) => item.id),
      contains('tools-screw-size'),
    );

    orchestrator.setSection(HardwareStoreSection.cuttingRental);

    expect(
      orchestrator.visiblePhrases.map((item) => item.id),
      containsAll(<String>[
        'services-cut-exact-size',
        'services-rental-deposit',
      ]),
    );
  });

  test('fast search is bilingual and stays inside selected section', () {
    final orchestrator = HardwareStoreMasterOrchestrator();

    orchestrator.setQuery('دهان');
    expect(orchestrator.visiblePhrases.single.id, 'materials-interior-paint');

    orchestrator
      ..clearSearch()
      ..setSection(HardwareStoreSection.cuttingRental)
      ..setQuery('Kaution');

    expect(orchestrator.visiblePhrases.single.id, 'services-rental-deposit');
  });

  test('shared catalog models cover tools, materials, cutting, and rental', () {
    final orchestrator = HardwareStoreMasterOrchestrator();
    final kinds = orchestrator.catalogItems.map((item) => item.kind).toSet();

    expect(kinds, containsAll(HardwareStoreItemKind.values));
    expect(
      orchestrator.catalogItems.any((item) => item.nameDe.contains('Bohrer')),
      isTrue,
    );
    expect(
      orchestrator.catalogItems.any((item) => item.nameDe.contains('Holzzuschnitt')),
      isTrue,
    );
  });

  test('module exposes core route and explicit dependency factory', () {
    const dependencies = HardwareStoreModuleDependencies();
    final routes = HardwareStoreModule.routes(dependencies: dependencies);

    expect(routes.containsKey(HardwareStoreModule.routeName), isTrue);
    expect(dependencies.createOrchestrator(), isA<HardwareStoreMasterOrchestrator>());
  });

  testWidgets('master hub uses glass cards, safe scrolling, and explicit BiDi', (
    tester,
  ) async {
    final orchestrator = HardwareStoreMasterOrchestrator();

    await tester.pumpWidget(
      MaterialApp(
        home: HardwareStoreMasterHub(orchestrator: orchestrator),
      ),
    );

    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);

    final directions = tester
        .widgetList<Directionality>(find.byType(Directionality))
        .map((widget) => widget.textDirection)
        .toSet();

    expect(directions, contains(TextDirection.ltr));
    expect(directions, contains(TextDirection.rtl));
    expect(find.textContaining('Baumarkt'), findsWidgets);
  });
}
