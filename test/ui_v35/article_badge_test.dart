import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/ui_v35/shared/article_badge.dart';
import '../../lib/ui_v35/theme/app_design_system.dart';

void main() {
  test('article badge colors are canonical and centralized', () {
    expect(articleBadgeColor('der'), AppPalette.articleDer);
    expect(articleBadgeColor('die'), AppPalette.articleDie);
    expect(articleBadgeColor('das'), AppPalette.articleDas);
    expect(articleBadgeColor('DER'), AppPalette.articleDer);
  });

  testWidgets('article badge keeps the grammatical article visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppDesignSystem.light(),
        home: const Scaffold(
          body: Center(child: ArticleBadge(article: 'der')),
        ),
      ),
    );

    expect(find.text('der'), findsOneWidget);
    expect(find.byKey(const Key('article-badge-der')), findsOneWidget);
  });
}
