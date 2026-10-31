import '../../../core/localization/german_article_style.dart';
import 'komposita_models.dart';

abstract class KompositaRepository {
  Future<List<KompositaChallengeItem>> getChallenges({
    String? level,
    LinkingElement? linkingElement,
  });

  Future<bool> validateComposition(
    String challengeId, {
    required List<String> orderedParts,
    required LinkingElement linkingElement,
    required GermanArticle finalArticle,
  });
}
