import '../domain/email_builder_models.dart';
import '../domain/email_builder_repository.dart';

final class LocalEmailBuilderRepository implements EmailBuilderRepository {
  LocalEmailBuilderRepository()
      : _scenarios = _buildScenarios(),
        _blocks = _buildBlocks();

  final List<EmailScenario> _scenarios;
  final List<EmailTemplateBlock> _blocks;

  @override
  Future<List<EmailScenario>> getScenarios() async =>
      List<EmailScenario>.unmodifiable(_scenarios);

  @override
  Future<List<EmailTemplateBlock>> getBlocks({
    required String scenarioId,
    LetterSection? section,
  }) async {
    final selected = _blocks.where((block) {
      if (block.scenarioId != scenarioId) return false;
      return section == null || block.section == section;
    }).toList(growable: false);
    return List<EmailTemplateBlock>.unmodifiable(selected);
  }

  @override
  Future<bool> validateStructure(List<EmailTemplateBlock> blocks) async {
    if (blocks.length != LetterSection.values.length) return false;
    if (blocks.map((item) => item.scenarioId).toSet().length != 1) {
      return false;
    }
    final seen = <LetterSection>{};
    for (var index = 0; index < LetterSection.values.length; index++) {
      final block = blocks[index];
      if (block.section != LetterSection.values[index]) return false;
      if (!seen.add(block.section)) return false;
    }
    return true;
  }

  @override
  Future<bool> isRegisterAppropriate({
    required String scenarioId,
    required EmailTemplateBlock block,
  }) async {
    final scenario = _scenarioById(scenarioId);
    return scenario != null &&
        block.scenarioId == scenarioId &&
        block.register == scenario.targetRegister;
  }

  @override
  Future<bool> validatePhrase({
    required String scenarioId,
    required String blockId,
  }) async {
    final block = _blockById(blockId);
    if (block == null || block.scenarioId != scenarioId) return false;
    if (!_isPhraseWellFormed(block)) return false;
    return isRegisterAppropriate(
      scenarioId: scenarioId,
      block: block,
    );
  }

  EmailScenario? _scenarioById(String id) {
    for (final scenario in _scenarios) {
      if (scenario.id == id) return scenario;
    }
    return null;
  }

  EmailTemplateBlock? _blockById(String id) {
    for (final block in _blocks) {
      if (block.id == id) return block;
    }
    return null;
  }

  static bool _isPhraseWellFormed(EmailTemplateBlock block) {
    if (block.text.trim().isEmpty) return false;
    if (block.section == LetterSection.salutation) {
      if (!block.text.endsWith(',')) return false;
      if (block.register == EmailRegister.formalOfficial) {
        return block.text.startsWith('Sehr geehrte');
      }
    }
    if (block.section == LetterSection.closingSignoff &&
        block.register == EmailRegister.formalOfficial) {
      return block.text == 'Mit freundlichen Grüßen';
    }
    return true;
  }

  static List<EmailScenario> _buildScenarios() {
    return const <EmailScenario>[
      EmailScenario(
        id: 'appointment_b1',
        titleDe: 'Termin vereinbaren',
        titleAr: 'طلب موعد',
        level: 'B1',
        promptDe:
            'Sie möchten einen Beratungstermin vereinbaren. Schreiben Sie eine formelle E-Mail und nennen Sie Anlass, Wunschzeit und eine höfliche Bitte um Bestätigung.',
        targetRegister: EmailRegister.formalOfficial,
      ),
      EmailScenario(
        id: 'complaint_b2',
        titleDe: 'Formelle Beschwerde',
        titleAr: 'شكوى رسمية',
        level: 'B2',
        promptDe:
            'Sie sind mit einer Dienstleistung unzufrieden. Beschreiben Sie sachlich das Problem, nennen Sie die Folgen und formulieren Sie eine angemessene Lösung.',
        targetRegister: EmailRegister.formalOfficial,
      ),
      EmailScenario(
        id: 'apology_work_b1',
        titleDe: 'Entschuldigung im Beruf',
        titleAr: 'اعتذار مهني',
        level: 'B1/B2',
        promptDe:
            'Sie können eine vereinbarte Aufgabe nicht rechtzeitig abschließen. Entschuldigen Sie sich bei einer Kollegin und schlagen Sie einen neuen Termin vor.',
        targetRegister: EmailRegister.semiFormalWork,
      ),
    ];
  }

