import '../domain/alltagssprache_models.dart';

class LocalAlltagsspracheRepository {
  const LocalAlltagsspracheRepository();

  static final List<AlltagScenario> _items = <AlltagScenario>[
    AlltagScenario(
      id: 'sonntagsruhe',
      topic: AlltagTopic.neighborhood,
      phraseDe: 'Sonntagsruhe',
      meaningAr: 'هدوء يوم الأحد',
      contextDe:
          'Am Sonntag nimmt man auf Nachbarn Rücksicht und vermeidet unnötigen Lärm.',
      etiquetteAr:
          'من الأدب مراعاة هدوء الجيران يوم الأحد واتباع نظام المبنى والقواعد المحلية.',
      promptAr: 'تريد نقل أثاث قد يسبب ضجيجًا يوم الأحد. ما التصرف الأنسب؟',
      optionsDe: <String>[
        'Ich verschiebe die laute Arbeit auf einen passenden Zeitpunkt.',
        'Ich mache die laute Arbeit ohne Rücksicht auf die Nachbarn.',
        'Ich erhöhe die Lautstärke, damit es schneller geht.',
      ],
      correctIndex: 0,
      feedbackAr:
          'الأفضل تأجيل العمل المزعج إلى وقت مناسب ومراعاة قواعد السكن المحلية.',
    ),
    AlltagScenario(
      id: 'ruhezeiten',
      topic: AlltagTopic.neighborhood,
      phraseDe: 'Ruhezeiten',
      meaningAr: 'أوقات الهدوء',
      contextDe:
          'Hausordnung und örtliche Regeln können Ruhezeiten vorsehen.',
      etiquetteAr:
          'لا تفترض ساعات ثابتة لكل ألمانيا؛ راجع نظام السكن والقواعد المحلية والتزم بها.',
      promptAr: 'لست متأكدًا من أوقات الهدوء في المبنى. ماذا تقول؟',
      optionsDe: <String>[
        'Entschuldigung, wann gelten hier die Ruhezeiten?',
        'Die Regeln interessieren mich nicht.',
        'Ich entscheide selbst, wann es ruhig sein soll.',
      ],
      correctIndex: 0,
      feedbackAr:
          'السؤال المباشر والمهذب أفضل من الافتراض، لأن التفاصيل قد تختلف بين الأماكن.',
    ),
    AlltagScenario(
      id: 'neighbor_notice',
      topic: AlltagTopic.neighborhood,
      phraseDe: 'Entschuldigung für die Störung.',
      meaningAr: 'عذرًا على الإزعاج.',
      contextDe:
          'Eine kurze Entschuldigung hilft, wenn man Nachbarn unbeabsichtigt gestört hat.',
      etiquetteAr:
          'اعتذار قصير وواضح مناسب عند حدوث إزعاج غير مقصود.',
      promptAr: 'اكتشفت أن صوتك كان مرتفعًا للحظات. ما العبارة الأنسب؟',
      optionsDe: <String>[
        'Entschuldigung für die Störung.',
        'Das ist nicht mein Problem.',
        'Sie müssen sich daran gewöhnen.',
      ],
      correctIndex: 0,
      feedbackAr: 'الاعتذار المختصر يحافظ على الاحترام ويهدئ الموقف.',
    ),
    AlltagScenario(
      id: 'shopping_greeting',
      topic: AlltagTopic.shopping,
      phraseDe: 'Guten Tag.',
      meaningAr: 'مرحبًا / نهارك سعيد.',
      contextDe:
          'Ein kurzer Gruß ist in vielen Geschäften eine höfliche Eröffnung.',
      etiquetteAr:
          'ابدأ التعامل بتحية بسيطة ثم اطلب ما تريد بصيغة مهذبة.',
      promptAr: 'دخلت متجرًا صغيرًا وتريد سؤال الموظف. كيف تبدأ؟',
      optionsDe: <String>[
        'Guten Tag, könnten Sie mir bitte helfen?',
        'Kommen Sie sofort her.',
        'Ich brauche jetzt Hilfe.',
      ],
      correctIndex: 0,
      feedbackAr:
          'التحية مع könnten Sie ... bitte صيغة مهذبة وواضحة في التعامل اليومي.',
    ),
    AlltagScenario(
      id: 'shopping_finished',
      topic: AlltagTopic.shopping,
      phraseDe: 'Danke, das ist alles.',
      meaningAr: 'شكرًا، هذا كل شيء.',
      contextDe:
          'Die Wendung beendet eine Bestellung oder einen Einkauf freundlich.',
      etiquetteAr:
          'استخدمها عندما تنتهي من طلبك بدل الاكتفاء بإشارة أو جواب مقتضب.',
      promptAr: 'سألك الموظف إن كنت تريد شيئًا آخر. ماذا تقول؟',
      optionsDe: <String>[
        'Danke, das ist alles.',
        'Nein. Ende.',
        'Gehen Sie weiter.',
      ],
      correctIndex: 0,
      feedbackAr: 'إضافة Danke تجعل الإجابة طبيعية ومهذبة.',
    ),
    AlltagScenario(
      id: 'shopping_passt_schon',
      topic: AlltagTopic.shopping,
      phraseDe: 'Passt schon.',
      meaningAr: 'تمام هكذا / مناسب.',
      contextDe:
          'Passt schon kann im Alltag bedeuten, dass etwas so in Ordnung ist.',
      etiquetteAr:
          'المعنى يعتمد على السياق؛ استخدم عبارة أدق إذا كان هناك احتمال لسوء الفهم عند الدفع.',
      promptAr: 'سألك الموظف إن كان التغليف الحالي مناسبًا لك. ماذا تجيب؟',
      optionsDe: <String>[
        'Passt schon, danke.',
        'Machen Sie irgendwas.',
        'Das ist mir egal.',
      ],
      correctIndex: 0,
      feedbackAr:
          'Passt schon, danke مناسبة عندما تقصد أن الوضع الحالي جيد كما هو.',
    ),
    AlltagScenario(
      id: 'punctual_arrival',
      topic: AlltagTopic.punctuality,
      phraseDe: 'Ich bin pünktlich da.',
      meaningAr: 'سأكون هناك في الموعد.',
      contextDe:
          'Bei verabredeten Terminen ist Pünktlichkeit ein Zeichen von Verlässlichkeit.',
      etiquetteAr:
          'في المواعيد المتفق عليها، احرص على الوصول في الوقت المحدد قدر الإمكان.',
      promptAr: 'أكدت موعدًا مهنيًا للساعة التاسعة. ما السلوك الأنسب؟',
      optionsDe: <String>[
        'Ich plane genug Zeit ein und bin pünktlich da.',
        'Ich komme irgendwann später ohne Nachricht.',
        'Ich warte ab, ob jemand mich erinnert.',
      ],
      correctIndex: 0,
      feedbackAr:
          'التخطيط المسبق والوصول في الموعد يعطيان انطباعًا بالالتزام.',
    ),
    AlltagScenario(
      id: 'punctual_delay',
      topic: AlltagTopic.punctuality,
      phraseDe: 'Ich verspäte mich um zehn Minuten.',
      meaningAr: 'سأتأخر عشر دقائق.',
      contextDe:
          'Bei absehbarer Verspätung informiert man die andere Person möglichst früh.',
      etiquetteAr:
          'إذا عرفت أنك ستتأخر، أخبر الطرف الآخر مبكرًا واذكر مدة تقريبية.',
      promptAr: 'تعطل الطريق وستتأخر قرابة عشر دقائق. ماذا ترسل؟',
      optionsDe: <String>[
        'Entschuldigung, ich verspäte mich um etwa zehn Minuten.',
        'Ich komme später.',
        'Warten Sie einfach.',
      ],
      correctIndex: 0,
      feedbackAr:
          'الاعتذار مع مدة تقريبية يعطي الطرف الآخر معلومة مفيدة وواضحة.',
    ),
    AlltagScenario(
      id: 'punctual_reschedule',
      topic: AlltagTopic.punctuality,
      phraseDe: 'Können wir den Termin verschieben?',
      meaningAr: 'هل يمكننا تأجيل الموعد؟',
      contextDe:
          'Wenn ein Termin nicht mehr passt, bittet man frühzeitig um eine neue Zeit.',
      etiquetteAr:
          'اطلب تغيير الموعد بوقت كافٍ واقترح بديلًا بدل الغياب دون إشعار.',
      promptAr: 'تعرف مسبقًا أنك لن تستطيع حضور الموعد. ما الأفضل؟',
      optionsDe: <String>[
        'Können wir den Termin bitte verschieben?',
        'Ich komme einfach nicht.',
        'Sie werden es schon merken.',
      ],
      correctIndex: 0,
      feedbackAr:
          'طلب التأجيل صراحة يحترم وقت الطرف الآخر ويسهّل إيجاد موعد جديد.',
    ),
    AlltagScenario(
      id: 'feierabend_wish',
      topic: AlltagTopic.politePhrases,
      phraseDe: 'Schönen Feierabend!',
      meaningAr: 'أتمنى لك نهاية دوام طيبة.',
      contextDe:
          'Die Wendung passt häufig, wenn Kolleginnen oder Kollegen ihre Arbeit beenden.',
      etiquetteAr:
          'عبارة ودية شائعة عند نهاية يوم العمل، والرد المناسب يمكن أن يكون Danke, gleichfalls.',
      promptAr: 'زميلك أنهى عمله ويغادر. ماذا تقول؟',
      optionsDe: <String>[
        'Schönen Feierabend!',
        'Bis irgendwann.',
        'Endlich gehst du.',
      ],
      correctIndex: 0,
      feedbackAr:
          'Schönen Feierabend عبارة ودية ومحايدة لإنهاء تواصل العمل اليومي.',
    ),
    AlltagScenario(
      id: 'mahlzeit_greeting',
      topic: AlltagTopic.politePhrases,
      phraseDe: 'Mahlzeit!',
      meaningAr: 'تحية مرتبطة بوقت الغداء.',
      contextDe:
          'Mahlzeit wird in manchen Arbeitsumgebungen rund um die Mittagszeit als lockerer Gruß verwendet.',
      etiquetteAr:
          'هي تحية غير رسمية نسبيًا وتشيع في بعض بيئات العمل وقت الظهر؛ راقب أسلوب المكان.',
      promptAr: 'قال لك زميل وقت الظهر: Mahlzeit! ما رد طبيعي؟',
      optionsDe: <String>[
        'Mahlzeit!',
        'Gute Nacht!',
        'Auf Wiedersehen für immer.',
      ],
      correctIndex: 0,
      feedbackAr:
          'يمكن الرد بنفس العبارة إذا كان الجو غير رسمي وهذا الأسلوب مستخدمًا في مكان العمل.',
    ),
    AlltagScenario(
      id: 'passt_schon_social',
      topic: AlltagTopic.politePhrases,
      phraseDe: 'Passt schon.',
      meaningAr: 'تمام / لا بأس هكذا.',
      contextDe:
          'Die Wendung kann Zustimmung oder Beruhigung ausdrücken, je nach Situation und Ton.',
      etiquetteAr:
          'استخدمها عندما يكون المعنى واضحًا؛ نبرة الصوت والسياق مهمان لأنها مختصرة.',
      promptAr: 'اعتذر شخص عن تعديل بسيط لا يزعجك. ماذا يمكن أن تقول؟',
      optionsDe: <String>[
        'Passt schon, kein Problem.',
        'Das war unverzeihlich.',
        'Reden Sie nicht mit mir.',
      ],
      correctIndex: 0,
      feedbackAr:
          'Passt schon, kein Problem تطمئن الطرف الآخر بطريقة يومية بسيطة.',
    ),
  ];

  List<AlltagScenario> all() => List<AlltagScenario>.unmodifiable(_items);

  List<AlltagScenario> byTopic(AlltagTopic topic) => List<AlltagScenario>.unmodifiable(
        _items.where((item) => item.topic == topic),
      );

  AlltagScenario? byId(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  bool isChoiceCorrect(AlltagScenario item, int selectedIndex) =>
      selectedIndex == item.correctIndex;
}
