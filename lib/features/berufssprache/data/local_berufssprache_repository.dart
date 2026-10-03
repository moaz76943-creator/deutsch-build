import '../domain/berufssprache_models.dart';

final class LocalBerufsspracheRepository implements BerufsspracheRepository {
  const LocalBerufsspracheRepository();

  static const List<WorkplacePhrase> _phrases = <WorkplacePhrase>[
    WorkplacePhrase(
      id: 'minutes_take_notes',
      topic: WorkplaceTopic.meetingMinutes,
      register: WorkplaceRegister.collegialSie,
      german: 'Ich übernehme das Protokoll der Besprechung.',
      arabic: 'سأتولى كتابة محضر الاجتماع.',
      usageArabic: 'صيغة مهنية واضحة لتحديد من سيكتب المحضر.',
    ),
    WorkplacePhrase(
      id: 'minutes_record_decisions',
      topic: WorkplaceTopic.meetingMinutes,
      register: WorkplaceRegister.writtenFormal,
      german: 'Im Protokoll halten wir die wichtigsten Beschlüsse fest.',
      arabic: 'نثبت أهم القرارات في محضر الاجتماع.',
      usageArabic: 'festhalten شائع في المحاضر بمعنى توثيق المعلومة رسميًا.',
    ),
    WorkplacePhrase(
      id: 'minutes_document_tasks',
      topic: WorkplaceTopic.meetingMinutes,
      register: WorkplaceRegister.writtenFormal,
      german: 'Als nächster Schritt wird die Aufgabenverteilung dokumentiert.',
      arabic: 'كخطوة تالية سيتم توثيق توزيع المهام.',
      usageArabic: 'صيغة محايدة مناسبة للكتابة الإدارية ومحاضر الاجتماعات.',
    ),
    WorkplacePhrase(
      id: 'minutes_repeat_decision',
      topic: WorkplaceTopic.meetingMinutes,
      register: WorkplaceRegister.formalSie,
      german:
          'Könnten Sie den Beschluss für das Protokoll bitte noch einmal zusammenfassen?',
      arabic: 'هل يمكن أن تلخصوا القرار مرة أخرى من أجل المحضر؟',
      usageArabic: 'طلب رسمي مهذب للتأكد من دقة القرار قبل تدوينه.',
    ),
    WorkplacePhrase(
      id: 'schedule_offer_tuesday',
      topic: WorkplaceTopic.scheduling,
      register: WorkplaceRegister.formalSie,
      german: 'Passt Ihnen Dienstag um zehn Uhr für die Besprechung?',
      arabic: 'هل يناسبكم يوم الثلاثاء الساعة العاشرة للاجتماع؟',
      usageArabic: 'سؤال مباشر ومهذب لاقتراح موعد.',
    ),
    WorkplacePhrase(
      id: 'schedule_move_wednesday',
      topic: WorkplaceTopic.scheduling,
      register: WorkplaceRegister.formalSie,
      german: 'Könnten wir den Termin auf Mittwochvormittag verschieben?',
      arabic: 'هل يمكننا نقل الموعد إلى صباح الأربعاء؟',
      usageArabic: 'verschieben هو الفعل المعتاد لتأجيل أو نقل الموعد.',
    ),
    WorkplacePhrase(
      id: 'schedule_availability',
      topic: WorkplaceTopic.scheduling,
      register: WorkplaceRegister.collegialSie,
      german: 'Ich bin zwischen neun und elf Uhr verfügbar.',
      arabic: 'أنا متاح بين الساعة التاسعة والحادية عشرة.',
      usageArabic: 'صيغة مختصرة لذكر نافذة التوفر في بيئة العمل.',
    ),
    WorkplacePhrase(
      id: 'schedule_confirm',
      topic: WorkplaceTopic.scheduling,
      register: WorkplaceRegister.writtenFormal,
      german: 'Dann bestätige ich den Termin für Donnerstag um 14 Uhr.',
      arabic: 'إذن أؤكد الموعد ليوم الخميس الساعة الثانية بعد الظهر.',
      usageArabic: 'صيغة مناسبة لتأكيد الموعد شفهيًا أو كتابيًا.',
    ),
    WorkplacePhrase(
      id: 'delegate_prepare_documents',
      topic: WorkplaceTopic.delegation,
      register: WorkplaceRegister.formalSie,
      german: 'Könnten Sie bitte die Unterlagen bis Freitag vorbereiten?',
      arabic: 'هل يمكنكم تجهيز المستندات حتى يوم الجمعة من فضلكم؟',
      usageArabic: 'تفويض مهذب يذكر المهمة والموعد النهائي بوضوح.',
    ),
    WorkplacePhrase(
      id: 'delegate_split_work',
      topic: WorkplaceTopic.delegation,
      register: WorkplaceRegister.collegialSie,
      german:
          'Ich übernehme die Auswertung; übernehmen Sie bitte die Qualitätsprüfung.',
      arabic: 'سأتولى التقييم؛ تفضلوا أنتم بتولي فحص الجودة.',
      usageArabic: 'صيغة عملية لتقسيم المسؤوليات بين الزملاء.',
    ),
    WorkplacePhrase(
      id: 'delegate_notify_team',
      topic: WorkplaceTopic.delegation,
      register: WorkplaceRegister.formalSie,
      german: 'Bitte informieren Sie das Team, sobald die Freigabe vorliegt.',
      arabic: 'يرجى إبلاغ الفريق فور صدور الموافقة.',
      usageArabic: 'sobald تربط تنفيذ المهمة بتحقق شرط واضح.',
    ),
    WorkplacePhrase(
      id: 'delegate_responsibility',
      topic: WorkplaceTopic.delegation,
      register: WorkplaceRegister.collegialSie,
      german: 'Wer kann die Verantwortung für die Dokumentation übernehmen?',
      arabic: 'من يمكنه تولي مسؤولية التوثيق؟',
      usageArabic: 'سؤال محايد لتوزيع المسؤولية دون لهجة أمر حادة.',
    ),
    WorkplacePhrase(
      id: 'request_check_table',
      topic: WorkplaceTopic.politeRequests,
      register: WorkplaceRegister.formalSie,
      german: 'Hätten Sie kurz Zeit, diese Tabelle mit mir zu prüfen?',
      arabic: 'هل لديكم بعض الوقت لمراجعة هذا الجدول معي؟',
      usageArabic: 'Hätten Sie ...? صيغة Konjunktiv II مهذبة جدًا للطلب.',
    ),
    WorkplacePhrase(
      id: 'request_send_version',
      topic: WorkplaceTopic.politeRequests,
      register: WorkplaceRegister.formalSie,
      german: 'Könnten Sie mir bitte die aktuelle Version zusenden?',
      arabic: 'هل يمكنكم إرسال النسخة الحالية لي من فضلكم؟',
      usageArabic: 'Könnten Sie ...? من أكثر صيغ الطلب المهني شيوعًا.',
    ),
    WorkplacePhrase(
      id: 'request_mark_change',
      topic: WorkplaceTopic.politeRequests,
      register: WorkplaceRegister.formalSie,
      german: 'Wären Sie so freundlich, die Änderung im Dokument zu markieren?',
      arabic: 'هل تتكرمون بوضع علامة على التغيير في المستند؟',
      usageArabic: 'صيغة رسمية لطيفة مناسبة عند طلب خدمة صغيرة من زميل.',
    ),
    WorkplacePhrase(
      id: 'request_comment_draft',
      topic: WorkplaceTopic.politeRequests,
      register: WorkplaceRegister.formalSie,
      german: 'Darf ich Sie bitten, den Entwurf bis morgen zu kommentieren?',
      arabic: 'هل يمكنني أن أطلب منكم التعليق على المسودة حتى الغد؟',
      usageArabic: 'Darf ich Sie bitten ...? صيغة رسمية واضحة للطلبات.',
    ),
    WorkplacePhrase(
      id: 'phone_introduction',
      topic: WorkplaceTopic.formalTelephone,
      register: WorkplaceRegister.formalSie,
      german: 'Guten Tag, hier spricht Frau Keller von der Personalabteilung.',
      arabic: 'مرحبًا، معكم السيدة كيلر من قسم الموارد البشرية.',
      usageArabic: 'hier spricht ... صيغة قياسية للتعريف بالنفس في مكالمة رسمية.',
    ),
    WorkplacePhrase(
      id: 'phone_connect',
      topic: WorkplaceTopic.formalTelephone,
      register: WorkplaceRegister.formalSie,
      german: 'Könnten Sie mich bitte mit Herrn Berger verbinden?',
      arabic: 'هل يمكنكم تحويلي إلى السيد بيرغر من فضلكم؟',
      usageArabic: 'verbinden mit تستخدم لطلب تحويل المكالمة إلى شخص آخر.',
    ),
    WorkplacePhrase(
      id: 'phone_take_message',
      topic: WorkplaceTopic.formalTelephone,
      register: WorkplaceRegister.formalSie,
      german: 'Herr Berger ist gerade nicht erreichbar. Darf ich etwas ausrichten?',
      arabic: 'السيد بيرغر غير متاح الآن. هل يمكنني نقل رسالة؟',
      usageArabic: 'etwas ausrichten تعني نقل رسالة لشخص غير متاح.',
    ),
    WorkplacePhrase(
      id: 'phone_close',
      topic: WorkplaceTopic.formalTelephone,
      register: WorkplaceRegister.formalSie,
      german:
          'Vielen Dank für Ihren Anruf. Ich sende Ihnen die Unterlagen noch heute per E-Mail.',
      arabic: 'شكرًا لاتصالكم. سأرسل لكم المستندات اليوم عبر البريد الإلكتروني.',
      usageArabic: 'خاتمة رسمية تحدد الإجراء التالي بوضوح.',
    ),
  ];

  @override
  Future<List<WorkplacePhrase>> getPhrases({WorkplaceTopic? topic}) async {
    final values = topic == null
        ? _phrases
        : _phrases.where((phrase) => phrase.topic == topic).toList();
    return List<WorkplacePhrase>.unmodifiable(values);
  }

  @override
  Future<WorkplacePhrase?> getPhraseById(String id) async {
    final normalizedId = id.trim();
    for (final phrase in _phrases) {
      if (phrase.id == normalizedId) return phrase;
    }
    return null;
  }

  @override
  Future<bool> validateGermanPhrase(String id, String candidate) async {
    final phrase = await getPhraseById(id);
    if (phrase == null) return false;
    return _normalize(candidate) == _normalize(phrase.german);
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[.!?,;:]'), '')
      .replaceAll(RegExp(r'\s+'), ' ');
}
