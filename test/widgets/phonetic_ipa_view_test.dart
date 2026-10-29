import 'package:deutsch_bilarabi/widgets/phonetic_ipa_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('IPA helpers', () {
    test('reject missing, empty, or delimiter-only phonetics', () {
      expect(hasPhoneticData(null), isFalse);
      expect(hasPhoneticData(''), isFalse);
      expect(hasPhoneticData(' \t\n '), isFalse);
      expect(hasPhoneticData('///'), isFalse);
      expect(hasPhoneticData(' / / '), isFalse);
      expect(formatIpa(' / / '), isEmpty);
    });

    test('detects valid IPA without requiring slash delimiters', () {
      expect(hasPhoneticData('baʊm'), isTrue);
      expect(hasPhoneticData(' /kæt/ '), isTrue);
      expect(hasPhoneticData('ˈdɔʏtʃ'), isTrue);
    });

    test('formats IPA with exactly one enclosing pair of slashes', () {
      expect(formatIpa('baʊm'), '/baʊm/');
      expect(formatIpa('/kæt/'), '/kæt/');
      expect(formatIpa(' ///ˈdɔʏtʃ/// '), '/ˈdɔʏtʃ/');
      expect(formatIpa('  / baʊm /  '), '/baʊm/');
      expect(formatIpa(''), isEmpty);
    });

    test('preserves Unicode phonemes and combining marks', () {
      expect(formatIpa('tʃɪə\u0303'), '/tʃɪə\u0303/');
    });
  });

  group('PhoneticIpaView', () {
    testWidgets('is invisible without phonetic data', (tester) async {
      for (final ipa in <String?>[null, '', '   ', '//', ' / / ']) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PhoneticIpaView(ipa: ipa)),
          ),
        );

        expect(find.byTooltip('Copy IPA pronunciation'), findsNothing);
        expect(
          find.descendant(
            of: find.byType(PhoneticIpaView),
            matching: find.byType(Text),
          ),
          findsNothing,
        );
      }
    });

    testWidgets('shows IPA left-to-right even inside an RTL screen',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: PhoneticIpaView(ipa: 'baʊm')),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text('/baʊm/'));
      expect(text.textDirection, TextDirection.ltr);
      expect(text.semanticsLabel, contains('IPA'));
      expect(text.style?.fontFamily, 'monospace');
      expect(text.style?.fontFamilyFallback, contains('serif'));
      expect(find.byTooltip('Copy IPA pronunciation'), findsOneWidget);
    });

    testWidgets('copies formatted IPA to system clipboard', (tester) async {
      String? clipboardText;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            final payload = call.arguments as Map<dynamic, dynamic>;
            clipboardText = payload['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(() {
        messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PhoneticIpaView(ipa: ' /kæt/ ')),
        ),
      );
      await tester.tap(find.byTooltip('Copy IPA pronunciation'));
      await tester.pump();

      expect(clipboardText, '/kæt/');
    });

    testWidgets('uses a high-contrast palette in light and dark themes',
        (tester) async {
      for (final brightness in <Brightness>[
        Brightness.light,
        Brightness.dark,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const Scaffold(
              body: PhoneticIpaView(ipa: '/ˈdɔʏtʃ/'),
            ),
          ),
        );
        // MaterialApp animates theme changes. The contrast colors are the
        // settled theme, not the first in-flight frame.
        await tester.pump(const Duration(milliseconds: 250));

        final isDark = brightness == Brightness.dark;
        final expectedTextColor = isDark ? Colors.white : Colors.black;
        final expectedBackground = isDark ? Colors.black : Colors.white;
        final text = tester.widget<Text>(find.text('/ˈdɔʏtʃ/'));
        final decoratedBox = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(PhoneticIpaView),
            matching: find.byType(DecoratedBox),
          ),
        );
        final decoration = decoratedBox.decoration as BoxDecoration;

        expect(text.style?.color, expectedTextColor);
        expect(decoration.color, expectedBackground);
      }
    });
  });
}
