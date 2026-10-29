import 'tailoring_catalog.dart';
import 'tailoring_models.dart';

final class ClothingTailoringAgent {
  const ClothingTailoringAgent();

  List<TailoringDialogue> findDialogues({
    TailoringService? service,
    String query = '',
  }) {
    final needle = _normalize(query);
    return List<TailoringDialogue>.unmodifiable(
      TailoringCatalog.dialogues.where((dialogue) {
        if (service != null && dialogue.service != service) return false;
        if (needle.isEmpty) return true;
        final text = <String>[
          dialogue.german,
          dialogue.arabic,
          dialogue.service.german,
          dialogue.service.arabic,
          ...dialogue.keywords,
        ].join(' ');
        return _normalize(text).contains(needle);
      }),
    );
  }

  TailoringAgreement? agreementFor(TailoringService service) {
    for (final agreement in TailoringCatalog.agreements) {
      if (agreement.service == service) return agreement;
    }
    return null;
  }

  static String _normalize(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), ' ');
}
