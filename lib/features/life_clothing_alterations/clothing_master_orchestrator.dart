import 'clothing_dependencies.dart';
import 'clothing_models.dart';
import 'fitting/fitting_models.dart';
import 'tailoring/tailoring_models.dart';

enum ClothingHubSource { fitting, tailoring }

final class ClothingHubPhrase {
  final ClothingHubSource source;
  final String german;
  final String arabic;

  const ClothingHubPhrase({
    required this.source,
    required this.german,
    required this.arabic,
  });
}

final class ClothingMasterOrchestrator {
  final ClothingAlterationsDependencies dependencies;

  const ClothingMasterOrchestrator({
    this.dependencies = const ClothingAlterationsDependencies(),
  });

  static const List<ClothingFabricInfo> fabricGuide = <ClothingFabricInfo>[
    ClothingFabricInfo(
      fabric: ClothingFabric.cotton,
      descriptionDe: 'Baumwolle ist ein natürlicher Stoff für viele Alltagshemden.',
      descriptionAr: 'القطن خامة طبيعية شائعة في القمصان اليومية.',
      carePromptDe: 'Welche Waschanleitung gilt für dieses Baumwollstück?',
      carePromptAr: 'ما تعليمات غسل هذه القطعة القطنية؟',
    ),
    ClothingFabricInfo(
      fabric: ClothingFabric.wool,
      descriptionDe: 'Wolle wird häufig für klassische Jacken und Wintermäntel verwendet.',
      descriptionAr: 'يستخدم الصوف كثيراً في السترات الكلاسيكية والمعاطف الشتوية.',
      carePromptDe: 'Wie soll ich dieses Wollstück waschen und bügeln?',
      carePromptAr: 'كيف ينبغي غسل هذه القطعة الصوفية وكيها؟',
    ),
  ];

  static const List<StandardClothingSize> sizeGuide = <StandardClothingSize>[
    StandardClothingSize(
      garment: ClothingGarment.shirt,
      label: 'M',
      euReference: '39/40',
      noteDe: 'Referenzgröße; Herstellerangaben und Anprobe prüfen.',
      noteAr: 'مقاس مرجعي؛ يُراجع دليل الشركة وتجربة القطعة.',
    ),
    StandardClothingSize(
      garment: ClothingGarment.trousers,
      label: 'M',
      euReference: '48/50',
      noteDe: 'Bundweite und Beinlänge zusätzlich prüfen.',
      noteAr: 'يُفحص أيضاً عرض الخصر وطول الساق.',
    ),
    StandardClothingSize(
      garment: ClothingGarment.jacket,
      label: 'M',
      euReference: '48/50',
      noteDe: 'Schulterweite und Ärmellänge bei der Anprobe prüfen.',
      noteAr: 'يُفحص عرض الكتفين وطول الأكمام أثناء التجربة.',
    ),
    StandardClothingSize(
      garment: ClothingGarment.winterCoat,
      label: 'M',
      euReference: '48/50',
      noteDe: 'Genügend Platz für Kleidung darunter einplanen.',
      noteAr: 'يُراعى وجود مساحة كافية للملابس أسفل المعطف.',
    ),
  ];

  List<ClothingHubPhrase> search(String query) {
    final fitting = dependencies.fittingAgent.findDialogues(query: query);
    final tailoring = dependencies.tailoringAgent.findDialogues(query: query);
    return List<ClothingHubPhrase>.unmodifiable(<ClothingHubPhrase>[
      for (final item in fitting)
        ClothingHubPhrase(
          source: ClothingHubSource.fitting,
          german: item.german,
          arabic: item.arabic,
        ),
      for (final item in tailoring)
        ClothingHubPhrase(
          source: ClothingHubSource.tailoring,
          german: item.german,
          arabic: item.arabic,
        ),
    ]);
  }

  List<FittingDialogue> fittingFor(FittingGarmentType garment) =>
      dependencies.fittingAgent.findDialogues(garment: garment);

  List<TailoringDialogue> tailoringFor(TailoringService service) =>
      dependencies.tailoringAgent.findDialogues(service: service);

  AlterationReceipt createReceipt({
    required String receiptId,
    required ClothingGarment garment,
    required String serviceDe,
    required String serviceAr,
    required DateTime receivedAt,
    required DateTime readyAt,
    double? agreedPriceEuro,
  }) {
    final id = receiptId.trim();
    if (id.isEmpty || id.length > 80) {
      throw ArgumentError.value(receiptId, 'receiptId', 'invalid receipt id');
    }
    if (readyAt.isBefore(receivedAt)) {
      throw ArgumentError('readyAt must not be before receivedAt');
    }
    if (agreedPriceEuro != null &&
        (!agreedPriceEuro.isFinite || agreedPriceEuro < 0)) {
      throw ArgumentError.value(
        agreedPriceEuro,
        'agreedPriceEuro',
        'must be a finite non-negative value',
      );
    }
    return AlterationReceipt(
      receiptId: id,
      garment: garment,
      serviceDe: serviceDe.trim(),
      serviceAr: serviceAr.trim(),
      receivedAt: receivedAt,
      readyAt: readyAt,
      agreedPriceEuro: agreedPriceEuro,
    );
  }
}
