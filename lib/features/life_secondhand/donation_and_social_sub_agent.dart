import 'secondhand_models.dart';

final class DonationAndSocialSubAgent {
  const DonationAndSocialSubAgent();

  List<SecondhandEntry> get entries => _entries;

  static const List<SecondhandEntry> _entries = <SecondhandEntry>[
    SecondhandEntry(
      id: 'donation-clothing-container',
      domain: SecondhandDomain.donationAndSocialStores,
      titleDe: 'Kleidercontainer richtig nutzen',
      titleAr: 'استخدام حاوية الملابس بشكل صحيح',
      german:
          'Bitte saubere, trockene Kleidung in einen geschlossenen Sack geben und Schuhe paarweise bündeln. Die Hinweise am Container gehen vor.',
      arabic:
          'ضع الملابس النظيفة والجافة في كيس مغلق واربط الأحذية كل زوج معًا. تعليمات الحاوية نفسها هي المرجع أولًا.',
      contextDe:
          'Spenden sauber und geschützt einwerfen; Betreiberhinweise am Standort beachten',
      contextAr:
          'التبرع بملابس نظيفة ومحميّة مع الالتزام بتعليمات الجهة المشغلة',
      keywords: <String>[
        'Kleidercontainer',
        'saubere Kleidung',
        'Sack',
        'Schuhe paarweise',
        'Spende',
      ],
    ),
    SecondhandEntry(
      id: 'social-store-locate',
      domain: SecondhandDomain.donationAndSocialStores,
      titleDe: 'Sozialkaufhaus finden',
      titleAr: 'العثور على متجر اجتماعي للمستعمل',
      german:
          'Gibt es in der Nähe ein Sozialkaufhaus, zum Beispiel vom Roten Kreuz oder von der Diakonie?',
      arabic:
          'هل يوجد متجر اجتماعي للمستعمل قريب، مثل متجر تابع للصليب الأحمر أو الدياكوني؟',
      contextDe:
          'Nach gemeinnützigen Secondhand-Angeboten in der eigenen Stadt fragen',
      contextAr:
          'السؤال عن متاجر مستعمل خيرية أو مجتمعية في المدينة',
      keywords: <String>[
        'Sozialkaufhaus',
        'Rotes Kreuz',
        'DRK',
        'Diakonie',
        'Secondhand',
      ],
    ),
    SecondhandEntry(
      id: 'social-store-visit',
      domain: SecondhandDomain.donationAndSocialStores,
      titleDe: 'Besuch & Annahme klären',
      titleAr: 'الاستفسار عن الزيارة وقبول التبرعات',
      german:
          'Wann ist das Sozialkaufhaus geöffnet, und welche gut erhaltenen Sachen kann ich direkt abgeben?',
      arabic:
          'متى يفتح المتجر الاجتماعي، وما الأشياء بحالة جيدة التي يمكنني تسليمها مباشرة؟',
      contextDe:
          'Öffnungszeiten und konkrete Annahmekriterien vor dem Besuch erfragen',
      contextAr:
          'التحقق من ساعات الدوام وشروط قبول التبرعات قبل الزيارة',
      keywords: <String>[
        'Öffnungszeiten',
        'Annahme',
        'abgeben',
        'Spenden',
        'gut erhalten',
      ],
    ),
    SecondhandEntry(
      id: 'social-store-household-donation',
      domain: SecondhandDomain.donationAndSocialStores,
      titleDe: 'Sachspende vorher abstimmen',
      titleAr: 'تنسيق التبرع بالأغراض مسبقًا',
      german:
          'Nehmen Sie derzeit Kleidung, Haushaltswaren oder kleine Möbel an? Soll ich vorher einen Termin vereinbaren?',
      arabic:
          'هل تستقبلون حاليًا الملابس أو الأدوات المنزلية أو قطع الأثاث الصغيرة؟ وهل أحتاج إلى موعد مسبق؟',
      contextDe:
          'Vor einer größeren Sachspende nach aktueller Annahme und Terminbedarf fragen',
      contextAr:
          'التأكد مسبقًا من قبول الأغراض والحاجة إلى موعد قبل نقلها',
      keywords: <String>[
        'Sachspende',
        'Kleidung',
        'Haushaltswaren',
        'Möbel',
        'Termin',
      ],
    ),
  ];
}
