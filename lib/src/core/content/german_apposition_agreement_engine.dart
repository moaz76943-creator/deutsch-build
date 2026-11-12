import 'dart:collection';

/// Represents grammatical cases in German appositive constructions.
enum GermanCase {
  nominative('Nominativ', 'الرفع'),
  accusative('Akkusativ', 'النصب'),
  dative('Dativ', 'الجر'),
  genitive('Genitiv', 'الإضافة');

  final String germanLabel;
  final String arabicLabel;
  const GermanCase(this.germanLabel, this.arabicLabel);
}

/// Category of apposition structure according to Duden Grammatik.
enum AppositionType {
  closeApposition(
    'Enge Apposition',
    'البدل المتصل (بدون فواصل)',
    'Kein Komma: Herr Müller, Kaiser Karl, die Stadt Berlin',
  ),
  looseApposition(
    'Lockere Apposition',
    'البدل المنفصل (محصور بين فاصلتين)',
    'Mit Komma: Herr Weber, der Leiter des Instituts, ...',
  ),
  appositionWithAlsWie(
    'Apposition mit als/wie',
    'البدل المقترن بـ als أو wie',
    'Kasuskongruenz mit Bezugswort: Er als erfahrener Arzt...',
  ),
  partitiveApposition(
    'Partitive Apposition / Maßangaben',
    'بدل الكميات والمقاييس',
    'ein Glas frisches Wasser / zwei Kilo reife Äpfel',
  );

  final String germanTitle;
  final String arabicTitle;
  final String structuralPattern;
  const AppositionType(this.germanTitle, this.arabicTitle, this.structuralPattern);
}

/// Status of case agreement between the apposition and its antecedent (Bezugswort).
enum AgreementStatus {
  congruent('Kongruent', 'متطابق إعرابياً'),
  incongruentNominativeFallback('Nominativ-Ersatzform', 'شذوذ الرفع الافتراضي للبدل'),
  incongruentDativeShift('Dativ-Sonderform', 'شذوذ الجر في بدائل الإضافة'),
  validUndeclined('Undekliniert zulässig', 'اسم غير معرب قياسي');

  final String label;
  final String arabicExplanation;
  const AgreementStatus(this.label, this.arabicExplanation);
}

/// Grammatical gender representation.
enum GrammaticalGender {
  masculine('Maskulinum', 'مذكر'),
  feminine('Femininum', 'مؤنث'),
  neuter('Neutrum', 'محايد'),
  plural('Plural', 'جمع');

  final String de;
  final String ar;
  const GrammaticalGender(this.de, this.ar);
}

/// Detailed model of an appositive construction.
class AppositiveModel {
  final String id;
  final String antecedent; // Das Bezugswort
  final GermanCase antecedentCase;
  final GrammaticalGender antecedentGender;
  final String appositionText;
  final GermanCase appositionCase;
  final AppositionType appositionType;
  final AgreementStatus agreementStatus;
  final String fullSentence;
  final String arabicTranslation;
  final String grammaticalAnalysisArabic;
  final String grammaticalAnalysisGerman;
  final bool hasPunctuationError;
  final String punctuationRule;

  const AppositiveModel({
    required this.id,
    required this.antecedent,
    required this.antecedentCase,
    required this.antecedentGender,
    required this.appositionText,
    required this.appositionCase,
    required this.appositionType,
    required this.agreementStatus,
    required this.fullSentence,
    required this.arabicTranslation,
    required this.grammaticalAnalysisArabic,
    required this.grammaticalAnalysisGerman,
    this.hasPunctuationError = false,
    required this.punctuationRule,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'antecedent': antecedent,
    'antecedentCase': antecedentCase.name,
    'antecedentGender': antecedentGender.name,
    'appositionText': appositionText,
    'appositionCase': appositionCase.name,
    'appositionType': appositionType.name,
    'agreementStatus': agreementStatus.name,
    'fullSentence': fullSentence,
    'arabicTranslation': arabicTranslation,
    'grammaticalAnalysisArabic': grammaticalAnalysisArabic,
    'grammaticalAnalysisGerman': grammaticalAnalysisGerman,
    'hasPunctuationError': hasPunctuationError,
    'punctuationRule': punctuationRule,
  };
}

/// Rule governance and diagnostic engine for German appositive syntax.
class GermanAppositionAgreementEngine {
  final List<AppositiveModel> _rulesCatalog = [];

