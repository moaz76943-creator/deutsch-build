import '../polyglot_unified_core.dart';

/// حزمة التواصل المهني والحياتي الواقعي (الطب، الهندسة، الأعمال، التعاملات اليومية)
class GermanRealWorldDialoguesPack implements PolyglotFeatureModule {
  @override
  String get moduleId => 'de_real_world_dialogues_pack';

  @override
  String get arabicTitle => 'الحوارات والتعبيرات الواقعية في الطب والهندسة والأعمال والحياة اليومية';

  @override
  List<PolyglotLearningUnit> get units => const [
        // --- 1. الطب والرعاية الصحية (Medizin & Klinikalltag) ---
        PolyglotLearningUnit(
          id: 'dlg_med_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.b2,
          domainId: 'medicine',
          categoryId: 'clinical_intake',
          title: 'وصف الأعراض وفحص العلامات الحيوية في العيادة',
          targetExpression: 'die Beschwerden abklären / den Blutdruck messen',
          contextualSentence:
              '„Seit wann treten die Schmerzen im Brustbereich auf?“ – „Seit gestern Abend, besonders beim tiefen Einatmen; lassen Sie uns zunächst das EKG und den Blutdruck abklären.“',
          commonPitfall: 'نسيان حرف الجر seit مع المضارع عند السؤال عن بداية الأعراض المستمرة',
          arabicExplanation:
              'في الفحص السريري، يُستخدم الفعل abklären بمعنى استيضاح السبب التشخيصي عبر الفحوصات، مع صيغة المضارع بعد seit.',
          tags: ['Medizin', 'Dialog', 'B2'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_med_02',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'medicine',
          categoryId: 'pharmacy_guidance',
          title: 'إرشادات صرف الدواء والتفاعلات الدوائية في الصيدلية',
          targetExpression: 'auf nüchternen Magen einnehmen / Wechselwirkungen ausschließen',
          contextualSentence:
              'Nehmen Sie diese Tablette morgens auf nüchternen Magen mit ausreichend Wasser ein, um eine optimale Aufnahme im Körper zu gewährleisten und Wechselwirkungen auszuschließen.',
          commonPitfall: 'الخلط بين einnehmen (للدواء) و nehmen (العامة)',
          arabicExplanation:
              'الفعل einnehmen هو المصطلح الدقيق لتناول الأقراص الدوائية، وعبارة auf nüchternen Magen تعني على معدة فارغة.',
          tags: ['Medizin', 'Apotheke', 'C1'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_med_03',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'medicine',
          categoryId: 'lab_report',
          title: 'مناقشة نتائج التحاليل المخبرية بشكل مطمئن ومهني',
          targetExpression: 'im Normbereich liegen / leicht erhöht sein',
          contextualSentence:
              'Die Entzündungswerte liegen erfreulicherweise wieder vollständig im Normbereich, lediglich der Eisenwert ist noch leicht erniedrigt.',
          commonPitfall: 'im normalen Bereich (تعبير ركيك مقارنة بالمصطلح الطبي im Normbereich)',
          arabicExplanation:
              'التعبير القياسي في التقارير الطبية الألمانية هو im Normbereich liegen للدلالة على سلامة المؤشرات الحيوية.',
          tags: ['Medizin', 'Labor', 'C1'],
        ),

        // --- 2. الهندسة والمواقع الصناعية (Ingenieurwesen & Technik) ---
        PolyglotLearningUnit(
          id: 'dlg_eng_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'engineering',
          categoryId: 'maintenance_handover',
          title: 'تسليم نوبة الصيانة وتوثيق الأعطال في المحطة',
          targetExpression: 'eine Störung beheben / in Betrieb nehmen',
          contextualSentence:
              '„Konnte die Frequenzabweichung am Wechselrichter behoben werden?“ – „Ja, nach dem Tausch des Kondensators haben wir die Anlage wieder stabil in Betrieb genommen.“',
          commonPitfall: 'in Betrieb machen (ترجمة حرفية خاطئة بدلاً من in Betrieb nehmen)',
          arabicExplanation:
              'الأفعال الوظيفية الدقيقة في الهندسة هي eine Störung beheben (إصلاح عطل) و eine Anlage in Betrieb nehmen (إدخال منشأة في الخدمة).',
          tags: ['Ingenieurwesen', 'Dialog', 'C1'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_eng_02',
          languageCode: 'de',
          level: CefrProficiencyLevel.c2,
          domainId: 'engineering',
          categoryId: 'quality_inspection',
          title: 'تقييم التحمل الإنشائي وجودة اللحام',
          targetExpression: 'den Anforderungen entsprechen / einer Belastung standhalten',
          contextualSentence:
              'Die Ultraschallprüfung bestätigt, dass sämtliche Schweißnähte den strengen Sicherheitsanforderungen entsprechen und der Dauerbelastung standhalten.',
          commonPitfall: 'entsprechen + Akkusativ (الصحيح أن entsprechen يحكم Dativ دائماً)',
          arabicExplanation:
              'الفعل entsprechen يأخذ حالة المجرور (Dativ: den Anforderungen) دون حرف جر، وكذلك standhalten + Dativ.',
          tags: ['Ingenieurwesen', 'Qualität', 'C2'],
        ),

        // --- 3. الأعمال والتفاوض المؤسسي (Wirtschaft & Projektmanagement) ---
        PolyglotLearningUnit(
          id: 'dlg_biz_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.b2,
          domainId: 'business',
          categoryId: 'negotiation',
          title: 'التفاوض على مواعيد التسليم وشروط التوريد',
          targetExpression: 'einen Liefertermin einhalten / einen Kompromiss erzielen',
          contextualSentence:
              '„Können Sie den vereinbarten Liefertermin trotz der Rohstoffknappheit einhalten?“ – „Bei Teillieferung ab Montag lässt sich ein tragfähiger Kompromiss erzielen.“',
          commonPitfall: 'einen Termin halten (الأدق مهنياً: einen Termin einhalten)',
          arabicExplanation:
              'في لغة الأعمال الألمانية نستخدم einhalten للالتزام بالموعد أو العقد، و erzielen لتحقيق اتفاق أو تسوية.',
          tags: ['Wirtschaft', 'Verhandlung', 'B2'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_biz_02',
          languageCode: 'de',
          level: CefrProficiencyLevel.c1,
          domainId: 'business',
          categoryId: 'meeting_protocol',
          title: 'تلخيص مخرجات الاجتماع وتوزيع المهام',
          targetExpression: 'einen Beschluss fassen / die Verantwortung übernehmen',
          contextualSentence:
              'Im Protokoll wurde festgehalten, dass die Entwicklungsabteilung bis Freitag die Kostenschätzung vorlegt und die Umsetzung koordiniert.',
          commonPitfall: 'im Protokoll schreiben (الأسلوب المؤسسي الفصيح: im Protokoll festhalten)',
          arabicExplanation:
              'التعبير im Protokoll festhalten هو الصياغة الرسمية المعتمدة لتدوين القرارات في محاضر الاجتماعات.',
          tags: ['Wirtschaft', 'Meeting', 'C1'],
        ),

        // --- 4. التعاملات اليومية والخدمات (Alltag & Behördenfreie Kommunikation) ---
        PolyglotLearningUnit(
          id: 'dlg_day_01',
          languageCode: 'de',
          level: CefrProficiencyLevel.b1,
          domainId: 'daily_life',
          categoryId: 'housing_maintenance',
          title: 'التواصل مع إدارة الصيانة السكنية بشأن التدفئة',
          targetExpression: 'die Heizung entlüften / einen Termin vereinbaren',
          contextualSentence:
              '„Guten Tag, der Heizkörper im Arbeitszimmer bleibt leider kalt.“ – „Ich schicke morgen Vormittag einen Monteur vorbei, um das System zu entlüften.“',
          commonPitfall: 'einen Termin machen (الأكثر لباقة ومهنية: einen Termin vereinbaren)',
          arabicExplanation:
              'في المعاملات اليومية المهذبة، نفضل einen Termin vereinbaren على machen، والفعل entlüften يعني تفريغ الهواء من شبكة التدفئة.',
          tags: ['Alltag', 'Wohnen', 'B1'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_day_02',
          languageCode: 'de',
          level: CefrProficiencyLevel.b2,
          domainId: 'daily_life',
          categoryId: 'transit_service',
          title: 'الاستفسار عن البدائل عند تأخر القطار في المحطة',
          targetExpression: 'eine Verbindung verpassen / auf einen anderen Zug ausweichen',
          contextualSentence:
              '„Mein Anschlusszug nach Frankfurt hat zwanzig Minuten Verspätung – welche Alternative habe ich?“ – „Sie können auf den Regionalexpress um 14:15 Uhr von Gleis vier ausweichen.“',
          commonPitfall: 'den Zug verlieren (الصحيح مع المواصلات في الألمانية: den Zug verpassen)',
          arabicExplanation:
              'فوات القطار أو الموعد يُعبر عنه بالفعل verpassen وليس verlieren، والفعل ausweichen auf يعني التحول إلى مسار بديل.',
          tags: ['Alltag', 'Mobilität', 'B2'],
        ),
        PolyglotLearningUnit(
          id: 'dlg_day_03',
          languageCode: 'de',
          level: CefrProficiencyLevel.b2,
          domainId: 'daily_life',
          categoryId: 'customer_service',
          title: 'طلب استبدال منتج تقني معيب بضمان المتجر',
          targetExpression: 'einen Artikel reklamieren / den Kaufbeleg vorlegen',
          contextualSentence:
              '„Das Ladegerät funktioniert seit gestern nicht mehr; hier ist der Kaufbeleg.“ – „Selbstverständlich, wir tauschen das Gerät im Rahmen der Garantie sofort um.“',
          commonPitfall: 'das Gerät zurückgeben (عند وجود عطل مصنعي نستخدم reklamieren / umtauschen)',
          arabicExplanation:
              'يُستخدم الفعل reklamieren لتقديم شكوى عطل أو طلب استبدال ضمن الضمان، مع تقديم فاتورة الشراء (Kaufbeleg).',
          tags: ['Alltag', 'Einkauf', 'B2'],
        ),
      ];

  @override
  List<PolyglotValidationRule> get validationRules => const [];
}
