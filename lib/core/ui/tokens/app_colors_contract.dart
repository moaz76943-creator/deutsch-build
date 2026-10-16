/// عقد الألوان المجرد لتسهيل دعم الثيمات والتباين العالي
class SemanticColorTokens {
  final int primaryRgba;
  final int surfaceBackgroundRgba;
  final int textHighEmphasisRgba;
  final int textMediumEmphasisRgba;
  final int successRgba;
  final int failureRgba;

  const SemanticColorTokens({
    required this.primaryRgba,
    required this.surfaceBackgroundRgba,
    required this.textHighEmphasisRgba,
    required this.textMediumEmphasisRgba,
    required this.successRgba,
    required this.failureRgba,
  });
}
