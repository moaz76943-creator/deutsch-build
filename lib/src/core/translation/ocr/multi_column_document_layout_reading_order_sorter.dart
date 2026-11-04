/// Task 1777: Topological reading order sorter for multi-column documents and menus
class DocumentReadingOrderSorter {
  List> sortBoxes(List> boxes) => boxes..sort((a, b) => (a['top'] ?? 0).compareTo(b['top'] ?? 0));
}
