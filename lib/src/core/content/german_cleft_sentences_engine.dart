import 'dart:collection';

/// Structural classification of German cleft and pseudo-cleft constructions.
enum CleftConstructionType {
  itCleftClassicalSpaltsatz(
    'Klassischer Spaltsatz (Es ist/sind X, der/die/das...)',
    'الجمل المشطورة الكلاسيكية بواسطة الضمير es التمهيدي',
    'Spaltet den Satz in Kopula-Matrix (Es ist/sind [Fokus]) und Relativsatz (Präsupposition). Erzwingt Kongruenz zwischen Kopula und Pluralfokus (Es sind die Sensoren, die...).',
  ),
  whPseudoCleftFreeRelative(
    'Pseudospaltsatz mit freiem Relativsatz (Was..., ist X)',
    'الجمل شبه المشطورة ذات الموصول الحر (ما يثير الاهتمام هو...)',
    'Stellt einen freien Relativsatz mit "was" ins Vorfeld und platziert die fokussierte Lösung/Komponente hinter die Kopula im Hauptsatz.',
  ),
  invertedPseudoCleft(
    'Invertierter Pseudospaltsatz (X ist es, was/der...)',
    'الجمل شبه المشطورة المعكوسة (المكون البؤري في الصدارة)',
    'Platziert den fokussierten Kernbegriff ins Vorfeld, gefolgt von der Kopula und dem anaphorischen "es" mit anschließendem Restriktivsatz.',
  ),
  specificationalNominalizedCleft(
    'Spezifikatorischer Cleft mit nominalem Kopf (Der Grund, weshalb..., liegt darin, dass...)',
    'الجمل المشطورة التخصيصية ذات الرأس الاسمي المعرف',
    'Verwendet Nomina wie Grund, Ursache, Faktor, Phänomen als Topic-Kopf und spezifiziert die Erklärung im Nachfeld-Komplementsatz.',
  ),
  contrastiveExhaustiveCleft(
    'Kontrastiver Exklusions-Spaltsatz (Nicht X, sondern Y ist es, der...)',
    'الجمل المشطورة التباينية الحصرية القاطعة لنفي البدائل',
    'Verknüpft die Spaltung mit koordinierter adversativer Negation zur unmissverständlichen Feststellung von Fehlerursachen in technischen Berichten.',
  );

  final String deTitle;
  final String arTitle;
  final String structuralCriteria;
  const CleftConstructionType(this.deTitle, this.arTitle, this.structuralCriteria);
}

/// Syntactic category of the constituent placed into the cleft focus.
enum CleftFocusCategory {
  subjectDP('Subjekt-Nominalphrase (Fokus auf Agens/Verursacher)', 'بؤرة الفاعل أو المسبب التقني المباشر'),
  directObjectDP('Akkusativ-Objekt (Fokus auf Patient/Zielobjekt)', 'بؤرة المفعول به الصريح المتأثر بالحدث'),
  prepositionalPP('Präpositionalphrase (Fokus auf Kausalität/Instrument)', 'بؤرة شبه الجملة المجرورة الدالة على الأداة أو السبب'),
  adverbialAdjunct('Adverbiale Bestimmung (Fokus auf Zeit/Ort/Bedingung)', 'بؤرة الظرف المخصص لشرط التشغيل أو توقيته'),
  complexProposition('Komplexe Proposition / Sachverhalt', 'بؤرة الواقعة المعقدة المحددة للخلل الهندسي');

  final String de;
  final String ar;
  const CleftFocusCategory(this.de, this.ar);
}

/// Technical and engineering communicative domains free of legal/medical liability.
enum CommunicativeDomain {
  renewableEnergyGrid('Erneuerbare Energien & Netztechnik', 'الطاقة المتجددة وهندسة الشبكات'),
  aerospaceAndAviation('Luft- & Raumfahrttechnik', 'هندسة الطيران واستكشاف الفضاء'),
  industrialRobotics('Industrierobotik & Mechatronik', 'الروبوتات الصناعية والميكاترونكس'),
  civilInfrastructure('Bauingenieurwesen & Statik', 'الهندسة المدنية والمنشآت'),
  materialScience('Materialwissenschaft & Nanotechnologie', 'علم المواد والتراكيب النانوية'),
  maritimeLogistics('Maritime Schifffahrt & Hafenumschlag', 'الملاحة البحرية والشحن الدولي');

