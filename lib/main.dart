import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'services/repository.dart';
import 'models/content.dart';
import 'services/authentication.dart';
import 'services/backend_transport.dart';
import 'services/backend_transport_factory.dart';
import 'services/ai_gateway_factory.dart';
import 'models/backend_runtime_config.dart';
import 'models/account_session.dart';
import 'models/ai_runtime_config.dart';
import 'models/pack_security_runtime_config.dart';
import 'services/authentication_providers.dart';
import 'services/auth_session_controller.dart';
import 'services/android_secure_session_storage.dart';
import 'services/app_dependencies.dart';
import 'services/search_index.dart';
import 'services/preferences_service.dart';
import 'services/learner_persistence.dart';
import 'services/privacy_settings.dart';
import 'services/neuro_accessibility_settings.dart';
import 'services/user_vocabulary_service.dart';
import 'services/grammar_hub_service.dart';
import 'services/pack_manager_service.dart';
import 'services/active_pack_runtime_provider.dart';
import 'services/pack_database_key_store.dart';
import 'services/pack_database_security.dart';
import 'services/open_source_license_registry.dart';
import 'services/tts_service.dart';
import 'services/runtime_failure_reporter.dart';
import 'features/audio/data/android_recorded_audio_player.dart';
import 'features/audio/data/audio_manifest_catalog.dart';
import 'features/audio/offline_audio_runtime.dart';
import 'features/pronunciation/data/android_pronunciation_signal_probe.dart';
import 'features/gamification/sqlite_gamification_repository.dart';
import 'ui_v35/app.dart';
import 'language/german/german_language_pack.dart';
import 'language/arabic/arabic_speech_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerProjectOpenSourceLicenses();
  const runtimeFailureReporter = NoopRuntimeFailureReporter();
  FlutterError.onError = (FlutterErrorDetails details) {
    runtimeFailureReporter.recordFlutterError(details);
    if (!kReleaseMode) {
      FlutterError.presentError(details);
    }
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.error_outline, size: 48),
            SizedBox(height: 12),
            Text('حدث خطأ غير متوقع'),
            SizedBox(height: 6),
            Text(
              'يمكنك العودة أو إعادة فتح التطبيق. لم نعرض تفاصيل الخطأ الحساسة.',
            ),
          ],
        ),
      ),
    ),
  );
  await runZonedGuarded(
    () async {
      try {
        final prefs = await PreferencesService.instance();
        final persistence = LearnerPersistence(
          prefs,
          LearnerRepository.key,
          LearnerRepository.legacyFavoriteKey,
        );
        final databaseRoot = await getDatabasesPath();
        final gamificationRepository =
            await SqliteGamificationRepository.open(
              p.join(databaseRoot, 'gamification_v1.db'),
            );
        final repo = LearnerRepository(
          prefs,
          persistence: persistence,
          gamificationReviewSink: gamificationRepository,
        );
        final languagePack = const GermanLanguagePack();
        final packSecurity = PackSecurityRuntimeConfig.fromEnvironment();
        final manifestVerifier = PackManifestVerifiers.fromSingleBase64Key(
          keyId: packSecurity.manifestKeyId,
          publicKeyBase64: packSecurity.manifestPublicKeyBase64,
        );
        final packDatabaseKeyStore =
            AndroidKeystorePackDatabaseKeyStore();
        const packDatabaseSecurity = SqlCipherPackDatabaseSecurity();
        final packManager = PackManagerService(
          prefs,
          manifestVerifier: manifestVerifier,
          databaseKeyStore: packDatabaseKeyStore,
          databaseCipher: packDatabaseSecurity,
          rootDirectory: Directory(
            p.join(databaseRoot, 'offline_language_packs'),
          ),
        );
        final runtime = await ActivePackRuntimeProvider(
          packManager: packManager,
          languagePack: languagePack,
          embeddedGrammar: GrammarHubService(),
          databaseKeyStore: packDatabaseKeyStore,
          databaseOpener: packDatabaseSecurity,
        ).resolve();
        final activeLanguagePack = runtime.languagePack;
        AudioManifestCatalog audioCatalog;
        try {
          audioCatalog = AudioManifestCatalog.parse(
            await rootBundle.loadString(
              'content/german/audio_manifest.json',
            ),
          );
        } on Object {
          audioCatalog = AudioManifestCatalog.empty();
        }
        final audioRuntime = OfflineAudioRuntime(
          speechProfile: activeLanguagePack.speechProfile,
          ttsEngine: FlutterOfflineTtsEngine(),
          catalog: audioCatalog,
          recordedPlayer: AndroidRecordedAudioPlayer(),
        );
        final sourceAudioRuntime = OfflineAudioRuntime(
          speechProfile: const ArabicSpeechProfile(),
          ttsEngine: FlutterOfflineTtsEngine(),
        );
        final contentPack = activeLanguagePack.contentPack;
        final corpus = contentPack.items;
        final verbIndex = contentPack.verbIndex;
        final searchIndex = SearchIndex(
          corpus,
          verbIndex,
          activeLanguagePack.textNormalizer,
        );
        final dependencies = AppDependencies<ContentItem>(
          grammarHubService: runtime.grammarHubService,
          gamificationRepository: gamificationRepository,
          audioRuntime: audioRuntime,
          sourceAudioRuntime: sourceAudioRuntime,
          pronunciationSignalProbe: const AndroidPronunciationSignalProbe(),
          wordFamilyRepository: runtime.wordFamilyRepository,
          packManagerService: packManager,
          runtimePackState: runtime.state,
          searchIndex: searchIndex,
          verbIndex: verbIndex,
          corpus: corpus,
          languagePack: activeLanguagePack,
          aiGateway: AiGatewayFactory.fromRuntimeConfig(
            AiRuntimeConfig.fromEnvironment(),
          ),
          privacySettings: LocalPrivacySettingsStore(prefs),
          neuroSettings: NeuroAccessibilitySettings(prefs),
          userVocabularyService: UserVocabularyService.instance,
          favoritesRepository: FavoritesRepository.instance,
          preferencesService: prefs,
        );
        final config = BackendRuntimeConfig.fromEnvironment();
        final BackendTransport transport =
            BackendTransportFactory.fromRuntimeConfig(config);
        final secureSessionStorage = AndroidSecureSessionStorage();
        final auth = AuthSessionController(
          ProviderAuthenticationService(
            emailOtpProvider: const UnavailableEmailOtpProvider(),
            backendGateway: TransportBackendAuthenticationGateway(
              transport,
              secureSessionStorage: secureSessionStorage,
            ),
            secureSessionStorage: secureSessionStorage,
            googleProvider: const UnavailableSocialAuthenticationProvider(
              AccountProvider.google,
            ),
            appleProvider: const UnavailableSocialAuthenticationProvider(
              AccountProvider.apple,
            ),
          ),
        );
        await auth.initialize();
        runApp(DeutschAppV35(repo, auth: auth, dependencies: dependencies));
      } catch (error, stack) {
        runtimeFailureReporter.record(
          error,
          stack,
          fatal: true,
          context: 'bootstrap',
        );
        runApp(const _BootFailureApp());
      }
    },
    (error, stack) {
      runtimeFailureReporter.record(
        error,
        stack,
        fatal: true,
        context: 'root_zone',
      );
    },
  );
}

class _BootFailureApp extends StatelessWidget {
  const _BootFailureApp();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(title: const Text('Deutsch بالعربي')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.error_outline, size: 48),
              SizedBox(height: 12),
              Text('تعذر فتح التخزين المحلي بأمان. لم يتم فقدان بياناتك.'),
              SizedBox(height: 8),
              Text(
                'أغلق التطبيق وأعد فتحه. إذا استمرت المشكلة، تحقق من مساحة التخزين.',
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
