import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for obtaining tax identification number and tax office communication.
class FinanzamtSteuerIdScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Finanzamt Servicestelle, guten Tag! Wie kann ich Ihr steuerliches Anliegen bearbeiten?',
      utteranceAr: 'مركز خدمة مصلحة الضرائب، نهاركم سعيد! كيف يمكنني متابعة معاملتكم الضريبية؟',
      linguisticTip: 'das Finanzamt = مكتب / مصلحة الضرائب والمالية الرسمية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Mein Arbeitgeber benötigt meine elfstellige Steuer-Identifikationsnummer für die Lohnabrechnung.',
      utteranceAr: 'نهاركم سعيد. يحتاج صاحب العمل إلى رقمي الضريبي المكون من 11 رقماً لإعداد كشف الراتب الشهري.',
      linguisticTip: 'die Steuer-Identifikationsnummer (Steuer-ID) = الرقم الضريبي الفردي الدائم في ألمانيا.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Die Steuer-ID wird nach der Erstanmeldung beim Bürgeramt automatisch per Post vom Bundeszentralamt versandt.',
      utteranceAr: 'يتم إرسال الرقم الضريبي تلقائياً بالبريد من المكتب الاتحادي بعد تسجيل السكن الأول في البلدية.',
      linguisticTip: 'automatisch per Post versandt = يُرسل تلقائياً عبر البريد المعتمد.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Verstehe. Kann ich eine vorläufige Bescheinigung für meine Personalabteilung erhalten?',
      utteranceAr: 'فهمت ذلك. هل يمكنني الحصول على إفادة مؤقتة لتقديمها لقسم شؤون الموظفين في شركتي؟',
      linguisticTip: 'die vorläufige Bescheinigung = الإفادة / الشهادة المؤقتة.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Selbstverständlich. Nach Prüfung Ihres Passes drucke ich Ihnen den Bestätigungsbeleg sofort aus.',
      utteranceAr: 'بكل تأكيد. بعد التحقق من جواز سفركم سأطبع لكم إفادة التأكيد الرسمية في الحال.',
      linguisticTip: 'ausdrucken = يطبع ورقياً، der Bestätigungsbeleg = إيصال أو مستند الإثبات.',
    ),
  ];
}
