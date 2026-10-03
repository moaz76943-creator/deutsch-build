import 'package:deutsch_bilarabi/features/life_clothing_alterations/fitting/fitting_agent.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/fitting/fitting_models.dart';
import 'package:deutsch_bilarabi/features/life_clothing_alterations/fitting/fitting_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClothingFittingAgent', () {
    const agent = ClothingFittingAgent();

    test('filters practical clothing dialogues by garment and search text', () {
      final results = agent.findDialogues(
        garment: FittingGarmentType.trousers,
        query: 'Taille',
      );

      expect(results, hasLength(1));
      expect(results.single.german, contains('Taille'));
    });

    test('builds neutral comfort requests for fit dimensions', () {
      expect(
        agent.comfortRequest(
          garment: FittingGarmentType.shirt,
          dimension: FitDimension.width,
        ),
        contains('Weite'),
      );
      expect(
        agent.comfortRequest(
          garment: FittingGarmentType.jacket,
          dimension: FitDimension.comfort,
        ),
        contains('bequemeren'),
      );
    });

    test('provides cotton and wool care questions', () {
      expect(agent.careFor(NaturalFabric.cotton), isNotNull);
      expect(agent.careFor(NaturalFabric.wool), isNotNull);
    });
  });

  testWidgets('fitting panel exposes fitting-room content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ClothingFittingPanel())),
    );

    expect(find.text('تجربة الملابس والمقاسات'), findsOneWidget);
    expect(find.textContaining('Umkleidekabine'), findsWidgets);
    expect(find.byType(ChoiceChip), findsWidgets);
  });
}
