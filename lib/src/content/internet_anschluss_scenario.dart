import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for establishing home internet and router activation.
class InternetAnschlussScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Kundenservice Telekommunikation, guten Tag! Wie kann ich Ihren Anschluss einrichten?',
      utteranceAr: 'خدمة عملاء الاتصالات، نهاركم سعيد! كيف يمكنني إعداد خط اتصالكم المنزلي؟',
      linguisticTip: 'der Internetanschluss = خط اشتراك الإنترنت المنزلي.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich bin neu eingezogen und möchte einen stabilen Glasfaser-Internetanschluss bestellen.',
      utteranceAr: 'نهاركم سعيد. انتقلت حديثاً إلى مسكني وأود الاشتراك في خط إنترنت ألياف بصرية فائق السرعة والموثوقية.',
      linguisticTip: 'neu einziehen = ينتقل حديثاً إلى سكن جديد، Glasfaser = ألياف بصرية.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. An Ihrer Adresse ist eine Bandbreite von bis zu 250 Megabit pro Sekunde verfügbar.',
      utteranceAr: 'بكل سرور. في عنوان سكنكم تتوفر سرعة تدفق بيانات تصل حتى 250 ميغابت في الثانية.',
      linguisticTip: 'die Bandbreite = سعة وسرعة تدفق الإنترنت.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Das ist perfekt für meine Arbeit im Homeoffice. Wann wird der WLAN-Router geliefert?',
      utteranceAr: 'هذا ممتاز ومثالي لعملي من المنزل. متى سيتم تسليم جهاز التوجيه اللاسلكي (الراوتر)؟',
      linguisticTip: 'das Homeoffice = العمل عن بعد من المنزل.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Der Router trifft übermorgen per Post ein. Die Freischaltung der Leitung erfolgt automatisch.',
      utteranceAr: 'سيصل جهاز الراوتر بعد غد عبر البريد. وسيتم تفعيل الخط تلقائياً دون الحاجة لزيارة فني.',
      linguisticTip: 'die Freischaltung = التفعيل والتشغيل الرسمي للخدمة.',
    ),
  ];
}
