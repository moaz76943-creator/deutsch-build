import '../language/german/german_word_family_repository.dart';
import '../models/linguistics/german_word_family.dart';
import 'canonical_linguistic_store.dart';
import 'pack_database_security.dart';

final class PackGermanWordFamilyRepository
    implements GermanWordFamilyRepository {
  const PackGermanWordFamilyRepository({
    required this.databasePath,
    required this.databaseOpener,
    required this.databasePassword,
  });

  final String databasePath;
  final PackDatabaseOpener databaseOpener;
  final String databasePassword;

  @override
  Future<List<GermanWordFamily>> listFamilies({int limit = 100}) async {
    final boundedLimit = limit.clamp(1, 200);
    final database = await databaseOpener.openReadOnly(
      databasePath,
      password: databasePassword,
    );
    try {
      final store = CanonicalLinguisticStore(database);
      final ids = await store.listGermanWordFamilyIds(limit: boundedLimit);
      final families = <GermanWordFamily>[];
      for (final id in ids) {
        final family = await store.readGermanWordFamily(id);
        if (family != null) {
          families.add(family);
        }
      }
      return List<GermanWordFamily>.unmodifiable(families);
    } finally {
      await database.close();
    }
  }
}
