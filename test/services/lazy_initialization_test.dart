import 'package:deutsch_bilarabi/core/audio/offline_audio_manager.dart';
import 'package:deutsch_bilarabi/main.dart';
import 'package:deutsch_bilarabi/providers/lazy_engine_providers.dart';
import 'package:deutsch_bilarabi/utils/agglutinative_suffix_stripper.dart';
import 'package:deutsch_bilarabi/providers/active_language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SpyLanguageStorage extends LanguagePackStorage {
  int manifestReads = 0;
  int integrityScans = 0;

  @override
  Future<String> fetchManifest() async {
    manifestReads++;
    return '{"languages":[{"code":"de","name":"German",'
        '"native_name":"Deutsch","is_active":true}]}';
  }

  @override
  Future<Set<String>> findInstalled(
    List<LanguagePackMetadata> packs,
  ) async {
    integrityScans++;
    return <String>{'de'};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('first app frame does not touch the pack catalog or filesystem',
      (tester) async {
    final storage = _SpyLanguageStorage();
    var linguisticAllocations = 0;
    await tester.pumpWidget(ProviderScope(
      overrides: <Override>[
        languagePackStorageProvider.overrideWith((ref) => storage),
        agglutinativeSuffixStripperProvider.overrideWith((ref) {
          linguisticAllocations++;
          return AgglutinativeSuffixStripper();
        }),
      ],
      child: const MyApp(),
    ));

    expect(find.byType(MyApp), findsOneWidget);
    expect(storage.manifestReads, 0);
    expect(storage.integrityScans, 0);
    expect(linguisticAllocations, 0);
    expect(OfflineAudioManager.instance.isAudioInitialized, isFalse);

    // The post-onboarding frame must not start storage work either.
    await tester.pump();
    expect(storage.manifestReads, 0);
    expect(storage.integrityScans, 0);

    final container = ProviderScope.containerOf(tester.element(find.byType(MyApp)));
    final suffix = container.read(agglutinativeSuffixStripperProvider);
    expect(suffix, isA<AgglutinativeSuffixStripper>());
    expect(linguisticAllocations, 1);
    await container.read(activeLanguageProvider.notifier).initialize();

    expect(storage.manifestReads, 1);
    expect(storage.integrityScans, 1);
    expect(OfflineAudioManager.instance.isAudioInitialized, isFalse);
  });

  test('audio engine is allocated only when a word is played', () async {
    var constructed = 0;
    final audio = OfflineAudioManager.forTesting(
      createTts: () {
        constructed++;
        return FlutterTts();
      },
    );
    await audio.stop();
    expect(constructed, 0);
    expect(audio.isAudioInitialized, isFalse);

    // On the test platform the voice plug-in may be unavailable. Playback
    // gracefully degrades, but the first request is the allocation boundary.
    await audio.speak('Hallo');
    expect(constructed, 1);
    expect(audio.isAudioInitialized, isTrue);
  });
}
