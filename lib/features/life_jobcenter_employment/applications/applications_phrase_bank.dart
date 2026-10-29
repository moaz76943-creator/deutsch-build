import 'applications_models.dart';

final class ApplicationsPhraseBank {
  const ApplicationsPhraseBank();

  List<ApplicationsPhrase> get phrases => _phrases;

  static const List<ApplicationsPhrase> _phrases =
      <ApplicationsPhrase>[
    ApplicationsPhrase(
      id: 'hauptantrag-help',
      topic: ApplicationsTopic.hauptantrag,
      german:
          'Ich fülle gerade den Hauptantrag aus. Können Sie mir bitte erklären, welche Angaben in diesem Abschnitt gemeint sind?',
      arabic:
          'أنا أملأ الطلب الرئيسي الآن. هل يمكن أن تشرح لي ما المقصود بالبيانات المطلوبة في هذا القسم؟',
      contextDe: 'Unklare Felder im Hauptantrag erklären lassen',
      contextAr: 'طلب شرح الحقول غير الواضحة في الطلب الرئيسي',
      keywords: <String>['Hauptantrag', 'Formular', 'Angaben', 'طلب'],
    ),
    ApplicationsPhrase(
      id: 'hauptantrag-documents',
      topic: ApplicationsTopic.hauptantrag,
      german:
          'Welche Unterlagen fehlen noch zu meinem Hauptantrag, und wie kann ich sie nachreichen?',
      arabic:
          'ما المستندات التي ما زالت ناقصة في طلبي الرئيسي وكيف يمكنني تقديمها لاحقاً؟',
      contextDe: 'Fehlende Unterlagen gezielt erfragen',
      contextAr: 'السؤال بشكل محدد عن المستندات الناقصة',
      keywords: <String>['Unterlagen', 'nachreichen', 'Hauptantrag', 'مستندات'],
    ),
    ApplicationsPhrase(
      id: 'housing-costs-fields',
      topic: ApplicationsTopic.housingCosts,
      german:
          'Wo trage ich im Antrag die Kosten der Unterkunft, also Miete, Nebenkosten und Heizkosten, ein?',
      arabic:
          'أين أسجل في الطلب تكاليف السكن، أي الإيجار والتكاليف الجانبية وتكاليف التدفئة؟',
      contextDe: 'Kosten der Unterkunft im Antrag zuordnen',
      contextAr: 'تحديد مكان بيانات تكاليف السكن في الطلب',
      keywords: <String>['Kosten der Unterkunft', 'Miete', 'Nebenkosten', 'Heizkosten', 'السكن'],
    ),
    ApplicationsPhrase(
      id: 'housing-costs-proof',
      topic: ApplicationsTopic.housingCosts,
      german:
          'Welche Nachweise brauchen Sie für meine Kosten der Unterkunft?',
      arabic:
          'ما الإثباتات التي تحتاجونها بخصوص تكاليف السكن الخاصة بي؟',
      contextDe: 'Nachweise zur Unterkunft erfragen',
      contextAr: 'السؤال عن إثباتات تكاليف السكن',
      keywords: <String>['Nachweise', 'Unterkunft', 'Mietvertrag', 'إثبات'],
    ),
    ApplicationsPhrase(
      id: 'notice-monthly-amounts',
      topic: ApplicationsTopic.approvalNotice,
      german:
          'Ich habe meinen Bewilligungsbescheid erhalten. Können Sie mir bitte erklären, wie sich die monatliche Leistung zusammensetzt?',
      arabic:
          'استلمت إشعار الموافقة. هل يمكن أن تشرح لي كيف تم احتساب الاستحقاق الشهري؟',
      contextDe: 'Monatliche Beträge im Bescheid verstehen',
      contextAr: 'فهم بنود المبلغ الشهري في الإشعار',
      keywords: <String>['Bewilligungsbescheid', 'monatliche Leistung', 'Betrag', 'شهري'],
    ),
    ApplicationsPhrase(
      id: 'notice-period',
      topic: ApplicationsTopic.approvalNotice,
      german:
          'Für welchen Bewilligungszeitraum gilt dieser Bescheid, und wo finde ich die einzelnen Beträge?',
      arabic:
          'لأي مدة استحقاق ينطبق هذا الإشعار، وأين أجد المبالغ المفصلة؟',
      contextDe: 'Bewilligungszeitraum und Positionen finden',
      contextAr: 'تحديد مدة الاستحقاق والمبالغ المفصلة',
      keywords: <String>['Bewilligungszeitraum', 'Bescheid', 'Beträge', 'استحقاق'],
    ),
    ApplicationsPhrase(
      id: 'objection-basic',
      topic: ApplicationsTopic.objection,
      german:
          'Hiermit lege ich gegen den Bescheid vom [Datum] Widerspruch ein. Bitte bestätigen Sie mir den Eingang.',
      arabic:
          'أتقدم بهذا باعتراض على الإشعار المؤرخ في [التاريخ]. يرجى تأكيد استلام الاعتراض.',
      contextDe: 'Kurze, sachliche Widerspruchsformulierung',
      contextAr: 'صياغة اعتراض قصيرة ومحايدة',
      keywords: <String>['Widerspruch', 'Bescheid', 'Eingang', 'اعتراض'],
    ),
    ApplicationsPhrase(
      id: 'objection-deadline',
      topic: ApplicationsTopic.objection,
      german:
          'Welche Frist steht in meinem Bescheid für einen Widerspruch, und welche Einreichungswege sind dort angegeben?',
      arabic:
          'ما المهلة المذكورة في إشعاري للاعتراض، وما طرق التقديم المذكورة فيه؟',
      contextDe: 'Frist im eigenen Bescheid prüfen',
      contextAr: 'فحص مهلة الاعتراض المكتوبة في الإشعار نفسه',
      keywords: <String>['Frist', 'Bescheid', 'Widerspruch', 'مهلة'],
    ),
    ApplicationsPhrase(
      id: 'payment-delay-status',
      topic: ApplicationsTopic.delayedPayment,
      german:
          'Die angekündigte Zahlung ist noch nicht auf meinem Konto eingegangen. Können Sie bitte den Bearbeitungs- und Zahlungsstatus prüfen?',
      arabic:
          'الدفعة المعلنة لم تصل بعد إلى حسابي. هل يمكن التحقق من حالة المعالجة والدفع؟',
      contextDe: 'Verspätete Zahlung sachlich nachverfolgen',
      contextAr: 'متابعة تأخر الدفعة بشكل واضح ومحايد',
      keywords: <String>['Zahlung', 'Bearbeitungsstatus', 'Konto', 'دفعة'],
    ),
    ApplicationsPhrase(
      id: 'payment-delay-missing-info',
      topic: ApplicationsTopic.delayedPayment,
      german:
          'Fehlen noch Unterlagen oder Angaben, die die Zahlung verzögern könnten?',
      arabic:
          'هل توجد مستندات أو بيانات ناقصة قد تكون سبباً في تأخر الدفعة؟',
      contextDe: 'Mögliche fehlende Angaben klären',
      contextAr: 'التحقق من وجود بيانات أو مستندات ناقصة',
      keywords: <String>['Unterlagen', 'verzögern', 'Zahlung', 'تأخير'],
    ),
  ];
}
