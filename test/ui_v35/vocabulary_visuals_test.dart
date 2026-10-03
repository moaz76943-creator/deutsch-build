import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v35/theme/app_design_system.dart';
import '../../lib/ui_v35/widgets/vocabulary_visuals.dart';

void main() {
  testWidgets('vocabulary header keeps article German and Arabic together', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: Scaffold(
          body: VocabularyWordHeader(
            article: 'der',
            german: 'Apfel',
            arabic: 'التفاحة',
            topic: 'الطعام',
            phonetic: '[ˈapfl̩]',
            onSpeak: () {},
          ),
        ),
      ),
    );

    expect(find.text('der'), findsOneWidget);
    expect(find.text('Apfel'), findsOneWidget);
    expect(find.text('التفاحة'), findsOneWidget);
    expect(find.text('[ˈapfl̩]'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('grid card exposes audio and favorite actions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 280,
            child: VocabularyGridCard(
              article: 'das',
              german: 'Buch',
              arabic: 'الكتاب',
              topic: 'التعلم',
              isFavorite: true,
              onSpeak: () {},
              onToggleFavorite: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('das'), findsOneWidget);
    expect(find.text('Buch'), findsOneWidget);
    expect(find.text('الكتاب'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
  });
}