  final String de;
  final String ar;
  const CommunicativeDomain(this.de, this.ar);
}

/// Structural model of a German cleft or pseudo-cleft construction.
class CleftSentenceModel {
  final String id;
  final CleftConstructionType constructionType;
  final CleftFocusCategory focusCategory;
  final CommunicativeDomain domain;
  final String baseUncleftSentence;
  final String cleftedGermanSentence;
  final String cleftFocusConstituent;
  final String relativeClausePresupposition;
  final String pragmaticExhaustivityGerman;
  final String pragmaticExhaustivityArabic;
  final String copulaNumberAgreementRule;
  final bool isPluralFocus;

  const CleftSentenceModel({
    required this.id,
    required this.constructionType,
    required this.focusCategory,
    required this.domain,
    required this.baseUncleftSentence,
    required this.cleftedGermanSentence,
    required this.cleftFocusConstituent,
    required this.relativeClausePresupposition,
    required this.pragmaticExhaustivityGerman,
    required this.pragmaticExhaustivityArabic,
    required this.copulaNumberAgreementRule,
    this.isPluralFocus = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'constructionType': constructionType.name,
    'focusCategory': focusCategory.name,
    'domain': domain.name,
    'baseUncleftSentence': baseUncleftSentence,
    'cleftedGermanSentence': cleftedGermanSentence,
    'cleftFocusConstituent': cleftFocusConstituent,
    'relativeClausePresupposition': relativeClausePresupposition,
    'pragmaticExhaustivityGerman': pragmaticExhaustivityGerman,
    'pragmaticExhaustivityArabic': pragmaticExhaustivityArabic,
    'copulaNumberAgreementRule': copulaNumberAgreementRule,
    'isPluralFocus': isPluralFocus,
  };
}

/// Validation result for cleft constructions.
class CleftValidationResult {
  final bool isValid;
  final List<String> issues;
  final List<String> syntaxNotes;

  const CleftValidationResult({
    required this.isValid,
    required this.issues,
    required this.syntaxNotes,
  });
}

/// Core Engine managing German Cleft & Pseudo-Cleft Constructions.
class GermanCleftSentencesEngine {
  final List<CleftSentenceModel> _catalog = [];

  GermanCleftSentencesEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<CleftSentenceModel> get catalog =>
      UnmodifiableListView(_catalog);

