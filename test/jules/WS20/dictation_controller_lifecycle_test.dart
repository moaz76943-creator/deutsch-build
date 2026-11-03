import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  setUp(() {
    LexicalRepository.initializeStore([
      const LexicalEntry(
        id: 'dict_test_01',
        domainId: 'domain_01',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Verantwortung',
        sourceMeaning: 'المسؤولية',
        targetExample: 'Ich übernehme die Verantwortung.',
        sourceExampleTranslation: 'أنا أتحمل المسؤولية.',
        partOfSpeech: 'noun',
      ),
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

  testWidgets('dictation releases its answer controller on screen removal',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DictationTrainerScreen(sourceLocale: 'ar-SA', targetLocale: 'de-DE')),
    );
    await tester.pumpAndSettle();

    final controller = tester.widget<TextField>(find.byType(TextField)).controller;
    expect(controller, isNotNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pumpAndSettle();

    expect(() => controller!.addListener(() {}), throwsFlutterError);
  });
}
