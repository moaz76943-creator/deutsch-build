import 'package:deutsch_bilarabi/core/audio/android_offline_voice_capability_probe.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('only installed non-network voices qualify and locales are deduplicated',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      switch (call.method) {
        case 'getVoices':
          return <Object?>[
            {'locale': 'de-DE', 'network_required': false},
            {'locale': 'de-DE', 'network_required': false},
            {'locale': 'ar-SA', 'network_required': 'false'},
            {'locale': 'fr-FR', 'network_required': true},
            {
              'locale': 'ja-JP',
              'network_required': false,
              'requiresNetwork': true
            },
            {'locale': 'tr-TR'},
            {'locale': 'es-ES', 'network_required': false},
            {
              'locale': 'it-IT',
              'network_required': false,
              'features': 'notInstalled'
            },
            {'locale': '', 'network_required': false},
            'not-a-voice',
          ];
        case 'isLanguageInstalled':
          return call.arguments == 'es-ES' ? 0 : 1;
        case 'getLanguages':
          return ['fr-FR', 'tr-TR'];
        default:
          return null;
      }
    });
    final locales = await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
        .getVerifiedOfflineLocales();
    expect(locales, ['de-DE', 'ar-SA']);
  });

  test('a catalogue without voice evidence cannot certify offline availability',
      () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'getVoices') return null;
      if (call.method == 'getLanguages') return ['de-DE'];
      if (call.method == 'isLanguageInstalled') return 1;
      return null;
    });
    expect(
        await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
            .getVerifiedOfflineLocales(),
        isEmpty);
  });

  test('engine failures return no locales instead of throwing', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'error', message: 'tts unavailable');
    });
    expect(
        await AndroidOfflineVoiceCapabilityProbe(FlutterTts())
            .getVerifiedOfflineLocales(),
        isEmpty);
  });
}
