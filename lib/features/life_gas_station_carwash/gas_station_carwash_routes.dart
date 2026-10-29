import 'gas_station_carwash_models.dart';

abstract final class GasStationCarwashRoutes {
  static const GasStationRouteDescriptor fuelPayment =
      GasStationRouteDescriptor(
    id: GasStationRouteId.fuelPayment,
    domain: GasStationDomain.fuelPayment,
    routeName: '/life-gas-station-carwash/fuel-payment',
    titleDe: 'Tanken & Bezahlen',
    titleAr: 'اختيار الوقود والدفع',
    descriptionDe:
        'Kraftstoff richtig auswählen, Zapfsäule bedienen, bezahlen und Belege klären.',
    descriptionAr:
        'اختيار نوع الوقود الصحيح واستخدام المضخة والدفع وطلب الإيصال.',
    searchTerms: <String>[
      'Benzin',
      'Super E5',
      'Super E10',
      'Diesel',
      'Zapfsäule',
      'Kasse',
      'Karte',
      'دفع',
      'وقود',
    ],
  );

  static const GasStationRouteDescriptor automaticWash =
      GasStationRouteDescriptor(
    id: GasStationRouteId.automaticWash,
    domain: GasStationDomain.automaticWash,
    routeName: '/life-gas-station-carwash/automatic-wash',
    titleDe: 'Automatische Autowäsche',
    titleAr: 'غسيل السيارات الآلي',
    descriptionDe:
        'Waschprogramm wählen, Fahrzeug vorbereiten, Einfahrt verstehen und sicher ausfahren.',
    descriptionAr:
        'اختيار برنامج الغسيل وتجهيز السيارة وفهم الدخول والخروج بأمان.',
    searchTerms: <String>[
      'Waschanlage',
      'Waschstraße',
      'Waschcode',
      'Programm',
      'Spiegel',
      'غسيل',
      'برنامج',
    ],
  );

  static const List<GasStationRouteDescriptor> all =
      <GasStationRouteDescriptor>[
    fuelPayment,
    automaticWash,
  ];
}
