/// عقد صريح لتفاعل البطاقات ثلاثية الأبعاد بدون فوضى في الواجهات
enum CardFlipSide { front, back }

abstract class CardSurfaceContract {
  String get cardId;
  CardFlipSide get currentSide;
  bool get isInteractable;
  void onCardFlipped(CardFlipSide newSide);
  void onDragThresholdExceeded(double deltaX);
}
