/// Task 1523: Last-Write-Wins (LWW-Element-Set) timestamped register
class LwwRegister<T> {
  T? value;
  int timestamp = 0;
  void update(T newValue, int newTs) {
    if (newTs >= timestamp) {
      value = newValue;
      timestamp = newTs;
    }
  }
}
