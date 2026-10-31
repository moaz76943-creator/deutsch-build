import 'dart:async';

import 'package:deutsch_bilarabi/core/audio/tts_platform_adapter.dart';
import 'package:deutsch_bilarabi/services/tts_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTtsPlatformAdapter implements TtsPlatformAdapter {
  bool languageAvailable = true;
  bool languageInstalled = true;
  bool failLanguageAvailableOnce = false;
  Object voices = const <Object>[];
  Completer<dynamic>? initializationCompleter;
  Completer<dynamic>? languageAvailableCompleter;
  Completer<dynamic>? speakCompleter;

  String? selectedLocale;
  Map<String, String>? selectedVoice;
  String? spokenText;
  int stopCalls = 0;

  void Function()? startHandler;
  void Function()? completionHandler;
  void Function()? cancelHandler;
  void Function(Object? message)? errorHandler;

  @override
  void setStartHandler(void Function() handler) => startHandler = handler;

  @override
  void setCompletionHandler(void Function() handler) =>
      completionHandler = handler;

  @override
  void setCancelHandler(void Function() handler) => cancelHandler = handler;

  @override
  void setErrorHandler(void Function(Object? message) handler) =>
      errorHandler = handler;

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    final pending = initializationCompleter;
    if (pending != null) return pending.future;
    return 1;
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async => 1;

  @override
  Future<dynamic> setVolume(double volume) async => 1;

  @override
  Future<dynamic> setPitch(double pitch) async => 1;

  @override
  Future<dynamic> isLanguageAvailable(String locale) async {
    final pending = languageAvailableCompleter;
    if (pending != null) return pending.future;
    if (failLanguageAvailableOnce) {
      failLanguageAvailableOnce = false;
      throw StateError('synthetic engine failure');
    }
    return languageAvailable;
  }

  @override
  Future<dynamic> isLanguageInstalled(String locale) async =>
      languageInstalled;

  @override
  Future<dynamic> getVoices() async => voices;

  @override
  Future<dynamic> setLanguage(String locale) async {
    selectedLocale = locale;
    return 1;
  }

  @override
  Future<dynamic> setVoice(Map<String, String> voice) async {
    selectedVoice = Map<String, String>.from(voice);
    return 1;
  }

  @override
  Future<dynamic> speak(String text) async {
    spokenText = text;
    startHandler?.call();
    final pending = speakCompleter;
    if (pending != null) return pending.future;
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    stopCalls++;
    return 1;
  }
}

