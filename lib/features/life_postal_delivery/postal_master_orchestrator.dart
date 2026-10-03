import 'package:flutter/foundation.dart';

import 'postal_models.dart';

final class PostalDeliveryMasterOrchestrator extends ChangeNotifier {
  PostalServiceArea _area = PostalServiceArea.shipping;
  String _query = '';

  PostalServiceArea get area => _area;
  String get query => _query;

  List<PostalHubAction> get visibleActions => List<PostalHubAction>.unmodifiable(
        _actions.where(
          (action) =>
              (_query.trim().isNotEmpty || action.area == _area) &&
              action.matches(_query),
        ),
      );

  void setArea(PostalServiceArea value) {
    if (_area == value) return;
    _area = value;
    notifyListeners();
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearSearch() => setQuery('');

  static const List<PostalHubAction> _actions = <PostalHubAction>[
    PostalHubAction(
      id: 'postal-send-receive',
      area: PostalServiceArea.shipping,
      titleDe: 'Briefe und Pakete versenden oder abholen',
      titleAr: 'إرسال أو استلام الرسائل والطرود',
      descriptionDe:
          'Briefmarke, Versandlabel, Einschreiben, Paketmaße, Versicherung und Abholung in Filiale oder Paketshop.',
      descriptionAr:
          'الطوابع وملصقات الشحن والبريد المسجل وأبعاد الطرد والتأمين والاستلام من الفرع أو متجر الطرود.',
      keywords: <String>[
        'DHL',
        'Hermes',
        'Deutsche Post',
        'Sendungsnummer',
        'Paketmaße',
        'Einschreiben',
      ],
    ),
    PostalHubAction(
      id: 'postal-packstation',
      area: PostalServiceArea.packstationIssues,
      titleDe: 'Packstation bedienen',
      titleAr: 'استخدام ماكينة Packstation',
      descriptionDe:
          'Barcode scannen, Abholcode eingeben und das richtige Fach sicher öffnen.',
      descriptionAr:
          'مسح الباركود وإدخال رمز الاستلام وفتح الخزانة الصحيحة بأمان.',
      keywords: <String>['Packstation', 'Barcode', 'Abholcode', 'Fach'],
    ),
    PostalHubAction(
      id: 'postal-notification-card',
      area: PostalServiceArea.packstationIssues,
      titleDe: 'Benachrichtigungskarte verstehen',
      titleAr: 'فهم بطاقة إشعار التسليم',
      descriptionDe:
          'Abholort, Frist und Referenz auf der Benachrichtigungskarte prüfen.',
      descriptionAr:
          'التحقق من مكان الاستلام والموعد النهائي والرقم المرجعي على بطاقة الإشعار.',
      keywords: <String>[
        'Benachrichtigungskarte',
        'Abholschein',
        'Filiale',
        'Paketshop',
      ],
    ),
    PostalHubAction(
      id: 'postal-delivery-problem',
      area: PostalServiceArea.packstationIssues,
      titleDe: 'Zustellproblem oder Sendungsverlust',
      titleAr: 'مشكلة تسليم أو فقدان شحنة',
      descriptionDe:
          'Nachbarn, Ablageort, Sendungsverfolgung und nächste Schritte systematisch prüfen.',
      descriptionAr:
          'التحقق من الجيران ومكان الإيداع والتتبع والخطوات التالية بصورة منظمة.',
      keywords: <String>[
        'Beim Nachbarn abgegeben',
        'Sendungsverlust',
        'Sendungsverfolgung',
      ],
    ),
  ];
}

final class PostalDeliveryModule {
  const PostalDeliveryModule();

  static const String routeName = '/life/postal-delivery';

  PostalDeliveryMasterOrchestrator createOrchestrator() =>
      PostalDeliveryMasterOrchestrator();
}
