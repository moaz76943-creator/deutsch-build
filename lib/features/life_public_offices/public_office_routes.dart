import 'public_office_models.dart';

abstract final class PublicOfficeRoutes {
  static const String anmeldungRouteName =
      '/life-public-offices/anmeldung-appointments';
  static const String documentsRouteName =
      '/life-public-offices/forms-documents';

  static const PublicOfficeRouteDescriptor anmeldung =
      PublicOfficeRouteDescriptor(
    id: PublicOfficeRouteId.anmeldungAppointments,
    routeName: anmeldungRouteName,
    titleDe: 'Anmeldung & Termine',
    titleAr: 'تسجيل السكن والمواعيد',
    descriptionDe:
        'Anmeldung, Ummeldung, Meldebestätigung und Terminvereinbarung am Bürgeramt.',
    descriptionAr:
        'تسجيل أو تغيير السكن، شهادة التسجيل، وحجز أو تعديل مواعيد البلدية.',
    supportedOffices: <PublicOfficeType>[
      PublicOfficeType.buergeramt,
      PublicOfficeType.auslaenderbehoerde,
    ],
    searchTerms: <String>[
      'Anmeldung',
      'Ummeldung',
      'Meldebestätigung',
      'Termin',
      'Bürgeramt',
      'Ausländerbehörde',
      'سكن',
      'موعد',
      'بلدية',
    ],
  );

  static const PublicOfficeRouteDescriptor documents =
      PublicOfficeRouteDescriptor(
    id: PublicOfficeRouteId.formsDocuments,
    routeName: documentsRouteName,
    titleDe: 'Formulare & Dokumente',
    titleAr: 'الاستمارات والوثائق',
    descriptionDe:
        'Anträge, Identitätsnachweise, Beglaubigungen, Vollmachten und Nachreichen von Unterlagen.',
    descriptionAr:
        'الطلبات وإثبات الهوية والتصديق والوكالات واستكمال المستندات الناقصة.',
    supportedOffices: <PublicOfficeType>[
      PublicOfficeType.buergeramt,
      PublicOfficeType.auslaenderbehoerde,
      PublicOfficeType.finanzamt,
    ],
    searchTerms: <String>[
      'Antrag',
      'Formular',
      'Beglaubigung',
      'Vollmacht',
      'Nachreichen',
      'Finanzamt',
      'استمارة',
      'وثائق',
      'تصديق',
      'وكالة',
    ],
  );

  static const List<PublicOfficeRouteDescriptor> all =
      <PublicOfficeRouteDescriptor>[
    anmeldung,
    documents,
  ];
}