  GermanAppositionAgreementEngine() {
    _initializeCatalog();
  }

  UnmodifiableListView<AppositiveModel> get rulesCatalog =>
      UnmodifiableListView(_rulesCatalog);

  void _initializeCatalog() {
    // 1. Loose Appositions (Lockere Appositionen) - Strict Case Agreement
    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-LOOSE-DAT-01',
        antecedent: 'Herrn Müller',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'dem Leiter des Forschungsinstituts',
        appositionCase: GermanCase.dative,
        appositionType: AppositionType.looseApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Wir danken Herrn Müller, dem Leiter des Forschungsinstituts, für seine Unterstützung.',
        arabicTranslation:
            'نشكر السيد مولر، مدير معهد البحوث، على دعمه ومساندته.',
        grammaticalAnalysisArabic:
            'بدل منفصل (Lockere Apposition): يتبع المبدل منه (Herrn Müller) في حالة الجر (Dativ) وجوباً وتوضع فاصلتان قبل البدل وبعده.',
        grammaticalAnalysisGerman:
            'Die lockere Apposition steht obligatorisch im Dativ, kongruent zum Bezugswort "Herrn Müller". Eingeschlossen in paarige Kommas.',
        punctuationRule:
            'Obligatorische Kommasetzung vor und nach der mehrgliedrigen Apposition.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-LOOSE-AKK-02',
        antecedent: 'unsere geschätzte Kollegin',
        antecedentCase: GermanCase.accusative,
        antecedentGender: GrammaticalGender.feminine,
        appositionText: 'eine renommierte Expertin für Völkerrecht',
        appositionCase: GermanCase.accusative,
        appositionType: AppositionType.looseApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Wir beglückwünschen unsere geschätzte Kollegin, eine renommierte Expertin für Völkerrecht, zu diesem Erfolg.',
        arabicTranslation:
            'نهنئ زميلتنا الفاضلة، الخبيرة المرموقة في القانون الدولي، على هذا النجاح.',
        grammaticalAnalysisArabic:
            'بدل منصوب (Akkusativ) مطابق لاسم المفعول المسبوق به (Kollegin) في الجنس والإعراب.',
        grammaticalAnalysisGerman:
            'Kongruenter Akkusativ nach dem direkten Objekt "Kollegin". Unbestimmter Artikel "eine" zeigt den Akkusativ Singular Femininum.',
        punctuationRule:
            'Die Apposition wird durch paarige Kommas vom restlichen Hauptsatz isoliert.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-LOOSE-GEN-03',
        antecedent: 'des Ministers',
        antecedentCase: GermanCase.genitive,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'des Schirmherrn der Veranstaltung',
        appositionCase: GermanCase.genitive,
        appositionType: AppositionType.looseApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Die Rede des Ministers, des Schirmherrn der Veranstaltung, fand großen Beifall.',
        arabicTranslation:
            'خطاب الوزير، راعي هذه الفعالية، لاقى استحساناً وترحيباً واسعاً.',
        grammaticalAnalysisArabic:
            'تطابق كامل في حالة الإضافة (Genitiv): كلاهما يحمل علامة الإضافة مع أداة التعريف des.',
        grammaticalAnalysisGerman:
            'Vollständige Genitivkongruenz zwischen Bezugssubstantiv und nachgestellter lockerer Apposition.',
        punctuationRule:
            'Paarige Kommasetzung zwingend erforderlich, um Einschub abzugrenzen.',
      ),
    );

