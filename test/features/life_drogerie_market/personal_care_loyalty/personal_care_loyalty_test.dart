import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/personal_care_loyalty/personal_care_loyalty_agent.dart';
import 'package:deutsch_bilarabi/features/life_drogerie_market/personal_care_loyalty/personal_care_loyalty_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = PersonalCareLoyaltyAgent();

  test('covers personal care plus dm and ROSSMANN loyalty language', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Shampoo'));
    expect(corpus, contains('Deodorant'));
    expect(corpus, contains('Zahnpasta'));
    expect(corpus, contains('PAYBACK'));
    expect(corpus, contains('ROSSMANN-App'));
    expect(corpus, contains('Coupon'));
    expect(corpus, contains('Treueaktion'));
  });

  test('brand-aware search remains deterministic', () {
    expect(agent.search('PAYBACK').every((e) => e.brand == DrogerieBrand.dm), isTrue);
    expect(
      agent.search('Coupon', brand: DrogerieBrand.rossmann),
      isNotEmpty,
    );
    expect(agent.search('عناية'), isNotEmpty);
  });

  testWidgets('personal care loyalty screen uses glass UI and BiDi', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: PersonalCareLoyaltyScreen(agent: PersonalCareLoyaltyAgent()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Körperpflege & Vorteile'), findsOneWidget);
  });
}
