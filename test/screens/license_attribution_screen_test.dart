import 'package:deutsch_bilarabi/screens/license_attribution_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('offline legal code and exact upstream revision are displayed',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: LicenseAttributionScreen(
      installedPacksLoader: () async => [
        {'languageCode': 'fr', 'version': '2.1',
          'attribution': {
            'licenseId': 'CC BY-SA 4.0',
            'contributors': ['Wiktionary contributors', 'Kaikki.org'],
            'sourceUrl': 'https://fr.wiktionary.org',
            'revisionTimestamp': '2026-08-10T12:00:00Z',
            'modifications': 'Converted to SQLite',
          }},
      ],
    )));
    await tester.pumpAndSettle();
    expect(find.textContaining('Wiktionary contributors'), findsAtLeastNWidgets(1));
    expect(find.textContaining('2026-08-10'), findsOneWidget);
    expect(find.textContaining(ccBySa40Url), findsOneWidget);
    expect(ccBySa40LegalText, contains('Section 8'));
    final legalTile = find.byKey(const ValueKey('legalcode-fr'));
    await tester.ensureVisible(legalTile);
    await tester.tap(legalTile);
    await tester.pumpAndSettle();
    expect(find.byType(SelectableText), findsWidgets);
  });

  testWidgets('missing credits and license are not guessed', (tester) async {
    await tester.pumpWidget(MaterialApp(home: LicenseAttributionScreen(
      installedPacksLoader: () async => [
        {'languageCode': 'th', 'version': '1.0.0'},
      ],
    )));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('attribution-de')), findsOneWidget);
    expect(find.textContaining('غير مكتملة'), findsWidgets);
    expect(find.textContaining('غير متاح محلياً'), findsWidgets);
  });
}
