/// Task 1262: Snaps line heights to an exact 4pt/8pt baseline grid
class BaselineGridSnapper {
  double snapToGrid(double value, double gridStep) => (value / gridStep).ceil() * gridStep;
}
