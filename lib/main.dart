import 'dart:async';
import 'package:flutter/material.dart';
import 'services/repository.dart';
import 'models/content.dart';
import 'services/authentication.dart';
import 'services/backend_transport.dart';
import 'services/backend_transport_factory.dart';
import 'services/ai_gateway_factory.dart';
import 'models/backend_runtime_config.dart';
import 'models/account_session.dart';
import 'models/ai_runtime_config.dart';
import 'services/authentication_providers.dart';
import 'services/auth_session_controller.dart';
import 'services/android_secure_session_storage.dart';
import 'services/app_dependencies.dart';
import 'services/search_index.dart';
import 'services/preferences_service.dart';
import 'services/learner_persistence.dart';
import 'services/privacy_settings.dart';
import 'ui_v35/app.dart';
import 'language/german/german_language_pack.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  ErrorWidget.builder = (FlutterErrorDetails details) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.error_outline, size: 48),
          SizedBox(height: 12),
          Text('حدث خطأ غير متوقع'),
          SizedBox(height: 6),
          Text('يمكنك العودة أو إعادة فتح التطبيق. لم نعرض تفاصيل الخطأ الحساسة.'),
        ]),
      ),
    ),
  );
  await runZonedGuarded(() async {
    try {
      final prefs = await PreferencesService.instance();
      final persistence = LearnerPersistence(prefs, LearnerRepository.key, LearnerRepository.legacyFavoriteKey);
      final repo = LearnerRepository(prefs, persistence: persistence);
      final languagePack = const GermanLanguagePack();
      final contentPack = languagePack.contentPack;
      final corpus = contentPack.items;
      final verbIndex = contentPack.verbIndex;
      final searchIndex = SearchIndex(corpus, verbIndex, languagePack.textNormalizer);
      final dependencies = AppDependencies<ContentItem>(
        searchIndex: searchIndex,
        verbIndex: verbIndex,
        corpus: corpus,
        languagePack: languagePack,
        aiGateway: AiGatewayFactory.fromRuntimeConfig(AiRuntimeConfig.fromEnvironment()),
        privacySettings: LocalPrivacySettingsStore(prefs),
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
          googleProvider: const UnavailableSocialAuthenticationProvider(AccountProvider.google),
          appleProvider: const UnavailableSocialAuthenticationProvider(AccountProvider.apple),
        ),
      );
      await auth.initialize();
      runApp(DeutschAppV35(repo, auth: auth, dependencies: dependencies));
    } catch (_) {
      runApp(const _BootFailureApp());
    }
  }, (error, stack) {
    // Last-resort containment for uncaught async/plugin errors.
    // Never throw from the error handler itself.
  });
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
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.error_outline, size: 48),
            SizedBox(height: 12),
            Text('تعذر فتح التخزين المحلي بأمان. لم يتم فقدان بياناتك.'),
            SizedBox(height: 8),
            Text('أغلق التطبيق وأعد فتحه. إذا استمرت المشكلة، تحقق من مساحة التخزين.'),
          ]),
        ),
      ),
    ),
  );
}
