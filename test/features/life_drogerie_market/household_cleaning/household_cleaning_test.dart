import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/household_cleaning/household_cleaning_agent.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/household_cleaning/household_cleaning_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = HouseholdCleaningAgent();

  test('covers detergent cleaner descaler and dosage language', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Waschmittel'));
    expect(corpus, contains('Buntwaschmittel'));
    expect(corpus, contains('Feinwaschmittel'));
    expect(corpus, contains('Allzweckreiniger'));
    expect(corpus, contains('Entkalker'));
    expect(corpus, contains('Dosierung'));
  });

  test('search works in German and Arabic', () {
    expect(agent.search('Entkalker'), isNotEmpty);
    expect(agent.search('منظف'), isNotEmpty);
  });

  testWidgets('household screen uses glass UI and scroll safety', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HouseholdCleaningScreen(agent: HouseholdCleaningAgent()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Haushalt & Reinigung'), findsOneWidget);
  });
}
