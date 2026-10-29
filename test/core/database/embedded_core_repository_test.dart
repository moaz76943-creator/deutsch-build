import 'package:deutsch_build/core/database/embedded_core_repository.dart';

void main() {
  const repo = EmbeddedCoreRepository();

  // التحقق من صحة استعلام البحث الداخلي
  final query = repo.buildSearchQuery('lernen');
  assert(query.contains("lemma LIKE 'lernen%'"));
  assert(query.contains("FROM core_lexicon"));

  print('Embedded core repository unit assertions passed.');
}
