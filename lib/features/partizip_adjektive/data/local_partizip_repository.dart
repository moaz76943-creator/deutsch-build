import '../domain/partizip_models.dart';
import '../domain/partizip_repository.dart';

final class LocalPartizipRepository implements PartizipRepository {
  LocalPartizipRepository();

  static final List<PartizipExercise> _exercises = <PartizipExercise>[
    PartizipExercise(
      id: 'p1_child_smiling',
      infinitive: 'lächeln',
      participle: 'lächelnd',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.simple,
      noun: 'Kind',
      correctAttribute: 'lächelndes Kind',
      sourceSentenceDe:
          'Ein lächelndes Kind begrüßt seine Lehrerin am Morgen.',
      translationAr:
          'طفل مبتسم يحيّي معلمته في الصباح.',
      explanationAr:
          'Partizip I يصف فعلاً نشطاً ومتزامناً: الطفل هو الذي يبتسم، لذلك تتحول lächelnd إلى lächelndes قبل Kind.',
      attributeTokens: <String>['lächelndes', 'Kind'],
    ),
    PartizipExercise(
      id: 'p1_plant_growing',
      infinitive: 'wachsen',
      participle: 'wachsend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.simple,
      noun: 'Pflanze',
      correctAttribute: 'die wachsende Pflanze',
      sourceSentenceDe:
          'Die wachsende Pflanze reagiert deutlich auf die veränderte Lichtmenge.',
      translationAr:
          'النبتة التي تنمو تستجيب بوضوح لكمية الضوء المتغيرة.',
      explanationAr:
          'Partizip I يصف فعلاً يحدث بالتزامن مع الاسم: النبتة هي التي تنمو الآن، لذلك نستخدم wachsend مع نهاية الصفة المناسبة.',
      attributeTokens: <String>['die', 'wachsende', 'Pflanze'],
    ),
    PartizipExercise(
      id: 'p1_plant_extended',
      infinitive: 'wachsen',
      participle: 'wachsend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.extended,
      noun: 'Pflanze',
      correctAttribute:
          'die unter kontrolliertem Licht schnell wachsende Pflanze',
      sourceSentenceDe:
          'Die unter kontrolliertem Licht schnell wachsende Pflanze wird täglich vermessen.',
      translationAr:
          'النبتة التي تنمو بسرعة تحت ضوء مضبوط تُقاس يومياً.',
      explanationAr:
          'في الوصف الموسّع تأتي تفاصيل الظرف قبل Partizip I كله داخل المجموعة الوصفية السابقة للاسم.',
      attributeTokens: <String>[
        'die',
        'unter',
        'kontrolliertem',
        'Licht',
        'schnell',
        'wachsende',
        'Pflanze',
      ],
    ),
    PartizipExercise(
      id: 'p1_researchers_extended',
      infinitive: 'forschen',
      participle: 'forschend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.extended,
      noun: 'Wissenschaftler',
      correctAttribute:
          'die seit Jahren an diesem Problem forschenden Wissenschaftler',
      sourceSentenceDe:
          'Die seit Jahren an diesem Problem forschenden Wissenschaftler vergleichen neue Datensätze.',
      translationAr:
          'العلماء الذين يبحثون في هذه المشكلة منذ سنوات يقارنون مجموعات بيانات جديدة.',
      explanationAr:
          'العلماء هم من يقومون بالبحث، لذا نستخدم Partizip I. وبسبب الجمع مع die تأخذ الصفة المشتقة النهاية -en.',
      attributeTokens: <String>[
        'die',
        'seit',
        'Jahren',
        'an',
        'diesem',
        'Problem',
        'forschenden',
        'Wissenschaftler',
      ],
    ),
    PartizipExercise(
      id: 'p1_machine_running',
      infinitive: 'laufen',
      participle: 'laufend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.extended,
      noun: 'Maschine',
      correctAttribute: 'die mit hoher Drehzahl laufende Maschine',
      sourceSentenceDe:
          'Die mit hoher Drehzahl laufende Maschine erzeugt zusätzliche Wärme.',
      translationAr:
          'الآلة التي تعمل بسرعة دوران عالية تولد حرارة إضافية.',
      explanationAr:
          'الآلة تقوم بالفعل laufend أثناء الوصف، لذا نستخدم Partizip I، وتأتي عبارة mit hoher Drehzahl قبله داخل الوصف الموسّع.',
      attributeTokens: <String>[
        'die',
        'mit',
        'hoher',
        'Drehzahl',
        'laufende',
        'Maschine',
      ],
    ),
    PartizipExercise(
      id: 'p1_students_reading',
      infinitive: 'lesen',
      participle: 'lesend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.extended,
      noun: 'Studierenden',
      correctAttribute: 'die aufmerksam lesenden Studierenden',
      sourceSentenceDe:
          'Die aufmerksam lesenden Studierenden markieren zentrale Begriffe im Fachtext.',
      translationAr:
          'الطلاب الذين يقرؤون بانتباه يحددون المصطلحات الأساسية في النص التخصصي.',
      explanationAr:
          'القراءة جارية ويقوم بها الطلاب أنفسهم، لذلك نستخدم lesend مع نهاية -en بعد die في الجمع.',
      attributeTokens: <String>[
        'die',
        'aufmerksam',
        'lesenden',
        'Studierenden',
      ],
    ),
    PartizipExercise(
      id: 'p1_water_flowing',
      infinitive: 'fließen',
      participle: 'fließend',
      kind: PartizipKind.partizipI,
      scope: PartizipAttributeScope.simple,
      noun: 'Wasser',
      correctAttribute: 'fließendes Wasser',
      sourceSentenceDe:
          'Fließendes Wasser wird für den Versuch in einem sauberen Behälter gesammelt.',
      translationAr:
          'يُجمع الماء الجاري للتجربة في وعاء نظيف.',
      explanationAr:
          'الماء هو الذي يتدفق، لذلك نستخدم Partizip I fließend ثم نهاية الصفة -es قبل Wasser.',
      attributeTokens: <String>['fließendes', 'Wasser'],
    ),
    PartizipExercise(
      id: 'p2_book_written',
      infinitive: 'schreiben',
      participle: 'geschrieben',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.simple,
      noun: 'Buch',
      correctAttribute: 'geschriebenes Buch',
      sourceSentenceDe:
          'Ein klar geschriebenes Buch erleichtert den Einstieg in das Thema.',
      translationAr:
          'كتاب مكتوب بوضوح يسهّل الدخول إلى الموضوع.',
      explanationAr:
          'Partizip II يصف نتيجة فعل الكتابة: الكتاب تمت كتابته، لذلك تتحول geschrieben إلى geschriebenes قبل Buch.',
      attributeTokens: <String>['geschriebenes', 'Buch'],
    ),
    PartizipExercise(
      id: 'p2_temperature_measured',
      infinitive: 'messen',
      participle: 'gemessen',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Temperatur',
      correctAttribute: 'die im Labor gemessene Temperatur',
      sourceSentenceDe:
          'Die im Labor gemessene Temperatur liegt deutlich über dem Referenzwert.',
      translationAr:
          'درجة الحرارة التي قِيست في المختبر أعلى بوضوح من القيمة المرجعية.',
      explanationAr:
          'القياس وقع على درجة الحرارة وانتهى، لذلك نستخدم Partizip II gemessen بوصف ذي معنى ناتج أو مبني للمجهول.',
      attributeTokens: <String>[
        'die',
        'im',
        'Labor',
        'gemessene',
        'Temperatur',
      ],
    ),
    PartizipExercise(
      id: 'p2_method_developed',
      infinitive: 'entwickeln',
      participle: 'entwickelt',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Methode',
      correctAttribute: 'die für diese Studie entwickelte Methode',
      sourceSentenceDe:
          'Die für diese Studie entwickelte Methode reduziert den Messfehler.',
      translationAr:
          'الطريقة المطورة لهذه الدراسة تقلل خطأ القياس.',
      explanationAr:
          'الطريقة تم تطويرها مسبقاً، لذلك نستخدم Partizip II entwickelte، وتدخل für diese Studie ضمن الوصف الموسّع.',
      attributeTokens: <String>[
        'die',
        'für',
        'diese',
        'Studie',
        'entwickelte',
        'Methode',
      ],
    ),
    PartizipExercise(
      id: 'p2_hypothesis_confirmed',
      infinitive: 'bestätigen',
      participle: 'bestätigt',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Hypothese',
      correctAttribute:
          'die durch mehrere Versuche bestätigte Hypothese',
      sourceSentenceDe:
          'Die durch mehrere Versuche bestätigte Hypothese wird im Bericht ausführlich diskutiert.',
      translationAr:
          'الفرضية التي أكّدتها عدة تجارب تُناقش بالتفصيل في التقرير.',
      explanationAr:
          'الفرضية تلقت فعل التأكيد، لذا نستخدم Partizip II، وتأتي جهة أو وسيلة التأكيد قبل bestätigte.',
      attributeTokens: <String>[
        'die',
        'durch',
        'mehrere',
        'Versuche',
        'bestätigte',
        'Hypothese',
      ],
    ),
    PartizipExercise(
      id: 'p2_machine_damaged',
      infinitive: 'beschädigen',
      participle: 'beschädigt',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Maschine',
      correctAttribute: 'die durch Überhitzung beschädigte Maschine',
      sourceSentenceDe:
          'Die durch Überhitzung beschädigte Maschine wird vor dem Neustart geprüft.',
      translationAr:
          'الآلة التي تضررت بسبب فرط الحرارة تُفحص قبل إعادة التشغيل.',
      explanationAr:
          'الضرر وقع على الآلة ونتيجته قائمة، لذلك Partizip II beschädigt هو الاختيار المناسب.',
      attributeTokens: <String>[
        'die',
        'durch',
        'Überhitzung',
        'beschädigte',
        'Maschine',
      ],
    ),
    PartizipExercise(
      id: 'p2_book_read',
      infinitive: 'lesen',
      participle: 'gelesen',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Fachbuch',
      correctAttribute: 'das häufig gelesene Fachbuch',
      sourceSentenceDe:
          'Das häufig gelesene Fachbuch erklärt die Methode mit vielen Diagrammen.',
      translationAr:
          'الكتاب التخصصي المقروء كثيراً يشرح الطريقة برسوم بيانية عديدة.',
      explanationAr:
          'الكتاب هو الشيء الذي تتم قراءته، لذلك نستخدم Partizip II gelesen مع نهاية الصفة -e بعد das.',
      attributeTokens: <String>[
        'das',
        'häufig',
        'gelesene',
        'Fachbuch',
      ],
    ),
    PartizipExercise(
      id: 'p2_plant_cultivated',
      infinitive: 'züchten',
      participle: 'gezüchtet',
      kind: PartizipKind.partizipII,
      scope: PartizipAttributeScope.extended,
      noun: 'Pflanze',
      correctAttribute:
          'die unter kontrollierten Bedingungen gezüchtete Pflanze',
      sourceSentenceDe:
          'Die unter kontrollierten Bedingungen gezüchtete Pflanze zeigt ein stabiles Wachstum.',
      translationAr:
          'النبتة المزروعة تحت ظروف مضبوطة تُظهر نمواً مستقراً.',
      explanationAr:
          'النبتة وقع عليها فعل الزراعة أو الاستنبات، لذلك Partizip II gezüchtet يعطي وصفاً ناتجاً.',
      attributeTokens: <String>[
        'die',
        'unter',
        'kontrollierten',
        'Bedingungen',
        'gezüchtete',
        'Pflanze',
      ],
    ),
  ];

