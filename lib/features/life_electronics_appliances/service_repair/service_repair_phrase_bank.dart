import 'service_repair_models.dart';

abstract final class ServiceRepairPhraseBank {
  static const List<ServiceRepairPhrase> all = <ServiceRepairPhrase>[
    ServiceRepairPhrase(
      id: 'fault-symptoms',
      topic: ServiceRepairTopic.faultReport,
      german:
          'Das Gerät startet, schaltet sich aber nach wenigen Minuten wieder aus. Der Fehler tritt seit gestern regelmäßig auf.',
      arabic:
          'الجهاز يعمل ثم ينطفئ بعد بضع دقائق. العطل يتكرر بانتظام منذ الأمس.',
      contextDe: 'Fehlerbild mit Zeitpunkt und Häufigkeit beschreiben',
      contextAr: 'وصف العطل ووقت ظهوره وتكراره',
      keywords: <String>['Defekt', 'Fehler', 'schaltet aus', 'عطل'],
    ),
    ServiceRepairPhrase(
      id: 'fault-model',
      topic: ServiceRepairTopic.faultReport,
      german:
          'Hier sind Modellnummer, Seriennummer und Kaufnachweis. Reichen diese Angaben für die Serviceaufnahme?',
      arabic:
          'هذه هي أرقام الموديل والتسلسل وإثبات الشراء. هل تكفي هذه البيانات لفتح طلب الصيانة؟',
      contextDe: 'Gerät eindeutig identifizieren',
      contextAr: 'تحديد الجهاز بشكل دقيق',
      keywords: <String>['Modellnummer', 'Seriennummer', 'Kaufnachweis', 'تسلسل'],
    ),
    ServiceRepairPhrase(
      id: 'fault-safety',
      topic: ServiceRepairTopic.faultReport,
      german:
          'Das Gerät riecht ungewöhnlich oder wird sehr heiß. Ich benutze es nicht weiter und möchte wissen, wie ich es sicher zum Service bringe.',
      arabic:
          'للجهاز رائحة غير طبيعية أو ترتفع حرارته كثيرًا. لن أستخدمه وأريد معرفة طريقة نقله للصيانة بأمان.',
      contextDe: 'Sicherheitsrelevanten Fehler nicht weiter provozieren',
      contextAr: 'عدم مواصلة استخدام جهاز قد يكون غير آمن',
      keywords: <String>['heiß', 'Geruch', 'Sicherheit', 'حرارة'],
    ),
    ServiceRepairPhrase(
      id: 'diagnosis-fee',
      topic: ServiceRepairTopic.diagnosis,
      german:
          'Fällt für die Diagnose eine Prüfpauschale an, und wird sie bei einer anschließenden Reparatur angerechnet?',
      arabic:
          'هل توجد رسوم للتشخيص، وهل تُحتسب ضمن تكلفة الإصلاح إذا وافقت عليه؟',
      contextDe: 'Diagnosekosten vor Abgabe klären',
      contextAr: 'تحديد رسوم التشخيص قبل التسليم',
      keywords: <String>['Diagnose', 'Prüfpauschale', 'رسوم'],
    ),
    ServiceRepairPhrase(
      id: 'diagnosis-data',
      topic: ServiceRepairTopic.diagnosis,
      german:
          'Muss das Gerät für die Diagnose zurückgesetzt oder entsperrt werden, und welche Daten könnten dabei gelöscht werden?',
      arabic:
          'هل يحتاج الجهاز إلى إعادة ضبط أو فتح قفل للتشخيص، وما البيانات التي قد تُحذف أثناء ذلك؟',
      contextDe: 'Datenrisiko vor Servicebeginn klären',
      contextAr: 'معرفة خطر فقدان البيانات قبل الصيانة',
      keywords: <String>['Daten', 'zurücksetzen', 'entsperren', 'بيانات'],
    ),
    ServiceRepairPhrase(
      id: 'diagnosis-backup',
      topic: ServiceRepairTopic.diagnosis,
      german:
          'Ich habe meine Daten gesichert und persönliche Konten abgemeldet. Gibt es weitere Schritte vor der Abgabe?',
      arabic:
          'أخذت نسخة احتياطية وسجلت الخروج من حساباتي الشخصية. هل توجد خطوات أخرى قبل تسليم الجهاز؟',
      contextDe: 'Datenschutz vor Reparatur vorbereiten',
      contextAr: 'تجهيز الخصوصية قبل الإصلاح',
      keywords: <String>['Backup', 'Datenschutz', 'Konten', 'نسخة احتياطية'],
    ),
    ServiceRepairPhrase(
      id: 'estimate-before-work',
      topic: ServiceRepairTopic.costEstimate,
      german:
          'Bitte erstellen Sie vor der Reparatur einen Kostenvoranschlag und beginnen Sie erst nach meiner Freigabe mit kostenpflichtigen Arbeiten.',
      arabic:
          'يرجى إعداد تقدير للتكلفة قبل الإصلاح وعدم بدء أي عمل مدفوع قبل موافقتي.',
      contextDe: 'Kostenfreigabe eindeutig festlegen',
      contextAr: 'تحديد الموافقة على التكلفة بوضوح',
      keywords: <String>['Kostenvoranschlag', 'Freigabe', 'تكلفة'],
    ),
    ServiceRepairPhrase(
      id: 'estimate-parts',
      topic: ServiceRepairTopic.costEstimate,
      german:
          'Sind Ersatzteil, Arbeitszeit und Diagnose im genannten Preis enthalten, oder kommen weitere Kosten dazu?',
      arabic:
          'هل السعر المذكور يشمل قطعة الغيار والعمل والتشخيص، أم توجد تكاليف إضافية؟',
      contextDe: 'Preisbestandteile einzeln verstehen',
      contextAr: 'فهم عناصر السعر بالتفصيل',
      keywords: <String>['Ersatzteil', 'Arbeitszeit', 'Kosten', 'قطعة غيار'],
    ),
    ServiceRepairPhrase(
      id: 'estimate-limit',
      topic: ServiceRepairTopic.costEstimate,
      german:
          'Wenn die Reparatur teurer als dieser Betrag wird, kontaktieren Sie mich bitte vor weiteren Arbeiten.',
      arabic:
          'إذا أصبحت تكلفة الإصلاح أعلى من هذا المبلغ، يرجى التواصل معي قبل أي عمل إضافي.',
      contextDe: 'Kostenobergrenze vereinbaren',
      contextAr: 'وضع حد للمبلغ قبل الأعمال الإضافية',
      keywords: <String>['Kostenobergrenze', 'Mehrkosten', 'حد'],
    ),
    ServiceRepairPhrase(
      id: 'status-reference',
      topic: ServiceRepairTopic.repairStatus,
      german:
          'Ich möchte den Reparaturstatus prüfen. Die Auftrags- oder Servicenummer steht auf meinem Annahmebeleg.',
      arabic:
          'أريد معرفة حالة الإصلاح. رقم الطلب أو الخدمة موجود على إيصال الاستلام.',
      contextDe: 'Status mit Referenznummer abfragen',
      contextAr: 'متابعة الحالة برقم الطلب',
      keywords: <String>['Reparaturstatus', 'Auftragsnummer', 'حالة'],
    ),
    ServiceRepairPhrase(
      id: 'status-delay',
      topic: ServiceRepairTopic.repairStatus,
      german:
          'Das Ersatzteil verzögert sich. Können Sie mir einen neuen realistischen Fertigstellungstermin nennen?',
      arabic:
          'تأخرت قطعة الغيار. هل يمكنكم إعطائي موعدًا واقعيًا جديدًا لإنهاء الإصلاح؟',
      contextDe: 'Neue Zeitangabe bei Verzögerung erfragen',
      contextAr: 'طلب موعد جديد عند التأخير',
      keywords: <String>['Ersatzteil', 'Verzögerung', 'Termin', 'تأخير'],
    ),
    ServiceRepairPhrase(
      id: 'status-pickup',
      topic: ServiceRepairTopic.repairStatus,
      german:
          'Ist das Gerät abholbereit, welche Arbeiten wurden durchgeführt und bekomme ich dazu einen Servicebericht?',
      arabic:
          'هل الجهاز جاهز للاستلام، وما الأعمال التي تم تنفيذها، وهل أحصل على تقرير صيانة؟',
      contextDe: 'Abholung mit Leistungsnachweis abschließen',
      contextAr: 'استلام الجهاز مع تقرير بالأعمال',
      keywords: <String>['abholbereit', 'Servicebericht', 'استلام'],
    ),
  ];
}
