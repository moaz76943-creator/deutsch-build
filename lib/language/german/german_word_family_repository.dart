import '../../models/linguistics/german_word_family.dart';

abstract interface class GermanWordFamilyRepository {
  Future<List<GermanWordFamily>> listFamilies({int limit = 100});
}

final class EmptyGermanWordFamilyRepository
    implements GermanWordFamilyRepository {
  const EmptyGermanWordFamilyRepository();

  @override
  Future<List<GermanWordFamily>> listFamilies({int limit = 100}) async =>
      const <GermanWordFamily>[];
}
