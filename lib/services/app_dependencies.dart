import 'grammar_hub_service.dart';
import '../features/life_supermarket_groceries/supermarket_master_orchestrator.dart';
import 'active_pack_runtime_provider.dart';
import 'pack_manager_service.dart';
export 'verb_index.dart' show VerbIndex;
import '../core/content_contract.dart';
import '../language/language_pack.dart';
import '../language/german/german_word_family_repository.dart';
import '../features/audio/domain/services/i_audio_runtime.dart';
import '../features/pronunciation/domain/services/pronunciation_signal_probe.dart';
import '../features/error_pattern_agent/application/error_pattern_agent_notifier.dart';
import '../features/gamification/gamification_repository.dart';
import '../features/app_settings/application/settings_controller.dart';
import '../features/life_doctor_appointment/application/doctor_appointment_master_orchestrator.dart';
import 'search_index.dart';
import 'ai_gateway.dart';
import 'verb_index.dart';
import 'privacy_settings.dart';
import 'neuro_accessibility_settings.dart';
import 'user_vocabulary_service.dart';
import 'preferences_service.dart';
import '../features/life_furniture_home_setup/furniture_home_module.dart';
import '../features/life_postal_delivery/postal_master_orchestrator.dart';

import '../features/life_restaurant_dining/restaurant_master_orchestrator.dart';
import '../features/life_haircut_barbershop/application/haircut_master_orchestrator.dart';

/// Composition-root dependencies shared by the application surface.
/// Concrete language models remain outside this shared dependency contract.
final class AppDependencies<T extends LearningContent> {
  const AppDependencies({
    required this.searchIndex,
    required this.verbIndex,
    required this.corpus,
    required this.languagePack,
    required this.aiGateway,
    required this.privacySettings,
    required this.neuroSettings,
    required this.userVocabularyService,
    required this.favoritesRepository,
    required this.preferencesService,
    required this.grammarHubService,
    this.supermarketGroceriesModule = const SupermarketGroceriesModule(),
    this.settingsController = const UnavailableSettingsController(),
    this.gamificationRepository = const UnavailableGamificationRepository(),
    this.audioRuntime = const UnavailableAudioRuntime(),
    this.sourceAudioRuntime = const UnavailableAudioRuntime(),
    this.pronunciationSignalProbe = const UnavailablePronunciationSignalProbe(),
    this.wordFamilyRepository = const EmptyGermanWordFamilyRepository(),
    this.packManagerService,
    this.errorPatternAgent,
    this.furnitureHomeSetupModule = const FurnitureHomeSetupModule(),
    this.postalDeliveryModule = const PostalDeliveryModule(),
    this.restaurantDiningFactory = const RestaurantDiningDependencyFactory(),
    this.haircutBarbershopModule = const HaircutBarbershopModule(),
    this.runtimePackState = const RuntimePackState.embeddedFallback(),
    this.doctorAppointmentOrchestrator =
        const DoctorAppointmentMasterOrchestrator(),
  });

  final SearchIndex<T> searchIndex;
  final VerbIndex verbIndex;
  final List<T> corpus;
  final LanguagePack languagePack;
  final AiGateway aiGateway;
  final PrivacySettingsStore privacySettings;
  final NeuroAccessibilitySettings neuroSettings;
  final UserVocabularyService userVocabularyService;
  final FavoritesRepository favoritesRepository;
  final PreferencesService preferencesService;
  final GrammarHubRepository grammarHubService;
  final SupermarketGroceriesModule supermarketGroceriesModule;
  final SettingsController settingsController;
  final GamificationRepository gamificationRepository;
  final IAudioRuntime audioRuntime;
  final IAudioRuntime sourceAudioRuntime;
  final PronunciationSignalProbe pronunciationSignalProbe;
  final GermanWordFamilyRepository wordFamilyRepository;
  final PackManagerService? packManagerService;
  final ErrorPatternAgentNotifier? errorPatternAgent;
  final FurnitureHomeSetupModule furnitureHomeSetupModule;
  final PostalDeliveryModule postalDeliveryModule;
  final RestaurantDiningDependencyFactory restaurantDiningFactory;
  final HaircutBarbershopModule haircutBarbershopModule;
  final RuntimePackState runtimePackState;
  final DoctorAppointmentMasterOrchestrator doctorAppointmentOrchestrator;
}
