import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:deutsch_bilarabi/services/hybrid_audio_service.dart';

void main() {
  test('unsupported BCP-47 language never reaches the TTS channel', () async {
    var called = false;
    String? banner;
    final service = HybridAudioService(
      voiceProbe: (_) async {
        called = true;
        return true;
      },
      speechPlayback: (_, __) async {
        called = true;
        return true;
      },
    );
    final played = await service.play(
      text: 'test',
      languageCode: 'xx-XX',
      ipa: 'tɛst',
      onUnavailable: (message) => banner = message,
    );
    expect(played, isFalse);
    expect(called, isFalse);
    expect(banner, contains('Pronounce using IPA: /tɛst/'));
  });

  test('registered but missing voice displays IPA without synthesis', () async {
    var spoken = false;
    String? banner;
    final service = HybridAudioService(
      voiceProbe: (_) async => false,
      speechPlayback: (_, __) async {
        spoken = true;
        return true;
      },
    );
    expect(
      await service.play(
        text: 'Hallo',
        languageCode: 'de',
        ipa: 'halo',
        onUnavailable: (message) => banner = message,
      ),
      isFalse,
    );
    expect(spoken, isFalse);
    expect(banner, contains('Audio not available'));
  });

  test(
      'screen-facing playAudio uses the selected language and exposes IPA fallback',
      () async {
    String? message;
    String? locale;
    final unavailable = HybridAudioService(
      voiceProbe: (_) async => false,
      speechPlayback: (text, tag) async => throw StateError('must not speak'),
    );
    expect(
        await unavailable.playAudio(
          text: 'Merhaba',
          languageCode: 'tr',
          ipa: 'mɛɾhaba',
          onUnavailable: (text) => message = text,
        ),
        isFalse);
    expect(message, contains('/mɛɾhaba/'));
    final available = HybridAudioService(
      voiceProbe: (_) async => true,
      speechPlayback: (_, tag) async {
        locale = tag;
        return true;
      },
    );
    expect(
        await available.playAudio(text: 'Bonjour', languageCode: 'fr'), isTrue);
    expect(locale, 'fr-FR');
  });

  test('platform probe timeouts do not block the interface', () async {
    final hung = Completer<bool>();
    final service = HybridAudioService(
      voiceProbe: (_) => hung.future,
      voiceTimeout: const Duration(milliseconds: 10),
    );
    expect(await service.play(text: 'Bonjour', languageCode: 'fr'), isFalse);
  });

  test('offline voice can speak in the requested BCP-47 locale', () async {
    String? selectedLocale;
    final service = HybridAudioService(
      voiceProbe: (_) async => true,
      speechPlayback: (_, locale) async {
        selectedLocale = locale;
        return true;
      },
    );
    expect(await service.play(text: 'Hallo', languageCode: 'de'), isTrue);
    expect(selectedLocale, 'de-DE');
  });

  testWidgets('missing voice presents a non-blocking floating banner',
      (tester) async {
    final service = HybridAudioService(voiceProbe: (_) async => false);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              unawaited(service.play(
                context: context,
                text: 'Haus',
                languageCode: 'de',
                ipa: 'haʊs',
              ));
            },
            child: const Text('Speak'),
          );
        }),
      ),
    ));
    await tester.tap(find.text('Speak'));
    await tester.pump();
    expect(find.textContaining('Pronounce using IPA: /haʊs/'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
