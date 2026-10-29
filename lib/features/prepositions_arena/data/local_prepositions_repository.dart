import '../../../core/localization/german_article_style.dart';
import '../domain/preposition_models.dart';
import '../domain/prepositions_repository.dart';

final class LocalPrepositionsRepository implements PrepositionsRepository {
  const LocalPrepositionsRepository();

  static const List<PrepositionItem> _items = <PrepositionItem>[
    PrepositionItem(
      id: 'durch',
      preposition: 'durch',
      type: PrepositionType.accusative,
      meaningAr: 'عبر / من خلال',
      level: 'A2',
    ),
    PrepositionItem(
      id: 'fuer',
      preposition: 'für',
      type: PrepositionType.accusative,
      meaningAr: 'لأجل / من أجل',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'gegen',
      preposition: 'gegen',
      type: PrepositionType.accusative,
      meaningAr: 'ضد / نحو',
      level: 'A2',
    ),
    PrepositionItem(
      id: 'ohne',
      preposition: 'ohne',
      type: PrepositionType.accusative,
      meaningAr: 'بدون',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'um',
      preposition: 'um',
      type: PrepositionType.accusative,
      meaningAr: 'حول / عند الساعة',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'aus',
      preposition: 'aus',
      type: PrepositionType.dative,
      meaningAr: 'من داخل / من',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'bei',
      preposition: 'bei',
      type: PrepositionType.dative,
      meaningAr: 'عند / لدى',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'mit',
      preposition: 'mit',
      type: PrepositionType.dative,
      meaningAr: 'مع / بواسطة',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'nach',
      preposition: 'nach',
      type: PrepositionType.dative,
      meaningAr: 'إلى / بعد',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'seit',
      preposition: 'seit',
      type: PrepositionType.dative,
      meaningAr: 'منذ',
      level: 'A2',
    ),
    PrepositionItem(
      id: 'von',
      preposition: 'von',
      type: PrepositionType.dative,
      meaningAr: 'من / عن',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'zu',
      preposition: 'zu',
      type: PrepositionType.dative,
      meaningAr: 'إلى / عند',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'gegenueber',
      preposition: 'gegenüber',
      type: PrepositionType.dative,
      meaningAr: 'مقابل',
      level: 'A2',
    ),
    PrepositionItem(
      id: 'an',
      preposition: 'an',
      type: PrepositionType.twoWay,
      meaningAr: 'عند / إلى جانب سطح عمودي',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'auf',
      preposition: 'auf',
      type: PrepositionType.twoWay,
      meaningAr: 'على / إلى سطح',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'hinter',
      preposition: 'hinter',
      type: PrepositionType.twoWay,
      meaningAr: 'خلف / إلى خلف',
      level: 'A2',
    ),
    PrepositionItem(
      id: 'in',
      preposition: 'in',
      type: PrepositionType.twoWay,
      meaningAr: 'في / إلى داخل',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'neben',
      preposition: 'neben',
      type: PrepositionType.twoWay,
      meaningAr: 'بجانب / إلى جانب',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'ueber',
      preposition: 'über',
      type: PrepositionType.twoWay,
      meaningAr: 'فوق / إلى فوق',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'unter',
      preposition: 'unter',
      type: PrepositionType.twoWay,
      meaningAr: 'تحت / إلى تحت',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'vor',
      preposition: 'vor',
      type: PrepositionType.twoWay,
      meaningAr: 'أمام / إلى أمام',
      level: 'A1',
    ),
    PrepositionItem(
      id: 'zwischen',
      preposition: 'zwischen',
      type: PrepositionType.twoWay,
      meaningAr: 'بين / إلى بين',
      level: 'A2',
    ),
  ];

