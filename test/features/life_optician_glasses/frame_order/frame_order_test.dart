import 'package:deutsch_bilarabi/design_system/design_system.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/frame_order/frame_order_agent.dart';
import 'package:deutsch_bilarabi/features/life_optician_glasses/frame_order/frame_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const agent = FrameOrderAgent();

  test('covers frames, lenses, fitting and collection', () {
    final corpus = agent.items.map((e) => '${e.german} ${e.arabic}').join(' ');
    expect(corpus, contains('Fassung'));
    expect(corpus, contains('Entspiegelung'));
    expect(corpus, contains('Gläser'));
    expect(corpus, contains('Bügel'));
    expect(corpus, contains('abholen'));
  });

  test('search finds ordering and fitting language', () {
    expect(agent.search('Fassung'), isNotEmpty);
    expect(agent.search('الإطار'), isNotEmpty);
  });

  testWidgets('frame screen uses glass shell and scroll safety', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FrameOrderScreen(agent: FrameOrderAgent()),
    ));
    expect(find.byType(AppGlassCard), findsWidgets);
    expect(find.byType(SafeArea), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Fassung & Brillengläser'), findsOneWidget);
  });
}
