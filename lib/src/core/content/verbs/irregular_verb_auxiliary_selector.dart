/// Task 2062: Perfect tense auxiliary verb selector (haben vs sein) with movement rules
class IrregularVerbAuxiliarySelector {
  String selectAuxiliary(String verb, bool isMovement) => isMovement ? 'sein' : 'haben';
}