  @override
  List<PartizipExercise> get allExercises =>
      List<PartizipExercise>.unmodifiable(_exercises);

  @override
  PartizipExercise? byId(String id) {
    final normalized = id.trim();
    for (final exercise in _exercises) {
      if (exercise.id == normalized) return exercise;
    }
    return null;
  }

  @override
  List<PartizipExercise> forKind(PartizipKind kind) =>
      List<PartizipExercise>.unmodifiable(
        _exercises.where((exercise) => exercise.kind == kind),
      );

  @override
  String formPartizipI(String infinitive) {
    final normalized = infinitive.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(
        infinitive,
        'infinitive',
        'must not be empty',
      );
    }
    return '${normalized}d';
  }

  @override
  String? partizipIIFor(String infinitive) {
    final normalized = infinitive.trim().toLowerCase();
    for (final exercise in _exercises) {
      if (exercise.kind == PartizipKind.partizipII &&
          exercise.infinitive.toLowerCase() == normalized) {
        return exercise.participle;
      }
    }
    return null;
  }

  @override
  String formAdjective({
    required String participle,
    required String ending,
  }) {
    final base = participle.trim();
    final suffix = ending.trim().replaceFirst(RegExp(r'^-'), '');
    if (base.isEmpty) {
      throw ArgumentError.value(
        participle,
        'participle',
        'must not be empty',
      );
    }
    const endings = <String>{'e', 'en', 'em', 'er', 'es'};
    if (!endings.contains(suffix)) {
      throw ArgumentError.value(
        ending,
        'ending',
        'must be a German adjective ending',
      );
    }
    return '$base$suffix';
  }

  @override
  bool isAnswerCorrect(
    PartizipExercise exercise,
    String candidate,
  ) =>
      normalizeAnswer(candidate) ==
      normalizeAnswer(exercise.correctAttribute);

  @override
  bool isTokenOrderCorrect(
    PartizipExercise exercise,
    List<String> candidateTokens,
  ) {
    if (candidateTokens.length != exercise.attributeTokens.length) {
      return false;
    }
    for (var index = 0; index < candidateTokens.length; index++) {
      if (candidateTokens[index] != exercise.attributeTokens[index]) {
        return false;
      }
    }
    return true;
  }

  @override
  String normalizeAnswer(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
}
