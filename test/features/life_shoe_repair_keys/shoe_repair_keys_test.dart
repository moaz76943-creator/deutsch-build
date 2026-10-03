import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_shoe_repair_keys/key_service_agent.dart';
import 'package:deutsch_bilarabi/features/life_shoe_repair_keys/quick_service_master_hub.dart';
import 'package:deutsch_bilarabi/features/life_shoe_repair_keys/shoe_repair_agent.dart';
import 'package:deutsch_bilarabi/features/life_shoe_repair_keys/shoe_repair_keys_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

QuickServiceMasterHub _hub() => QuickServiceMasterHub(
      entries: <QuickServicePhrase>[
        ...ShoeRepairAgent.entries,
        ...KeyServiceAgent.entries,
      ],
    );

void main() {
  group('QuickServiceMasterHub', () {
    test('filters bilingual shoe and key content', () {
      final hub = _hub();

      expect(hub.visibleEntries.length, 10);
      hub.setQuery('Sohle');
      expect(
        hub.visibleEntries.single.id,
        'shoe-sole',
      );

      hub.setQuery('مفتاح');
      expect(
        hub.visibleEntries.every(
          (entry) => entry.category == QuickServiceCategory.keyService,
        ),
        isTrue,
      );
    });

    test('category toggle isolates shoe repair', () {
      final hub = _hub();
      hub.toggleCategory(QuickServiceCategory.keyService);

      expect(
        hub.visibleEntries.every(
          (entry) => entry.category == QuickServiceCategory.shoeRepair,
        ),
        isTrue,
      );
    });

    test('urgent mode exposes safe price-before-arrival language', () {
      final hub = _hub();
      hub.setUrgency(QuickServiceUrgency.urgentLockout);

      expect(hub.urgencyPromptDe, contains('Gesamtpreis'));
      expect(hub.urgencyPromptDe, contains('Anfahrt'));
      expect(hub.urgencyPromptAr, contains('السعر الإجمالي'));
    });
  });

  test('branch agents cover shoe repair and legitimate key service', () {
    final shoe = ShoeRepairAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');
    final keys = KeyServiceAgent.entries
        .map((entry) => '${entry.topicDe} ${entry.german}')
        .join(' ');

    expect(shoe, contains('Absatz'));
    expect(shoe, contains('Sohle'));
    expect(shoe, contains('Reißverschluss'));
    expect(keys, contains('Schlüssel nachmachen'));
    expect(keys, contains('Sicherungskarte'));
    expect(keys, contains('Berechtigung'));
    expect(keys, contains('Gesamtpreis'));
  });

  testWidgets('quick services screen is scroll safe and searchable',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ShoeRepairKeysMasterScreen()),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.text('Schuhreparatur & Schlüsselservice'), findsOneWidget);

    final search = find.byKey(const ValueKey<String>('quick-services-search'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'Sicherungskarte');
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('quick-entry-key-security-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('quick-entry-shoe-heel')),
      findsNothing,
    );
  });
}
