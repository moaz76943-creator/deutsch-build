import 'package:deutsch_bilarabi/core/lexical_repository.dart';
import 'package:deutsch_bilarabi/screens/dictation_trainer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dictation releases its answer controller on screen removal',
      (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.deutschbilarabi.app/offline_voice_capability'),
      (call) async => <String>[],
    );
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.deutschbilarabi.app/offline_voice_capability'),
        null,
      );
    });
    LexicalRepository.initializeStore(<LexicalEntry>[
      const LexicalEntry(
        id: 'de.haus',
        domainId: 'daily',
        sourceLocale: 'ar-SA',
        targetLocale: 'de-DE',
        targetTerm: 'Haus',
        sourceMeaning: 'بيت',
        targetExample: 'Das Haus ist groß.',
        sourceExampleTranslation: 'البيت كبير.',
        partOfSpeech: 'noun',
      ),
    ]);
    addTearDown(() => LexicalRepository.initializeStore(<LexicalEntry>[]));

    await tester.pumpWidget(
      const MaterialApp(home: DictationTrainerScreen()),
    );
    await tester.pump();
    await tester.pump();
    final controller =
        tester.widget<TextField>(find.byType(TextField)).controller;
    expect(controller, isNotNull);

    await tester.pumpWidget(const SizedBox());
    expect(() => controller!.addListener(() {}), throwsFlutterError);
  });
}
