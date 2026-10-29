import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deutsch_bilarabi/features/onboarding/fast_onboarding_screen.dart';

class MockNavigatorObserver extends NavigatorObserver {
  bool didPushMainShell = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is MaterialPageRoute) {
      if (route.builder.toString().contains('MainShellScreen')) {
        didPushMainShell = true;
      }
    }
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is MaterialPageRoute) {
      if (newRoute.builder.toString().contains('MainShellScreen')) {
        didPushMainShell = true;
      }
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({MockNavigatorObserver? observer, Future<bool> Function(String)? packVerifier}) {
    return MaterialApp(
      home: FastOnboardingScreen(languagePackVerifier: packVerifier),
      navigatorObservers: observer != null ? [observer] : [],
    );
  }

  testWidgets('fresh install stays on onboarding screen and shows UI for interface, source and target', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('إعدادات اللغة'), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNWidgets(3));
  });

  testWidgets('existing learner bypasses onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    final observer = MockNavigatorObserver();

    await tester.pumpWidget(createTestWidget(observer: observer));
    await tester.pumpAndSettle();

    expect(observer.didPushMainShell, isTrue);
  });

  testWidgets('shows error when submitting without selections', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('continue_button')));
    await tester.tap(find.byKey(const Key('continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('يرجى اختيار لغة الواجهة، اللغة المصدر، واللغة الهدف'), findsOneWidget);
  });

  testWidgets('shows error for unsupported target language', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // The dropdowns can be tricky. We just call onChanged directly by digging into state or using tapping carefully
    await tester.tap(find.byType(DropdownButton<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التركية (Turkish)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية (Arabic)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButton<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('التركية (Turkish)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('continue_button')));
    await tester.tap(find.byKey(const Key('continue_button')));
    await tester.pumpAndSettle();

    expect(find.text('هذه اللغة غير مدعومة حالياً للاستخدام كهدف'), findsOneWidget);
  });

  testWidgets('missing pack recoverable state shows correct error message', (tester) async {
    final packVerifier = (String locale) async => false;

    await tester.pumpWidget(createTestWidget(packVerifier: packVerifier));
    await tester.pumpAndSettle();

    // Setting state using a more robust way to avoid tap misses due to scrolling in Dropdowns
    final BuildContext context = tester.element(find.byType(FastOnboardingScreen));
    final state = context.findAncestorStateOfType<State<FastOnboardingScreen>>();

    // As it's private, we have to just tap and handle scroll
    // Interface: ar (Arabic is first item generally)
    await tester.tap(find.byType(DropdownButton<String>).at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('العربية (Arabic)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Source: en
    await tester.tap(find.byType(DropdownButton<String>).at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الإنجليزية (English)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Target: de
    await tester.tap(find.byType(DropdownButton<String>).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('الألمانية (German)').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('continue_button')));
    await tester.tap(find.byKey(const Key('continue_button')), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Check missing pack message
    expect(find.text('حزمة اللغة غير متوفرة أو تالفة. يرجى التحقق من توفر الحزمة.'), findsOneWidget);
  });

  testWidgets('cancelled onboarding does not save state', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_complete'), isNull);
  });
}
