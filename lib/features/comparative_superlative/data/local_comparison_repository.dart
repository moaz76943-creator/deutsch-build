import '../domain/comparison_models.dart';
import '../domain/comparison_repository.dart';

final class LocalComparisonRepository implements ComparisonRepository {
  LocalComparisonRepository() : _challenges = _buildBank();

  final List<ComparisonChallengeItem> _challenges;

  @override
  Future<List<ComparisonChallengeItem>> getChallenges({
    ComparisonRuleType? ruleType,
  }) async {
    final selected = ruleType == null
        ? _challenges
        : _challenges
            .where((item) => item.ruleType == ruleType)
            .toList(growable: false);
    return List<ComparisonChallengeItem>.unmodifiable(selected);
  }

  @override
  Future<bool> checkForm(
    String challengeId,
    ComparisonDegree degree,
    String answer,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;

    final normalized = _normalize(answer);
    if (normalized == _normalize(challenge.answerFor(degree))) return true;

    return degree == ComparisonDegree.superlativ &&
        challenge.attributiveSuperlativ != null &&
        normalized == _normalize(challenge.attributiveSuperlativ!);
  }

  @override
  Future<bool> checkConnector(
    String challengeId,
    ComparisonDegree degree,
    String connector,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;

    final expected = challenge.connectorFor(degree);
    if (expected == null) return _normalize(connector).isEmpty;
    return _normalize(connector) == _normalize(expected);
  }

