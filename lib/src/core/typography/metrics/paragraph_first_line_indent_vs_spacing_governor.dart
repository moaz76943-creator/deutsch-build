/// Task 1277: Enforces first-line indent OR paragraph spacing, never both
class ParagraphSpacingGovernor {
  double getIndent(bool useSpacing) => useSpacing ? 0.0 : 16.0;
  double getBottomSpacing(bool useSpacing) => useSpacing ? 12.0 : 0.0;
}
