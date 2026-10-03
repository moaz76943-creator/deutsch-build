import '../../clause_connector_agent/data/local_clause_connector_repository.dart';
import '../../clause_connector_agent/domain/clause_connector_models.dart';
import '../../clause_connector_agent/domain/clause_connector_repository.dart';
import '../domain/conjunctions_models.dart';
import '../domain/conjunctions_repository.dart';

final class LocalConjunctionsRepository implements ConjunctionsRepository {
  LocalConjunctionsRepository({
    ClauseConnectorRepository? canonicalRepository,
  }) : _canonicalRepository =
            canonicalRepository ?? LocalClauseConnectorRepository();

  final ClauseConnectorRepository _canonicalRepository;
  List<ConjunctionDrillItem>? _cachedBank;

  static const List<ConjunctionDrillItem> _arenaSupplements =
      <ConjunctionDrillItem>[
    ConjunctionDrillItem(
      id: 'arena_und_lernen',
      category: ConjunctionCategory.coordinatingADUSO,
      mainClause: 'Ich lerne Deutsch.',
      linkedClause: 'Ich übe jeden Abend.',
      targetConnector: 'und',
      correctVerbPosition: ConjunctionDrillItem.positionZero,
      arabicTranslation: 'أتعلم الألمانية وأتدرّب كل مساء.',
      verbPositionExplanationAr:
          'und أداة تنسيق في Position 0؛ لا تغيّر ترتيب الجملة الثانية، ويبقى الفعل übe في موقعه الطبيعي V2.',
    ),
    ConjunctionDrillItem(
      id: 'arena_aber_muede',
      category: ConjunctionCategory.coordinatingADUSO,
      mainClause: 'Ich bin müde.',
      linkedClause: 'Ich lerne weiter.',
      targetConnector: 'aber',
      correctVerbPosition: ConjunctionDrillItem.positionZero,
      arabicTranslation: 'أنا متعب، لكنني أواصل الدراسة.',
      verbPositionExplanationAr:
          'aber تأتي في Position 0؛ الجملة بعدها تبقى جملة رئيسية ويظل الفعل lerne في V2.',
    ),
    ConjunctionDrillItem(
      id: 'arena_oder_bus',
      category: ConjunctionCategory.coordinatingADUSO,
      mainClause: 'Wir fahren mit dem Bus.',
      linkedClause: 'Wir gehen zu Fuß.',
      targetConnector: 'oder',
      correctVerbPosition: ConjunctionDrillItem.positionZero,
      arabicTranslation: 'نذهب بالحافلة أو نمشي على الأقدام.',
      verbPositionExplanationAr:
          'oder لا تحتل خانة من الجملة التالية؛ لذلك تبقى الجملة الرئيسية بعدها بترتيب V2.',
    ),
    ConjunctionDrillItem(
      id: 'arena_sondern_tee',
      category: ConjunctionCategory.coordinatingADUSO,
      mainClause: 'Ich trinke keinen Kaffee.',
      linkedClause: 'Ich trinke Tee.',
      targetConnector: 'sondern',
      correctVerbPosition: ConjunctionDrillItem.positionZero,
      arabicTranslation: 'أنا لا أشرب القهوة، بل أشرب الشاي.',
      verbPositionExplanationAr:
          'sondern تستخدم بعد نفي لتصحيح البديل، وهي Position 0؛ الفعل trinke يبقى في V2.',
    ),
    ConjunctionDrillItem(
      id: 'arena_wenn_zeit',
      category: ConjunctionCategory.subordinatingNebensatz,
      mainClause: 'Ich rufe dich an.',
      linkedClause: 'Ich habe Zeit.',
      targetConnector: 'wenn',
      correctVerbPosition: ConjunctionDrillItem.positionEnd,
      arabicTranslation: 'سأتصل بك عندما يكون لدي وقت.',
      verbPositionExplanationAr:
          'wenn تبدأ Nebensatz؛ لذلك ينتقل الفعل المصرف habe إلى نهاية الجملة الفرعية.',
    ),
  ];

  static const Map<String, String> _canonicalTranslations =
      <String, String>{
    'weil_krank': 'أبقى في البيت لأنني مريض.',
    'denn_krank': 'أبقى في البيت لأنني مريض.',
    'obwohl_regen': 'تتمشى ميا رغم أن المطر يهطل بغزارة اليوم.',
    'dass_zeit': 'أعرف أن لديك وقتًا اليوم.',
    'weil_modal': 'أنام مبكرًا لأن عليّ أن أعمل غدًا.',
    'denn_modal': 'أنام مبكرًا لأن عليّ أن أعمل غدًا.',
    'deshalb_mued': 'أنا متعب، لذلك أذهب إلى السرير مبكرًا.',
    'trotzdem_regen': 'المطر يهطل بغزارة، ومع ذلك نذهب للتنزه.',
  };

  @override
  Future<List<ConjunctionDrillItem>> getDrills({
    ConjunctionCategory? category,
  }) async {
    final bank = await _loadBank();
    final filtered = category == null
        ? bank
        : bank.where((item) => item.category == category);
    return List<ConjunctionDrillItem>.unmodifiable(filtered);
  }

  @override
  Future<bool> validateAnswer(
    String drillId,
    String chosenConnector,
    int chosenVerbPosition,
  ) async {
    final normalizedId = drillId.trim();
    final normalizedConnector = chosenConnector.trim().toLowerCase();
    if (normalizedId.isEmpty || normalizedConnector.isEmpty) return false;

    final bank = await _loadBank();
    ConjunctionDrillItem? drill;
    for (final item in bank) {
      if (item.id == normalizedId) {
        drill = item;
        break;
      }
    }
    if (drill == null) return false;

    return normalizedConnector == drill.targetConnector.toLowerCase() &&
        chosenVerbPosition == drill.correctVerbPosition;
  }

  Future<List<ConjunctionDrillItem>> _loadBank() async {
    final cached = _cachedBank;
    if (cached != null) return cached;

    final canonical = await _canonicalRepository.getChallenges();
    final mapped = <ConjunctionDrillItem>[
      for (final item in canonical) _fromCanonical(item),
      ..._arenaSupplements,
    ];

    _cachedBank = List<ConjunctionDrillItem>.unmodifiable(mapped);
    return _cachedBank!;
  }

  static ConjunctionDrillItem _fromCanonical(
    ConnectorChallengeItem item,
  ) {
    return ConjunctionDrillItem(
      id: 'canonical_${item.id}',
      category: _categoryFor(item.type),
      mainClause: item.firstSentence,
      linkedClause: item.secondSentence,
      targetConnector: item.targetConnector,
      correctVerbPosition: _positionFor(item.type),
      arabicTranslation: _canonicalTranslations[item.id] ??
          'تدريب على ربط الجمل باستخدام ${item.targetConnector}.',
      verbPositionExplanationAr:
          item.arabicVerbPositionExplanation,
    );
  }

  static ConjunctionCategory _categoryFor(ConjunctionType type) {
    return switch (type) {
      ConjunctionType.positionZero =>
        ConjunctionCategory.coordinatingADUSO,
      ConjunctionType.verbKicker =>
        ConjunctionCategory.subordinatingNebensatz,
      ConjunctionType.adverbialConnector =>
        ConjunctionCategory.adverbialInversion,
    };
  }

  static int _positionFor(ConjunctionType type) {
    return switch (type) {
      ConjunctionType.positionZero => ConjunctionDrillItem.positionZero,
      ConjunctionType.verbKicker => ConjunctionDrillItem.positionEnd,
      ConjunctionType.adverbialConnector =>
        ConjunctionDrillItem.positionOne,
    };
  }
}
