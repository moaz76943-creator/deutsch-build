/// Task 1653: 3D drag-and-drop controller for custom loci rearrangement
class LociDragDropHandler {
  List<double> updatePosition(double origX, double origY, double deltaX, double deltaY) => [origX + deltaX, origY + deltaY];
}
