/// Task 1267: Compensates line height inversely proportional to column width
class LineHeightCompensator {
  double calculateLineHeight(double fontSize, double columnWidth) => fontSize * (columnWidth > 600 ? 1.6 : 1.4);
}
