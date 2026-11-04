/// Task 1342: Gender agreement detector (der/die/das vs noun gender)
class ArticleGenderConcordDetector {
  bool isArticleMismatch(String article, String nounGender) => (article == 'der' && nounGender == 'Fem');
}