  static final List<PrepositionChallenge> _challenges =
      <PrepositionChallenge>[
    PrepositionChallenge(
      id: 'akk-fuer-article-der',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Ich kaufe ein Geschenk für ___ Mann.',
      translationAr: 'أشتري هدية للرجل.',
      prepositionId: 'fuer',
      baseArticle: GermanArticle.der,
      options: const <String>['den', 'dem', 'der'],
      explanationAr: 'für يأخذ Akkusativ، لذلك der يتحول إلى den.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'akk-ohne-preposition',
      kind: PrepositionChallengeKind.prepositionChoice,
      sentenceTemplate: 'Er trinkt Kaffee ___ Zucker.',
      translationAr: 'هو يشرب القهوة بدون سكر.',
      prepositionId: 'ohne',
      correctPreposition: 'ohne',
      options: const <String>['ohne', 'mit', 'bei'],
      explanationAr: 'ohne يعني بدون ويأخذ Akkusativ.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'akk-durch-article-der',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Wir gehen durch ___ Park.',
      translationAr: 'نحن نمشي عبر الحديقة.',
      prepositionId: 'durch',
      baseArticle: GermanArticle.der,
      options: const <String>['den', 'dem', 'der'],
      explanationAr: 'durch يأخذ Akkusativ، لذلك der يصبح den.',
      level: 'A2',
    ),
    PrepositionChallenge(
      id: 'dat-mit-article-der',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Ich fahre mit ___ Bus.',
      translationAr: 'أذهب بالحافلة.',
      prepositionId: 'mit',
      baseArticle: GermanArticle.der,
      options: const <String>['dem', 'den', 'der'],
      explanationAr: 'mit يأخذ Dativ، لذلك der يتحول إلى dem.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'dat-mit-preposition',
      kind: PrepositionChallengeKind.prepositionChoice,
      sentenceTemplate: 'Ich fahre ___ dem Bus.',
      translationAr: 'أذهب بالحافلة.',
      prepositionId: 'mit',
      correctPreposition: 'mit',
      options: const <String>['mit', 'für', 'ohne'],
      explanationAr: 'mit هو حرف الجر المناسب لمعنى بواسطة / مع.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'dat-bei-article-die',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Ich bin bei ___ Ärztin.',
      translationAr: 'أنا عند الطبيبة.',
      prepositionId: 'bei',
      baseArticle: GermanArticle.die,
      options: const <String>['der', 'die', 'dem'],
      explanationAr: 'bei يأخذ Dativ، لذلك die تتحول إلى der.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'dat-zu-preposition',
      kind: PrepositionChallengeKind.prepositionChoice,
      sentenceTemplate: 'Wir gehen ___ meiner Freundin.',
      translationAr: 'نحن نذهب إلى صديقتي.',
      prepositionId: 'zu',
      correctPreposition: 'zu',
      options: const <String>['zu', 'für', 'durch'],
      explanationAr: 'zu يأخذ Dativ ويستخدم للاتجاه نحو مكان أو شخص.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-in-wohin-der',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Ich gehe in ___ Park.',
      translationAr: 'أذهب إلى داخل الحديقة.',
      prepositionId: 'in',
      baseArticle: GermanArticle.der,
      spatialQuestion: SpatialQuestion.wohin,
      options: const <String>['den', 'dem', 'der'],
      explanationAr: 'Wohin؟ توجد حركة نحو مكان، لذلك in يأخذ Akkusativ: den Park.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-auf-wo-der',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Das Buch liegt auf ___ Tisch.',
      translationAr: 'الكتاب موجود على الطاولة.',
      prepositionId: 'auf',
      baseArticle: GermanArticle.der,
      spatialQuestion: SpatialQuestion.wo,
      options: const <String>['dem', 'den', 'der'],
      explanationAr: 'Wo؟ لا توجد حركة، لذلك auf يأخذ Dativ: dem Tisch.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-vor-wo-die',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Sie steht vor ___ Tür.',
      translationAr: 'هي تقف أمام الباب.',
      prepositionId: 'vor',
      baseArticle: GermanArticle.die,
      spatialQuestion: SpatialQuestion.wo,
      options: const <String>['der', 'die', 'dem'],
      explanationAr: 'Wo؟ حالة ثابتة، لذلك vor يأخذ Dativ وdie تصبح der.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-ueber-wo-das',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Das Bild hängt über ___ Sofa.',
      translationAr: 'الصورة معلقة فوق الأريكة.',
      prepositionId: 'ueber',
      baseArticle: GermanArticle.das,
      spatialQuestion: SpatialQuestion.wo,
      options: const <String>['dem', 'das', 'den'],
      explanationAr: 'Wo؟ موضع ثابت، لذلك über يأخذ Dativ وdas تصبح dem.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-ueber-wohin-das',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Ich hänge das Bild über ___ Sofa.',
      translationAr: 'أعلّق الصورة فوق الأريكة.',
      prepositionId: 'ueber',
      baseArticle: GermanArticle.das,
      spatialQuestion: SpatialQuestion.wohin,
      options: const <String>['das', 'dem', 'den'],
      explanationAr: 'Wohin؟ توجد حركة نحو موضع جديد، لذلك über يأخذ Akkusativ ويبقى das.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-in-preposition',
      kind: PrepositionChallengeKind.prepositionChoice,
      sentenceTemplate: 'Ich gehe ___ den Park.',
      translationAr: 'أدخل إلى الحديقة.',
      prepositionId: 'in',
      correctPreposition: 'in',
      spatialQuestion: SpatialQuestion.wohin,
      options: const <String>['in', 'mit', 'von'],
      explanationAr: 'in مناسب للدخول إلى مكان، ومع الحركة يأتي Akkusativ.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-auf-preposition',
      kind: PrepositionChallengeKind.prepositionChoice,
      sentenceTemplate: 'Wir sitzen ___ dem Balkon.',
      translationAr: 'نحن نجلس على الشرفة.',
      prepositionId: 'auf',
      correctPreposition: 'auf',
      spatialQuestion: SpatialQuestion.wo,
      options: const <String>['auf', 'durch', 'zu'],
      explanationAr: 'auf مناسب لموضع على سطح، ومع Wo يأتي Dativ.',
      level: 'A1',
    ),
    PrepositionChallenge(
      id: 'two-zwischen-wo-die',
      kind: PrepositionChallengeKind.articleChoice,
      sentenceTemplate: 'Der Stuhl steht zwischen ___ Tür und dem Fenster.',
      translationAr: 'الكرسي موجود بين الباب والنافذة.',
      prepositionId: 'zwischen',
      baseArticle: GermanArticle.die,
      spatialQuestion: SpatialQuestion.wo,
      options: const <String>['der', 'die', 'dem'],
      explanationAr: 'Wo؟ موضع ثابت، لذلك zwischen يأخذ Dativ وdie تصبح der.',
      level: 'A2',
    ),
  ];

  @override
  List<PrepositionItem> allPrepositions() =>
      List<PrepositionItem>.unmodifiable(_items);

  @override
  PrepositionItem? byId(String id) {
    final normalized = id.trim().toLowerCase();
    for (final item in _items) {
      if (item.id == normalized) return item;
    }
    return null;
  }

  @override
  List<PrepositionChallenge> challenges({
    PrepositionType? type,
    String? level,
  }) {
    final normalizedLevel = level?.trim().toUpperCase();
    final result = <PrepositionChallenge>[];
    for (final challenge in _challenges) {
      final preposition = byId(challenge.prepositionId);
      if (preposition == null) continue;
      if (type != null && preposition.type != type) continue;
      if (normalizedLevel != null &&
          normalizedLevel.isNotEmpty &&
          challenge.level != normalizedLevel) {
        continue;
      }
      result.add(challenge);
    }
    return List<PrepositionChallenge>.unmodifiable(result);
  }
}
