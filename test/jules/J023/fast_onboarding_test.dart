import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/core/catalog/directed_catalog_readiness.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/providers/active_language_provider.dart';
import 'package:deutsch_bilarabi/screens/main_shell_screen.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget startWithProgress(int count) => ProviderScope(
    child: MaterialApp(
      home: FastOnboardingScreen(readReviewCount: () async => count),
    ),
  );

  testWidgets('Fresh install stays on welcome until learner starts',
      (tester) async {
    await tester.pumpWidget(startWithProgress(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainShellScreen), findsNothing);
    expect(find.text('ابدأ التعلم الآن'), findsOneWidget);
  });

  testWidgets('Learner with progress bypasses first-run welcome',
      (tester) async {
    await tester.pumpWidget(startWithProgress(3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  test('Directed pairs cannot silently become reflexive or reverse pairs', () {
    const arabicToGerman = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0',
    );
    const germanToArabic = DirectedPairId(
      sourceLocale: 'de', targetLocale: 'ar', semanticVersion: '1.0.0',
    );
    const sameLanguage = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0',
    );

    expect(sameLanguage.isValidForLearning(), isFalse);
    expect(arabicToGerman.isValidForLearning(), isTrue);
    expect(arabicToGerman.uniqueKey, isNot(germanToArabic.uniqueKey));
  });

  test('A catalog entry or archived pack cannot unlock target learning', () {
    final readiness = DirectedCatalogReadiness()
      ..registerLanguage('en')
      ..registerLanguage('fr');
    const pair = DirectedPairId(
      sourceLocale: 'en', targetLocale: 'fr', semanticVersion: '1.0.0',
    );
    final archiveState = ActiveLanguageState.initial().copyWith(
      verifiedArchiveCodes: {'fr'},
    );

    expect(archiveState.isInstalled('fr'), isFalse);
    final result = readiness.resolvePairStatus(pair);
    expect(result, isA<PairUnavailable>());
    expect((result as PairUnavailable).reason,
        UnavailableReason.targetMissingPack);
  });

  testWidgets('Unfinished onboarding does not persist false completion',
      (tester) async {
    await tester.pumpWidget(startWithProgress(0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final prefs = await SharedPreferences.getInstance();
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(prefs.getBool('has_completed_onboarding'), isNull);
    expect(prefs.getString('language_manager.active_code.v1'), isNull);
  });
}