Map<String, Object> localVoice(String name, String locale) =>
    <String, Object>{
      'name': name,
      'locale': locale,
      'network_required': false,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('five pilot language identities require their installed local voice',
      () async {
    const expected = <String, String>{
      'de': 'de-DE',
      'ar': 'ar-SA',
      'en': 'en-US',
      'es': 'es-ES',
      'fr': 'fr-FR',
    };

    for (final item in expected.entries) {
      final fake = FakeTtsPlatformAdapter()
        ..voices = <Object>[
          localVoice('local-' + item.key, item.value),
        ];
      final service = TtsService(adapter: fake);

      final capability = await service.probeVoiceCapability(item.key);

      expect(capability.canSpeakOffline, isTrue, reason: item.key);
      expect(capability.locale, item.value, reason: item.key);
      expect(capability.voice?.locale, item.value, reason: item.key);
      await service.dispose();
    }
  });

  test('BCP-47 script and region identities are preserved', () async {
    const cases = <String, String>{
      'zh-Hant': 'zh-TW',
      'fr-CA': 'fr-CA',
      'sr-Latn-RS': 'sr-Latn-RS',
    };

    for (final item in cases.entries) {
      final fake = FakeTtsPlatformAdapter()
        ..voices = <Object>[localVoice('local', item.value)];
      final service = TtsService(adapter: fake);

      final capability = await service.probeVoiceCapability(item.key);

      expect(capability.canSpeakOffline, isTrue, reason: item.key);
      expect(capability.locale, item.value, reason: item.key);
      await service.dispose();
    }
  });

  test('registered language is not treated as an installed voice', () async {
    final fake = FakeTtsPlatformAdapter()
      ..languageInstalled = false
      ..voices = <Object>[localVoice('German', 'de-DE')];
    final service = TtsService(adapter: fake);

    final capability = await service.probeVoiceCapability('de');

    expect(capability.state, TtsVoiceCapabilityState.voiceMissing);
    expect(capability.canSpeakOffline, isFalse);
    await service.dispose();
  });

  test('voice list cannot silently fall back to another spoken language',
      () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('English only', 'en-US')];
    final service = TtsService(adapter: fake);

    final capability = await service.probeVoiceCapability('de-DE');

    expect(capability.state, TtsVoiceCapabilityState.voiceMissing);
    expect(fake.selectedLocale, isNull);
    await service.dispose();
  });

  test('explicit network-required voices are rejected offline', () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[
        <String, Object>{
          'name': 'network-de',
          'locale': 'de-DE',
          'network_required': true,
        },
      ];
    final service = TtsService(adapter: fake);

    final capability = await service.probeVoiceCapability('de');

    expect(capability.state, TtsVoiceCapabilityState.onlineOnly);
    expect(capability.canSpeakOffline, isFalse);
    await service.dispose();
  });

  test('network-only exact locale is not replaced by another local region',
      () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[
        <String, Object>{
          'name': 'network-au',
          'locale': 'en-AU',
          'network_required': true,
        },
        localVoice('local-us', 'en-US'),
      ];
    final service = TtsService(adapter: fake);

    final capability = await service.probeVoiceCapability('en-AU');

    expect(capability.state, TtsVoiceCapabilityState.onlineOnly);
    expect(capability.canSpeakOffline, isFalse);
    await service.dispose();
  });

  test('local playback preserves exact locale and selects exact local voice',
      () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('German local', 'de-DE')];
    final service = TtsService(adapter: fake);

    final played = await service.speak('Haus', languageCode: 'de-DE');

    expect(played, isTrue);
    expect(fake.selectedLocale, 'de-DE');
    expect(fake.selectedVoice?['name'], 'German local');
    expect(fake.spokenText, 'Haus');
    await service.dispose();
  });

  test('rapid stop cancels pending playback result', () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('German local', 'de-DE')]
      ..speakCompleter = Completer<dynamic>();
    final service = TtsService(adapter: fake);

    final pending = service.speak('Haus', languageCode: 'de');
    while (fake.spokenText == null) {
      await Future<void>.delayed(Duration.zero);
    }

    await service.stop();
    fake.speakCompleter!.complete(1);

    expect(await pending, isFalse);
    expect(service.status, TtsStatus.stopped);
    await service.dispose();
  });

  test('lifecycle pause cancels speech without polling', () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('French local', 'fr-FR')]
      ..speakCompleter = Completer<dynamic>();
    final service = TtsService(adapter: fake);

    final pending = service.speak('bonjour', languageCode: 'fr');
    while (fake.spokenText == null) {
      await Future<void>.delayed(Duration.zero);
    }

    await service.handleLifecycleState(AppLifecycleState.paused);
    fake.speakCompleter!.complete(1);

    expect(await pending, isFalse);
    expect(fake.stopCalls, greaterThan(0));
    await service.dispose();
  });

  test('initialization timeout is bounded and retryable', () async {
    final fake = FakeTtsPlatformAdapter()
      ..initializationCompleter = Completer<dynamic>();
    final service = TtsService(
      adapter: fake,
      initializationTimeout: const Duration(milliseconds: 10),
    );

    expect(await service.initialize(), isFalse);

    fake.initializationCompleter!.complete(1);
    fake.initializationCompleter = null;
    expect(await service.initialize(), isTrue);
    await service.dispose();
  });

  test('dispose cancels navigation-stale pending playback', () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('Spanish local', 'es-ES')]
      ..speakCompleter = Completer<dynamic>();
    final service = TtsService(adapter: fake);

    final pending = service.speak('hola', languageCode: 'es');
    while (fake.spokenText == null) {
      await Future<void>.delayed(Duration.zero);
    }

    await service.dispose();
    fake.speakCompleter!.complete(1);

    expect(await pending, isFalse);
    expect(fake.stopCalls, greaterThan(0));
  });

  test('capability timeout fails closed instead of blocking the UI', () async {
    final fake = FakeTtsPlatformAdapter()
      ..languageAvailableCompleter = Completer<dynamic>();
    final service = TtsService(
      adapter: fake,
      operationTimeout: const Duration(milliseconds: 10),
    );

    final capability = await service.probeVoiceCapability('es');

    expect(capability.state, TtsVoiceCapabilityState.engineUnavailable);
    expect(capability.canSpeakOffline, isFalse);
    await service.dispose();
  });

  test('engine probe failure can recover on a later request', () async {
    final fake = FakeTtsPlatformAdapter()
      ..failLanguageAvailableOnce = true
      ..voices = <Object>[localVoice('Arabic local', 'ar-SA')];
    final service = TtsService(adapter: fake);

    final first = await service.probeVoiceCapability('ar');
    final second = await service.probeVoiceCapability('ar');

    expect(first.state, TtsVoiceCapabilityState.engineUnavailable);
    expect(second.canSpeakOffline, isTrue);
    await service.dispose();
  });

  test('oversized text is rejected before voice work', () async {
    final fake = FakeTtsPlatformAdapter()
      ..voices = <Object>[localVoice('English local', 'en-US')];
    final service = TtsService(adapter: fake);

    final played = await service.speak(
      List<String>.filled(
        TtsService.maximumSpeechCharacters + 1,
        'a',
      ).join(),
      languageCode: 'en',
    );

    expect(played, isFalse);
    expect(fake.spokenText, isNull);
    await service.dispose();
  });
}
