import 'package:deutsch_bilarabi/features/pronunciation/pronunciation_coach_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const speech = MethodChannel('plugin.csdcorp.com/speech_to_text');
  const tts = MethodChannel('flutter_tts');
  const secure = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(speech, null);
    messenger.setMockMethodCallHandler(tts, null);
    messenger.setMockMethodCallHandler(secure, null);
  });

  testWidgets('unavailable speech stays on screen and does not start listening',
      (tester) async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(speech, (call) async {
      calls.add('speech:${call.method}');
      if (call.method == 'initialize') return false;
      return null;
    });
    messenger.setMockMethodCallHandler(tts, (call) async {
      calls.add('tts:${call.method}');
      return 1;
    });
    messenger.setMockMethodCallHandler(secure, (call) async {
      calls.add('secure:${call.method}');
      expect(call.arguments['key'], 'pronunciation_streak');
      return null;
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PronunciationCoachScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Guten Morgen'), findsOneWidget);
    expect(
      find.text('Speech recognition not available on this device'),
      findsOneWidget,
    );

    await tester.tap(find.text('Start Speaking'));
    await tester.pump();

    expect(calls.where((call) => call == 'speech:listen'), isEmpty);
    expect(
      find.text('Speech recognition not available on this device'),
      findsOneWidget,
    );
  });

  testWidgets('a permission failure does not replace the target phrase',
      (tester) async {
    messenger.setMockMethodCallHandler(speech, (call) async {
      if (call.method == 'initialize') {
        throw PlatformException(code: 'error_permission', message: 'denied');
      }
      return null;
    });
    messenger.setMockMethodCallHandler(tts, (call) async {
      throw PlatformException(code: 'tts', message: 'missing engine');
    });
    messenger.setMockMethodCallHandler(secure, (call) async {
      throw PlatformException(code: 'keystore', message: 'locked');
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: PronunciationCoachScreen()),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Guten Morgen'), findsOneWidget);
    expect(
      find.text('Speech recognition not available on this device'),
      findsOneWidget,
    );
  });
}
