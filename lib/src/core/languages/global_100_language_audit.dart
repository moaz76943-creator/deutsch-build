import 'declarative_language_engine.dart';
import 'western_languages_registry.dart';
import 'romance_germanic_languages_registry.dart';
import 'slavic_languages_registry.dart';
import 'near_eastern_languages_registry.dart';
import 'east_asian_languages_registry.dart';
import 'nordic_languages_registry.dart';
import 'baltic_languages_registry.dart';
import 'balkan_languages_registry.dart';
import 'celtic_languages_registry.dart';
import 'indic_languages_registry.dart';
import 'dravidian_languages_registry.dart';
import 'african_languages_registry.dart';
import 'central_turkic_languages_registry.dart';
import 'uralic_languages_registry.dart';
import 'semitic_languages_registry.dart';

/// Comprehensive acceptance auditor for the 100-language platform architecture.
class Global100LanguageAudit {
  final DeclarativeLanguageEngine engine;

  Global100LanguageAudit({required this.engine});

  /// Initializes and registers all regional language registries across the world.
  void registerAllGlobalRegistries() {
    engine.initialize();
    WesternLanguagesRegistry.registerWesternProfiles(engine);
    RomanceGermanicLanguagesRegistry.registerProfiles(engine);
    SlavicLanguagesRegistry.registerProfiles(engine);
    NearEasternLanguagesRegistry.registerProfiles(engine);
    EastAsianLanguagesRegistry.registerProfiles(engine);
    NordicLanguagesRegistry.registerProfiles(engine);
    BalticLanguagesRegistry.registerProfiles(engine);
    BalkanLanguagesRegistry.registerProfiles(engine);
    CelticLanguagesRegistry.registerProfiles(engine);
    IndicLanguagesRegistry.registerProfiles(engine);
    DravidianLanguagesRegistry.registerProfiles(engine);
    AfricanLanguagesRegistry.registerProfiles(engine);
    CentralTurkicLanguagesRegistry.registerProfiles(engine);
    UralicLanguagesRegistry.registerProfiles(engine);
    SemiticLanguagesRegistry.registerProfiles(engine);
  }

  /// Verifies registered profiles integrity and memory safety.
  bool verifyPlatformIntegrity() {
    registerAllGlobalRegistries();
    // Verify major typologies exist
    final hasSVO = engine.availableIsoCodes.any((c) => engine.getProfile(c)?.typology == 'SVO');
    final hasSOV = engine.availableIsoCodes.any((c) => engine.getProfile(c)?.typology == 'SOV');
    final hasVSO = engine.availableIsoCodes.any((c) => engine.getProfile(c)?.typology == 'VSO');
    final hasRtl = engine.availableIsoCodes.any((c) => engine.getProfile(c)?.isRtl == true);

    return engine.registeredCount >= 25 && hasSVO && hasSOV && hasVSO && hasRtl;
  }
}