  static List<EmailTemplateBlock> _buildBlocks() {
    const commaRule =
        'بعد التحية الألمانية التي تنتهي بفاصلة، يبدأ السطر التالي عادةً بحرف صغير إذا كانت الجملة مستمرة.';
    const bodyRule =
        'لا نضع فاصلة تلقائياً بعد بداية الفقرة؛ استخدم علامات الترقيم بحسب تركيب الجملة.';
    const closingRule =
        'Mit freundlichen Grüßen لا تتبعها فاصلة في المراسلات الألمانية الحديثة.';

    const blocks = <EmailTemplateBlock>[
      EmailTemplateBlock(
        id: 'appointment_salutation_formal',
        scenarioId: 'appointment_b1',
        section: LetterSection.salutation,
        text: 'Sehr geehrte Damen und Herren,',
        register: EmailRegister.formalOfficial,
        toneAr: 'رسمي ومحايد عند عدم معرفة اسم المخاطَب',
        translationAr: 'السيدات والسادة المحترمون،',
        punctuationNoteAr: commaRule,
        applications: <String>['طلب موعد', 'استفسار رسمي', 'مراسلة مؤسسة'],
      ),
      EmailTemplateBlock(
        id: 'appointment_opening_formal',
        scenarioId: 'appointment_b1',
        section: LetterSection.openingHook,
        text: 'ich schreibe Ihnen bezüglich eines Beratungstermins.',
        register: EmailRegister.formalOfficial,
        toneAr: 'مباشر ورسمي',
        translationAr: 'أكتب إليكم بخصوص موعد للاستشارة.',
        punctuationNoteAr: commaRule,
        applications: <String>['طلب موعد', 'استفسار'],
      ),
      EmailTemplateBlock(
        id: 'appointment_reason_formal',
        scenarioId: 'appointment_b1',
        section: LetterSection.mainBodyReason,
        text:
            'Ich benötige eine Beratung zu meinen Unterlagen und würde die nächsten Schritte gern persönlich besprechen.',
        register: EmailRegister.formalOfficial,
        toneAr: 'واضح ومهذب',
        translationAr:
            'أحتاج إلى استشارة بخصوص أوراقي وأرغب في مناقشة الخطوات التالية شخصياً.',
        punctuationNoteAr: bodyRule,
        applications: <String>['طلب موعد', 'استشارة'],
      ),
      EmailTemplateBlock(
        id: 'appointment_request_formal',
        scenarioId: 'appointment_b1',
        section: LetterSection.requestOrComplaint,
        text:
            'Könnten Sie mir bitte einen Termin am kommenden Dienstag oder Mittwoch anbieten?',
        register: EmailRegister.formalOfficial,
        toneAr: 'طلب مهذب بصيغة Konjunktiv II',
        translationAr:
            'هل يمكنكم من فضلكم أن تعرضوا عليّ موعداً يوم الثلاثاء أو الأربعاء القادم؟',
        punctuationNoteAr:
            'تنتهي صيغة السؤال المباشر بعلامة استفهام، مع بقاء الصياغة رسمية ومهذبة.',
        applications: <String>['طلب موعد', 'طلب تأكيد'],
      ),
      EmailTemplateBlock(
        id: 'appointment_closing_formal',
        scenarioId: 'appointment_b1',
        section: LetterSection.closingSignoff,
        text: 'Mit freundlichen Grüßen',
        register: EmailRegister.formalOfficial,
        toneAr: 'خاتمة رسمية معيارية',
        translationAr: 'مع أطيب التحيات',
        punctuationNoteAr: closingRule,
        applications: <String>['طلب موعد', 'رسالة رسمية'],
      ),
      EmailTemplateBlock(
        id: 'appointment_opening_friendly',
        scenarioId: 'appointment_b1',
        section: LetterSection.openingHook,
        text: 'ich wollte mal fragen, ob wir uns treffen können.',
        register: EmailRegister.informalFriendly,
        toneAr: 'ودي وغير مناسب لمؤسسة رسمية',
        translationAr: 'كنت أريد فقط أن أسأل إن كان بإمكاننا أن نلتقي.',
        punctuationNoteAr: commaRule,
        applications: <String>['محادثة ودية'],
      ),

      EmailTemplateBlock(
        id: 'complaint_salutation_formal',
        scenarioId: 'complaint_b2',
        section: LetterSection.salutation,
        text: 'Sehr geehrte Damen und Herren,',
        register: EmailRegister.formalOfficial,
        toneAr: 'رسمي ومحايد',
        translationAr: 'السيدات والسادة المحترمون،',
        punctuationNoteAr: commaRule,
        applications: <String>['شكوى رسمية', 'خدمة عملاء'],
      ),
      EmailTemplateBlock(
        id: 'complaint_opening_formal',
        scenarioId: 'complaint_b2',
        section: LetterSection.openingHook,
        text: 'ich wende mich an Sie, weil es ein Problem mit Ihrer Dienstleistung gibt.',
        register: EmailRegister.formalOfficial,
        toneAr: 'رسمي وموضوعي',
        translationAr: 'أتواصل معكم لوجود مشكلة في خدمتكم.',
        punctuationNoteAr: commaRule,
        applications: <String>['شكوى رسمية'],
      ),
      EmailTemplateBlock(
        id: 'complaint_reason_formal',
        scenarioId: 'complaint_b2',
        section: LetterSection.mainBodyReason,
        text:
            'Die vereinbarte Leistung wurde nicht vollständig erbracht, obwohl der gesamte Betrag bereits bezahlt wurde.',
        register: EmailRegister.formalOfficial,
        toneAr: 'موضوعي ودقيق دون انفعال',
        translationAr:
            'لم تُنفذ الخدمة المتفق عليها بالكامل رغم أن المبلغ الكامل دُفع مسبقاً.',
        punctuationNoteAr: bodyRule,
        applications: <String>['شكوى رسمية', 'مطالبة خدمة'],
      ),
      EmailTemplateBlock(
        id: 'complaint_request_formal',
        scenarioId: 'complaint_b2',
        section: LetterSection.requestOrComplaint,
        text:
            'Ich bitte Sie daher um eine schriftliche Stellungnahme und eine angemessene Lösung innerhalb der nächsten sieben Tage.',
        register: EmailRegister.formalOfficial,
        toneAr: 'حازم ومهذب',
        translationAr:
            'لذلك أرجو منكم رداً خطياً وحلاً مناسباً خلال الأيام السبعة القادمة.',
        punctuationNoteAr: bodyRule,
        applications: <String>['شكوى رسمية', 'طلب حل'],
      ),
      EmailTemplateBlock(
        id: 'complaint_closing_formal',
        scenarioId: 'complaint_b2',
        section: LetterSection.closingSignoff,
        text: 'Mit freundlichen Grüßen',
        register: EmailRegister.formalOfficial,
        toneAr: 'خاتمة رسمية حتى مع وجود شكوى',
        translationAr: 'مع أطيب التحيات',
        punctuationNoteAr: closingRule,
        applications: <String>['شكوى رسمية'],
      ),
      EmailTemplateBlock(
        id: 'complaint_opening_friendly',
        scenarioId: 'complaint_b2',
        section: LetterSection.openingHook,
        text: 'ich bin echt enttäuscht und wollte euch das einfach sagen.',
        register: EmailRegister.informalFriendly,
        toneAr: 'ودي وعاطفي وغير مناسب لشكوى رسمية',
        translationAr: 'أنا محبط فعلاً وأردت فقط أن أخبركم بذلك.',
        punctuationNoteAr: commaRule,
        applications: <String>['رسالة ودية غير رسمية'],
      ),

      EmailTemplateBlock(
        id: 'apology_salutation_work',
        scenarioId: 'apology_work_b1',
        section: LetterSection.salutation,
        text: 'Guten Tag Frau Schneider,',
        register: EmailRegister.semiFormalWork,
        toneAr: 'مهني مباشر',
        translationAr: 'مرحباً السيدة شنايدر،',
        punctuationNoteAr: commaRule,
        applications: <String>['اعتذار مهني', 'مراسلة زميلة'],
      ),
      EmailTemplateBlock(
        id: 'apology_opening_work',
        scenarioId: 'apology_work_b1',
        section: LetterSection.openingHook,
        text: 'ich möchte mich für die Verzögerung entschuldigen.',
        register: EmailRegister.semiFormalWork,
        toneAr: 'مهني ومسؤول',
        translationAr: 'أود أن أعتذر عن التأخير.',
        punctuationNoteAr: commaRule,
        applications: <String>['اعتذار مهني'],
      ),
      EmailTemplateBlock(
        id: 'apology_reason_work',
        scenarioId: 'apology_work_b1',
        section: LetterSection.mainBodyReason,
        text:
            'Wegen eines unerwarteten technischen Problems kann ich die Unterlagen heute leider nicht fertigstellen.',
        register: EmailRegister.semiFormalWork,
        toneAr: 'واضح دون مبالغة في التبرير',
        translationAr:
            'بسبب مشكلة تقنية غير متوقعة لا أستطيع للأسف إنهاء المستندات اليوم.',
        punctuationNoteAr: bodyRule,
        applications: <String>['اعتذار مهني', 'تأخير مهمة'],
      ),
      EmailTemplateBlock(
        id: 'apology_request_work',
        scenarioId: 'apology_work_b1',
        section: LetterSection.requestOrComplaint,
        text:
            'Wäre es für Sie in Ordnung, wenn ich Ihnen die vollständigen Unterlagen morgen bis 12 Uhr schicke?',
        register: EmailRegister.semiFormalWork,
        toneAr: 'مهني مع اقتراح حل واضح',
        translationAr:
            'هل سيكون مناسباً لكم أن أرسل المستندات الكاملة غداً حتى الساعة الثانية عشرة؟',
        punctuationNoteAr:
            'صيغة Wäre es ...? طلب مهذب وتنتهي بعلامة استفهام.',
        applications: <String>['اقتراح موعد بديل', 'اعتذار مهني'],
      ),
      EmailTemplateBlock(
        id: 'apology_closing_work',
        scenarioId: 'apology_work_b1',
        section: LetterSection.closingSignoff,
        text: 'Viele Grüße',
        register: EmailRegister.semiFormalWork,
        toneAr: 'خاتمة مهنية أخف من الصيغة الرسمية جداً',
        translationAr: 'مع تحياتي',
        punctuationNoteAr:
            'لا توضع فاصلة بعد Viele Grüße في هذا الاستخدام.',
        applications: <String>['مراسلة عمل شبه رسمية'],
      ),
      EmailTemplateBlock(
        id: 'apology_opening_formal',
        scenarioId: 'apology_work_b1',
        section: LetterSection.openingHook,
        text: 'ich bitte die entstandene Verzögerung zu entschuldigen.',
        register: EmailRegister.formalOfficial,
        toneAr: 'رسمي أكثر من المطلوب بين الزملاء',
        translationAr: 'أرجو المعذرة عن التأخير الذي حدث.',
        punctuationNoteAr: commaRule,
        applications: <String>['اعتذار رسمي'],
      ),
    ];

    final ids = blocks.map((block) => block.id).toSet();
    if (ids.length != blocks.length) {
      throw StateError('email template bank contains duplicate ids');
    }
    return List<EmailTemplateBlock>.unmodifiable(blocks);
  }
}
