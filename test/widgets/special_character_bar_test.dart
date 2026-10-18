import 'package:deutsch_bilarabi/providers/active_language_provider.dart';
import 'package:deutsch_bilarabi/widgets/special_character_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpecialCharacterBar character mapping', () {
    test('returns the requested German, Turkish, Czech and Polish glyphs', () {
      expect(SpecialCharacterBar.charactersForLanguage('de'),
          <String>['ä', 'ö', 'ü', 'ß']);
      expect(SpecialCharacterBar.charactersForLanguage('tr'),
          <String>['ç', 'ğ', 'ı', 'ö', 'ş', 'ü']);
      expect(SpecialCharacterBar.charactersForLanguage('cs'), <String>[
        'č', 'ď', 'é', 'ě', 'í', 'ň', 'ó', 'ř', 'š', 'ť', 'ú', 'ů', 'ý', 'ž',
      ]);
      expect(SpecialCharacterBar.charactersForLanguage('pl'),
          <String>['ą', 'ć', 'ę', 'ł', 'ń', 'ó', 'ś', 'ź', 'ż']);
    });

    test('normalizes regional and underscore-separated language tags', () {
      expect(SpecialCharacterBar.charactersForLanguage(' DE-de '),
          <String>['ä', 'ö', 'ü', 'ß']);
      expect(SpecialCharacterBar.charactersForLanguage('TR_tr'),
          <String>['ç', 'ğ', 'ı', 'ö', 'ş', 'ü']);
    });

    test('returns no chips for ASCII-only, Arabic-script and unknown codes', () {
      for (final code in <String>['en', 'ar', 'ar-JO', 'fa', 'ur', 'zz']) {
        expect(SpecialCharacterBar.charactersForLanguage(code), isEmpty,
            reason: 'Unsupported or non-accented script: $code');
      }
    });
  });

  group('SpecialCharacterBar widget', () {
    late TextEditingController controller;

    setUp(() => controller = TextEditingController());
    tearDown(() => controller.dispose());

    Future<void> pumpBar(
      WidgetTester tester, {
      required String languageCode,
      FocusNode? fieldFocusNode,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TextField(controller: controller, focusNode: fieldFocusNode),
              bottomSheet: SpecialCharacterBar(
                controller: controller,
                languageCode: languageCode,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows four tappable German chips and horizontal scroll',
        (tester) async {
      await pumpBar(tester, languageCode: 'de');

      for (final glyph in <String>['ä', 'ö', 'ü', 'ß']) {
        expect(find.byKey(ValueKey<String>('special-character-$glyph')),
            findsOneWidget);
      }
      final scroll = tester.widget<SingleChildScrollView>(
        find.descendant(
          of: find.byType(SpecialCharacterBar),
          matching: find.byType(SingleChildScrollView),
        ),
      );
      expect(scroll.scrollDirection, Axis.horizontal);
    });

    testWidgets('inserts at the current cursor and moves the caret forward',
        (tester) async {
      controller.value = const TextEditingValue(
        text: 'Hallo',
        selection: TextSelection.collapsed(offset: 1),
      );
      await pumpBar(tester, languageCode: 'de');
      await tester.tap(find.byKey(const ValueKey<String>('special-character-ä')));
      await tester.pump();

      expect(controller.text, 'Häallo');
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
    });

    testWidgets('replaces a selection and clears stale IME composition',
        (tester) async {
      controller.value = const TextEditingValue(
        text: 'Hallo',
        selection: TextSelection(baseOffset: 1, extentOffset: 4),
        composing: TextRange(start: 0, end: 5),
      );
      await pumpBar(tester, languageCode: 'de');
      await tester.tap(find.byKey(const ValueKey<String>('special-character-ö')));
      await tester.pump();

      expect(controller.text, 'Höo');
      expect(controller.selection, const TextSelection.collapsed(offset: 2));
      expect(controller.value.composing, TextRange.empty);
    });

    testWidgets('appends at end when there is no valid caret',
        (tester) async {
      controller.value = const TextEditingValue(
        text: 'Guten',
        selection: TextSelection.collapsed(offset: -1),
      );
      await pumpBar(tester, languageCode: 'de');
      await tester.tap(find.byKey(const ValueKey<String>('special-character-ß')));
      await tester.pump();

      expect(controller.text, 'Gutenß');
      expect(controller.selection, const TextSelection.collapsed(offset: 6));
    });

    testWidgets('does not take focus away from the active search field',
        (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await pumpBar(tester, languageCode: 'de', fieldFocusNode: focus);
      await tester.showKeyboard(find.byType(TextField));
      expect(focus.hasFocus, isTrue);

      await tester.tap(find.byKey(const ValueKey<String>('special-character-ü')));
      await tester.pump();

      expect(focus.hasFocus, isTrue);
      expect(controller.text, 'ü');
    });

    testWidgets('collapses completely for ASCII and Arabic languages',
        (tester) async {
      for (final code in <String>['en-US', 'ar-JO']) {
        await pumpBar(tester, languageCode: code);
        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(tester.getSize(find.byType(SpecialCharacterBar)).height, 0);
      }
    });

    testWidgets('rebuilds its glyphs after the active language changes',
        (tester) async {
      final language = StateProvider<String>((ref) => 'de');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeLanguageCodeProvider.overrideWith((ref) => ref.watch(language)),
          ],
          child: MaterialApp(
            home: Scaffold(
              bottomSheet: SpecialCharacterBar(controller: controller),
            ),
          ),
        ),
      );
      expect(find.byKey(const ValueKey<String>('special-character-ä')),
          findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SpecialCharacterBar)),
      );
      container.read(language.notifier).state = 'pl';
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('special-character-ł')),
          findsOneWidget);
      expect(find.byKey(const ValueKey<String>('special-character-ä')),
          findsNothing);
    });

    testWidgets('sits just above keyboard inset in a Scaffold bottom sheet',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewInsets: const EdgeInsets.only(bottom: 240),
                ),
                child: Scaffold(
                  bottomSheet: SpecialCharacterBar(
                    controller: controller,
                    languageCode: 'de',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffoldHeight = tester.getSize(find.byType(Scaffold)).height;
      final barBottom = tester.getBottomRight(
        find.byType(SpecialCharacterBar),
      ).dy;
      expect(barBottom, closeTo(scaffoldHeight - 240, 1));
    });
  });
}
