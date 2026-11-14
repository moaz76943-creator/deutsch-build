import '../polyglot_unified_core.dart';

/// حزمة معيارية موحدة توضح كيف يمكن إضافة محتوى وقواعد جديدة في ملف واحد نظيف
class GermanC1C2CoreFeaturePack implements PolyglotFeatureModule {
  @override
  String get moduleId => 'de_c1_c2_core_pack';

  @override
  String get arabicTitle => 'الحزمة المتقدمة الموحدة لقواعد ومصطلحات الألمانية (C1–C2)';

  @override
  List<PolyglotLearningUnit> get units => const [
        PolyglotLearningUnit(
          id: 'uni_de_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'renewable_energy',
          categoryId: 'genitive_relatives',
          title: 'الضمير الموصول المضاف (dessen / deren)',
          targetExpression: 'dessen Wirkungsgrad / deren Schaufeln',
          contextualSentence:
              'Der Wechselrichter, dessen Wirkungsgrad bei 98,4 Prozent liegt, arbeitet völlig geräuschlos.',
          commonPitfall: 'dessen der Wirkungsgrad (إقحام أداة تعريف بعد dessen)',
          arabicExplanation:
              'يحل الضمير الموصول المضاف (dessen/deren) محل أداة التعريف، فلا يجوز وضع der/die/das بعده مباشرة.',
          tags: ['Relativsatz', 'Genitiv', 'C1'],
        ),
        PolyglotLearningUnit(
          id: 'uni_de_02',
          languageCode: 'de',
          level: CefrProficiencyLevel.c2,
          domainId: 'aerospace',
          categoryId: 'verb_cluster_ipp',
          title: 'المصدر البديل وتقديم الفعل المساعد (Ersatzinfinitiv)',
          targetExpression: 'hätte kalibriert werden müssen',
          contextualSentence:
              'Der Test wurde verschoben, da die Hydraulikpumpe vorab hat kalibriert werden müssen.',
          commonPitfall: 'kalibriert werden gemusst hat',
          arabicExplanation:
              'عند اجتماع فعل ناقص مع مصدر في الماضي داخل جملة جانبية، يتقدم الفعل المساعد (hat/hätte) ويتحول الفعل الناقص إلى المصدر البديل.',
          tags: ['Topologie', 'Ersatzinfinitiv', 'C2'],
        ),
        PolyglotLearningUnit(
          id: 'uni_de_03',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'robotics',
          categoryId: 'reflexive_case',
          title: 'الضمير الانعكاسي في حالة الجر (Dativ-Reflexiv)',
          targetExpression: 'Ich sehe mir das Schaltbild an',
          contextualSentence:
              'Ich schaue mir das Schaltbild des Steuergeräts genau an, bevor ich die Achse freigebe.',
          commonPitfall: 'Ich schaue mich das Schaltbild an',
          arabicExplanation:
              'عند وجود مفعول به منصوب صريح في الجملة، يتحول الضمير الانعكاسي وجوباً إلى حالة الجر (mir / dir).',
          tags: ['Reflexivpronomen', 'Dativ', 'C1'],
        ),
        PolyglotLearningUnit(
          id: 'uni_de_04',
          languageCode: 'de',
          level: CefrProficiencyLevel.c2,
          domainId: 'civil_engineering',
          categoryId: 'kongruenz',
          title: 'المطابقة الفعلية مع اللواحق الاسمية (samt / einschließlich)',
          targetExpression: 'Der Hauptträger samt seinen Stützen wurde geprüft',
          contextualSentence:
              'Der Hauptträger samt seinen vier seitlichen Stützpfeilern wurde erfolgreich vermessen.',
          commonPitfall: 'Der Hauptträger samt seinen Stützen wurden vermessen',
          arabicExplanation:
              'العبارات المسبوقة بـ (samt / nebst / einschließlich) لا تجمع الفاعل المفرد، فيبقى الفعل مفرداً.',
          tags: ['Kongruenz', 'Syntax', 'C2'],
        ),
        PolyglotLearningUnit(
          id: 'uni_de_05',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'materials',
          categoryId: 'word_formation',
          title: 'الاشتقاق الصرفي بالبادئة المتعدية (be-) واللاحقة (-nis)',
          targetExpression: 'die Messergebnisse besprechen',
          contextualSentence:
              'Die Ingenieure besprechen die neuen Messergebnisse der Ultraschallprüfung.',
          commonPitfall: 'besprechen über die Messergebnise',
          arabicExplanation:
              'البادئة be- تغني عن حرف الجر über، والأسماء المنتهية بـ -nis تضاعف فيها السين عند الجمع (Messergebnisse).',
          tags: ['Wortbildung', 'Morphologie', 'C1'],
        ),
      ];

  @override
  List<PolyglotValidationRule> get validationRules => [
        PolyglotValidationRule(
          ruleId: 'de_no_article_after_dessen_deren',
          languageCode: 'de',
          errorPattern: RegExp(
            r'\b(dessen|deren)\s+(der|die|das|den|dem|des)\b',
            caseSensitive: false,
          ),
          ruleTitle: 'Nullartikel nach dessen/deren',
          arabicFeedback: 'لا تضع أداة تعريف بعد الضمير الموصول المضاف (dessen / deren).',
          autoCorrector: (input) => input.replaceAllMapped(
            RegExp(r'\b(dessen|deren)\s+(der|die|das|den|dem|des)\s+', caseSensitive: false),
            (m) => '${m.group(1)} ',
          ),
        ),
        PolyglotValidationRule(
          ruleId: 'de_besprechen_without_ueber',
          languageCode: 'de',
          errorPattern: RegExp(r'\bbespr(ech|ich)[a-zäöüß]*\s+über\b', caseSensitive: false),
          ruleTitle: 'besprechen + direktes Akkusativobjekt',
          arabicFeedback: 'الفعل besprechen متعدٍ بنفسه ولا يأخذ حرف الجر über.',
          autoCorrector: (input) => input.replaceAllMapped(
            RegExp(r'(\bbespr(?:ech|ich)[a-zäöüß]*)\s+über\s+', caseSensitive: false),
            (m) => '${m.group(1)} ',
          ),
        ),
        PolyglotValidationRule(
          ruleId: 'de_nis_plural_double_s',
          languageCode: 'de',
          errorPattern: RegExp(r'\b([A-ZÄÖÜa-zäöüß]+nis)e\b'),
          ruleTitle: 'Plural auf -nisse',
          arabicFeedback: 'الأسماء المنتهية بـ -nis تُجمع بمضاعفة حرف السين (-nisse).',
          autoCorrector: (input) => input.replaceAllMapped(
            RegExp(r'\b([A-ZÄÖÜa-zäöüß]+nis)e\b'),
            (m) => '${m.group(1)}se',
          ),
        ),
      ];
}
