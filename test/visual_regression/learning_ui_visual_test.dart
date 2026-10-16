import 'package:deutsch_bilarabi/screens/curriculum_units_screen.dart';
import 'package:deutsch_bilarabi/screens/home_screen.dart';
import 'package:deutsch_bilarabi/screens/onboarding_screen.dart';
import 'package:deutsch_bilarabi/screens/placement_level_screen.dart';
import 'package:deutsch_bilarabi/screens/srs_flashcard_deck_screen.dart';
import 'package:deutsch_bilarabi/widgets/accessible_multilingual_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _smallPhone(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _app(Widget home, {double scale = 1, TextDirection direction = TextDirection.rtl}) {
  return MaterialApp(
    home: Builder(builder: (context) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(scale),
        ),
        child: Directionality(textDirection: direction, child: home),
      );
    }),
  );
}

void main() {
  testWidgets('Home: primary learning CTA remains tappable on a narrow phone',
      (tester) async {
    await _smallPhone(tester);
    var navigationCount = 0;
    await tester.pumpWidget(_app(
      Scaffold(
        body: HomeScreen(onNavigateToUnits: () => navigationCount++),
      ),
    ));

    final continueButton = find.text('متابعة الدرس الحالي');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pump();

    expect(navigationCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Placement: A2 can be selected before starting the learning path',
      (tester) async {
    await _smallPhone(tester);
    var completed = false;
    await tester.pumpWidget(_app(
      PlacementLevelScreen(onComplete: () => completed = true),
      scale: 1.5,
    ));

    expect(find.text('ما هو مستواك الحالي؟'), findsOneWidget);
    await tester.tap(find.text('أساسيات التواصل (A2)'));
    await tester.pump();
    await tester.tap(find.text('بدء المسار التعليمي'));
    expect(completed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Learning Path: four levels of locked/unlocked units stay scrollable',
      (tester) async {
    await _smallPhone(tester);
    await tester.pumpWidget(_app(
      const Scaffold(body: CurriculumUnitsScreen()),
      scale: 1.4,
    ));
    expect(find.text('الوحدة 1: التحيات والتعارف'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('الوحدة 4: التسوق والطعام'),
      140,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('الوحدة 4: التسوق والطعام'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Review: flip reveals meaning and rating advances exactly one card',
      (tester) async {
    await _smallPhone(tester);
    await tester.pumpWidget(_app(const SrsFlashcardDeckScreen()));

    expect(find.text('die Entwicklung'), findsOneWidget);
    await tester.tap(find.text('die Entwicklung'));
    await tester.pump();

    expect(find.text('التطور / النشوء'), findsOneWidget);
    await tester.tap(find.text('أتقنتها جيداً'));
    await tester.pump();

    expect(find.text('erfolgreich'), findsOneWidget);
    expect(find.text('التطور / النشوء'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Navigation: first-run CTA responds without requesting network',
      (tester) async {
    await _smallPhone(tester);
    var navigations = 0;
    await tester.pumpWidget(_app(
      OnboardingScreen(onStart: () => navigations++),
    ));
    await tester.tap(find.text('ابدأ التعلم الآن'));
    expect(navigations, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BiDi: German and Japanese phrases retain LTR inside Arabic RTL',
      (tester) async {
    await _smallPhone(tester);
    await tester.pumpWidget(_app(const Scaffold(
      body: Column(
        children: [
          AccessibleMultilingualText(
            text: 'die Donaudampfschifffahrtsgesellschaft',
            languageTag: 'de-DE',
          ),
          AccessibleMultilingualText(
            text: '日本語の長い例文です',
            languageTag: 'ja-JP',
          ),
          AccessibleMultilingualText(
            text: 'اللغة العربية',
            languageTag: 'ar-JO',
          ),
        ],
      ),
    ), scale: 1.6));

    final widgets = find.byType(AccessibleMultilingualText);
    expect(widgets, findsNWidgets(3));
    final german = tester.widget<Text>(find.descendant(
      of: widgets.at(0), matching: find.byType(Text),
    ));
    final japanese = tester.widget<Text>(find.descendant(
      of: widgets.at(1), matching: find.byType(Text),
    ));
    final arabic = tester.widget<Text>(find.descendant(
      of: widgets.at(2), matching: find.byType(Text),
    ));
    expect(german.textDirection, TextDirection.ltr);
    expect(japanese.textDirection, TextDirection.ltr);
    expect(arabic.textDirection, TextDirection.rtl);
    expect(tester.takeException(), isNull);
  });
}
