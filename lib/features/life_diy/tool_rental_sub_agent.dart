import 'diy_models.dart';

final class ToolRentalSubAgent {
  const ToolRentalSubAgent();

  List<DiyPhrase> get phrases => _phrases;

  static const List<DiyPhrase> _phrases = <DiyPhrase>[
    DiyPhrase(
      id: 'rental-drill-hammer',
      domain: DiyDomain.servicesRental,
      german:
          'Ich möchte einen Bohrhammer für einen Tag mieten. Welche Modelle haben Sie verfügbar?',
      arabic:
          'أريد استئجار مطرقة حفر ليوم واحد. ما الأجهزة المتوفرة لديكم؟',
      contextDe: 'Einen Bohrhammer im Geräteverleih mieten',
      contextAr: 'طلب استئجار مطرقة حفر من قسم التأجير',
      keywords: <String>[
        'Geräteverleih',
        'Bohrhammer',
        'mieten',
        'ausleihen',
      ],
    ),
    DiyPhrase(
      id: 'rental-carpet-cleaner',
      domain: DiyDomain.servicesRental,
      german:
          'Kann ich einen Teppichreiniger für das Wochenende ausleihen?',
      arabic: 'هل يمكنني استئجار جهاز تنظيف السجاد لعطلة نهاية الأسبوع؟',
      contextDe: 'Einen Teppichreiniger reservieren',
      contextAr: 'السؤال عن استئجار جهاز تنظيف السجاد',
      keywords: <String>[
        'Teppichreiniger',
        'Wochenende',
        'reservieren',
        'ausleihen',
      ],
    ),
    DiyPhrase(
      id: 'rental-deposit',
      domain: DiyDomain.servicesRental,
      german:
          'Wie hoch ist die Kaution, und wann bekomme ich sie nach der Rückgabe zurück?',
      arabic: 'كم قيمة التأمين، ومتى أسترده بعد إعادة الجهاز؟',
      contextDe: 'Kaution und Erstattung klären',
      contextAr: 'السؤال عن مبلغ التأمين وموعد استرداده',
      keywords: <String>['Kaution', 'Pfand', 'Erstattung', 'Rückgabe'],
    ),
    DiyPhrase(
      id: 'rental-return-conditions',
      domain: DiyDomain.servicesRental,
      german:
          'Bis wann muss ich das Gerät zurückgeben, und muss es gereinigt zurückgegeben werden?',
      arabic: 'حتى أي وقت يجب أن أعيد الجهاز، وهل يجب إعادته بعد تنظيفه؟',
      contextDe: 'Rückgabezeit und Rückgabebedingungen prüfen',
      contextAr: 'التأكد من وقت وشروط إعادة الجهاز',
      keywords: <String>[
        'Rückgabebedingungen',
        'Rückgabe',
        'gereinigt',
        'Frist',
      ],
    ),
  ];
}
