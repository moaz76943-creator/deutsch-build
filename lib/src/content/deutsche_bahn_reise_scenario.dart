import 'buergeramt_anmeldung_scenario.dart';

/// Interactive dialogue scenario for booking long-distance ICE train tickets and managing transfers.
class DeutscheBahnReiseScenario {
  static const List<ScenarioDialogueTurn> turns = [
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Reisezentrum der Deutschen Bahn, guten Tag! Welche Zugverbindung suchen Sie?',
      utteranceAr: 'مركز خدمة المسافرين في السكك الحديدية، نهاركم سعيد! ما هي وجهة القطار التي تبحثون عنها؟',
      linguisticTip: 'das Reisezentrum = مكتب حجز واستعلامات السفر الرسمي في المحطات الكبرى.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Guten Tag. Ich möchte morgen früh von Berlin nach Hamburg reisen, am liebsten mit dem schnellen ICE.',
      utteranceAr: 'نهاركم سعيد. أود السفر صباح الغد من برلين إلى هامبورغ، ويفضل أن يكون على متن قطار ICE السريع.',
      linguisticTip: 'der ICE (Intercity-Express) = أسرع قطارات الركاب في ألمانيا.',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Da gibt es eine Direktverbindung um 08:30 Uhr ab Hauptbahnhof. Möchten Sie eine Sitzplatzreservierung im Ruhebereich?',
      utteranceAr: 'تتوفر رحلة مباشرة عند الساعة الثامنة والنصف صباحاً من المحطة المركزية. هل ترغبون بحجز مقعد في مقصورة الهدوء؟',
      linguisticTip: 'der Ruhebereich = منطقة الهدوء في القطار المخصصة للقراءة دون ضوضاء.',
    ),
    ScenarioDialogueTurn(
      speaker: 'learner',
      utteranceDe: 'Ja bitte, ein Fensterplatz im Ruhebereich wäre ideal zum Lesen und Arbeiten.',
      utteranceAr: 'نعم من فضلكم، مقعد بجوار النافذة في مقصورة الهدوء سيكون مثالياً للقراءة وإنجاز العمل.',
      linguisticTip: 'der Fensterplatz = مقعد بجوار النافذة (خلاف Gangplatz = مقعد بجانب الممر).',
    ),
    ScenarioDialogueTurn(
      speaker: 'clerk',
      utteranceDe: 'Sehr gerne. Ihr Ticket und die Reservierung sind gebucht. Abfahrt ist an Gleis 5. Eine angenehme und sichere Fahrt!',
      utteranceAr: 'بكل سرور. تم تأكيد حجز تذكرتكم ومقعدكم بنجاح. الانطلاق من الرصيف رقم 5. نتمنى لكم رحلة ممتعة وآمنة!',
      linguisticTip: 'die Abfahrt an Gleis = الانطلاق من الرصيف المحدد.',
    ),
  ];
}
