import 'package:deutsch_bilarabi/core/audio/android_offline_voice_capability_probe.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_tts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('merges voice locales and installed languages without duplicates', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getVoices':
          return <Object?>[
            <String, String>{'name': 'de-de-x-nfh', 'locale': 'de-DE'},
            'not-a-voice',
            <String, String>{'name': 'empty', 'locale': ''},
            <String, String>{'name': 'ar', 'locale': 'ar-SA'},
          ];
        case 'getLanguages':
          return <Object>['de-DE', 3, 'tr-TR', ''];
        default:
          return null;
      }
    });

    final locales = await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
        .getVerifiedOfflineLocales();

    expect(locales, containsAll(<String>['de-DE', 'ar-SA', 'tr-TR']));
    expect(locales.where((locale) => locale == 'de-DE'), hasLength(1));
    expect(locales, isNot(contains('')));
  });

  test('a null voice list still reports installed languages', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getVoices') return null;
      if (call.method == 'getLanguages') return <String>['de-DE'];
      return null;
    });

    final locales = await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
        .getVerifiedOfflineLocales();
    expect(locales, <String>['de-DE']);
  });

  test('engine failures return no locales instead of throwing', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'error', message: 'tts unavailable');
    });

    expect(
      await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
          .getVerifiedOfflineLocales(),
      isEmpty,
    );
  });
}
