import 'dart:async';

import '../../core/agents/polyglot_agent_models.dart';
import '../../core/curriculum/advanced_vocabulary.dart';
import '../../core/orchestration/orchestration.dart';
import 'life_curriculum_catalog.dart';
import 'life_feature_runtime.dart';
import 'production_agent_runtime.dart';

Future<void> main() async {
  final bus = AgentEventBus.isolated();
  final observerKernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final localization = observerKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.localization',
      role: AgentRole.localization,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );
  final voice = observerKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.voice',
      role: AgentRole.voice,
      subscriptions: const <String>{AgentTopics.ttsRequest},
    ),
  );
  final grammar = observerKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.grammar',
      role: AgentRole.grammar,
      subscriptions: const <String>{AgentTopics.grammarRequest},
    ),
  );

  final featureRuntime = LifeFeatureRuntime.isolated(
    eventBus: bus,
    initialUserLanguageTag: 'ar',
    initialSourceLanguageTag: 'ar',
    initialTargetLanguageTag: 'de',
  );

  final voiceSub = voice.events(AgentTopics.ttsRequest).listen((event) {
    voice.publish(
      topic: AgentTopics.ttsPrepared,
      targetRoles: const <AgentRole>{AgentRole.task},
      context: event.context,
      payload: <String, Object?>{
        'accepted': true,
        'text': event.payload['text'] as String,
        'targetLanguage': event.payload['targetLanguage'] as String,
        'speed': event.payload['speed'] as num,
        'backend': 'contract',
        'providerReady': true,
      },
    );
  });
  final grammarSub =
      grammar.events(AgentTopics.grammarRequest).listen((event) {
    grammar.publish(
      topic: AgentTopics.grammarResponse,
      targetRoles: const <AgentRole>{AgentRole.task},
      context: event.context,
      payload: <String, Object?>{
        'ok': true,
        'capability': event.payload['capability'] as String,
        'targetLanguage': 'de',
        'engineId': 'contract.german',
        'items': const <Object?>[],
      },
    );
  });

  localization.publish(
    topic: AgentTopics.localizationChanged,
    targetRoles: const <AgentRole>{
      AgentRole.design,
      AgentRole.routing,
    },
    context: AgentContextSnapshot.empty('phase7-l10n-1'),
    payload: const <String, Object?>{
      'revision': 12,
      'userLocale': 'en',
      'sourceLocale': 'ar',
      'targetLocale': 'de',
      'direction': 'ltr',
      'isRtl': false,
      'loadedLocales': <String>['ar', 'de', 'en'],
    },
  );

  await Future<void>.delayed(Duration.zero);
  _expect(
    featureRuntime.snapshot.userLocale.languageCode,
    'en',
    'feature runtime follows localization.changed UI locale',
  );
  _expect(
    featureRuntime.snapshot.sourceLocale.languageCode,
    'ar',
    'feature runtime keeps explicit source locale',
  );
  _expect(
    featureRuntime.snapshot.targetLocale.languageCode,
    'de',
    'feature runtime keeps explicit target locale',
  );

  final localized = featureRuntime.resolveUiLiteral(
    'Fahrrad & Mobilität',
  );
  _expect(
    localized,
    'Fahrrad & Mobilität',
    'literal rendering is resolved through DynamicL10nEngine fallback',
  );

  final speech = await featureRuntime.requestSpeech(
    text: 'Guten Morgen',
    languageTag: 'de',
    speed: 0.85,
  );
  _expect(speech.accepted, true, 'target-side TTS request succeeds');
  _expect(speech.targetLanguageTag, 'de', 'TTS target is explicit');
  _expect(speech.speed, 0.85, 'TTS speed is preserved');

  final grammarResult = await featureRuntime.requestGrammar(
    capability: UniversalGrammarCapability.konjunktivIi,
    seed: 3,
    count: 2,
  );
  _expect(grammarResult.ok, true, 'grammar query uses event route');
  _expect(
    grammarResult.engineId,
    'contract.german',
    'grammar response comes from event-stream agent',
  );

  await featureRuntime.close();
  await grammarSub.cancel();
  await voiceSub.cancel();
  await observerKernel.close();

  final catalog = LifeCurriculumCatalog.standard();
  _expect(catalog.links.length, 50, 'all fifty life tasks remain registered');

  final runtime = Phase3AgentRuntime.start(
    catalog: catalog,
    decks: VocabularyProjectionDeckRegistry(
      <String, List<VocabularyFlashcardProjection>>{
        'contract': const <VocabularyFlashcardProjection>[],
      },
    ),
  );
  final appBus = AgentEventBus();
  final appKernel = OrchestrationKernel(
    eventBus: appBus,
    services: ServiceContainer(),
  );
  final appLocalization = appKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.app-localization',
      role: AgentRole.localization,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );
  final appVoice = appKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.app-voice',
      role: AgentRole.voice,
      subscriptions: const <String>{AgentTopics.ttsRequest},
    ),
  );
  final appGrammar = appKernel.connect(
    AgentDescriptor(
      id: 'phase7.contract.app-grammar',
      role: AgentRole.grammar,
      subscriptions: const <String>{AgentTopics.grammarRequest},
    ),
  );
  final appVoiceSub = appVoice
      .events(AgentTopics.ttsRequest)
      .listen((event) {
    appVoice.publish(
      topic: AgentTopics.ttsPrepared,
      targetRoles: const <AgentRole>{AgentRole.system},
      context: event.context,
      payload: <String, Object?>{
        'accepted': true,
        'text': event.payload['text'] as String,
        'targetLanguage': event.payload['targetLanguage'] as String,
        'speed': event.payload['speed'] as num,
        'backend': 'phase3-contract',
        'providerReady': true,
      },
    );
  });
  final appGrammarSub = appGrammar
      .events(AgentTopics.grammarRequest)
      .listen((event) {
    appGrammar.publish(
      topic: AgentTopics.grammarResponse,
      targetRoles: const <AgentRole>{AgentRole.system},
      context: event.context,
      payload: <String, Object?>{
        'ok': true,
        'capability': event.payload['capability'] as String,
        'targetLanguage': 'ar',
        'engineId': 'phase3-contract.grammar',
        'items': const <Object?>[],
      },
    );
  });

  appLocalization.publish(
    topic: AgentTopics.localizationChanged,
    targetRoles: const <AgentRole>{
      AgentRole.design,
      AgentRole.routing,
    },
    context: AgentContextSnapshot.empty('phase7-runtime-l10n'),
    payload: const <String, Object?>{
      'revision': 13,
      'userLocale': 'de',
      'sourceLocale': 'de',
      'targetLocale': 'ar',
      'direction': 'ltr',
      'isRtl': false,
      'loadedLocales': <String>['ar', 'de', 'en'],
    },
  );

  await Future<void>.delayed(Duration.zero);
  final design = await runtime.requestDesign();
  _expect(
    design.direction,
    'ltr',
    'original Phase3 design agent observes localization.changed',
  );
  final route = await runtime.requestRoute('life_bicycle_mobility');
  _expect(
    route.featureKey,
    'life_bicycle_mobility',
    'routing remains functional after localization subscription',
  );

  final phase3Speech = await runtime.requestSpeech(
    text: 'مرحبا',
    targetLanguageTag: 'ar',
    speed: 1.0,
  );
  _expect(
    phase3Speech.backend,
    'phase3-contract',
    'Phase3 TTS request returns through the event stream',
  );

  final phase3Grammar = await runtime.requestGrammar(
    capability: UniversalGrammarCapability.comparativeSuperlative,
    seed: 4,
    count: 1,
  );
  _expect(
    phase3Grammar.engineId,
    'phase3-contract.grammar',
    'Phase3 grammar request returns through the universal event route',
  );

  await runtime.close();
  await appGrammarSub.cancel();
  await appVoiceSub.cancel();
  await appKernel.close();
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: ' +
          contract +
          '. Expected <' +
          expected.toString() +
          '>, got <' +
          actual.toString() +
          '>.',
    );
  }
}
