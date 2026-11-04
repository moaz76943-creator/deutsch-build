/// Task 1736: Zero-allocation activation reuse buffer
class ActivationMemoryGuard {
  final List<double> _buffer = List.filled(512, 0.0);
  List<double> get scratchpad => _buffer;
}
