/// Task 1645: Quick 90-degree snap turn gesture controller
class CardinalDirectionTurnNavigator {
  int snapTurn(int currentAngleDeg, bool turnRight) => (currentAngleDeg + (turnRight ? 90 : -90)) % 360;
}
