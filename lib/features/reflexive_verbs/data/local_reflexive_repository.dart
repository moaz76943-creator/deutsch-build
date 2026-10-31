import '../domain/reflexive_models.dart';
import '../domain/reflexive_repository.dart';

final class LocalReflexiveRepository implements ReflexiveRepository {
  const LocalReflexiveRepository();

  static const List<ReflexiveDrillItem> _drills = <ReflexiveDrillItem>[
    ReflexiveDrillItem(
      id: 'beeilen_ich_akk',
      infinitiveWithSich: 'sich beeilen',
      subjectPronoun: 'ich',
      reflexivePronoun: 'mich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ مستقل، لذلك يأخذ الضمير الانعكاسي حالة Akkusativ.',
      contextSentence: 'Ich beeile mich, damit ich pünktlich zur Arbeit komme.',
      translationAr: 'أستعجل لكي أصل إلى العمل في الوقت المحدد.',
      explanationAr:
          'مع ich في Akkusativ نستخدم mich. الفعل sich beeilen يُستعمل انعكاسياً.',
    ),
    ReflexiveDrillItem(
      id: 'erinnern_du_akk',
      infinitiveWithSich: 'sich erinnern',
      subjectPronoun: 'du',
      reflexivePronoun: 'dich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'الفعل هنا بلا مفعول Akkusativ إضافي، لذا يكون الضمير الانعكاسي Akkusativ.',
      contextSentence: 'Du erinnerst dich an den Termin morgen.',
      translationAr: 'أنت تتذكر موعد الغد.',
      explanationAr:
          'مع du في Akkusativ نستخدم dich: du erinnerst dich.',
    ),
    ReflexiveDrillItem(
      id: 'schaemen_er_akk',
      infinitiveWithSich: 'sich schämen',
      subjectPronoun: 'er',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ مستقل؛ ومع er يكون الضمير الانعكاسي sich.',
      contextSentence: 'Er schämt sich für seinen Fehler.',
      translationAr: 'هو يشعر بالخجل من خطئه.',
      explanationAr:
          'مع er لا تتغير صيغة sich بين Akkusativ وDativ، لذلك نحدد الحالة من بنية الجملة.',
    ),
    ReflexiveDrillItem(
      id: 'erkundigen_sie_akk',
      infinitiveWithSich: 'sich erkundigen',
      subjectPronoun: 'sie',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'sich erkundigen فعل انعكاسي، ولا يوجد هنا مفعول Akkusativ إضافي.',
      contextSentence: 'Sie erkundigt sich nach dem Fahrplan.',
      translationAr: 'هي تستفسر عن جدول المواصلات.',
      explanationAr:
          'مع sie المفرد نستخدم sich في هذا الاستعمال الانعكاسي.',
    ),
    ReflexiveDrillItem(
      id: 'freuen_wir_akk',
      infinitiveWithSich: 'sich freuen',
      subjectPronoun: 'wir',
      reflexivePronoun: 'uns',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ إضافي، فيبقى الضمير الانعكاسي في Akkusativ.',
      contextSentence: 'Wir freuen uns auf das Wochenende.',
      translationAr: 'نحن نتطلع إلى عطلة نهاية الأسبوع.',
      explanationAr:
          'مع wir نستخدم uns في Akkusativ وكذلك Dativ؛ الحالة تُفهم من تركيب الجملة.',
    ),
    ReflexiveDrillItem(
      id: 'ausruhen_ihr_akk',
      infinitiveWithSich: 'sich ausruhen',
      subjectPronoun: 'ihr',
      reflexivePronoun: 'euch',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ مستقل، لذلك يكون euch هنا ضميراً انعكاسياً في Akkusativ.',
      contextSentence: 'Ihr ruht euch nach der Wanderung aus.',
      translationAr: 'أنتم ترتاحون بعد المشي الطويل.',
      explanationAr:
          'مع ihr يكون الضمير الانعكاسي euch في الحالتين، ونحدد الحالة من البنية.',
    ),
    ReflexiveDrillItem(
      id: 'befinden_sie_plural_akk',
      infinitiveWithSich: 'sich befinden',
      subjectPronoun: 'sie',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.trueReflexive,
      caseReasonAr:
          'الفعل sich befinden انعكاسي، ولا يوجد مفعول Akkusativ إضافي.',
      contextSentence: 'Sie befinden sich vor dem Bahnhof.',
      translationAr: 'هم موجودون أمام محطة القطار.',
      explanationAr:
          'مع sie الجمع نستخدم sich؛ وهنا الضمير في Akkusativ.',
    ),
    ReflexiveDrillItem(
      id: 'waschen_ich_akk',
      infinitiveWithSich: 'sich waschen',
      subjectPronoun: 'ich',
      reflexivePronoun: 'mich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ آخر؛ الشخص نفسه هو المفعول، لذلك نستخدم mich.',
      contextSentence: 'Ich wasche mich vor dem Frühstück.',
      translationAr: 'أغتسل قبل الإفطار.',
      explanationAr:
          'عندما أغسل نفسي كاملةً نقول mich. إذا ذكرت جزءاً مثل die Hände يصبح الضمير mir.',
    ),
    ReflexiveDrillItem(
      id: 'anziehen_du_akk',
      infinitiveWithSich: 'sich anziehen',
      subjectPronoun: 'du',
      reflexivePronoun: 'dich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ إضافي؛ du نفسه هو المفعول، لذلك نستخدم dich.',
      contextSentence: 'Du ziehst dich schnell an.',
      translationAr: 'أنت ترتدي ملابسك بسرعة.',
      explanationAr:
          'مع du في Akkusativ نستخدم dich عندما لا نذكر قطعة ملابس كمفعول مستقل.',
    ),
    ReflexiveDrillItem(
      id: 'rasieren_er_akk',
      infinitiveWithSich: 'sich rasieren',
      subjectPronoun: 'er',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      caseReasonAr:
          'لا يوجد مفعول Akkusativ مستقل؛ er يحلق نفسه، لذلك يكون sich هنا Akkusativ.',
      contextSentence: 'Er rasiert sich vor der Arbeit.',
      translationAr: 'هو يحلق ذقنه قبل العمل.',
      explanationAr:
          'مع er نستخدم sich؛ تحديد Akkusativ يأتي من عدم وجود مفعول Akkusativ آخر.',
    ),
    ReflexiveDrillItem(
      id: 'treffen_wir_reciprocal_akk',
      infinitiveWithSich: 'sich treffen',
      subjectPronoun: 'wir',
      reflexivePronoun: 'uns',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.reciprocal,
      caseReasonAr:
          'uns هنا متبادل بمعنى بعضنا بعضاً، وهو مفعول Akkusativ للفعل treffen.',
      contextSentence: 'Wir treffen uns vor dem Kino.',
      translationAr: 'نلتقي ببعضنا أمام السينما.',
      explanationAr:
          'مع wir يكون الاستعمال تبادلياً: uns تعني بعضنا بعضاً.',
    ),
    ReflexiveDrillItem(
      id: 'unterhalten_ihr_reciprocal_akk',
      infinitiveWithSich: 'sich unterhalten',
      subjectPronoun: 'ihr',
      reflexivePronoun: 'euch',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.reciprocal,
      caseReasonAr:
          'euch هنا يشير إلى تفاعل متبادل بين أفراد المجموعة، ولا يوجد مفعول Akkusativ آخر.',
      contextSentence: 'Ihr unterhaltet euch über den Deutschkurs.',
      translationAr: 'أنتم تتحدثون مع بعضكم عن دورة الألمانية.',
      explanationAr:
          'مع ihr نستخدم euch، وهنا المعنى تبادلي بين أكثر من شخص.',
    ),
    ReflexiveDrillItem(
      id: 'begruessen_sie_reciprocal_akk',
      infinitiveWithSich: 'sich begrüßen',
      subjectPronoun: 'sie',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.akkusativ,
      reflexiveType: ReflexiveType.reciprocal,
      caseReasonAr:
          'sich هنا تبادلي بمعنى أن الأشخاص يحيّي بعضهم بعضاً، وهو Akkusativ.',
      contextSentence: 'Sie begrüßen sich am Eingang.',
      translationAr: 'هم يحيّون بعضهم عند المدخل.',
      explanationAr:
          'مع sie الجمع نستخدم sich، والمعنى هنا متبادل لا انعكاسي فردي.',
    ),
    ReflexiveDrillItem(
      id: 'haende_waschen_ich_dat',
      infinitiveWithSich: 'sich die Hände waschen',
      subjectPronoun: 'ich',
      reflexivePronoun: 'mir',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'die Hände',
      caseReasonAr:
          'die Hände هي المفعول Akkusativ المباشر؛ لذلك يتحول الضمير الانعكاسي إلى Dativ: mir.',
      contextSentence: 'Ich wasche mir vor dem Essen die Hände.',
      translationAr: 'أغسل يديّ قبل الطعام.',
      explanationAr:
          'وجود die Hände كمفعول مباشر يجعل الضمير مع ich هو mir وليس mich.',
    ),
    ReflexiveDrillItem(
      id: 'zaehne_putzen_du_dat',
      infinitiveWithSich: 'sich die Zähne putzen',
      subjectPronoun: 'du',
      reflexivePronoun: 'dir',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'die Zähne',
      caseReasonAr:
          'die Zähne مفعول Akkusativ مستقل؛ لذلك نستخدم dir كضمير انعكاسي في Dativ.',
      contextSentence: 'Du putzt dir nach dem Frühstück die Zähne.',
      translationAr: 'أنت تنظف أسنانك بعد الإفطار.',
      explanationAr:
          'مع du: dich في Akkusativ، لكن مع مفعول مباشر مثل die Zähne نستخدم dir.',
    ),
    ReflexiveDrillItem(
      id: 'jacke_anziehen_er_dat',
      infinitiveWithSich: 'sich die Jacke anziehen',
      subjectPronoun: 'er',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'die Jacke',
      caseReasonAr:
          'die Jacke هي المفعول Akkusativ؛ لذلك الضمير الانعكاسي نحويّاً Dativ رغم أن شكله يبقى sich.',
      contextSentence: 'Er zieht sich vor dem Ausgang die Jacke an.',
      translationAr: 'هو يرتدي سترته قبل الخروج.',
      explanationAr:
          'مع er يبقى الشكل sich في الحالتين، لكن وجود die Jacke يكشف أن الحالة Dativ.',
    ),
    ReflexiveDrillItem(
      id: 'haare_kaemmen_sie_dat',
      infinitiveWithSich: 'sich die Haare kämmen',
      subjectPronoun: 'sie',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'die Haare',
      caseReasonAr:
          'die Haare مفعول Akkusativ مباشر، ولذلك يكون sich هنا في Dativ.',
      contextSentence: 'Sie kämmt sich morgens die Haare.',
      translationAr: 'هي تمشط شعرها صباحاً.',
      explanationAr:
          'وجود die Haare يجعل الضمير الانعكاسي Dativ، حتى لو بقي شكله sich.',
    ),
    ReflexiveDrillItem(
      id: 'pause_goennen_wir_dat',
      infinitiveWithSich: 'sich eine Pause gönnen',
      subjectPronoun: 'wir',
      reflexivePronoun: 'uns',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'eine Pause',
      caseReasonAr:
          'eine Pause هي المفعول Akkusativ، وuns يشير إلى المستفيد في Dativ.',
      contextSentence: 'Wir gönnen uns nach der Arbeit eine Pause.',
      translationAr: 'نمنح أنفسنا استراحة بعد العمل.',
      explanationAr:
          'uns لا يتغير شكله بين الحالتين؛ وجود eine Pause يثبت أن الحالة هنا Dativ.',
    ),
    ReflexiveDrillItem(
      id: 'kaffee_bestellen_ihr_dat',
      infinitiveWithSich: 'sich einen Kaffee bestellen',
      subjectPronoun: 'ihr',
      reflexivePronoun: 'euch',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'einen Kaffee',
      caseReasonAr:
          'einen Kaffee مفعول Akkusativ مباشر؛ euch هو المستفيد ولذلك حالته Dativ.',
      contextSentence: 'Ihr bestellt euch im Café einen Kaffee.',
      translationAr: 'أنتم تطلبون لأنفسكم قهوة في المقهى.',
      explanationAr:
          'مع ihr يبقى الشكل euch، لكن وجود einen Kaffee يحدد Dativ.',
    ),
    ReflexiveDrillItem(
      id: 'schuhe_kaufen_sie_dat',
      infinitiveWithSich: 'sich neue Schuhe kaufen',
      subjectPronoun: 'sie',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'neue Schuhe',
      caseReasonAr:
          'neue Schuhe هو المفعول Akkusativ؛ sich هنا ضمير المستفيد في Dativ.',
      contextSentence: 'Sie kaufen sich für den Winter neue Schuhe.',
      translationAr: 'هم يشترون لأنفسهم أحذية جديدة للشتاء.',
      explanationAr:
          'مع sie يبقى sich، ويكشف المفعول neue Schuhe أن الحالة Dativ.',
    ),
    ReflexiveDrillItem(
      id: 'adresse_merken_ich_dat',
      infinitiveWithSich: 'sich eine Adresse merken',
      subjectPronoun: 'ich',
      reflexivePronoun: 'mir',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'die Adresse',
      caseReasonAr:
          'die Adresse مفعول Akkusativ؛ لذلك يأتي الضمير مع ich بصيغة Dativ: mir.',
      contextSentence: 'Ich merke mir die Adresse des Hotels.',
      translationAr: 'أحفظ عنوان الفندق في ذهني.',
      explanationAr:
          'في تركيب sich etwas merken نستخدم mir مع ich لأن الشيء المحفوظ هو المفعول المباشر.',
    ),
    ReflexiveDrillItem(
      id: 'zeit_nehmen_du_dat',
      infinitiveWithSich: 'sich Zeit nehmen',
      subjectPronoun: 'du',
      reflexivePronoun: 'dir',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'Zeit',
      caseReasonAr:
          'Zeit هي المفعول المباشر؛ لذلك يكون الضمير مع du هو dir في Dativ.',
      contextSentence: 'Du nimmst dir für die Aufgabe genug Zeit.',
      translationAr: 'أنت تمنح نفسك وقتاً كافياً للمهمة.',
      explanationAr:
          'في sich Zeit nehmen نستخدم dir مع du لأن Zeit تشغل موقع المفعول المباشر.',
    ),
    ReflexiveDrillItem(
      id: 'kaffee_wuenschen_er_dat',
      infinitiveWithSich: 'sich einen Kaffee wünschen',
      subjectPronoun: 'er',
      reflexivePronoun: 'sich',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.optionalReflexive,
      additionalObject: 'einen Kaffee',
      caseReasonAr:
          'einen Kaffee مفعول Akkusativ، لذلك يكون sich هنا في Dativ.',
      contextSentence: 'Er wünscht sich nach dem Essen einen Kaffee.',
      translationAr: 'هو يرغب في قهوة بعد الطعام.',
      explanationAr:
          'مع er يبقى الضمير sich؛ وجود einen Kaffee يبين أن وظيفته Dativ.',
    ),
    ReflexiveDrillItem(
      id: 'helfen_wir_reciprocal_dat',
      infinitiveWithSich: 'sich helfen',
      subjectPronoun: 'wir',
      reflexivePronoun: 'uns',
      reflexiveCase: ReflexiveCase.dativ,
      reflexiveType: ReflexiveType.reciprocal,
      caseReasonAr:
          'الفعل helfen نفسه يطلب Dativ، وuns هنا تبادلي بمعنى نساعد بعضنا بعضاً.',
      contextSentence: 'Wir helfen uns bei den Hausaufgaben.',
      translationAr: 'نساعد بعضنا بعضاً في الواجبات.',
      explanationAr:
          'هذه حالة Dativ بسبب قاعدة helfen، وليست بسبب وجود مفعول Akkusativ إضافي.',
    ),
  ];

