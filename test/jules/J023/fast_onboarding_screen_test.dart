import 'package:deutsch_bilarabi/core/architecture/directed_pair_id.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';
import 'package:deutsch_bilarabi/providers/active_language_provider.dart';
import 'package:deutsch_bilarabi/screens/main_shell_screen.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// J023 originally expected dropdowns on FastOnboardingScreen. The startup
/// boundary now only decides between a first-run explanation and saved progress;
/// language pack admission and directed-pair validity are separate contracts.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('First run reaches the real offline welcome screen',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: FastOnboardingScreen(readReviewCount: () async => 0),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('ابدأ التعلم الآن'), findsOneWidget);
    expect(find.byType(MainShellScreen), findsNothing);
  });

  test('A language cannot be both source and target', () {
    const invalid = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'ar', semanticVersion: '1.0.0',
    );
    const valid = DirectedPairId(
      sourceLocale: 'ar', targetLocale: 'de', semanticVersion: '1.0.0',
    );

    expect(invalid.isValidForLearning(), isFalse);
    expect(valid.isValidForLearning(), isTrue);
    expect(invalid, isNot(valid));
  });

  testWidgets('Saved learner progress resumes the real main shell',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: FastOnboardingScreen(readReviewCount: () async => 2),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  test('A downloaded but uninstalled language remains unavailable', () {
    final state = ActiveLanguageState.initial().copyWith(
      verifiedArchiveCodes: {'fr'},
    );
    expect(state.hasVerifiedArchive('fr'), isTrue);
    expect(state.isInstalled('fr'), isFalse);
    expect(state.activeLanguageCode, 'de');
  });

  testWidgets('Existing review records take precedence over welcome screen',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: FastOnboardingScreen(readReviewCount: () async => 1),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.text('ابدأ التعلم الآن'), findsNothing);
  });

  testWidgets('Failed progress read offers retry without losing first run',
      (tester) async {
    var attempts = 0;
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        home: FastOnboardingScreen(readReviewCount: () async {
          attempts++;
          if (attempts == 1) throw const FormatException('damaged local data');
          return 0;
        }),
      ),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('إعادة المحاولة'), findsOneWidget);
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(attempts, 2);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
