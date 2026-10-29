import 'dart:async';

import '../orchestration/orchestration.dart';
import 'l10n.dart';

Future<void> main() async {
  final loader = L10nBundleLoader(
    readText: (assetPath) async {
      if (assetPath == 'assets/l10n/it.json') {
        return '{"locale":"it","strings":{"nav.home":"Home"}}';
      }
      throw StateError('Unexpected localization asset: $assetPath');
    },
  );
  final italian = await loader.load(
    assetPath: 'assets/l10n/it.json',
    format: L10nSourceFormat.json,
  );
  _expect(italian.locale.languageTag, 'it', 'bundle loader locale');
  _expect(italian.require('nav.home').template, 'Home', 'bundle loader content');

  final arabic = L10nDictionaryCodec.decodeArb(
    '''
{
  "@@locale": "ar-JO",
  "nav.home": "الرئيسية",
  "welcome.user": "مرحباً {name}",
  "@welcome.user": {
    "description": "Personalized welcome",
    "placeholders": {
      "name": {"type": "String", "example": "سليم"}
    }
  }
}
''',
  );
  final german = L10nDictionaryCodec.decodeJson(
    '''
{
  "locale": "de-DE",
  "strings": {
    "nav.home": "Start",
    "welcome.user": "Hallo {name}"
  }
}
''',
  );
  final english = L10nDictionaryCodec.decodeJson(
    '''
{
  "locale": "en",
  "strings": {
    "nav.home": "Home",
    "fallback.only": "Fallback value"
  }
}
''',
  );

  _expect(arabic.locale.languageTag, 'ar-JO', 'ARB locale parsing');
  _expect(arabic.messages.length, 2, 'ARB metadata is not a UI message');
  _expect(
    arabic.require('welcome.user').placeholders.contains('name'),
    true,
    'ARB placeholders are modeled',
  );

  final engine = DynamicL10nEngine(
    initialState: LocalizationState.fromLanguageTags(
      userLanguageTag: 'ar-JO',
      sourceLanguageTag: 'ar',
      targetLanguageTag: 'de-DE',
    ),
    fallbackLanguageTag: 'en',
    dictionaries: <L10nDictionary>[arabic, german, english],
  );

  _expect(engine.snapshot.userLocale.languageTag, 'ar-JO', 'initial UI locale');
  _expect(engine.snapshot.isRtl, true, 'Arabic UI resolves RTL');
  _expect(engine.text('nav.home'), 'الرئيسية', 'exact locale lookup');
  _expect(
    engine.text('welcome.user', arguments: const <String, Object?>{'name': 'سليم'}),
    'مرحباً سليم',
    'placeholder interpolation',
  );
  _expect(
    engine.text('fallback.only'),
    'Fallback value',
    'fallback dictionary lookup',
  );
  _expect(engine.text('missing.key'), 'missing.key', 'missing key fallback');

  final beforePair = engine.snapshot;
  engine.setUserLanguage('de-DE');
  _expect(engine.snapshot.userLocale.languageTag, 'de-DE', 'UI locale switch');
  _expect(engine.snapshot.isRtl, false, 'German UI resolves LTR');
  _expect(
    engine.snapshot.sourceLocale.languageTag,
    beforePair.sourceLocale.languageTag,
    'UI locale does not mutate source language',
  );
  _expect(
    engine.snapshot.targetLocale.languageTag,
    beforePair.targetLocale.languageTag,
    'UI locale does not mutate target language',
  );

  engine.setLearningPair(sourceLanguageTag: 'de-DE', targetLanguageTag: 'ar');
  _expect(engine.snapshot.userLocale.languageTag, 'de-DE', 'pair keeps UI locale');
  _expect(engine.snapshot.sourceLocale.languageTag, 'de-DE', 'source changes');
  _expect(engine.snapshot.targetLocale.languageTag, 'ar', 'target changes');

  var missingPlaceholderRejected = false;
  try {
    arabic.require('welcome.user').render();
  } on FormatException {
    missingPlaceholderRejected = true;
  }
  _expect(
    missingPlaceholderRejected,
    true,
    'missing placeholder arguments are rejected',
  );

  final batchRevision = engine.snapshot.revision;
  engine.registerAll(
    <L10nDictionary>[
      L10nDictionaryCodec.decodeJson(
        '{"locale":"fr","strings":{"nav.home":"Accueil"}}',
      ),
      L10nDictionaryCodec.decodeJson(
        '{"locale":"es","strings":{"nav.home":"Inicio"}}',
      ),
    ],
  );
  _expect(
    engine.snapshot.revision,
    batchRevision + 1,
    'dictionary batch produces one localization revision',
  );
  _expect(
    engine.snapshot.loadedLocales.containsAll(<String>{'fr', 'es'}),
    true,
    'dictionary batch registers every locale',
  );

  final bus = AgentEventBus.isolated();
  final kernel = OrchestrationKernel(
    eventBus: bus,
    services: ServiceContainer(),
  );
  final localizationEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'l10n.runtime',
      role: AgentRole.localization,
      subscriptions: const <String>{
        AgentTopics.localizationChangeRequested,
      },
    ),
  );
  final designEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'l10n.design-observer',
      role: AgentRole.design,
      subscriptions: const <String>{
        AgentTopics.localizationChanged,
      },
    ),
  );
  final routingEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'l10n.routing-observer',
      role: AgentRole.routing,
      subscriptions: const <String>{
        AgentTopics.localizationChanged,
      },
    ),
  );
  final recoveryEndpoint = kernel.connect(
    AgentDescriptor(
      id: 'l10n.recovery-observer',
      role: AgentRole.recovery,
      subscriptions: const <String>{AgentTopics.systemError},
    ),
  );
  final requester = kernel.connect(
    AgentDescriptor(
      id: 'l10n.requester',
      role: AgentRole.task,
      subscriptions: const <String>{AgentTopics.contextUpdated},
    ),
  );

  final bridge = L10nEventBridge(
    engine: engine,
    endpoint: localizationEndpoint,
  );

  final designEvent = Completer<AgentEvent>();
  final routingEvent = Completer<AgentEvent>();
  final designSub = designEndpoint
      .events(AgentTopics.localizationChanged)
      .listen((event) {
    if (!designEvent.isCompleted) designEvent.complete(event);
  });
  final routingSub = routingEndpoint
      .events(AgentTopics.localizationChanged)
      .listen((event) {
    if (!routingEvent.isCompleted) routingEvent.complete(event);
  });

  requester.publish(
    topic: AgentTopics.localizationChangeRequested,
    targetRoles: const <AgentRole>{AgentRole.localization},
    context: AgentContextSnapshot.empty('l10n-change-1'),
    payload: const <String, Object?>{
      'userLocale': 'ar-JO',
    },
  );

  final designChanged = await designEvent.future.timeout(
    const Duration(seconds: 1),
  );
  final routingChanged = await routingEvent.future.timeout(
    const Duration(seconds: 1),
  );

  _expect(
    designChanged.payload['userLocale'],
    'ar-JO',
    'design receives changed UI locale',
  );
  _expect(
    designChanged.payload['direction'],
    'rtl',
    'design receives RTL direction immediately',
  );
  _expect(
    routingChanged.payload['revision'],
    designChanged.payload['revision'],
    'routing and design observe the same localization revision',
  );
  _expect(engine.snapshot.isRtl, true, 'event request mutates central state');

  final recoveryEvent = Completer<AgentEvent>();
  final recoverySub = recoveryEndpoint
      .events(AgentTopics.systemError)
      .listen((event) {
    if (!recoveryEvent.isCompleted) recoveryEvent.complete(event);
  });
  requester.publish(
    topic: AgentTopics.localizationChangeRequested,
    targetRoles: const <AgentRole>{AgentRole.localization},
    context: AgentContextSnapshot.empty('l10n-invalid-1'),
    payload: const <String, Object?>{
      'sourceLocale': 'de-DE',
    },
  );
  final invalidRequest = await recoveryEvent.future.timeout(
    const Duration(seconds: 1),
  );
  _expect(
    invalidRequest.payload['fatal'],
    false,
    'malformed language request fails safe',
  );
  _expect(
    invalidRequest.payload['context'],
    'l10n.change_request',
    'malformed request is identified to recovery',
  );

  await recoverySub.cancel();
  await designSub.cancel();
  await routingSub.cancel();
  await bridge.close();
  await kernel.close();
  await engine.close();

  _expect(bus.isClosed, true, 'isolated localization bus closes');
}

void _expect(Object? actual, Object? expected, String contract) {
  if (actual != expected) {
    throw StateError(
      'Contract failed: $contract. Expected <$expected>, got <$actual>.',
    );
  }
}
