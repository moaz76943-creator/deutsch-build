import '../domain/relativsaetze_models.dart';
import '../domain/relativsaetze_repository.dart';

final class LocalRelativsaetzeRepository
    implements RelativsaetzeRepository {
  LocalRelativsaetzeRepository();

  static final List<RelativeClauseChallengeItem> _bank =
      <RelativeClauseChallengeItem>[
    RelativeClauseChallengeItem(
      id: 'prep_mit_mann',
      antecedent: 'der Mann',
      antecedentGender: RelativeAntecedentGender.masculine,
      sourceSentence: 'Das ist der Mann.',
      relativeIdea: 'Ich habe gestern mit ihm gesprochen.',
      correctSentence:
          'Das ist der Mann, mit dem ich gestern gesprochen habe.',
      grammaticalCase: RelativePronounCase.dative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'mit',
      arabicExplanation:
          'mit يأخذ Dativ دائماً. المرجع der Mann مذكر، لذلك يصبح الضمير النسبي dem: mit dem. داخل Relativsatz يذهب الفعل المصرف habe إلى نهاية الجملة.',
    ),
    RelativeClauseChallengeItem(
      id: 'prep_auf_kollegin',
      antecedent: 'die Kollegin',
      antecedentGender: RelativeAntecedentGender.feminine,
      sourceSentence: 'Das ist die Kollegin.',
      relativeIdea: 'Ich warte auf sie.',
      correctSentence:
          'Das ist die Kollegin, auf die ich warte.',
      grammaticalCase: RelativePronounCase.accusative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'auf',
      arabicExplanation:
          'الفعل warten يأتي مع auf + Akkusativ. المرجع die Kollegin مؤنث، وصيغة Akkusativ المؤنث للضمير النسبي هي die: auf die. الفعل warte يبقى في نهاية الجملة النسبية.',
    ),
    RelativeClauseChallengeItem(
      id: 'prep_an_projekt',
      antecedent: 'das Projekt',
      antecedentGender: RelativeAntecedentGender.neuter,
      sourceSentence: 'Das ist das Projekt.',
      relativeIdea: 'Wir arbeiten an ihm.',
      correctSentence:
          'Das ist das Projekt, an dem wir arbeiten.',
      grammaticalCase: RelativePronounCase.dative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'an',
      arabicExplanation:
          'arbeiten an يُستخدم هنا مع Dativ. المرجع das Projekt محايد، لذلك الضمير النسبي هو dem: an dem. الفعل arbeiten يأتي في نهاية Relativsatz.',
    ),
    RelativeClauseChallengeItem(
      id: 'prep_von_leuten',
      antecedent: 'die Leute',
      antecedentGender: RelativeAntecedentGender.plural,
      sourceSentence: 'Das sind die Leute.',
      relativeIdea: 'Ich habe von ihnen erzählt.',
      correctSentence:
          'Das sind die Leute, von denen ich erzählt habe.',
      grammaticalCase: RelativePronounCase.dative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'von',
      arabicExplanation:
          'von يأخذ Dativ. مع مرجع جمع نستخدم denen، لذلك: von denen. في الجملة النسبية المركبة يأتي habe في النهاية.',
    ),
    RelativeClauseChallengeItem(
      id: 'prep_fuer_kurs',
      antecedent: 'der Kurs',
      antecedentGender: RelativeAntecedentGender.masculine,
      sourceSentence: 'Das ist der Kurs.',
      relativeIdea: 'Ich interessiere mich für ihn.',
      correctSentence:
          'Das ist der Kurs, für den ich mich interessiere.',
      grammaticalCase: RelativePronounCase.accusative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'für',
      arabicExplanation:
          'für يأخذ Akkusativ دائماً. المرجع der Kurs مذكر، لذلك نستخدم den: für den. الفعل المصرف interessiere يأتي في نهاية Relativsatz.',
    ),
    RelativeClauseChallengeItem(
      id: 'prep_in_stadt',
      antecedent: 'die Stadt',
      antecedentGender: RelativeAntecedentGender.feminine,
      sourceSentence: 'Berlin ist eine Stadt.',
      relativeIdea: 'Ich wohne in ihr.',
      correctSentence:
          'Berlin ist eine Stadt, in der ich gern wohne.',
      grammaticalCase: RelativePronounCase.dative,
      focus: RelativeClauseFocus.prepositional,
      preposition: 'in',
      arabicExplanation:
          'هنا in يعبّر عن مكان ثابت، لذلك نستخدم Dativ. المرجع die Stadt مؤنث، وصيغة Dativ هي der: in der. الفعل wohne في نهاية الجملة النسبية.',
    ),
    RelativeClauseChallengeItem(
      id: 'genitiv_mann_auto',
      antecedent: 'der Mann',
      antecedentGender: RelativeAntecedentGender.masculine,
      sourceSentence: 'Der Mann wartet draußen.',
      relativeIdea: 'Sein Auto steht vor dem Haus.',
      correctSentence:
          'Der Mann, dessen Auto vor dem Haus steht, wartet draußen.',
      grammaticalCase: RelativePronounCase.genitive,
      focus: RelativeClauseFocus.genitivePossession,
      arabicExplanation:
          'dessen يدل على ملكية تعود إلى مرجع مذكر أو محايد. هنا المرجع der Mann، لذلك نقول dessen Auto. اختيار dessen يعتمد على صاحب الشيء، لا على جنس Auto. الفعل steht يأتي في نهاية Relativsatz.',
    ),
    RelativeClauseChallengeItem(
      id: 'genitiv_frau_tochter',
      antecedent: 'die Frau',
      antecedentGender: RelativeAntecedentGender.feminine,
      sourceSentence: 'Die Frau arbeitet hier.',
      relativeIdea: 'Ihre Tochter studiert Medizin.',
      correctSentence:
          'Die Frau, deren Tochter Medizin studiert, arbeitet hier.',
      grammaticalCase: RelativePronounCase.genitive,
      focus: RelativeClauseFocus.genitivePossession,
      arabicExplanation:
          'deren يُستخدم عندما يكون المرجع مؤنثاً أو جمعاً. المرجع die Frau مؤنث، لذلك: deren Tochter. الفعل studiert في نهاية الجملة النسبية.',
    ),
    RelativeClauseChallengeItem(
      id: 'genitiv_kind_eltern',
      antecedent: 'das Kind',
      antecedentGender: RelativeAntecedentGender.neuter,
      sourceSentence: 'Das Kind ist neu in der Klasse.',
      relativeIdea: 'Seine Eltern wohnen in Bonn.',
      correctSentence:
          'Das Kind, dessen Eltern in Bonn wohnen, ist neu in der Klasse.',
      grammaticalCase: RelativePronounCase.genitive,
      focus: RelativeClauseFocus.genitivePossession,
      arabicExplanation:
          'المرجع das Kind محايد، لذلك نستخدم dessen رغم أن الاسم المملوك Eltern جمع. صيغة Genitiv تتبع المرجع، والفعل wohnen يأتي في نهاية Relativsatz.',
    ),
    RelativeClauseChallengeItem(
      id: 'genitiv_nachbarn_haus',
      antecedent: 'die Nachbarn',
      antecedentGender: RelativeAntecedentGender.plural,
      sourceSentence: 'Die Nachbarn sind im Urlaub.',
      relativeIdea: 'Ihr Haus wird renoviert.',
      correctSentence:
          'Die Nachbarn, deren Haus renoviert wird, sind im Urlaub.',
      grammaticalCase: RelativePronounCase.genitive,
      focus: RelativeClauseFocus.genitivePossession,
      arabicExplanation:
          'المرجع die Nachbarn جمع، لذلك صيغة Genitiv هي deren: deren Haus. deren يتبع أصحاب الملكية، وليس الاسم Haus. في المبني للمجهول يأتي wird في نهاية الجملة النسبية.',
    ),
  ];

  @override
  Future<List<RelativeClauseChallengeItem>> getChallenges({
    RelativeClauseFocus? focus,
  }) async {
    final challenges = focus == null
        ? _bank
        : _bank.where((item) => item.focus == focus);
    return List<RelativeClauseChallengeItem>.unmodifiable(challenges);
  }

  @override
  Future<List<String>> getAnswerOptions(String challengeId) async {
    final challenge = _find(challengeId);
    if (challenge == null) return const <String>[];

    final expected = challenge.expectedPronoun;
    final candidates = challenge.focus ==
            RelativeClauseFocus.genitivePossession
        ? <String>['dessen', 'deren', 'dem', 'der']
        : <String>['der', 'die', 'das', 'den', 'dem', 'denen'];

    final options = <String>[expected];
    for (final candidate in candidates) {
      if (candidate != expected && !options.contains(candidate)) {
        options.add(candidate);
      }
      if (options.length == 4) break;
    }
    return List<String>.unmodifiable(options);
  }

  @override
  Future<bool> validatePronoun(
    String challengeId,
    String pronoun,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;
    return _normalizeToken(pronoun) ==
        _normalizeToken(challenge.expectedPronoun);
  }

  @override
  Future<bool> validateSentence(
    String challengeId,
    String sentence,
  ) async {
    final challenge = _find(challengeId);
    if (challenge == null) return false;
    return _normalizeSentence(sentence) ==
        _normalizeSentence(challenge.correctSentence);
  }

  static RelativeClauseChallengeItem? _find(String id) {
    final normalizedId = id.trim();
    for (final item in _bank) {
      if (item.id == normalizedId) return item;
    }
    return null;
  }

  static String _normalizeToken(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _normalizeSentence(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' ,', ',')
        .replaceAll(' .', '.')
        .replaceAll(' ?', '?')
        .replaceAll(' !', '!')
        .replaceAll(RegExp(r'[.!?]+$'), '')
        .trim();
  }
}