  ComparisonChallengeItem? _find(String id) {
    for (final challenge in _challenges) {
      if (challenge.id == id) return challenge;
    }
    return null;
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<ComparisonChallengeItem> _buildBank() {
    const items = <ComparisonChallengeItem>[
      ComparisonChallengeItem(
        id: 'regular_schnell',
        positiv: 'schnell',
        komparativ: 'schneller',
        superlativ: 'am schnellsten',
        attributiveSuperlativ: 'der schnellste',
        ruleType: ComparisonRuleType.regular,
        positivSentence: 'Mia läuft genauso ___ ___ Lea.',
        komparativSentence: 'Der Zug ist ___ ___ der Bus.',
        superlativSentence: 'Von allen Zügen fährt der ICE ___.',
        positivTranslationAr: 'ميا تركض بالسرعة نفسها مثل ليا.',
        komparativTranslationAr: 'القطار أسرع من الحافلة.',
        superlativTranslationAr: 'من بين جميع القطارات، يسير ICE بأعلى سرعة.',
        explanationAr:
            'القاعدة المنتظمة: نضيف -er للمقارنة، ونستخدم am + الصفة + -sten للتفضيل. للمساواة نستخدم wie، وللمفاضلة نستخدم als.',
      ),
      ComparisonChallengeItem(
        id: 'regular_langsam',
        positiv: 'langsam',
        komparativ: 'langsamer',
        superlativ: 'am langsamsten',
        attributiveSuperlativ: 'der langsamste',
        ruleType: ComparisonRuleType.regular,
        positivSentence: 'Heute fährt er genauso ___ ___ gestern.',
        komparativSentence: 'Der Bus fährt ___ ___ der Zug.',
        superlativSentence: 'Dieses Fahrzeug fährt ___.',
        positivTranslationAr: 'اليوم يقود بالبطء نفسه مثل الأمس.',
        komparativTranslationAr: 'الحافلة أبطأ من القطار.',
        superlativTranslationAr: 'هذه المركبة هي الأبطأ.',
        explanationAr:
            'langsam تتبع القاعدة المنتظمة: langsamer ثم am langsamsten. استخدم wie مع التساوي وals عند وجود فرق.',
      ),
      ComparisonChallengeItem(
        id: 'regular_klein',
        positiv: 'klein',
        komparativ: 'kleiner',
        superlativ: 'am kleinsten',
        attributiveSuperlativ: 'der kleinste',
        ruleType: ComparisonRuleType.regular,
        positivSentence: 'Das Zimmer ist genauso ___ ___ die Küche.',
        komparativSentence: 'Das Bad ist ___ ___ das Schlafzimmer.',
        superlativSentence: 'Der Abstellraum ist ___.',
        positivTranslationAr: 'الغرفة صغيرة بقدر المطبخ.',
        komparativTranslationAr: 'الحمام أصغر من غرفة النوم.',
        superlativTranslationAr: 'غرفة التخزين هي الأصغر.',
        explanationAr:
            'klein لا يغيّر جذره: klein → kleiner → am kleinsten.',
      ),
      ComparisonChallengeItem(
        id: 'regular_neu',
        positiv: 'neu',
        komparativ: 'neuer',
        superlativ: 'am neuesten',
        attributiveSuperlativ: 'der neueste',
        ruleType: ComparisonRuleType.regular,
        positivSentence: 'Mein Handy ist genauso ___ ___ deins.',
        komparativSentence: 'Dieses Modell ist ___ ___ das alte.',
        superlativSentence: 'Das hier ist ___.',
        positivTranslationAr: 'هاتفي جديد بقدر هاتفك.',
        komparativTranslationAr: 'هذا الطراز أحدث من القديم.',
        superlativTranslationAr: 'هذا هو الأحدث.',
        explanationAr:
            'neu → neuer → am neuesten. صيغة التفضيل تحتاج هنا إلى -esten لتسهيل النطق.',
      ),
      ComparisonChallengeItem(
        id: 'umlaut_gross',
        positiv: 'groß',
        komparativ: 'größer',
        superlativ: 'am größten',
        attributiveSuperlativ: 'der größte',
        ruleType: ComparisonRuleType.umlautChange,
        positivSentence: 'Unser Balkon ist genauso ___ ___ euer Balkon.',
        komparativSentence: 'Berlin ist ___ ___ Bonn.',
        superlativSentence: 'Dieses Zimmer ist ___.',
        positivTranslationAr: 'شرفتنا كبيرة بقدر شرفتكم.',
        komparativTranslationAr: 'برلين أكبر من بون.',
        superlativTranslationAr: 'هذه الغرفة هي الأكبر.',
        explanationAr:
            'هنا يتحول o إلى ö: groß → größer → am größten. التغيير بالأوملاوت جزء من الصيغة ويجب كتابته.',
      ),
      ComparisonChallengeItem(
        id: 'umlaut_alt',
        positiv: 'alt',
        komparativ: 'älter',
        superlativ: 'am ältesten',
        attributiveSuperlativ: 'der älteste',
        ruleType: ComparisonRuleType.umlautChange,
        positivSentence: 'Omar ist genauso ___ ___ Sami.',
        komparativSentence: 'Mein Bruder ist ___ ___ ich.',
        superlativSentence: 'Mein Großvater ist ___.',
        positivTranslationAr: 'عمر في العمر نفسه مثل سامي.',
        komparativTranslationAr: 'أخي أكبر مني عمراً.',
        superlativTranslationAr: 'جدي هو الأكبر عمراً.',
        explanationAr:
            'alt يأخذ Umlaut في المقارنة: alt → älter → am ältesten.',
      ),
      ComparisonChallengeItem(
        id: 'umlaut_jung',
        positiv: 'jung',
        komparativ: 'jünger',
        superlativ: 'am jüngsten',
        attributiveSuperlativ: 'der jüngste',
        ruleType: ComparisonRuleType.umlautChange,
        positivSentence: 'Lina ist genauso ___ ___ Noor.',
        komparativSentence: 'Mein Cousin ist ___ ___ mein Bruder.',
        superlativSentence: 'Ali ist in der Gruppe ___.',
        positivTranslationAr: 'لينا في العمر نفسه مثل نور.',
        komparativTranslationAr: 'ابن عمي أصغر من أخي.',
        superlativTranslationAr: 'علي هو الأصغر في المجموعة.',
        explanationAr:
            'jung → jünger → am jüngsten؛ يتحول u إلى ü في درجتي المقارنة والتفضيل.',
      ),
      ComparisonChallengeItem(
        id: 'umlaut_lang',
        positiv: 'lang',
        komparativ: 'länger',
        superlativ: 'am längsten',
        attributiveSuperlativ: 'der längste',
        ruleType: ComparisonRuleType.umlautChange,
        positivSentence: 'Der Weg ist genauso ___ ___ die Straße.',
        komparativSentence: 'Diese Strecke ist ___ ___ die andere.',
        superlativSentence: 'Diese Route ist ___.',
        positivTranslationAr: 'الطريق بطول الشارع نفسه.',
        komparativTranslationAr: 'هذا المسار أطول من الآخر.',
        superlativTranslationAr: 'هذا المسار هو الأطول.',
        explanationAr:
            'lang → länger → am längsten؛ يتحول a إلى ä عند المقارنة.',
      ),
      ComparisonChallengeItem(
        id: 'irregular_gut',
        positiv: 'gut',
        komparativ: 'besser',
        superlativ: 'am besten',
        attributiveSuperlativ: 'der beste',
        ruleType: ComparisonRuleType.irregular,
        positivSentence: 'Der erste Plan ist genauso ___ ___ der zweite.',
        komparativSentence: 'Diese Lösung ist ___ ___ die alte.',
        superlativSentence: 'Diese Lösung ist ___.',
        positivTranslationAr: 'الخطة الأولى جيدة بقدر الثانية.',
        komparativTranslationAr: 'هذا الحل أفضل من القديم.',
        superlativTranslationAr: 'هذا الحل هو الأفضل.',
        explanationAr:
            'gut شاذة بالكامل: gut → besser → am besten. لا نبنيها بإضافة -er و-sten إلى gut.',
      ),
      ComparisonChallengeItem(
        id: 'irregular_gern',
        positiv: 'gern',
        komparativ: 'lieber',
        superlativ: 'am liebsten',
        ruleType: ComparisonRuleType.irregular,
        positivSentence: 'Ich lerne genauso ___ zu Hause ___ in der Bibliothek.',
        komparativSentence: 'Ich lerne ___ zu Hause ___ im Café.',
        superlativSentence: 'Ich lerne ___ am Morgen.',
        positivTranslationAr: 'أحب الدراسة في البيت بقدر المكتبة.',
        komparativTranslationAr: 'أفضل الدراسة في البيت على المقهى.',
        superlativTranslationAr: 'أفضل الدراسة أكثر شيء في الصباح.',
        explanationAr:
            'gern لها صيغ شاذة محفوظة: gern → lieber → am liebsten.',
      ),
      ComparisonChallengeItem(
        id: 'irregular_viel',
        positiv: 'viel',
        komparativ: 'mehr',
        superlativ: 'am meisten',
        ruleType: ComparisonRuleType.irregular,
        positivSentence: 'Heute habe ich genauso ___ Zeit ___ gestern.',
        komparativSentence: 'Heute habe ich ___ Zeit ___ gestern.',
        superlativSentence: 'Am Wochenende habe ich ___.',
        positivTranslationAr: 'لدي اليوم وقت بقدر الأمس.',
        komparativTranslationAr: 'لدي اليوم وقت أكثر من الأمس.',
        superlativTranslationAr: 'لدي أكبر قدر من الوقت في عطلة نهاية الأسبوع.',
        explanationAr:
            'viel شاذة: viel → mehr → am meisten.',
      ),
      ComparisonChallengeItem(
        id: 'stem_hoch',
        positiv: 'hoch',
        komparativ: 'höher',
        superlativ: 'am höchsten',
        attributiveSuperlativ: 'der höchste',
        ruleType: ComparisonRuleType.stemChange,
        positivSentence: 'Der Schrank ist genauso ___ ___ die Tür.',
        komparativSentence: 'Der Turm ist ___ ___ das Haus.',
        superlativSentence: 'Dieser Berg ist ___.',
        positivTranslationAr: 'الخزانة بارتفاع الباب نفسه.',
        komparativTranslationAr: 'البرج أعلى من المنزل.',
        superlativTranslationAr: 'هذا الجبل هو الأعلى.',
        explanationAr:
            'hoch يغيّر الجذر: hoch → höher → am höchsten. لاحظ سقوط c وظهور Umlaut.',
      ),
      ComparisonChallengeItem(
        id: 'stem_nah',
        positiv: 'nah',
        komparativ: 'näher',
        superlativ: 'am nächsten',
        attributiveSuperlativ: 'der nächste',
        ruleType: ComparisonRuleType.stemChange,
        positivSentence: 'Die Apotheke ist genauso ___ ___ der Supermarkt.',
        komparativSentence: 'Die Haltestelle ist ___ ___ der Bahnhof.',
        superlativSentence: 'Dieses Geschäft ist ___.',
        positivTranslationAr: 'الصيدلية قريبة بقدر السوبرماركت.',
        komparativTranslationAr: 'الموقف أقرب من محطة القطار.',
        superlativTranslationAr: 'هذا المتجر هو الأقرب.',
        explanationAr:
            'nah → näher → am nächsten. صيغة التفضيل تغيّر الجذر بوضوح، لذلك تُحفظ كصيغة خاصة.',
      ),
      ComparisonChallengeItem(
        id: 'stem_teuer',
        positiv: 'teuer',
        komparativ: 'teurer',
        superlativ: 'am teuersten',
        attributiveSuperlativ: 'der teuerste',
        ruleType: ComparisonRuleType.stemChange,
        positivSentence: 'Die Jacke ist genauso ___ ___ der Mantel.',
        komparativSentence: 'Der Mantel ist ___ ___ die Jacke.',
        superlativSentence: 'Dieser Anzug ist ___.',
        positivTranslationAr: 'السترة غالية بقدر المعطف.',
        komparativTranslationAr: 'المعطف أغلى من السترة.',
        superlativTranslationAr: 'هذه البدلة هي الأغلى.',
        explanationAr:
            'teuer يفقد e الداخلية في Komparativ: teuer → teurer، ثم am teuersten.',
      ),
    ];

    final ids = items.map((item) => item.id).toSet();
    if (ids.length != items.length) {
      throw StateError('comparison challenge bank contains duplicate ids');
    }
    return List<ComparisonChallengeItem>.unmodifiable(items);
  }
}
