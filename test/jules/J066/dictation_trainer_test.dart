import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/core/srs/bridge/srs_compat_bridge.dart';
import 'package:deutsch_bilarabi/core/progress/review_transaction_envelope.dart';
import 'package:flutter/services.dart';

void main() {
  setUp(() {
    try {
      SrsCompatBridge.instance.bindCanonicalWriter((ReviewTransactionEnvelope envelope) async {});
    } catch (_) {
      // Ignore if already bound
    }
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'dict_test_1',
        domainId: 'domain_1',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Verantwortung',
        sourceMeaning: 'المسؤولية',
        targetExample: 'Er trägt die Verantwortung.',
        sourceExampleTranslation: 'هو يتحمل المسؤولية.',
        partOfSpeech: 'noun',
      )
    ]);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.deutschbilarabi.app/offline_voice_capability'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getOfflineVoices') {
          return ['de-DE-local', 'ar-SA-local'];
        }
        return null;
      },
    );
  });

  testWidgets('Screen shows voice unavailable if local voice missing', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.deutschbilarabi.app/offline_voice_capability'),
      (MethodCall methodCall) async {
        return [];
      },
    );
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));
    await tester.pumpAndSettle();

    expect(find.text('الصوت غير متاح حالياً. اقرأ المعنى واكتب الكلمة.'), findsOneWidget);
  });

  testWidgets('Correct answer triggers success and prevents duplicates', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Verantwortung');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.textContaining('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);

    // Check if duplicate submissions are blocked
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull); // disabled
  });

  testWidgets('Non-Latin script normalization test (Arabic)', (WidgetTester tester) async {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'dict_test_2',
        domainId: 'domain_1',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE', // we hardcoded ar-SA -> de-DE in the screen
        targetTerm: 'مَسْؤُولِيَّة', // fake German target term for testing
        sourceMeaning: 'Responsibility',
        targetExample: '..',
        sourceExampleTranslation: '..',
        partOfSpeech: 'noun',
      ),
    ]);

    await tester.pumpWidget(const MaterialApp(home: DictationTrainerScreen()));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'مَسْؤُولِيَّة');
    await tester.tap(find.text('تحقق من التهجئة'));
    await tester.pumpAndSettle();

    expect(find.textContaining('إجابة صحيحة تماماً! أحسنت 🚀'), findsOneWidget);
  });

  testWidgets('Interrupted navigation cleans up', (WidgetTester tester) async {
    final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Home')));
        }
        return MaterialPageRoute(builder: (_) => const DictationTrainerScreen());
      },
    ));
    await tester.pumpAndSettle();

    // Push the dictation screen
    navKey.currentState!.pushNamed('/dictation');
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsOneWidget);

    // Pop the screen
    navKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(find.byType(DictationTrainerScreen), findsNothing);
  });
}
