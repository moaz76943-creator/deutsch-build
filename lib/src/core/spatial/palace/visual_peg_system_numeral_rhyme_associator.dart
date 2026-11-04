/// Task 1611: Peg System generator mapping numbers to concrete 3D objects
class VisualPegSystem {
  String getPegObject(int number) => number == 1 ? 'CANDLE' : (number == 2 ? 'SWAN' : 'FORK');
}