    // 2. Appositions with "als" / "wie"
    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-ALS-NOM-04',
        antecedent: 'Er',
        antecedentCase: GermanCase.nominative,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'als erfahrener Notarzt',
        appositionCase: GermanCase.nominative,
        appositionType: AppositionType.appositionWithAlsWie,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Er bewahrte als erfahrener Notarzt in dieser kritischen Situation stets Ruhe.',
        arabicTranslation:
            'حافظ بصفته طبيب طوارئ متمرس على هدوئه التام في هذا الموقف الحرج.',
        grammaticalAnalysisArabic:
            'البدل المقترن بـ als يتبع الفاعل (Er) في حالة الرفع (Nominativ): "als erfahrener Notarzt" بدون أداة مع صفة قوية بالرفع.',
        grammaticalAnalysisGerman:
            'Apposition mit "als" bezieht sich auf das Subjekt "Er" und steht kongruent im Nominativ.',
        punctuationRule:
            'In der Regel kein Komma bei eng verknüpften als-Appositionen ohne satzwertige Ausdehnung.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-ALS-AKK-05',
        antecedent: 'ihn',
        antecedentCase: GermanCase.accusative,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'als zuverlässigen Partner',
        appositionCase: GermanCase.accusative,
        appositionType: AppositionType.appositionWithAlsWie,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Die Gemeinschaft schätzt ihn als zuverlässigen und aufrichtigen Partner.',
        arabicTranslation:
            'يقدره المجتمع بوصفه شريكاً موثوقاً ومخلصاً.',
        grammaticalAnalysisArabic:
            'البدل المقترن بـ als يعود على الضمير المنصوب (ihn)، لذا جاءت الصفة والاسم بالنصب: "als zuverlässigen Partner".',
        grammaticalAnalysisGerman:
            'Akkusativkongruenz mit dem Pronominalobjekt "ihn": "zuverlässigen" mit Akkusativ-Endung -en.',
        punctuationRule:
            'Kein Komma notwendig bei einfachen adverbial-appositiven als-Phrasen.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-ALS-DAT-06',
        antecedent: 'Ihnen',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.plural,
        appositionText: 'als führenden Spezialisten unseres Fachgebiets',
        appositionCase: GermanCase.dative,
        appositionType: AppositionType.appositionWithAlsWie,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Wir übergeben diese Aufgabe Ihnen als führenden Spezialisten unseres Fachgebiets.',
        arabicTranslation:
            'نُسند هذه المهمة إليكم بوصفكم كبار المتخصصين في مجالنا العلمي.',
        grammaticalAnalysisArabic:
            'تطابق في حالة الجر (Dativ) مع ضمير المخاطب الرسمي المجرور (Ihnen).',
        grammaticalAnalysisGerman:
            'Dativ-Kongruenz der als-Apposition mit dem Bezugspronomen im Dativ Plural.',
        punctuationRule: 'Keine Kommasetzung erforderlich.',
      ),
    );

    // 3. Close Appositions (Enge Appositionen) - Titles & Proper Names
    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-CLOSE-TITLE-07',
        antecedent: 'des Kollegen',
        antecedentCase: GermanCase.genitive,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'Schmidt',
        appositionCase: GermanCase.nominative,
        appositionType: AppositionType.closeApposition,
        agreementStatus: AgreementStatus.validUndeclined,
        fullSentence:
            'Das Gutachten des Kollegen Schmidt liegt nun zur Prüfung vor.',
        arabicTranslation:
            'تقرير الزميل شميدت متاح الآن للتدقيق والمراجعة.',
        grammaticalAnalysisArabic:
            'بدل متصل (Enge Apposition): عندما يسبق الاسم علمٌ بلقب معرف (des Kollegen)، يعرب اللقب ويبقى العلم مجرداً بدون علامة s.',
        grammaticalAnalysisGerman:
            'Enge Apposition mit determiniertem Gattungsnamen: "des Kollegen" dekliniert im Genitiv, der Eigenname "Schmidt" bleibt endungslos.',
        punctuationRule:
            'Niemals Komma bei engen Appositionen zwischen Titel/Gattungsname und Eigennamen.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-CLOSE-TITLE-08',
        antecedent: 'König',
        antecedentCase: GermanCase.genitive,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'Friedrichs',
        appositionCase: GermanCase.genitive,
        appositionType: AppositionType.closeApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Die Reformen König Friedrichs des Großen prägten die Epoche maßgeblich.',
        arabicTranslation:
            'إصلاحات الملك فريدريش الأكبر تركت بصمة جوهرية في ذلك العصر.',
        grammaticalAnalysisArabic:
            'عند عدم وجود أداة تعريف قبل اللقب (König)، ينتقل إعراب الإضافة (s) إلى اسم العلم نفسه (Friedrichs).',
        grammaticalAnalysisGerman:
            'Artikellose Titulatur: Der Gattungsname bleibt unverändert ("König"), der Eigenname trägt das Genitiv-s ("Friedrichs").',
        punctuationRule: 'Keine Kommasetzung zwischen Titel und Vorname/Beiname.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-CLOSE-GEO-09',
        antecedent: 'der Stadt',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.feminine,
        appositionText: 'Köln',
        appositionCase: GermanCase.dative,
        appositionType: AppositionType.closeApposition,
        agreementStatus: AgreementStatus.validUndeclined,
        fullSentence:
            'Die Konferenz fand im historischen Rathaus der Stadt Köln statt.',
        arabicTranslation:
            'عُقد المؤتمر في دار البلدية التاريخية لمدينة كولونيا.',
        grammaticalAnalysisArabic:
            'الأسماء الجغرافية بعد أسماء الأجناس (Stadt / Land / Fluss) ترد كبدل متصل لا ينصرف ولا يُعرب.',
        grammaticalAnalysisGerman:
            'Geografischer Eigenname als enge Apposition nach Gattungsbezeichnung: "Köln" bleibt unflektiert.',
        punctuationRule:
            'Kein Komma zwischen Gattungsbezeichnung und geografischem Namen.',
      ),
    );

    // 4. Partitive Apposition / Measure & Material
    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-PARTITIVE-10',
        antecedent: 'einem Glas',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.neuter,
        appositionText: 'frischem Quellwasser',
        appositionCase: GermanCase.dative,
        appositionType: AppositionType.partitiveApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Er erfrischte sich mit einem Glas frischem Quellwasser.',
        arabicTranslation:
            'انتعش بكأس من ماء النبع العذب.',
        grammaticalAnalysisArabic:
            'بدل الكميات والمقاييس (Partitive Apposition): الاسم الدال على المادة يتبع وعاء القياس في إعراب الجر (Dativ).',
        grammaticalAnalysisGerman:
            'Kongruierender Dativ bei partitiver Apposition nach Präposition "mit": "Glas" (Dativ) -> "frischem Quellwasser" (Dativ).',
        punctuationRule: 'Keine Kommasetzung zwischen Maßangabe und Substantiv.',
      ),
    );

    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-PARTITIVE-FALLBACK-11',
        antecedent: 'zwei Kilo',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.neuter,
        appositionText: 'reife Äpfel',
        appositionCase: GermanCase.nominative,
        appositionType: AppositionType.partitiveApposition,
        agreementStatus: AgreementStatus.incongruentNominativeFallback,
        fullSentence:
            'Zu den zwei Kilo reife Äpfel legte er noch Birnen hinzu.',
        arabicTranslation:
            'إلى كيلوغرامي التفاح الناضج، أضاف أيضاً بعض الإجاص.',
        grammaticalAnalysisArabic:
            'ظاهرة الرفع الافتراضي (Nominativ-Ersatzform) في الأوزان غير المتصرفة، مقبولة في الاستعمال الفصيح المعاصر.',
        grammaticalAnalysisGerman:
            'Nominativische Ersatzform bei attributiver Maßangabe, standardsprachlich geduldet.',
        punctuationRule: 'Absolut kommalos.',
      ),
    );

    // 5. Complex Loose Apposition with Relative Sub-clause Interleaving
    _rulesCatalog.add(
      const AppositiveModel(
        id: 'APP-COMPLEX-PAIRED-12',
        antecedent: 'Herrn Dr. Al-Mansoor',
        antecedentCase: GermanCase.dative,
        antecedentGender: GrammaticalGender.masculine,
        appositionText: 'unserem geschätzten Gastdozenten aus Bagdad',
        appositionCase: GermanCase.dative,
        appositionType: AppositionType.looseApposition,
        agreementStatus: AgreementStatus.congruent,
        fullSentence:
            'Wir überreichen Herrn Dr. Al-Mansoor, unserem geschätzten Gastdozenten aus Bagdad, die Ehrenurkunde.',
        arabicTranslation:
            'نُسلم الدكتور المنصور، أستاذنا الزائر الموقر من بغداد، شهادة التقدير والتكريم.',
        grammaticalAnalysisArabic:
            'بدل منفصل مجرور بالياء/الميم بالداوديف (unserem geschätzten Gastdozenten) متطابق تماماً مع المنادى/المستلم.',
        grammaticalAnalysisGerman:
            'Mehrgliedrige lockere Apposition im Dativ mit Adjektiv- und Herkunftsattribut, strikt kongruent.',
        punctuationRule:
            'Einschließende Kommas sind unverzichtbar; Weglassen des zweiten Kommas ist ein schwerer Grammatikfehler.',
      ),
    );
  }

  /// Evaluates an input sentence against expected appositive agreement patterns.
  ValidationReport validateApposition({
    required GermanCase antecedentCase,
    required GermanCase appositionCase,
    required AppositionType type,
    required bool containsPairCommas,
  }) {
    final issues = <String>[];
    final recommendations = <String>[];
    AgreementStatus status = AgreementStatus.congruent;

    if (type == AppositionType.looseApposition) {
      if (!containsPairCommas) {
        issues.add('Fehlende Kommasetzung: Eine lockere Apposition muss durch paarige Kommas abgegrenzt werden.');
        recommendations.add('Fügen Sie Kommas vor und nach der Apposition ein.');
      }
      if (antecedentCase != appositionCase) {
        if (appositionCase == GermanCase.nominative) {
          status = AgreementStatus.incongruentNominativeFallback;
          recommendations.add('Vermeiden Sie den Nominativ bei Dativ/Akkusativ-Bezugswörtern in der Standardsprache.');
        } else {
          status = AgreementStatus.incongruentDativeShift;
          issues.add('Kasusdiskrepanz: Die lockere Apposition stimmt nicht im Kasus mit dem Bezugswort überein.');
        }
      }
    } else if (type == AppositionType.closeApposition) {
      if (containsPairCommas) {
        issues.add('Unzulässige Kommasetzung: Enge Appositionen (Titel, Namen, Maße) werden nie durch Kommas getrennt.');
        recommendations.add('Entfernen Sie die Kommas.');
      }
    } else if (type == AppositionType.appositionWithAlsWie) {
      if (antecedentCase != appositionCase) {
        issues.add('Fehler bei als/wie: Der Kasus nach "als/wie" muss mit dem Bezugswort übereinstimmen.');
        recommendations.add('Prüfen Sie den Kasus des Bezugsworts (Subjekt -> Nominativ, Objekt -> Akkusativ/Dativ).');
      }
    }

    return ValidationReport(
      isValid: issues.isEmpty,
      status: status,
      issues: issues,
      recommendations: recommendations,
      arabicVerdict: issues.isEmpty
          ? 'التركيب النحوي للبدل سليم ومطابق للقواعد الألمانية الفصيحة.'
          : 'توجد ملاحظات إعرابية أو علامات ترقيم تحتاج إلى تصحيح في تركيب البدل.',
    );
  }

  /// Filters rules by apposition type.
  List<AppositiveModel> getByType(AppositionType type) {
    return _rulesCatalog.where((m) => m.appositionType == type).toList();
  }

  /// Filters rules by grammatical case.
  List<AppositiveModel> getByCase(GermanCase gCase) {
    return _rulesCatalog.where((m) => m.antecedentCase == gCase).toList();
  }
}

/// Validation result container.
class ValidationReport {
  final bool isValid;
  final AgreementStatus status;
  final List<String> issues;
  final List<String> recommendations;
  final String arabicVerdict;

  const ValidationReport({
    required this.isValid,
    required this.status,
    required this.issues,
    required this.recommendations,
    required this.arabicVerdict,
  });
}
