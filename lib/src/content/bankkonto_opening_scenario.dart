import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for opening an ethical checking account (Girokonto).
class BankkontoOpeningScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Guten Tag! Wie kann ich Ihnen heute bei der Bank helfen?',
      utteranceAr: 'نهاركم سعيد! كيف يمكنني مساعدتكم اليوم في المصرف؟',
      linguisticTip: 'صيغة الاستقبال المهذبة والترحيب بالعميل.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich möchte gerne ein Girokonto für mein Gehalt eröffnen.',
      utteranceAr: 'نهاركم سعيد. أود فتح حساب جاري مصرفي لاستلام راتبي.',
      linguisticTip: 'Ich möchte gerne + Infinitiv am Ende (صيغة الطلب اللبقة).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. Haben Sie Ihren Ausweis und die Meldebescheinigung dabei?',
      utteranceAr: 'بكل سرور. هل جواز سفركم وشهادة تسجيل السكن متوفران معكم؟',
      linguisticTip: 'الوثائق الإلزامية في ألمانيا لفتح أي حساب بنكي قانوني.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Ja, hier sind mein Reisepass und die Meldebescheinigung vom Bürgeramt.',
      utteranceAr: 'نعم، تفضل جواز سفري وشهادة تسجيل السكن الصادرة عن البلدية.',
      linguisticTip: 'تقديم الوثائق الأصلية للموظف للتحقق.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Ausgezeichnet. Ihre Debitkarte und die PIN senden wir per Post zu.',
      utteranceAr: 'ممتاز. سنرسل بطاقة الدفع المصرفية والرمز السري إليكم عبر البريد المسجل.',
      linguisticTip: 'في ألمانيا تصل البطاقة والرمز السري في رسالتين منفصلتين لأسباب أمنية.',
    ),
  ];
}
