import '../domain/verb_models.dart';

List<VerbLexemeSpec> buildCommonVerbSeeds() => <VerbLexemeSpec>[
      _seed(
        'sein', 'يكون', VerbKind.irregular,
        'bin|bist|ist|sind|seid|sind',
        'war|warst|war|waren|wart|waren',
        PerfectAuxiliary.sein, 'gewesen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'haben', 'لديه / يملك', VerbKind.irregular,
        'habe|hast|hat|haben|habt|haben',
        'hatte|hattest|hatte|hatten|hattet|hatten',
        PerfectAuxiliary.haben, 'gehabt',
      ),
      _seed(
        'werden', 'يصبح', VerbKind.irregular,
        'werde|wirst|wird|werden|werdet|werden',
        'wurde|wurdest|wurde|wurden|wurdet|wurden',
        PerfectAuxiliary.sein, 'geworden',
        emphasis: const <String>['i'],
      ),
      _seed(
        'können', 'يستطيع', VerbKind.irregular,
        'kann|kannst|kann|können|könnt|können',
        'konnte|konntest|konnte|konnten|konntet|konnten',
        PerfectAuxiliary.haben, 'gekonnt',
      ),
      _seed(
        'müssen', 'يجب', VerbKind.irregular,
        'muss|musst|muss|müssen|müsst|müssen',
        'musste|musstest|musste|mussten|musstet|mussten',
        PerfectAuxiliary.haben, 'gemusst',
      ),
      _seed(
        'wollen', 'يريد', VerbKind.irregular,
        'will|willst|will|wollen|wollt|wollen',
        'wollte|wolltest|wollte|wollten|wolltet|wollten',
        PerfectAuxiliary.haben, 'gewollt',
      ),
      _seed(
        'sollen', 'ينبغي', VerbKind.irregular,
        'soll|sollst|soll|sollen|sollt|sollen',
        'sollte|solltest|sollte|sollten|solltet|sollten',
        PerfectAuxiliary.haben, 'gesollt',
      ),
      _seed(
        'dürfen', 'يُسمح له', VerbKind.irregular,
        'darf|darfst|darf|dürfen|dürft|dürfen',
        'durfte|durftest|durfte|durften|durftet|durften',
        PerfectAuxiliary.haben, 'gedurft',
      ),
      _seed(
        'mögen', 'يحب / يفضّل', VerbKind.irregular,
        'mag|magst|mag|mögen|mögt|mögen',
        'mochte|mochtest|mochte|mochten|mochtet|mochten',
        PerfectAuxiliary.haben, 'gemocht',
      ),
      _seed(
        'machen', 'يفعل / يصنع', VerbKind.regular,
        'mache|machst|macht|machen|macht|machen',
        'machte|machtest|machte|machten|machtet|machten',
        PerfectAuxiliary.haben, 'gemacht',
      ),
      _seed(
        'sagen', 'يقول', VerbKind.regular,
        'sage|sagst|sagt|sagen|sagt|sagen',
        'sagte|sagtest|sagte|sagten|sagtet|sagten',
        PerfectAuxiliary.haben, 'gesagt',
      ),
      _seed(
        'gehen', 'يذهب', VerbKind.irregular,
        'gehe|gehst|geht|gehen|geht|gehen',
        'ging|gingst|ging|gingen|gingt|gingen',
        PerfectAuxiliary.sein, 'gegangen',
      ),
      _seed(
        'kommen', 'يأتي', VerbKind.irregular,
        'komme|kommst|kommt|kommen|kommt|kommen',
        'kam|kamst|kam|kamen|kamt|kamen',
        PerfectAuxiliary.sein, 'gekommen',
      ),
      _seed(
        'sehen', 'يرى', VerbKind.irregular,
        'sehe|siehst|sieht|sehen|seht|sehen',
        'sah|sahst|sah|sahen|saht|sahen',
        PerfectAuxiliary.haben, 'gesehen',
        emphasis: const <String>['ie'],
      ),
      _seed(
        'geben', 'يعطي', VerbKind.irregular,
        'gebe|gibst|gibt|geben|gebt|geben',
        'gab|gabst|gab|gaben|gabt|gaben',
        PerfectAuxiliary.haben, 'gegeben',
        emphasis: const <String>['i'],
      ),
      _seed(
        'nehmen', 'يأخذ', VerbKind.irregular,
        'nehme|nimmst|nimmt|nehmen|nehmt|nehmen',
        'nahm|nahmst|nahm|nahmen|nahmt|nahmen',
        PerfectAuxiliary.haben, 'genommen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'finden', 'يجد', VerbKind.irregular,
        'finde|findest|findet|finden|findet|finden',
        'fand|fandest|fand|fanden|fandet|fanden',
        PerfectAuxiliary.haben, 'gefunden',
      ),
      _seed(
        'wissen', 'يعرف معلومة', VerbKind.irregular,
        'weiß|weißt|weiß|wissen|wisst|wissen',
        'wusste|wusstest|wusste|wussten|wusstet|wussten',
        PerfectAuxiliary.haben, 'gewusst',
      ),
      _seed(
        'denken', 'يفكر', VerbKind.irregular,
        'denke|denkst|denkt|denken|denkt|denken',
        'dachte|dachtest|dachte|dachten|dachtet|dachten',
        PerfectAuxiliary.haben, 'gedacht',
      ),
      _seed(
        'sprechen', 'يتحدث', VerbKind.irregular,
        'spreche|sprichst|spricht|sprechen|sprecht|sprechen',
        'sprach|sprachst|sprach|sprachen|spracht|sprachen',
        PerfectAuxiliary.haben, 'gesprochen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'fahren', 'يسافر / ينتقل بمركبة', VerbKind.irregular,
        'fahre|fährst|fährt|fahren|fahrt|fahren',
        'fuhr|fuhrst|fuhr|fuhren|fuhrt|fuhren',
        PerfectAuxiliary.sein, 'gefahren',
        emphasis: const <String>['ä'],
      ),
      _seed(
        'lesen', 'يقرأ', VerbKind.irregular,
        'lese|liest|liest|lesen|lest|lesen',
        'las|lasest|las|lasen|last|lasen',
        PerfectAuxiliary.haben, 'gelesen',
        emphasis: const <String>['ie'],
      ),
      _seed(
        'schreiben', 'يكتب', VerbKind.irregular,
        'schreibe|schreibst|schreibt|schreiben|schreibt|schreiben',
        'schrieb|schriebst|schrieb|schrieben|schriebt|schrieben',
        PerfectAuxiliary.haben, 'geschrieben',
      ),
      _seed(
        'essen', 'يأكل', VerbKind.irregular,
        'esse|isst|isst|essen|esst|essen',
        'aß|aßest|aß|aßen|aßt|aßen',
        PerfectAuxiliary.haben, 'gegessen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'trinken', 'يشرب', VerbKind.irregular,
        'trinke|trinkst|trinkt|trinken|trinkt|trinken',
        'trank|trankst|trank|tranken|trankt|tranken',
        PerfectAuxiliary.haben, 'getrunken',
      ),
      _seed(
        'schlafen', 'ينام', VerbKind.irregular,
        'schlafe|schläfst|schläft|schlafen|schlaft|schlafen',
        'schlief|schliefst|schlief|schliefen|schlieft|schliefen',
        PerfectAuxiliary.haben, 'geschlafen',
        emphasis: const <String>['ä'],
      ),
      _seed(
        'arbeiten', 'يعمل', VerbKind.regular,
        'arbeite|arbeitest|arbeitet|arbeiten|arbeitet|arbeiten',
        'arbeitete|arbeitetest|arbeitete|arbeiteten|arbeitetet|arbeiteten',
        PerfectAuxiliary.haben, 'gearbeitet',
      ),
      _seed(
        'lernen', 'يتعلم', VerbKind.regular,
        'lerne|lernst|lernt|lernen|lernt|lernen',
        'lernte|lerntest|lernte|lernten|lerntet|lernten',
        PerfectAuxiliary.haben, 'gelernt',
      ),
      _seed(
        'spielen', 'يلعب', VerbKind.regular,
        'spiele|spielst|spielt|spielen|spielt|spielen',
        'spielte|spieltest|spielte|spielten|spieltet|spielten',
        PerfectAuxiliary.haben, 'gespielt',
      ),
      _seed(
        'kaufen', 'يشتري', VerbKind.regular,
        'kaufe|kaufst|kauft|kaufen|kauft|kaufen',
        'kaufte|kauftest|kaufte|kauften|kauftet|kauften',
        PerfectAuxiliary.haben, 'gekauft',
      ),
      _seed(
        'brauchen', 'يحتاج', VerbKind.regular,
        'brauche|brauchst|braucht|brauchen|braucht|brauchen',
        'brauchte|brauchtest|brauchte|brauchten|brauchtet|brauchten',
        PerfectAuxiliary.haben, 'gebraucht',
      ),
      _seed(
        'fragen', 'يسأل', VerbKind.regular,
        'frage|fragst|fragt|fragen|fragt|fragen',
        'fragte|fragtest|fragte|fragten|fragtet|fragten',
        PerfectAuxiliary.haben, 'gefragt',
      ),
      _seed(
        'antworten', 'يجيب', VerbKind.regular,
        'antworte|antwortest|antwortet|antworten|antwortet|antworten',
        'antwortete|antwortetest|antwortete|antworteten|antwortetet|antworteten',
        PerfectAuxiliary.haben, 'geantwortet',
      ),
      _seed(
        'wohnen', 'يسكن', VerbKind.regular,
        'wohne|wohnst|wohnt|wohnen|wohnt|wohnen',
        'wohnte|wohntest|wohnte|wohnten|wohntet|wohnten',
        PerfectAuxiliary.haben, 'gewohnt',
      ),
      _seed(
        'leben', 'يعيش', VerbKind.regular,
        'lebe|lebst|lebt|leben|lebt|leben',
        'lebte|lebtest|lebte|lebten|lebtet|lebten',
        PerfectAuxiliary.haben, 'gelebt',
      ),
      _seed(
        'lieben', 'يحب', VerbKind.regular,
        'liebe|liebst|liebt|lieben|liebt|lieben',
        'liebte|liebtest|liebte|liebten|liebtet|liebten',
        PerfectAuxiliary.haben, 'geliebt',
      ),
      _seed(
        'helfen', 'يساعد', VerbKind.irregular,
        'helfe|hilfst|hilft|helfen|helft|helfen',
        'half|halfst|half|halfen|halft|halfen',
        PerfectAuxiliary.haben, 'geholfen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'bleiben', 'يبقى', VerbKind.irregular,
        'bleibe|bleibst|bleibt|bleiben|bleibt|bleiben',
        'blieb|bliebst|blieb|blieben|bliebt|blieben',
        PerfectAuxiliary.sein, 'geblieben',
      ),
      _seed(
        'bringen', 'يجلب', VerbKind.irregular,
        'bringe|bringst|bringt|bringen|bringt|bringen',
        'brachte|brachtest|brachte|brachten|brachtet|brachten',
        PerfectAuxiliary.haben, 'gebracht',
      ),
      _seed(
        'kennen', 'يعرف شخصًا / شيئًا', VerbKind.irregular,
        'kenne|kennst|kennt|kennen|kennt|kennen',
        'kannte|kanntest|kannte|kannten|kanntet|kannten',
        PerfectAuxiliary.haben, 'gekannt',
      ),
      _seed(
        'heißen', 'يُدعى', VerbKind.irregular,
        'heiße|heißt|heißt|heißen|heißt|heißen',
        'hieß|hießest|hieß|hießen|hießt|hießen',
        PerfectAuxiliary.haben, 'geheißen',
      ),
      _seed(
        'stehen', 'يقف', VerbKind.irregular,
        'stehe|stehst|steht|stehen|steht|stehen',
        'stand|standest|stand|standen|standet|standen',
        PerfectAuxiliary.haben, 'gestanden',
      ),
      _seed(
        'sitzen', 'يجلس', VerbKind.irregular,
        'sitze|sitzt|sitzt|sitzen|sitzt|sitzen',
        'saß|saßest|saß|saßen|saßt|saßen',
        PerfectAuxiliary.haben, 'gesessen',
      ),
      _seed(
        'liegen', 'يقع / يستلقي', VerbKind.irregular,
        'liege|liegst|liegt|liegen|liegt|liegen',
        'lag|lagst|lag|lagen|lagt|lagen',
        PerfectAuxiliary.haben, 'gelegen',
      ),
      _seed(
        'laufen', 'يركض / يمشي', VerbKind.irregular,
        'laufe|läufst|läuft|laufen|lauft|laufen',
        'lief|liefst|lief|liefen|lieft|liefen',
        PerfectAuxiliary.sein, 'gelaufen',
        emphasis: const <String>['äu'],
      ),
      _seed(
        'tragen', 'يحمل / يرتدي', VerbKind.irregular,
        'trage|trägst|trägt|tragen|tragt|tragen',
        'trug|trugst|trug|trugen|trugt|trugen',
        PerfectAuxiliary.haben, 'getragen',
        emphasis: const <String>['ä'],
      ),
      _seed(
        'treffen', 'يقابل', VerbKind.irregular,
        'treffe|triffst|trifft|treffen|trefft|treffen',
        'traf|trafst|traf|trafen|traft|trafen',
        PerfectAuxiliary.haben, 'getroffen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'vergessen', 'ينسى', VerbKind.irregular,
        'vergesse|vergisst|vergisst|vergessen|vergesst|vergessen',
        'vergaß|vergaßest|vergaß|vergaßen|vergaßt|vergaßen',
        PerfectAuxiliary.haben, 'vergessen',
        emphasis: const <String>['i'],
      ),
      _seed(
        'verstehen', 'يفهم', VerbKind.irregular,
        'verstehe|verstehst|versteht|verstehen|versteht|verstehen',
        'verstand|verstandest|verstand|verstanden|verstandet|verstanden',
        PerfectAuxiliary.haben, 'verstanden',
      ),
      _seed(
        'anfangen', 'يبدأ', VerbKind.separable,
        'fange an|fängst an|fängt an|fangen an|fangt an|fangen an',
        'fing an|fingst an|fing an|fingen an|fingt an|fingen an',
        PerfectAuxiliary.haben, 'angefangen',
        emphasis: const <String>['ä'],
      ),
    ];

VerbLexemeSpec _seed(
  String infinitive,
  String meaningAr,
  VerbKind kind,
  String present,
  String preterite,
  PerfectAuxiliary auxiliary,
  String participle, {
  List<String> emphasis = const <String>[],
}) =>
    VerbLexemeSpec(
      infinitive: infinitive,
      meaningAr: meaningAr,
      kind: kind,
      presentForms: _forms(present),
      preteriteForms: _forms(preterite),
      auxiliary: auxiliary,
      participle: participle,
      presentEmphasisTokens: emphasis,
    );

Map<GermanPronoun, String> _forms(String compact) {
  final values = compact.split('|');
  if (values.length != GermanPronoun.values.length) {
    throw StateError('expected six forms, found ${values.length}: $compact');
  }
  return <GermanPronoun, String>{
    for (var index = 0; index < GermanPronoun.values.length; index++)
      GermanPronoun.values[index]: values[index],
  };
}