  void _initializeCatalog() {
    _catalog.addAll([
      // 1. Classical it-cleft (Singular)
      const CleftSentenceModel(
        id: 'CLEFT-4959-01',
        constructionType: CleftConstructionType.itCleftClassicalSpaltsatz,
        focusCategory: CleftFocusCategory.subjectDP,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseUncleftSentence:
            'Der primäre Wechselrichter verursachte den Spannungsabfall im Einspeiseknoten.',
        cleftedGermanSentence:
            'Es ist der primäre Wechselrichter, der den Spannungsabfall im Einspeiseknoten verursachte.',
        cleftFocusConstituent: 'der primäre Wechselrichter',
        relativeClausePresupposition:
            'Jemand oder etwas verursachte den Spannungsabfall im Einspeiseknoten.',
        pragmaticExhaustivityGerman:
            'Exklusive Zuordnung der Ausfallursache: Schließt Transformatoren oder Batteriemodule als Primärursache aus.',
        pragmaticExhaustivityArabic:
            'تخصيص قطعي لمصدر الخلل: إن المحول الرئيسي هو تحديداً من تسبب في هبوط الجهد دون بقية الوحدات.',
        copulaNumberAgreementRule: 'Singular-Kongruenz: "Es ist" bei maskulinem Singular-Subjekt.',
        isPluralFocus: false,
      ),
      // 2. Classical it-cleft (Plural with mandatory agreement: Es SIND...)
      const CleftSentenceModel(
        id: 'CLEFT-4959-02',
        constructionType: CleftConstructionType.itCleftClassicalSpaltsatz,
        focusCategory: CleftFocusCategory.subjectDP,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseUncleftSentence:
            'Die Schwingungsdämpfer der linken Tragfläche haben bei den Windkanalversuchen versagt.',
        cleftedGermanSentence:
            'Es sind die Schwingungsdämpfer der linken Tragfläche, die bei den Windkanalversuchen versagt haben.',
        cleftFocusConstituent: 'die Schwingungsdämpfer der linken Tragfläche',
        relativeClausePresupposition:
            'Bestimmte mechanische Komponenten haben bei den Windkanalversuchen versagt.',
        pragmaticExhaustivityGerman:
            'Grammatische Pflicht im Deutschen: Die Kopula MUSS mit dem pluralischen Fokus kongruieren ("Es sind", nicht *"Es ist").',
        pragmaticExhaustivityArabic:
            'مطابقة نحوية إلزامية: يجب تصريف فعل الكينونة بالجمع (Es sind) لأن البؤرة جمع (مخمدات الاهتزاز).',
        copulaNumberAgreementRule: 'Plural-Kongruenz: "Es sind" ist obligatorisch bei Plural-Fokus!',
        isPluralFocus: true,
      ),
      // 3. wh-Pseudo-cleft (Free relative)
      const CleftSentenceModel(
        id: 'CLEFT-4959-03',
        constructionType: CleftConstructionType.whPseudoCleftFreeRelative,
        focusCategory: CleftFocusCategory.complexProposition,
        domain: CommunicativeDomain.industrialRobotics,
        baseUncleftSentence:
            'Die adaptive Drehmomentregelung optimiert die Taktzeit des Knickarmroboters.',
        cleftedGermanSentence:
            'Was die Taktzeit des Knickarmroboters optimiert, ist die adaptive Drehmomentregelung.',
        cleftFocusConstituent: 'die adaptive Drehmomentregelung',
        relativeClausePresupposition:
            'Etwas optimiert die Taktzeit des Knickarmroboters.',
        pragmaticExhaustivityGerman:
            'Pseudospaltsatz: Bündelt das technische Ziel im Vorfeld und präsentiert die Reglerlösung als Höhepunkt.',
        pragmaticExhaustivityArabic:
            'جملة شبه مشطورة تقدم الغاية الميكانيكية أولاً وتجعل خوارزمية العزم هي الإجابة الحصرية في الختام.',
        copulaNumberAgreementRule: 'Kopula "ist" richtet sich nach dem singulären Prädikativum.',
        isPluralFocus: false,
      ),
      // 4. Inverted Pseudo-cleft
      const CleftSentenceModel(
        id: 'CLEFT-4959-04',
        constructionType: CleftConstructionType.invertedPseudoCleft,
        focusCategory: CleftFocusCategory.directObjectDP,
        domain: CommunicativeDomain.materialScience,
        baseUncleftSentence:
            'Die mikrostrukturelle Versetzungsdichte bestimmt die Härte des Titanaluminids.',
        cleftedGermanSentence:
            'Die mikrostrukturelle Versetzungsdichte ist es, was die Härte des Titanaluminids maßgeblich bestimmt.',
        cleftFocusConstituent: 'Die mikrostrukturelle Versetzungsdichte',
        relativeClausePresupposition:
            'Ein bestimmter werkstoffkundlicher Faktor bestimmt maßgeblich die Härte.',
        pragmaticExhaustivityGerman:
            'Inversion: Der physikalische Hauptfaktor rückt an die absolut erste Satzposition mit "ist es, was...".',
        pragmaticExhaustivityArabic:
            'شبه جملة معكوسة تبدأ مباشرة بالعامل الفيزيائي ذي النبر العالي لتأكيد أهميته الحاسمة.',
        copulaNumberAgreementRule: 'Kopula "ist" mit anaphorischem "es" und Relativum "was".',
        isPluralFocus: false,
      ),
      // 5. Specificational Nominalized Cleft (Der Grund...)
      const CleftSentenceModel(
        id: 'CLEFT-4959-05',
        constructionType: CleftConstructionType.specificationalNominalizedCleft,
        focusCategory: CleftFocusCategory.prepositionalPP,
        domain: CommunicativeDomain.civilInfrastructure,
        baseUncleftSentence:
            'Die Pfeilergründung senkte sich infolge unvorhergesehener Grundwasserverschiebungen ab.',
        cleftedGermanSentence:
            'Der Grund, weshalb sich die Pfeilergründung absenkte, liegt in den unvorhergesehenen Grundwasserverschiebungen.',
        cleftFocusConstituent: 'in den unvorhergesehenen Grundwasserverschiebungen',
        relativeClausePresupposition:
            'Die Pfeilergründung senkte sich aus einer bestimmten geologischen Ursache ab.',
        pragmaticExhaustivityGerman:
            'Formale Gutachtersprache: Nominale Kausalstruktur trennt Tatbestand und Schadensursache sachlich voneinander.',
        pragmaticExhaustivityArabic:
            'صياغة تقرير هندسي معتمد تفصل واقعة هبوط الأساسات عن مسببها الهيدرولوجي بأسلوب علمي رصين.',
        copulaNumberAgreementRule: 'Verbum "liegt darin / ist" kongruiert mit dem Subjekt "Der Grund".',
        isPluralFocus: false,
      ),
      // 6. Contrastive Exhaustive Cleft
      const CleftSentenceModel(
        id: 'CLEFT-4959-06',
        constructionType: CleftConstructionType.contrastiveExhaustiveCleft,
        focusCategory: CleftFocusCategory.subjectDP,
        domain: CommunicativeDomain.maritimeLogistics,
        baseUncleftSentence:
            'Nicht die Seeventile, sondern der Wellendichtring des Stevenrohrs hat die Leckage verursacht.',
        cleftedGermanSentence:
            'Nicht die Seeventile, sondern der Wellendichtring des Stevenrohrs ist es, der die Leckage im Maschinenraum verursachte.',
        cleftFocusConstituent: 'der Wellendichtring des Stevenrohrs',
        relativeClausePresupposition:
            'Eine Dichtungskomponente im Schiffsantrieb hat die Leckage verursacht.',
        pragmaticExhaustivityGerman:
            'Scharfe Abweisung der anfänglichen Vermutung (Seeventile) und Fixierung auf den Dichtring.',
        pragmaticExhaustivityArabic:
            'نفي حاسم للظن الخاطئ بأن صمامات البحر هي السبب، وحصر العطل قطعياً في حلقة إحكام عمود التوجيه.',
        copulaNumberAgreementRule: 'Kopula "ist es, der" richtet sich nach dem bejahten Glied (der Wellendichtring).',
        isPluralFocus: false,
      ),
      // 7. Classical it-cleft (Adverbial Focus)
      const CleftSentenceModel(
        id: 'CLEFT-4959-07',
        constructionType: CleftConstructionType.itCleftClassicalSpaltsatz,
        focusCategory: CleftFocusCategory.adverbialAdjunct,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseUncleftSentence:
            'Erst bei Erreichen der thermischen Grenzlast greift der Not-Aus-Schutz des Umrichters ein.',
        cleftedGermanSentence:
            'Es ist erst bei Erreichen der thermischen Grenzlast, dass der Not-Aus-Schutz des Umrichters eingreift.',
        cleftFocusConstituent: 'erst bei Erreichen der thermischen Grenzlast',
        relativeClausePresupposition:
            'Der Not-Aus-Schutz des Umrichters greift unter einer bestimmten Bedingung ein.',
        pragmaticExhaustivityGerman:
            'Spaltung einer präpositionalen Zeit-/Bedingungsangabe mittels "dass"-Satz.',
        pragmaticExhaustivityArabic:
            'شطر ظرف الشرط والوقت لتأكيد أن الحماية الطارئة لا تنشط إلا عند بلوغ الحد الحراري الأقصى حصراً.',
        copulaNumberAgreementRule: 'Unpersönliches "Es ist" verbindet sich mit adverbialer PP und "dass"-Konnektor.',
        isPluralFocus: false,
      ),
      // 8. wh-Pseudo-cleft (Instrumental Focus)
      const CleftSentenceModel(
        id: 'CLEFT-4959-08',
        constructionType: CleftConstructionType.whPseudoCleftFreeRelative,
        focusCategory: CleftFocusCategory.prepositionalPP,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseUncleftSentence:
            'Das optische LIDAR-Sensorsystem gewährleistet die millimetergenaue Docking-Präzision.',
        cleftedGermanSentence:
            'Womit die millimetergenaue Docking-Präzision gewährleistet wird, ist das optische LIDAR-Sensorsystem.',
        cleftFocusConstituent: 'das optische LIDAR-Sensorsystem',
        relativeClausePresupposition:
            'Die millimetergenaue Docking-Präzision wird mit einem bestimmten Sensorsystem gewährleistet.',
        pragmaticExhaustivityGerman:
            'Pronominaladverb "Womit" eröffnet den Pseudospaltsatz und hebt das messtechnische Instrument hervor.',
        pragmaticExhaustivityArabic:
            'استهلال بأداة الربط المركبة "بماذا" لإبراز منظومة الليدار كأداة حصرية لتحقيق دقة الالتحام الفضائي.',
        copulaNumberAgreementRule: 'Kopula "ist" verknüpft Instrumentalanalyse mit dem Subjektnomen.',
        isPluralFocus: false,
      ),
      // 9. Classical it-cleft (Plural Accusative Object)
      const CleftSentenceModel(
        id: 'CLEFT-4959-09',
        constructionType: CleftConstructionType.itCleftClassicalSpaltsatz,
        focusCategory: CleftFocusCategory.directObjectDP,
        domain: CommunicativeDomain.industrialRobotics,
        baseUncleftSentence:
            'Das Servoventil steuert genau die drei hydraulischen Stellzylinder der Hebebühne an.',
        cleftedGermanSentence:
            'Es sind genau die drei hydraulischen Stellzylinder der Hebebühne, die das Servoventil ansteuert.',
        cleftFocusConstituent: 'die drei hydraulischen Stellzylinder der Hebebühne',
        relativeClausePresupposition:
            'Das Servoventil steuert bestimmte Stellglieder der Hebebühne an.',
        pragmaticExhaustivityGerman:
            'Plural-Akkusativobjekt im Fokus erfordert ebenfalls Plural-Kopula: "Es SIND die drei Stellzylinder, die..."',
        pragmaticExhaustivityArabic:
            'بؤرة مفعول به جمع تتطلب فعل كينونة بالجمع (Es sind) مع ضمير وصل للمفعول به (die).',
        copulaNumberAgreementRule: 'Plural-Kongruenz trotz Objektsstatus des fokussierten Nomens!',
        isPluralFocus: true,
      ),
      // 10. Specificational Nominalized Cleft (Die Eigenschaft...)
      const CleftSentenceModel(
        id: 'CLEFT-4959-10',
        constructionType: CleftConstructionType.specificationalNominalizedCleft,
        focusCategory: CleftFocusCategory.complexProposition,
        domain: CommunicativeDomain.materialScience,
        baseUncleftSentence:
            'Die außergewöhnliche Kriechbeständigkeit der Superlegierung prädestiniert sie für Triebwerksschaufeln.',
        cleftedGermanSentence:
            'Die entscheidende Eigenschaft, die die Superlegierung für Triebwerksschaufeln prädestiniert, ist ihre außergewöhnliche Kriechbeständigkeit.',
        cleftFocusConstituent: 'ihre außergewöhnliche Kriechbeständigkeit',
        relativeClausePresupposition:
            'Eine bestimmte werkstoffliche Eigenschaft prädestiniert die Superlegierung für diesen Einsatzzweck.',
        pragmaticExhaustivityGerman:
            'Definitioneller Cleft: "Die entscheidende Eigenschaft, die..., ist..." stellt die Werkstoffeigenschaft isoliert dar.',
        pragmaticExhaustivityArabic:
            'بناء تعريفي تخصيصي يبرز خاصية مقاومة الزحف الحراري كميزة فريدة تؤهل السبيكة لمحركات الطائرات.',
        copulaNumberAgreementRule: 'Kongruenz zwischen "Die Eigenschaft" (Sg.) und Kopula "ist".',
        isPluralFocus: false,
      ),
      // 11. Inverted Pseudo-cleft (Plural Subject)
      const CleftSentenceModel(
        id: 'CLEFT-4959-11',
        constructionType: CleftConstructionType.invertedPseudoCleft,
        focusCategory: CleftFocusCategory.subjectDP,
        domain: CommunicativeDomain.civilInfrastructure,
        baseUncleftSentence:
            'Moderne Piezo-Sensoren erfassen die Mikrorisse im Brückenpfeiler rechtzeitig.',
        cleftedGermanSentence:
            'Moderne Piezo-Sensoren sind es, die die Mikrorisse im Brückenpfeiler rechtzeitig erfassen.',
        cleftFocusConstituent: 'Moderne Piezo-Sensoren',
        relativeClausePresupposition:
            'Bestimmte Sensoren erfassen die Mikrorisse im Brückenpfeiler rechtzeitig.',
        pragmaticExhaustivityGerman:
            'Invertierter Cleft mit Plural-Vorfeld: "Sensoren SIND es, die...".',
        pragmaticExhaustivityArabic:
            'جملة شبه مشطورة معكوسة في صيغة الجمع: مستشعرات البيزو هي تحديداً التي ترصد الشروخ.',
        copulaNumberAgreementRule: 'Kopula "sind" kongruiert mit dem pluralischen Vorfeld-Subjekt.',
        isPluralFocus: true,
      ),
      // 12. Contrastive Exhaustive Cleft (Akkusativ)
      const CleftSentenceModel(
        id: 'CLEFT-4959-12',
        constructionType: CleftConstructionType.contrastiveExhaustiveCleft,
        focusCategory: CleftFocusCategory.directObjectDP,
        domain: CommunicativeDomain.maritimeLogistics,
        baseUncleftSentence:
            'Das Hafenleitsystem hat nicht den Öltanker, sondern das Containerschiff zur Schleusung freigegeben.',
        cleftedGermanSentence:
            'Nicht den Öltanker, sondern das Containerschiff war es, das das Hafenleitsystem zur Schleusung freigab.',
        cleftFocusConstituent: 'das Containerschiff',
        relativeClausePresupposition:
            'Das Hafenleitsystem hat ein bestimmtes Schiff zur Schleusung freigegeben.',
        pragmaticExhaustivityGerman:
            'Präteritaler kontrastiver Spaltsatz zur lückenlosen Rekonstruktion eines Hafenmanövers.',
        pragmaticExhaustivityArabic:
            'جملة مشطورة بصيغة الماضي تؤكد إعطاء الإذن لسفينة الحاويات دون ناقلة النفط لتفادي حوادث الاصطدام.',
        copulaNumberAgreementRule: 'Präteritum-Kopula "war es, das" kongruiert mit neutralem Einzelschiff.',
        isPluralFocus: false,
      ),
      // 13. wh-Pseudo-cleft (Causal focus)
      const CleftSentenceModel(
        id: 'CLEFT-4959-13',
        constructionType: CleftConstructionType.whPseudoCleftFreeRelative,
        focusCategory: CleftFocusCategory.complexProposition,
        domain: CommunicativeDomain.renewableEnergyGrid,
        baseUncleftSentence:
            'Die thermische Überlastung der Leistungshalbleiter führte zum Netzausfall.',
        cleftedGermanSentence:
            'Was letztlich zum Netzausfall führte, war die thermische Überlastung der Leistungshalbleiter.',
        cleftFocusConstituent: 'die thermische Überlastung der Leistungshalbleiter',
        relativeClausePresupposition:
            'Ein bestimmtes elektrotechnisches Phänomen führte letztlich zum Netzausfall.',
        pragmaticExhaustivityGerman:
            'Kausaler wh-Pseudospaltsatz: Identifiziert die physikalische Wurzel des Blackouts.',
        pragmaticExhaustivityArabic:
            'استفهام موصولي حر يحدد الجذر الفيزيائي لانقطاع التيار الكهربائي في فرط حرارة أشباه الموصلات.',
        copulaNumberAgreementRule: 'Präteritum-Kopula "war" kongruiert mit der femininen Singular-Ursache.',
        isPluralFocus: false,
      ),
      // 14. Classical it-cleft (Prepositional Focus)
      const CleftSentenceModel(
        id: 'CLEFT-4959-14',
        constructionType: CleftConstructionType.itCleftClassicalSpaltsatz,
        focusCategory: CleftFocusCategory.prepositionalPP,
        domain: CommunicativeDomain.aerospaceAndAviation,
        baseUncleftSentence:
            'Nur unter reinem Stickstoff darf das Betanken des Treibstofftanks erfolgen.',
        cleftedGermanSentence:
            'Es ist nur unter reinem Stickstoff, dass das Betanken des Treibstofftanks vorschriftsmäßig erfolgen darf.',
        cleftFocusConstituent: 'nur unter reinem Stickstoff',
        relativeClausePresupposition:
            'Das Betanken des Treibstofftanks darf unter einer bestimmten Schutzatmosphäre erfolgen.',
        pragmaticExhaustivityGerman:
            'Spaltsatz zur nachdrücklichen Formulierung sicherheitskritischer Luftfahrtvorschriften.',
        pragmaticExhaustivityArabic:
            'جملة مشطورة لصياغة معايير الأمان الصارمة: حصر التزود بالوقود تحت غطاء غاز النيتروجين الخامل.',
        copulaNumberAgreementRule: 'Präpositionale Fokussierung mit unpersönlichem "Es ist ... dass".',
        isPluralFocus: false,
      ),
      // 15. Specificational Nominalized Cleft (Die Herausforderung...)
      const CleftSentenceModel(
        id: 'CLEFT-4959-15',
        constructionType: CleftConstructionType.specificationalNominalizedCleft,
        focusCategory: CleftFocusCategory.complexProposition,
        domain: CommunicativeDomain.industrialRobotics,
        baseUncleftSentence:
            'Die synchrone Latenzzeitminimierung auf unter 2 Millisekunden stellt die Hauptherausforderung dar.',
        cleftedGermanSentence:
            'Die größte Herausforderung, vor der die Entwickler stehen, ist die synchrone Latenzzeitminimierung auf unter 2 Millisekunden.',
        cleftFocusConstituent: 'die synchrone Latenzzeitminimierung auf unter 2 Millisekunden',
        relativeClausePresupposition:
            'Die Entwickler stehen vor einer bestimmten Hauptherausforderung.',
        pragmaticExhaustivityGerman:
            'Strukturierter Spezifikationssatz zur Definition des Entwicklungsziels im Pflichtenheft.',
        pragmaticExhaustivityArabic:
            'هيكل تخصيصي يحدد بدقة التحدي البرمجي الأبرز في خفض زمن الاستجابة إلى أقل من 2 ميلي ثانية.',
        copulaNumberAgreementRule: 'Kopula "ist" kongruiert mit der femininen Nominalphrase "Die Herausforderung".',
        isPluralFocus: false,
      ),
      // 16. Contrastive Exhaustive Cleft (Plural subject)
      const CleftSentenceModel(
        id: 'CLEFT-4959-16',
        constructionType: CleftConstructionType.contrastiveExhaustiveCleft,
        focusCategory: CleftFocusCategory.subjectDP,
        domain: CommunicativeDomain.civilInfrastructure,
        baseUncleftSentence:
            'Nicht die Stahlseile, sondern die Betonverankerungen müssen ausgetauscht werden.',
        cleftedGermanSentence:
            'Nicht die Stahlseile, sondern die Betonverankerungen sind es, die vor der Freigabe ausgetauscht werden müssen.',
        cleftFocusConstituent: 'die Betonverankerungen',
        relativeClausePresupposition:
            'Bestimmte Tragelemente müssen vor der Freigabe ausgetauscht werden.',
        pragmaticExhaustivityGerman:
            'Pluralischer Kontrastfokus mit obligatorischem "sind es, die...".',
        pragmaticExhaustivityArabic:
            'بؤرة تباينية بصيغة الجمع مع إلزامية "sind es, die" لتحديد استبدال القواعد الخرسانية دون الكابلات.',
        copulaNumberAgreementRule: 'Plural-Kongruenz: "sind es, die" wegen "die Betonverankerungen" (Plural).',
        isPluralFocus: true,
      ),
    ]);
  }

