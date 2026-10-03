import 'bewerbung_models.dart';

abstract class BewerbungRepository {
  Future<List<BewerbungTemplate>> getTemplates({
    BewerbungDocumentType? documentType,
    CareerTrack? careerTrack,
  });

  Future<List<String>> validateProfile(
    BewerbungProfile profile,
  );

  Future<BewerbungPreview> buildPreview(
    String templateId,
    BewerbungProfile profile,
  );
}
