import '../../../core/localization/german_article_style.dart';
import '../domain/komposita_models.dart';
import '../domain/komposita_repository.dart';

final class LocalKompositaRepository implements KompositaRepository {
  static final List<KompositaChallengeItem> _bank =
      <KompositaChallengeItem>[
    KompositaChallengeItem(
      id: 'apfelbaum',
      compoundWord: 'Apfelbaum',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Apfel',
          arabicMeaning: 'تفاحة',
          originalArticle: GermanArticle.der,
        ),
        CompoundWordPart(
          word: 'Baum',
          arabicMeaning: 'شجرة',
          originalArticle: GermanArticle.der,
        ),
      ],
      linkingElement: LinkingElement.none,
      finalArticle: GermanArticle.der,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'شجرة تفاح',
      derivationExplanationAr:
          'Apfel يحدد نوع الشجرة، وBaum هو Grundwort الأخير؛ لذلك الكلمة الناتجة der Apfelbaum بلا حرف وصل.',
      level: 'A1',
    ),
    KompositaChallengeItem(
      id: 'haustuer',
      compoundWord: 'Haustür',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Haus',
          arabicMeaning: 'بيت',
          originalArticle: GermanArticle.das,
        ),
        CompoundWordPart(
          word: 'Tür',
          arabicMeaning: 'باب',
          originalArticle: GermanArticle.die,
        ),
      ],
      linkingElement: LinkingElement.none,
      finalArticle: GermanArticle.die,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'باب المنزل',
      derivationExplanationAr:
          'Haus هو Bestimmungswort وTür هي Grundwort؛ لا يوجد Fugenlaut، وأداة الناتج die لأن الجزء الأخير die Tür.',
      level: 'A1',
    ),
    KompositaChallengeItem(
      id: 'handschuh',
      compoundWord: 'Handschuh',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Hand',
          arabicMeaning: 'يد',
          originalArticle: GermanArticle.die,
        ),
        CompoundWordPart(
          word: 'Schuh',
          arabicMeaning: 'حذاء',
          originalArticle: GermanArticle.der,
        ),
      ],
      linkingElement: LinkingElement.none,
      finalArticle: GermanArticle.der,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'قفاز',
      derivationExplanationAr:
          'Hand تحدد الاستعمال، وSchuh هي الكلمة الرأس؛ لذلك المفرد der Handschuh. الجمع هو die Handschuhe.',
      level: 'A1',
    ),
    KompositaChallengeItem(
      id: 'woerterbuch',
      compoundWord: 'Wörterbuch',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Wort',
          arabicMeaning: 'كلمة',
          originalArticle: GermanArticle.das,
        ),
        CompoundWordPart(
          word: 'Buch',
          arabicMeaning: 'كتاب',
          originalArticle: GermanArticle.das,
        ),
      ],
      linkingElement: LinkingElement.er,
      finalArticle: GermanArticle.das,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'قاموس / كتاب كلمات',
      derivationExplanationAr:
          'Wort يأخذ صيغة الربط Wörter- قبل Buch؛ الجزء الأخير das Buch يحدد الأداة، لذلك das Wörterbuch.',
      level: 'A1',
    ),
    KompositaChallengeItem(
      id: 'arbeitszimmer',
      compoundWord: 'Arbeitszimmer',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Arbeit',
          arabicMeaning: 'عمل',
          originalArticle: GermanArticle.die,
        ),
        CompoundWordPart(
          word: 'Zimmer',
          arabicMeaning: 'غرفة',
          originalArticle: GermanArticle.das,
        ),
      ],
      linkingElement: LinkingElement.s,
      finalArticle: GermanArticle.das,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'غرفة عمل / مكتب منزلي',
      derivationExplanationAr:
          'بين Arbeit وZimmer يظهر Fugen-s: Arbeit + s + Zimmer. الكلمة الأخيرة das Zimmer تجعل الناتج das Arbeitszimmer.',
      level: 'A2',
    ),
    KompositaChallengeItem(
      id: 'tageslicht',
      compoundWord: 'Tageslicht',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Tag',
          arabicMeaning: 'يوم',
          originalArticle: GermanArticle.der,
        ),
        CompoundWordPart(
          word: 'Licht',
          arabicMeaning: 'ضوء',
          originalArticle: GermanArticle.das,
        ),
      ],
      linkingElement: LinkingElement.es,
      finalArticle: GermanArticle.das,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'ضوء النهار',
      derivationExplanationAr:
          'Tag يرتبط بـLicht عبر Fugen-es: Tag + es + Licht. لأن الجزء الأخير das Licht فالناتج das Tageslicht.',
      level: 'A2',
    ),
    KompositaChallengeItem(
      id: 'strassenbahn',
      compoundWord: 'Straßenbahn',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Straße',
          arabicMeaning: 'شارع',
          originalArticle: GermanArticle.die,
        ),
        CompoundWordPart(
          word: 'Bahn',
          arabicMeaning: 'قطار / سكة',
          originalArticle: GermanArticle.die,
        ),
      ],
      linkingElement: LinkingElement.n,
      finalArticle: GermanArticle.die,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'ترام / قطار الشارع',
      derivationExplanationAr:
          'Straße تأخذ n في صيغة الربط: Straße + n + Bahn. Grundwort هي die Bahn، لذلك die Straßenbahn.',
      level: 'A2',
    ),
    KompositaChallengeItem(
      id: 'studentenwohnheim',
      compoundWord: 'Studentenwohnheim',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Student',
          arabicMeaning: 'طالب جامعي',
          originalArticle: GermanArticle.der,
        ),
        CompoundWordPart(
          word: 'Wohnheim',
          arabicMeaning: 'سكن داخلي',
          originalArticle: GermanArticle.das,
        ),
      ],
      linkingElement: LinkingElement.en,
      finalArticle: GermanArticle.das,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'سكن الطلاب',
      derivationExplanationAr:
          'Student يرتبط بـWohnheim عبر en: Student + en + Wohnheim. الكلمة الأخيرة das Wohnheim تحدد الأداة.',
      level: 'B1',
    ),
    KompositaChallengeItem(
      id: 'kinderzimmer',
      compoundWord: 'Kinderzimmer',
      parts: const <CompoundWordPart>[
        CompoundWordPart(
          word: 'Kind',
          arabicMeaning: 'طفل',
          originalArticle: GermanArticle.das,
        ),
        CompoundWordPart(
          word: 'Zimmer',
          arabicMeaning: 'غرفة',
          originalArticle: GermanArticle.das,
        ),
      ],
      linkingElement: LinkingElement.er,
      finalArticle: GermanArticle.das,
      articleRuleAr: KompositaChallengeItem.canonicalArticleRuleAr,
      overallMeaningAr: 'غرفة أطفال',
      derivationExplanationAr:
          'Kind يأخذ صيغة الربط Kinder- قبل Zimmer. الجزء الأخير das Zimmer يحدد الأداة: das Kinderzimmer.',
      level: 'B1',
    ),
  ];

  @override
  Future<List<KompositaChallengeItem>> getChallenges({
    String? level,
    LinkingElement? linkingElement,
  }) async {
    final normalizedLevel = level?.trim().toUpperCase();
    final result = _bank.where((item) {
      if (normalizedLevel != null &&
          normalizedLevel.isNotEmpty &&
          item.level != normalizedLevel) {
        return false;
      }
      if (linkingElement != null &&
          item.linkingElement != linkingElement) {
        return false;
      }
      return true;
    }).toList(growable: false);

    return List<KompositaChallengeItem>.unmodifiable(result);
  }

  @override
  Future<bool> validateComposition(
    String challengeId, {
    required List<String> orderedParts,
    required LinkingElement linkingElement,
    required GermanArticle finalArticle,
  }) async {
    final normalizedId = challengeId.trim();
    KompositaChallengeItem? challenge;
    for (final item in _bank) {
      if (item.id == normalizedId) {
        challenge = item;
        break;
      }
    }
    if (challenge == null) return false;

    final normalizedParts = orderedParts
        .map((part) => part.trim().toLowerCase())
        .toList(growable: false);
    final expectedParts = challenge.parts
        .map((part) => part.word.trim().toLowerCase())
        .toList(growable: false);

    return _sameOrderedParts(normalizedParts, expectedParts) &&
        linkingElement == challenge.linkingElement &&
        finalArticle == challenge.finalArticle;
  }

  static bool _sameOrderedParts(
    List<String> submitted,
    List<String> expected,
  ) {
    if (submitted.length != expected.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (submitted[index] != expected[index]) return false;
    }
    return true;
  }
}