  List<CleftSentenceModel> getByType(CleftConstructionType type) =>
      _catalog.where((c) => c.constructionType == type).toList();

  List<CleftSentenceModel> getByFocusCategory(CleftFocusCategory category) =>
      _catalog.where((c) => c.focusCategory == category).toList();

  List<CleftSentenceModel> getByDomain(CommunicativeDomain domain) =>
      _catalog.where((c) => c.domain == domain).toList();

  /// Validates the morphosyntax and agreement of German cleft sentences.
  CleftValidationResult validateCleftStructure({
    required CleftConstructionType type,
    required bool isPluralFocus,
    required bool copulaIsPlural,
    required bool relativePronounAgreementCompliant,
  }) {
    final List<String> issues = [];
    final List<String> notes = [];

    // Rule 1: Plural focus in German it-clefts REQUIRES plural copula ("Es sind X [Plural], die...")
    if (type == CleftConstructionType.itCleftClassicalSpaltsatz ||
        type == CleftConstructionType.invertedPseudoCleft ||
        type == CleftConstructionType.contrastiveExhaustiveCleft) {
      if (isPluralFocus && !copulaIsPlural) {
        issues.add(
            'Kongruenzfehler: Bei pluralischem Fokus MUSS die Kopula im Plural stehen ("Es SIND die Bauteile, die...", nicht *"Es ist").');
      } else if (!isPluralFocus && copulaIsPlural) {
        issues.add(
            'Kongruenzfehler: Bei singulärem Fokus darf die Kopula NICHT im Plural stehen.');
      } else {
        notes.add('Kongruenz gesichert: Kopulanumerus stimmt exakt mit der Fokus-Nominalphrase überein.');
      }
    }

    // Rule 2: Relative pronoun agreement
    if (!relativePronounAgreementCompliant) {
      issues.add(
          'Relativpronomen-Fehler: Das einleitende Pronomen des Spaltsatzes muss in Genus, Numerus und Kasus mit dem Spaltfokus übereinstimmen.');
    } else {
      notes.add('Morphosyntax korrekt: Relativpronomen kongruiert normgerecht.');
    }

    // Rule 3: Pseudo-cleft pronoun selection
    if (type == CleftConstructionType.whPseudoCleftFreeRelative) {
      notes.add('Pseudospaltsatz-Norm: Freier Relativsatz mit "was" fungiert als vorangestelltes Thema.');
    }

    return CleftValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
      syntaxNotes: notes,
    );
  }

  Map<String, dynamic> generateTelemetrySnapshot() {
    return {
      'totalExemplars': _catalog.length,
      'constructionTypeDistribution': {
        for (var t in CleftConstructionType.values)
          t.name: _catalog.where((c) => c.constructionType == t).length,
      },
      'focusCategoryDistribution': {
        for (var f in CleftFocusCategory.values)
          f.name: _catalog.where((c) => c.focusCategory == f).length,
      },
      'domainDistribution': {
        for (var d in CommunicativeDomain.values)
          d.name: _catalog.where((c) => c.domain == d).length,
      },
      'pluralFocusCount': _catalog.where((c) => c.isPluralFocus).length,
      'cefrLevel': 'CEFR C1-C2 Masterclass Cleft Syntax',
      'engineVersion': '1.0.0+subsystem1793',
    };
  }
}
