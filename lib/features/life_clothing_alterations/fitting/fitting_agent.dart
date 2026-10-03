import 'fitting_catalog.dart';
import 'fitting_models.dart';

final class ClothingFittingAgent {
  const ClothingFittingAgent();

  List<FittingDialogue> findDialogues({
    FittingGarmentType? garment,
    String query = '',
  }) {
    final needle = _normalize(query);
    return List<FittingDialogue>.unmodifiable(
      FittingCatalog.dialogues.where((dialogue) {
        if (garment != null && dialogue.garment != garment) return false;
        if (needle.isEmpty) return true;
        final haystack = _normalize(
          <String>[
            dialogue.german,
            dialogue.arabic,
            ...dialogue.keywords,
          ].join(' '),
        );
        return haystack.contains(needle);
      }),
    );
  }

  FabricCareNote? careFor(NaturalFabric fabric) {
    for (final note in FittingCatalog.fabrics) {
      if (note.fabric == fabric) return note;
    }
    return null;
  }

  String comfortRequest({
    required FittingGarmentType garment,
    required FitDimension dimension,
  }) {
    return switch (dimension) {
      FitDimension.length =>
        'Könnten Sie mir die ' + garment.german + ' in einer passenderen Länge zeigen?',
      FitDimension.width =>
        'Haben Sie die ' + garment.german + ' mit etwas mehr Weite?',
      FitDimension.comfort =>
        'Haben Sie die ' + garment.german + ' in einer etwas bequemeren Passform?',
    };
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');
}
