import '../domain/separable_verbs_models.dart';
import '../domain/separable_verbs_repository.dart';

final class LocalSeparableVerbsRepository
    implements SeparableVerbsRepository {
  LocalSeparableVerbsRepository();

  static final List<VerbPrefixDrillItem> _drills =
      <VerbPrefixDrillItem>[
    _item(
      id: 'sep_an_anrufen',
      infinitive: 'anrufen',
      prefix: 'an',
      root: 'rufen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ meine Mutter heute Abend ___.',
      completed: 'Ich rufe meine Mutter heute Abend an.',
      translation: 'أتصل بوالدتي هذا المساء.',
      meaning:
          'anrufen يعني الاتصال هاتفيًا؛ السابقة an تنفصل في الجملة الرئيسية.',
      rule:
          'السابقة an انفصالية هنا: الفعل المصرف rufe يأتي في الموقع الثاني، '
          'وتنتقل an إلى نهاية الجملة.',
      subject: 'ich',
      conjugated: 'rufe',
      choices: <String>['rufe', 'anrufe', 'rufst'],
    ),
    _item(
      id: 'sep_auf_aufstehen',
      infinitive: 'aufstehen',
      prefix: 'auf',
      root: 'stehen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ jeden Tag um sieben Uhr ___.',
      completed: 'Ich stehe jeden Tag um sieben Uhr auf.',
      translation: 'أستيقظ كل يوم الساعة السابعة.',
      meaning:
          'aufstehen يعني النهوض أو الاستيقاظ؛ auf تضيف معنى الصعود/القيام.',
      rule:
          'السابقة auf انفصالية: stehe في الموقع الثاني، وauf في Satzende.',
      subject: 'ich',
      conjugated: 'stehe',
      choices: <String>['stehe', 'aufstehe', 'steht'],
    ),
    _item(
      id: 'sep_aus_ausgehen',
      infinitive: 'ausgehen',
      prefix: 'aus',
      root: 'gehen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Wir ___ am Samstag zusammen ___.',
      completed: 'Wir gehen am Samstag zusammen aus.',
      translation: 'نخرج معًا يوم السبت.',
      meaning:
          'ausgehen يعني الخروج للترفيه؛ aus تضيف معنى الخروج إلى الخارج.',
      rule:
          'مع aus الانفصالية يبقى gehen مصرفًا في الموقع الثاني، '
          'وتأتي aus في نهاية الجملة.',
      subject: 'wir',
      conjugated: 'gehen',
      choices: <String>['gehen', 'ausgehen', 'geht'],
    ),
    _item(
      id: 'sep_ein_einkaufen',
      infinitive: 'einkaufen',
      prefix: 'ein',
      root: 'kaufen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ nach der Arbeit ___.',
      completed: 'Ich kaufe nach der Arbeit ein.',
      translation: 'أتسوق بعد العمل.',
      meaning:
          'einkaufen يعني التسوق؛ ein مع kaufen يعطي التعبير اليومي للتسوق.',
      rule:
          'السابقة ein تنفصل: kaufe في الموقع الثاني وein في النهاية.',
      subject: 'ich',
      conjugated: 'kaufe',
      choices: <String>['kaufe', 'einkaufe', 'kauft'],
    ),
    _item(
      id: 'sep_mit_mitkommen',
      infinitive: 'mitkommen',
      prefix: 'mit',
      root: 'kommen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ gern ins Café ___.',
      completed: 'Ich komme gern ins Café mit.',
      translation: 'آتي معكم إلى المقهى بسرور.',
      meaning:
          'mitkommen يعني المجيء مع شخص؛ mit تضيف معنى المشاركة والمرافقة.',
      rule:
          'mit انفصالية: komme يأتي في الموقع الثاني، وmit في نهاية الجملة.',
      subject: 'ich',
      conjugated: 'komme',
      choices: <String>['komme', 'mitkomme', 'kommt'],
    ),
    _item(
      id: 'sep_vor_vorstellen',
      infinitive: 'vorstellen',
      prefix: 'vor',
      root: 'stellen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ mich kurz ___.',
      completed: 'Ich stelle mich kurz vor.',
      translation: 'أعرّف بنفسي باختصار.',
      meaning:
          'sich vorstellen يعني تقديم النفس؛ vor تنفصل في هذا المعنى.',
      rule:
          'vor انفصالية هنا: stelle في الموقع الثاني وvor في Satzende.',
      subject: 'ich',
      conjugated: 'stelle',
      choices: <String>['stelle', 'vorstelle', 'stellt'],
    ),
    _item(
      id: 'sep_zu_zumachen',
      infinitive: 'zumachen',
      prefix: 'zu',
      root: 'machen',
      type: PrefixType.separable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ die Tür leise ___.',
      completed: 'Ich mache die Tür leise zu.',
      translation: 'أغلق الباب بهدوء.',
      meaning:
          'zumachen يعني الإغلاق؛ zu تضيف معنى الإغلاق إلى machen.',
      rule:
          'zu انفصالية في zumachen: mache في الموقع الثاني وzu في النهاية.',
      subject: 'ich',
      conjugated: 'mache',
      choices: <String>['mache', 'zumache', 'macht'],
    ),
    _item(
      id: 'insep_be_bezahlen',
      infinitive: 'bezahlen',
      prefix: 'be',
      root: 'zahlen',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ die Rechnung sofort.',
      completed: 'Ich bezahle die Rechnung sofort.',
      translation: 'أدفع الفاتورة فورًا.',
      meaning:
          'bezahlen يعني الدفع مقابل شيء؛ be تبقى جزءًا من الفعل المصرف.',
      rule:
          'be سابقة غير انفصالية: bezahle يبقى كاملًا في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'bezahle',
      choices: <String>['bezahle', 'zahle', 'bezahlt'],
    ),
    _item(
      id: 'insep_emp_empfehlen',
      infinitive: 'empfehlen',
      prefix: 'emp',
      root: 'fehlen',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ dir diesen Kurs.',
      completed: 'Ich empfehle dir diesen Kurs.',
      translation: 'أنصحك بهذه الدورة.',
      meaning:
          'empfehlen يعني التوصية أو النصح؛ emp لا تنفصل عن الفعل.',
      rule:
          'emp غير انفصالية: empfehle يظهر كفعل واحد في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'empfehle',
      choices: <String>['empfehle', 'fehle', 'empfiehlst'],
    ),
    _item(
      id: 'insep_ent_entdecken',
      infinitive: 'entdecken',
      prefix: 'ent',
      root: 'decken',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ heute ein neues Café.',
      completed: 'Ich entdecke heute ein neues Café.',
      translation: 'أكتشف اليوم مقهى جديدًا.',
      meaning:
          'entdecken يعني الاكتشاف؛ ent تبقى متصلة في التصريف.',
      rule:
          'ent غير انفصالية: entdecke كاملًا في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'entdecke',
      choices: <String>['entdecke', 'decke', 'entdeckst'],
    ),
    _item(
      id: 'insep_er_erzaehlen',
      infinitive: 'erzählen',
      prefix: 'er',
      root: 'zählen',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ dir später die Geschichte.',
      completed: 'Ich erzähle dir später die Geschichte.',
      translation: 'أحكي لك القصة لاحقًا.',
      meaning:
          'erzählen يعني الحكي أو السرد؛ er لا تنفصل هنا.',
      rule:
          'er غير انفصالية: erzähle يبقى متصلًا في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'erzähle',
      choices: <String>['erzähle', 'zähle', 'erzählst'],
    ),
    _item(
      id: 'insep_ge_gehoeren',
      infinitive: 'gehören',
      prefix: 'ge',
      root: 'hören',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Das Buch ___ mir.',
      completed: 'Das Buch gehört mir.',
      translation: 'الكتاب لي.',
      meaning:
          'gehören يعني أن يكون الشيء مملوكًا لشخص؛ ge لا تنفصل.',
      rule:
          'ge غير انفصالية في gehören: gehört يبقى كاملًا في الموقع الثاني.',
      subject: 'das Buch',
      conjugated: 'gehört',
      choices: <String>['gehört', 'hört', 'gehöre'],
    ),
    _item(
      id: 'insep_miss_missverstehen',
      infinitive: 'missverstehen',
      prefix: 'miss',
      root: 'verstehen',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ deine Frage.',
      completed: 'Ich missverstehe deine Frage.',
      translation: 'أسيء فهم سؤالك.',
      meaning:
          'missverstehen يعني الفهم الخاطئ؛ miss تضيف معنى الخطأ ولا تنفصل.',
      rule:
          'miss غير انفصالية: missverstehe يبقى فعلًا واحدًا في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'missverstehe',
      choices: <String>['missverstehe', 'verstehe', 'missverstehst'],
    ),
    _item(
      id: 'insep_ver_verstehen',
      infinitive: 'verstehen',
      prefix: 'ver',
      root: 'stehen',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ die Erklärung jetzt.',
      completed: 'Ich verstehe die Erklärung jetzt.',
      translation: 'أفهم الشرح الآن.',
      meaning:
          'verstehen يعني الفهم؛ ver جزء ثابت من الفعل ولا ينفصل.',
      rule:
          'ver من السوابق غير الانفصالية الصارمة: verstehe كاملًا في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'verstehe',
      choices: <String>['verstehe', 'stehe', 'versteht'],
    ),
    _item(
      id: 'insep_zer_zerstoeren',
      infinitive: 'zerstören',
      prefix: 'zer',
      root: 'stören',
      type: PrefixType.inseparable,
      placement: PrefixPlacement.position2Attached,
      template: 'Der Sturm ___ das alte Dach.',
      completed: 'Der Sturm zerstört das alte Dach.',
      translation: 'العاصفة تدمر السقف القديم.',
      meaning:
          'zerstören يعني التدمير؛ zer تحمل معنى التفكيك/التخريب ولا تنفصل.',
      rule:
          'zer غير انفصالية: zerstört يبقى كاملًا في الموقع الثاني.',
      subject: 'der Sturm',
      conjugated: 'zerstört',
      choices: <String>['zerstört', 'stört', 'zerstöre'],
    ),
    _item(
      id: 'dual_ueber_translate',
      infinitive: 'übersetzen',
      prefix: 'über',
      root: 'setzen',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ den Text ins Arabische.',
      completed: 'Ich übersetze den Text ins Arabische.',
      translation: 'أترجم النص إلى العربية.',
      meaning:
          'übersetzen بنبر غير بارز على السابقة يعني الترجمة؛ السابقة تبقى متصلة.',
      rule:
          'über من السوابق المتغيرة. في معنى الترجمة لا تنفصل: übersetze في الموقع الثاني.',
      subject: 'ich',
      conjugated: 'übersetze',
      choices: <String>['übersetze', 'setze', 'übersetzt'],
    ),
    _item(
      id: 'dual_ueber_cross',
      infinitive: 'übersetzen',
      prefix: 'über',
      root: 'setzen',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ die Gäste mit dem Boot ___.',
      completed: 'Ich setze die Gäste mit dem Boot über.',
      translation: 'أنقل الضيوف بالقارب إلى الضفة الأخرى.',
      meaning:
          'über|setzen مع نبر على السابقة يعني نقل شخص إلى الجهة الأخرى؛ هنا تنفصل.',
      rule:
          'über متغيرة. في معنى العبور/النقل تكون انفصالية: setze في الموقع الثاني وüber في النهاية.',
      subject: 'ich',
      conjugated: 'setze',
      choices: <String>['setze', 'übersetze', 'setzt'],
    ),
    _item(
      id: 'dual_unter_impute',
      infinitive: 'unterstellen',
      prefix: 'unter',
      root: 'stellen',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ ihm keine böse Absicht.',
      completed: 'Ich unterstelle ihm keine böse Absicht.',
      translation: 'لا أنسب إليه نية سيئة.',
      meaning:
          'unterstellen هنا يعني نسب أمر أو اتهام ضمني؛ السابقة لا تنفصل.',
      rule:
          'unter متغيرة. في معنى الاتهام/النسب تبقى متصلة: unterstelle.',
      subject: 'ich',
      conjugated: 'unterstelle',
      choices: <String>['unterstelle', 'stelle', 'unterstellt'],
    ),
    _item(
      id: 'dual_unter_shelter',
      infinitive: 'unterstellen',
      prefix: 'unter',
      root: 'stellen',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ das Fahrrad im Hof ___.',
      completed: 'Ich stelle das Fahrrad im Hof unter.',
      translation: 'أضع الدراجة في مكان مسقوف في الساحة.',
      meaning:
          'unter|stellen هنا يعني وضع الشيء تحت ساتر أو في مأوى؛ السابقة تنفصل.',
      rule:
          'unter متغيرة. في المعنى المكاني تكون انفصالية: stelle ... unter.',
      subject: 'ich',
      conjugated: 'stelle',
      choices: <String>['stelle', 'unterstelle', 'stellt'],
    ),
    _item(
      id: 'dual_um_avoid',
      infinitive: 'umfahren',
      prefix: 'um',
      root: 'fahren',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.position2Attached,
      template: 'Ich ___ die Baustelle.',
      completed: 'Ich umfahre die Baustelle.',
      translation: 'أتجاوز موقع الأشغال بالالتفاف حوله.',
      meaning:
          'umfahren هنا يعني القيادة حول عائق وتجاوزه؛ السابقة تبقى متصلة.',
      rule:
          'um متغيرة. في معنى الالتفاف حول شيء لا تنفصل: umfahre.',
      subject: 'ich',
      conjugated: 'umfahre',
      choices: <String>['umfahre', 'fahre', 'umfährst'],
    ),
    _item(
      id: 'dual_um_knock',
      infinitive: 'umfahren',
      prefix: 'um',
      root: 'fahren',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Ich ___ den leichten Kegel versehentlich ___.',
      completed: 'Ich fahre den leichten Kegel versehentlich um.',
      translation: 'أصدم المخروط الخفيف بالخطأ فيسقط.',
      meaning:
          'um|fahren هنا يعني إسقاط شيء بالاصطدام به؛ السابقة تنفصل.',
      rule:
          'um متغيرة. في معنى إسقاط الشيء بالاصطدام تكون انفصالية: fahre ... um.',
      subject: 'ich',
      conjugated: 'fahre',
      choices: <String>['fahre', 'umfahre', 'fährst'],
    ),
    _item(
      id: 'dual_durch_cross',
      infinitive: 'durchqueren',
      prefix: 'durch',
      root: 'queren',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.position2Attached,
      template: 'Wir ___ den Park zu Fuß.',
      completed: 'Wir durchqueren den Park zu Fuß.',
      translation: 'نعبر الحديقة سيرًا على الأقدام.',
      meaning:
          'durchqueren يعني اجتياز مكان من طرف إلى آخر؛ durch لا تنفصل في هذا الفعل.',
      rule:
          'durch من السوابق التي قد تتغير حسب الفعل والمعنى، '
          'لكنها في durchqueren تبقى متصلة: durchqueren في الموقع الثاني.',
      subject: 'wir',
      conjugated: 'durchqueren',
      choices: <String>['durchqueren', 'queren', 'durchquert'],
    ),
    _item(
      id: 'dual_durch_review',
      infinitive: 'durchgehen',
      prefix: 'durch',
      root: 'gehen',
      type: PrefixType.dualVariable,
      placement: PrefixPlacement.sentenceEndDetached,
      template: 'Wir ___ den Plan noch einmal ___.',
      completed: 'Wir gehen den Plan noch einmal durch.',
      translation: 'نراجع الخطة مرة أخرى خطوة بخطوة.',
      meaning:
          'durch|gehen هنا يعني مراجعة شيء بالكامل؛ السابقة تنفصل.',
      rule:
          'durch متغيرة. في معنى المراجعة الكاملة تكون انفصالية: gehen ... durch.',
      subject: 'wir',
      conjugated: 'gehen',
      choices: <String>['gehen', 'durchgehen', 'geht'],
    ),
  ];

  late final Map<String, VerbPrefixDrillItem> _byId =
      <String, VerbPrefixDrillItem>{
    for (final item in _drills) item.id: item,
  };

  @override
  Future<List<VerbPrefixDrillItem>> getDrills() async =>
      List<VerbPrefixDrillItem>.unmodifiable(_drills);

  @override
  Future<bool> validateAnswer({
    required String drillId,
    required PrefixPlacement selectedPlacement,
    required String conjugatedVerb,
  }) async {
    final item = _byId[drillId];
    if (item == null) return false;

    final normalizedVerb = conjugatedVerb.trim().toLowerCase();
    return selectedPlacement == item.expectedPlacement &&
        normalizedVerb == item.expectedConjugatedVerb.toLowerCase();
  }
}

VerbPrefixDrillItem _item({
  required String id,
  required String infinitive,
  required String prefix,
  required String root,
  required PrefixType type,
  required PrefixPlacement placement,
  required String template,
  required String completed,
  required String translation,
  required String meaning,
  required String rule,
  required String subject,
  required String conjugated,
  required List<String> choices,
}) =>
    VerbPrefixDrillItem(
      id: id,
      fullInfinitive: infinitive,
      prefix: prefix,
      rootVerb: root,
      prefixType: type,
      ruleExplanation: rule,
      expectedPlacement: placement,
      trainingSentenceTemplate: template,
      completedSentence: completed,
      arabicTranslation: translation,
      meaningExplanationAr: meaning,
      subjectPronoun: subject,
      expectedConjugatedVerb: conjugated,
      conjugationChoices: choices,
    );
