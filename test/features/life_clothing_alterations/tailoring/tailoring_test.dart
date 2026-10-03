import 'package:deutsch_bilarabi/features/life_clothing_alterations/tailoring/tailoring_agent.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/tailoring/tailoring_models.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/tailoring/tailoring_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClothingTailoringAgent', () {
    const agent = ClothingTailoringAgent();

    test('filters zipper repair dialogue', () {
      final results = agent.findDialogues(
        service: TailoringService.zipperRepair,
        query: 'Reißverschluss',
      );

      expect(results, hasLength(1));
      expect(results.single.german, contains('reparieren'));
    });

    test('provides pickup and cost agreement for core alterations', () {
      final agreement = agent.agreementFor(
        TailoringService.trousersShortening,
      );

      expect(agreement, isNotNull);
      expect(agreement!.readyWhenDe, contains('abholen'));
      expect(agreement.costQuestionDe, contains('kostet'));
    });

    test('keeps button and pocket repair in the practical service bank', () {
      expect(
        agent.findDialogues(service: TailoringService.buttonRepair),
        isNotEmpty,
      );
      expect(
        agent.findDialogues(service: TailoringService.pocketRepair),
        isNotEmpty,
      );
    });
  });

  testWidgets('tailoring panel exposes classic alteration services',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClothingTailoringPanel())),
    );

    expect(find.text('الخياطة والتعديلات'), findsOneWidget);
    expect(find.textContaining('Reißverschluss'), findsWidgets);
    expect(find.byType(AppBar), findsNothing);
  });
}