  static const Map<String, Map<ReflexiveCase, String>> _pronouns =
      <String, Map<ReflexiveCase, String>>{
    'ich': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'mich',
      ReflexiveCase.dativ: 'mir',
    },
    'du': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'dich',
      ReflexiveCase.dativ: 'dir',
    },
    'er': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'sich',
      ReflexiveCase.dativ: 'sich',
    },
    'sie': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'sich',
      ReflexiveCase.dativ: 'sich',
    },
    'es': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'sich',
      ReflexiveCase.dativ: 'sich',
    },
    'wir': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'uns',
      ReflexiveCase.dativ: 'uns',
    },
    'ihr': <ReflexiveCase, String>{
      ReflexiveCase.akkusativ: 'euch',
      ReflexiveCase.dativ: 'euch',
    },
  };

  @override
  List<ReflexiveDrillItem> get allDrills =>
      List<ReflexiveDrillItem>.unmodifiable(_drills);

  @override
  ReflexiveDrillItem? byId(String id) {
    final normalized = id.trim();
    for (final item in _drills) {
      if (item.id == normalized) return item;
    }
    return null;
  }

  @override
  List<ReflexiveDrillItem> forCase(ReflexiveCase reflexCase) =>
      List<ReflexiveDrillItem>.unmodifiable(
        _drills.where((item) => item.reflexiveCase == reflexCase),
      );

  @override
  bool isCorrectPronoun(
    ReflexiveDrillItem item,
    String candidate,
  ) =>
      normalizePronoun(candidate) ==
      normalizePronoun(item.reflexivePronoun);

  @override
  bool isCorrectCase(
    ReflexiveDrillItem item,
    ReflexiveCase candidate,
  ) =>
      item.reflexiveCase == candidate;

  @override
  String? expectedPronoun({
    required String subjectPronoun,
    required ReflexiveCase reflexCase,
  }) {
    final subject = normalizePronoun(subjectPronoun);
    return _pronouns[subject]?[reflexCase];
  }

  @override
  String normalizePronoun(String value) => value.trim().toLowerCase();
}
